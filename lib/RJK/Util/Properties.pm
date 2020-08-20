package RJK::Util::Properties;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{props} = {};
    return $self;
}

sub get {
    my ($self, $prop) = @_;
    return $self->{props}{$prop};
}

sub has {
    my ($self, $prop) = @_;
    return exists $self->{props}{$prop};
}

sub hash {
    my $self = shift;
    return wantarray ? %{$self->{props}} : $self->{props};
}

sub load {
    my ($self, $path) = @_;
    my ($eat, @prop);

    open my $fh, '<', $path or die "$!: $path";
    while (<$fh>) {
        s/^\s+//;                                   # trim leading space
        next unless /./;                            # skip empty line
        next if /^[!#]/;                            # skip comments
        chomp;

        if ($eat) {
            $prop[1] .= $_;
        } else {
            @prop = split /\s*=\s*/, $_, 2;
        }
        next if $eat =
            s/(\\\\)+$//r =~ /\\$/                  # check if trailing backslash isn't escaped
            && $prop[1] =~ s/\\$//;                 # remove newline escaping backslash

        $prop[1] =~ s/\\([rnt'"\\])/"qq|\\$1|"/gee; # escaped characters
        $self->{props}{$prop[0]} = $prop[1];
    }
    close $fh;
}

1;
