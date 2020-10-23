package RJK::Media::MPC::WebIFMonitor;
use parent 'RJK::Media::MPC::Monitor';

use strict;
use warnings;

use RJK::Media::MPC::Status ':constants';
use RJK::Media::MPC::WebIF;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;

    $opts{url} ||= "http://localhost:$opts{port}/variables.html";

    $self->{opts} = \%opts;

    return $self;
}

sub init {
    my $self = shift;
    $self->{webIf} = new RJK::Media::MPC::WebIF(%{$self->{opts}})->init;
}

sub doPoll {
    my $self = shift;

}

sub getStatus {
    my $self = shift;
    my $status = new RJK::Media::MPC::Status(%{$self->{webIf}->getStatus});
    return $status;
}

1;
