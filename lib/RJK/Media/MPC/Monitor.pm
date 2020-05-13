package RJK::Media::MPC::Monitor;
use parent 'RJK::Util::Observable';

sub new {
    return bless {}, shift;
}

sub init {
    return shift;
}

sub finish {}

sub poll {
    my $self = shift;
    return if ! @{$self->{observers}};
    $self->doPoll();
}

1;
