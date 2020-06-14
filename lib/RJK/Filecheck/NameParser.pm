package RJK::Filecheck::NameParser;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->addConf(shift || []);
    return $self;
}

sub addConf {
    my ($self, $conf) = @_;
    push @{$self->{config}}, @$conf;
}

sub parse {
    my ($self, $name) = @_;
    my $props = baseProps($name);

    foreach my $conf (@{$self->{config}}) {
        next unless $self->match($conf, $name, $props);
        if ($conf->{properties}) {
            while (my ($prop, $val) = each %{$conf->{properties}}) {
                $props->{$prop} = $val;
            }
        }
        last;
    }

    return $props;
}

sub match {
    my ($self, $conf, $name, $props) = @_;

    my $match;
    foreach my $re (@{$conf->{regex}}) {
        next unless $name =~ /$re/xi;
        $props->{$_} = $+{$_} for keys %+;
        $match = 1;
        last;
    }
    return unless $match;

    $props->{nameWords} = words($props->{name}) if $props->{name};

    return 1;
}

sub baseProps {
    my $name = shift;
    my $props = {
        filename => $name,
        basename => $name,
    };

    $props->{basename} =~ s/\.([^\.]+)$//; #remove extension
    $props->{extension} = $1;
    $props->{words} = words($props->{basename});

    return $props;
}

sub words {
    my $w = shift;
    $w =~ s/\W/ /g;
    $w =~ s/ +/ /g;
    $w =~ s/ $//;
    $w =~ s/^ //;
    return $w;
}

1;
