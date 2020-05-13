package RJK::Util::Observable;

use strict;
use warnings;

sub addObserver {
    my ($self, @observers) = @_;
    push @{$self->{observers}}, @observers;
}

sub removeObserver {
    my ($self, @observers) = @_;
    $self->{observers} // return;

    my $c = @{$self->{observers}};

    foreach my $observer (@observers) {
        $self->{observers} = [ grep { $_ != $observer } @{$self->{observers}} ];
    }
    return $c - @{$self->{observers}};
}

sub hasObserver {
    my ($self, $observer) = @_;
    return scalar grep { $_ == $observer } @{$self->{observers}};
}

sub notifyObservers {
    my ($self, $event) = @_;

    my ($isEventObject, $method);
    if ($isEventObject = ref $event eq "HASH") {
        $method = "handle" . $event->{type} . "Event";
    }

    foreach (@{$self->{observers}}) {
        if ($isEventObject) {
            $_->$method($event->{payload}) if $_->can($method);
        } elsif ($_->can("update")) {
            $_->update($event);
        } elsif (ref $_ eq "CODE") {
            $_->($event);
        } else {
            warn "No handler found for event $event and observer $_";
        }
    }
}

1;
