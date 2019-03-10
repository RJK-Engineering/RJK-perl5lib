package RJK::TemplateProcessor;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{conf} = shift;
    return $self;
}

sub getString {
    my ($self, $name, $args) = @_;
    if (! ref $args) {
        $args = [$args];
    }
    if (ref $args eq 'ARRAY') {
        $args = $self->getArgs($name, @$args);
    }
    return $self->processString($name, $args);
}

sub getArgs {
    my ($self, $name, @args) = @_;
    my $string = $self->{conf}{$name}{string};
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
    my ($self, $name, $args) = @_;
    my $string = $self->{conf}{$name}{string};
    my $replace = $self->{conf}{$name}{replace};
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
