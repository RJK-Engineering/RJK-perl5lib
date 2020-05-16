package RJK::Media::MPC::IniMonitor;
use parent 'RJK::Media::MPC::Monitor';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->setFile($opts{file});
    return $self;
}

1;
