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
    my ($self, $event) = @_;
    my $method = "handle" . $event->{type} . "Event";
    local $_ = $event;

    foreach my $observer (@{$self->{observers}}) {
        if ($observer->can($method)) {
            $observer->$method($event->{payload}, $self);
        } elsif ($observer->can("update")) {
            $observer->update($event, $self);
        } else {
            warn "No handler method for $event->{type} event in observer class " . ref($observer);
        }
    }
}

1;
