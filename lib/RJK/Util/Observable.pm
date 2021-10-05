package RJK::Util::Observable;

use strict;
use warnings;

sub addObserver {
    my ($self, $observer) = @_;
    $self->{observers} //= [];

    if (ref $observer ne "CODE") {
        push @{$self->{observers}}, $observer;
    } elsif (eval "require RJK::Util::SimpleObserver") {
        push @{$self->{observers}}, new RJK::Util::SimpleObserver($observer);
    } else {
        print STDERR "$@\n";
        die "$!";
    }
}

sub removeObserver {
    my ($self, $observer) = @_;
    $self->{observers} // return;

    $self->{observers} = [ grep {
        $observer != (ref eq "RJK::Util::SimpleObserver" ? $_->{sub} : $_)
    } @{$self->{observers}} ];
}

sub observers {
    $_[0]{observers} //= [];
}

sub hasObservers {
    my $self = shift;
    $self->{observers} //= [];
    return @{$self->{observers}} > 0;
}

sub hasObserver {
    my ($self, $observer) = @_;
    return scalar grep {
        $observer == (ref eq "RJK::Util::SimpleObserver" ? $_->{sub} : $_)
    } @{$self->{observers}};
}

sub notifyObservers {
    my $self = shift;
    my $event = shift;
    my %opts = @_ == 1 ? (payload => $_[0]) : @_;

    if (! ref $event) {
        $opts{type} = $event;
        $event = \%opts;
    }

    my $var = "$event->{type}::ISA";
    if (eval "\@$var and \$${var}[0] eq 'RJK::Event'") {
        local $_ = bless $event, $event->{type};
    } else {
        local $_ = bless $event, 'RJK::Event';
    }

    my $method = 'handle' . $event->{type};
    foreach my $observer (@{$self->{observers}}) {
        if ($observer->can($method)) {
            $observer->$method($event, $self);
        } elsif ($observer->can('update')) {
            $observer->update($event, $self);
        } else {
            warn "No handler method for $event->{type} in observer class " . ref($observer);
        }
    }
}

1;
