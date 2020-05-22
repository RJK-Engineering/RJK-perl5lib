=begin TML

---+ package RJK::TotalCmd::FtpIni

=cut

package RJK::TotalCmd::FtpIni;

use strict;
use warnings;

use RJK::Util::Ini;

# see topic "wcx_ftp.ini INI settings" in Total Commander help

###############################################################################
=pod

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::FtpIni
Returns a new =RJK::TotalCmd::FtpIni= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{ini} = new RJK::Util::Ini(shift);
    $self->{sessions} = {}; # name => { host, username, anonymous, directory, pasvmode }
    return $self;
}

###############################################################################
=pod

---++ File access

---+++ read([$path]) -> RJK::TotalCmd::FtpIni
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::FtpIni
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my ($self, $path) = @_;
    $path //= $self->{ini}{path};
    $self->{ini}->read($path);

    $self->{general} = $self->{ini}->getSection('General');
    $self->{certAlias} = $self->{ini}->getSection('CertAlias');
    $self->{default} = $self->{ini}->getSection('default');
    $self->{firewall} = $self->{ini}->getSection('firewall');
    $self->{connections} = $self->{ini}->getList('connections');
    $self->{oldConnections} = $self->{ini}->getList('OldConnections');

    my $sessions = {};
    foreach (@{$self->{connections}}) {
        $sessions->{$_} = $self->{ini}{properties}{$_};
    }
    $self->{sessions} = $sessions;

    return $self;
}

sub general {
    $_[0]{general};
}

sub certAlias {
    $_[0]{certAlias};
}

sub default {
    $_[0]{default};
}

sub firewall {
    $_[0]{firewall};
}

sub connections {
    $_[0]{connections};
}

sub oldConnections {
    $_[0]{oldConnections};
}

sub session {
    $_[0]{sessions}{$_[1]};
}

1;
