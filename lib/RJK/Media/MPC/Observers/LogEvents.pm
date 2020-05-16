package RJK::Media::MPC::Observers::LogEvents;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub update {
    my ($self, $event) = @_;
    print "$event->{type} $event->{payload}\n";
}

1;
