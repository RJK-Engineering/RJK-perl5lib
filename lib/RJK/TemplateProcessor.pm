package RJK::TemplateProcessor;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{conf} = shift;
    $self->_init();
    return $self;
}

sub _init {
    my ($self) = @_;
    my $replace = $self->{conf}{replace};
    foreach (keys %$replace) {
        $replace->{$_} = [$replace->{$_}] if ! ref $replace->{$_}[0];
    }
}

sub getString {
    my ($self, $args) = @_;
    $args = [$args] if ! ref $args;
    $args = $self->getArgs(@$args) if ref $args eq 'ARRAY';
    return $self->processString($args);
}

sub getArgs {
    my ($self, @args) = @_;
    my $string = $self->{conf}{string};
    my @fields = $string =~ /{(\w+)}/g;
    my (%fields, %args);
    foreach my $f (@fields) {
        next if $fields{$f};
        $fields{$f} = 1;
        $args{$f} = shift @args;
    }
    return \%args;
}

sub processString {
    my ($self, $args) = @_;
    my $string = $self->{conf}{string};
    my $replace = $self->{conf}{replace};
    my @fields = keys %$args;
    foreach my $f (@fields) {
        my $arg = $args->{$f};
        foreach (@{$replace->{$f}}) {
            $arg =~ s/$_->[0]/$_->[1]/g;
        }
        $string =~ s/{$f}/$arg/g;
    }
    return $string;
}

1;
