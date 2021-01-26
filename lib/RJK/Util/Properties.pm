package RJK::Util::Properties;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{props} = {};
    $self->{keys} = [];
    return $self;
}

sub get {
    my ($self, $key) = @_;
    return $self->{props}{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    push @{$self->{keys}}, $key if not defined $self->{props}{$key};
    $self->{props}{$key} = $val;
}

sub has {
    my ($self, $key) = @_;
    return exists $self->{props}{$key};
}

sub hash {
    my $self = shift;
    return wantarray ? %{$self->{props}} : $self->{props};
}

sub load {
    my ($self, $path) = @_;
    my ($eat, @prop, $comment);

    open my $fh, '<', $path or die "$!: $path";
    while (<$fh>) {
        s/^\s+(\S)/$1/;         # trim leading space
        if (/^$/ || /^[!#]/) {
            $comment .= $_;
            next;
        }
        chomp;

        if ($eat) {
            $prop[1] .= $_;
        } else {
            @prop = split /\s*=\s*/, $_, 2;
        }
        next if $eat =
            s/(\\\\)+$//r =~ /\\$/                  # check if trailing backslash isn't escaped
            && $prop[1] =~ s/\\$//;                 # remove newline escaping backslash

        $prop[1] =~ s/\\([nrt'"\\])/"qq|\\$1|"/gee; # escaped characters
        $self->{props}{$prop[0]} = $prop[1];
        push @{$self->{keys}}, $prop[0];
        if ($comment) {
            $self->{comments}{$prop[0]} = $comment;
            $comment = undef;
        }
    }
    close $fh;
    $self->{trailingComment} = $comment if $comment;
}

sub save {
    my ($self, $path) = @_;

    open my $fh, '>', $path or die "$!: $path";
    foreach (@{$self->{keys}}) {
        next if not defined $self->{props}{$_};
        my $val = $self->{props}{$_}
            =~ s/\n/\\n/gr
            =~ s/\r/\\r/gr
            =~ s/\t/\\t/gr
            =~ s/\\/\\\\/gr;
        print $fh $self->{comments}{$_} if $self->{comments}{$_};
        print $fh "$_=$val\n";
    }
    print $fh $self->{trailingComment} if $self->{trailingComment};
    close $fh;
}

1;
