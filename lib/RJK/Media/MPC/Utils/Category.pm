package RJK::Media::MPC::Utils::Category;
use parent 'RJK::Media::MPC::Util';

use File::Copy ();

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

    #~ $self->console->confirm("Delete?") || return;

    while (my ($file, $settings) = each %{$self->settings->{settings}}) {
        next if $settings->{category} ne "delete";

        #~ if (unlink $file) {
            print "Deleted $file\n";
        #~ } else {
        #~     print "$!: $file";
        #~ }
    }
}

sub move {
    my $self = shift;

    #~ $self->console->confirm("Move?") || return;

    while (my ($file, $settings) = each %{$self->settings->{settings}}) {
        next if ! $settings->{category};
        next if $settings->{category} eq "delete";

        my $dir = $file =~ s/[\\\/]+[^\\\/]+$//r;
        $dir .= "\\$settings->{category}\\";
        mkdir $dir;

        #~ if (File::Copy::move $file, $dir) {
            print "Moved $file -> $dir\n";
        #~ } else {
        #~     print "$!: $file";
        #~ }
    }
}

1;
