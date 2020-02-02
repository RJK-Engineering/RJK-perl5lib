package RJK::File::Search;

use strict;
use warnings;

use Exporter ();
use File::Spec::Functions qw(splitpath catpath canonpath);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    Files
);

# Options:
#   in => path to directory,
#   filter => sub, $_ = filename
#   pathFilter => sub, $_ = file path
#   orderBy => name|path|size|mdate|date|adate|cdate name=path, mdate=date
#   orderReversed => 1|0,
#   visit => sub, $_ = filename
#   visitPath => sub, $_ = file path
#
# Returned array is sorted if "orderBy" option is set, the "visit" and
# "visitPath" subs are not guaranteed to be called in any order.
sub Files {
    my %opts = @_;
    my @paths;

    my @in = ref $opts{in} ? @{$opts{in}} : $opts{in};

    foreach my $in (@in) {
        opendir my $dh, $in or die "$!";
        while (readdir $dh) {
            my $path = canonpath "$in/$_";
            my ($volume, $dirs, $name) = splitpath $path;
            my $dir = catpath $volume, $dirs, "";

            next if ! -f $path;
            next if $opts{filter} && ! $opts{filter}($_);
            next if $opts{pathFilter} && ! $opts{pathFilter}($_ = $path);

            $opts{visit}($_) if $opts{visit};
            $opts{visitPath}($_ = $path) if $opts{visitPath};

            push @paths, $path;
        }
        closedir $dh;
    }

    if ($opts{orderBy}) {
        if ($opts{orderBy} eq 'name' || $opts{orderBy} eq 'path') {
            @paths = $opts{orderReversed} ? reverse sort @paths
                                          : sort @paths;
        } elsif ($opts{orderBy} eq 'mdate' || $opts{orderBy} eq 'date') {
            @paths = $opts{orderReversed} ? sort { -M $b <=> -M $a } @paths
                                          : sort { -M $a <=> -M $b } @paths;
        } elsif ($opts{orderBy} eq 'size') {
            @paths = $opts{orderReversed} ? sort { -s $b <=> -s $a } @paths
                                          : sort { -s $a <=> -s $b } @paths;
        } elsif ($opts{orderBy} eq 'adate') {
            @paths = $opts{orderReversed} ? sort { -A $b <=> -A $a } @paths
                                          : sort { -A $a <=> -A $b } @paths;
        } elsif ($opts{orderBy} eq 'cdate') {
            @paths = $opts{orderReversed} ? sort { -C $b <=> -C $a } @paths
                                          : sort { -C $a <=> -C $b } @paths;
        }
    }

    return wantarray ? @paths : \@paths;
}

1;
