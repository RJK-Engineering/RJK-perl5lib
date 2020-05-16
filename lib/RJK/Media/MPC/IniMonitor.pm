package RJK::Media::MPC::IniMonitor;
use parent qw(RJK::Util::FileMonitor RJK::Media::MPC::Monitor);

use strict;
use warnings;

use RJK::Util::Ini;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->setFile($opts{file});
    return $self;
}

sub getIniSection {
    my ($self, $payload, $section) = @_;
    my $ini = $self->getIni($payload);
    return $ini->getSection($section);
}

sub getIni {
    my ($self, $payload) = @_;
    return $payload->{ini} if $payload->{ini};
    return $payload->{ini} = new RJK::Util::Ini($payload->{file})->read;
}

1;
