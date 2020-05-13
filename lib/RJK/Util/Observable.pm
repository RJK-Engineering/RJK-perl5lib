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
    my ($hash, $code);

    foreach (@{$self->{observers}}) {
        if ($hash //= ref $event eq "HASH") {
            my $method = "handle" . $event->{type} . "Event";
            $_->$method($event->{payload}) if $_->can($method);
        } elsif ($_->can("update")) {
            $_->update($event);
        } elsif (ref $_ eq "CODE") {
            $_->($event);
        } else {
            warn "Invalid event: $event";
        }
    }
}

1;
