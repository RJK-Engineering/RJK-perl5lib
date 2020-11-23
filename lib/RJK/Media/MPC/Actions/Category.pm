package RJK::Media::MPC::Actions::Category;
use parent 'RJK::Media::MPC::Util';

use File::Copy ();
use RJK::File::Path::Util;
use RJK::Files;
use Try::Tiny;

sub switch {
    my ($self, $file) = @_;

    my $categories = $self->opts->{categories};
    my $currCat = $self->settings->get($file->{path}, "category");

    if (defined $currCat) {
        my $newCat;
        for (my $i=0; $i<@$categories; $i++) {
            if ($categories->[$i] eq $currCat) {
                $newCat = $categories->[$i+1];
                last;
            }
        }
        if (defined $newCat) {
            $currCat = $newCat;
        } elsif ($currCat =~ /^\d+$/) {
            $currCat++;
        } else {
            $currCat = @$categories;
        }
    } else {
        $currCat = $categories->[0];
    }

    $self->settings->set($file->{path}, "category", $currCat);
    print "$file->{path}\n";
    print "Category: $currCat\n";
}

sub delete {
    my $self = shift;

    $self->console->confirm("Delete?") || return;

    while (my ($file, $settings) = each %{$self->settings->files}) {
        next if $settings->{category} ne "delete";

        try {
            my ($sidecars, $dir) = $self->getSidecarFiles($file);
            $self->moveSidecarFiles($sidecars, $dir, "$dir\\.removed");

            if (unlink $file) {
                $self->settings->delete($file, "category");
                print "Deleted $file\n";
            } else {
                print "$!: $file\n" if $self->opts->{verbose};
            }
        } catch {
        };
    }
    print "Done.\n";
}

sub moveSidecarFiles {
    my ($self, $sidecars, $dir, $target) = @_;
    RJK::File::Path::Util::checkdir($target);
    foreach (@$sidecars) {
        $self->moveFile("$dir\\$_", $target);
    }
}

sub getSidecarFiles {
    my ($self, $file) = @_;
    my @sidecar;
    my ($dir, $name, $nameStart) = $file =~ /(.+)\\((.+)\.\w+)$/;
    my $nameStartRe = qr/^$nameStart/;

    my $names = RJK::Files->getEntries($dir) // [];
    foreach (@$names) {
        next if $_ eq $name;
        if (/$nameStartRe/) {
            push @sidecar, $_;
        }
    }
    return \@sidecar, $dir, $name, $nameStart;
}

sub move {
    my $self = shift;

    $self->console->confirm("Move?") || return;

    while (my ($file, $settings) = each %{$self->settings->files}) {
        next if ! $settings->{category};
        next if $settings->{category} eq "delete";

        try {
            my ($sidecars, $dir) = $self->getSidecarFiles($file);
            my $target = "$dir\\$settings->{category}";
            $self->moveSidecarFiles($sidecars, $dir, $target);

            if ($self->moveFile($file, $target)) {
                $self->settings->delete($file, "category");
            }
        } catch {
        };
    }
    print "Done.\n";
}

sub moveFile {
    my ($self, $file, $target) = @_;

    if (File::Copy::move $file, $target) {
        print "Moved $file -> $target\n";
        return 1;
    }
    print "$!: $file\n";
    return 0;
}

1;
