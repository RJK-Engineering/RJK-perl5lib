package RJK::Util::Observable;

use strict;
use warnings;

sub addObserver {
    my ($self, @observers) = @_;
    push @{$self->{observers}}, map {
        if (ref ne "CODE") {
            $_;
        } elsif (eval "require RJK::Util::SimpleObserver") {
            new RJK::Util::SimpleObserver($_);
        } else {
            print "$@\n";
            die "$!";
        }
    } @observers;
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
    return $c - @{$self->{observers}};
}

sub hasObserver {
    my ($self, $observer) = @_;
    return scalar grep { $_ == $observer } @{$self->{observers}};
}

sub notifyObservers {
    my ($self, $event) = @_;

    my $method = "handle" . $event->{type} . "Event";

    foreach (@{$self->{observers}}) {
        if ($_->can($method)) {
            $_->$method($event->{payload});
        } elsif ($_->can("update")) {
            $_->update($event);
        } else {
            warn "No handler method for $event->{type} event in observer class " . ref();
        }
    }
}

1;
