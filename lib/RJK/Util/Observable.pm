package RJK::Util::Observable;

use strict;
use warnings;

sub addObserver {
    my ($self, @observers) = @_;
    $self->{observers} //= [];
    my $c = @{$self->{observers}};

    push @{$self->{observers}}, map {
        if (ref ne "CODE") {
            $_;
        } elsif (eval "require RJK::Util::SimpleObserver") {
            new RJK::Util::SimpleObserver($_);
        } else {
            print STDERR "$@\n";
            die "$!";
        }
    } @observers;

    $self->resume() unless $c;
}

sub removeObserver {
    my ($self, @observers) = @_;
    $self->{observers} // return;

    my $c = @{$self->{observers}};

    foreach my $observer (@observers) {
        $self->{observers} = [ grep {
            $observer != (ref eq "RJK::Util::SimpleObserver" ? $_->{sub} : $_)
        } @{$self->{observers}} ];
    }

    $self->pause() if $c && ! @{$self->{observers}};

    return $c - @{$self->{observers}};

}

sub pause {}
sub resume {}

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
