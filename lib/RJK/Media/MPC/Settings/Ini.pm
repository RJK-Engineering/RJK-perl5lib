package RJK::Media::MPC::Settings::Ini;
use parent 'RJK::Util::Ini';

use strict;
use warnings;

###############################################################################
=pod

---++ getCommandMods() -> %mods or \%mods

=cut
###############################################################################

sub getCommandMods {
    my $self = shift;
    my %mods;
    foreach ($self->getList('Commands2', 'CommandMod')) {
        my @mod = split /\s/;
        $mod[3] =~ s/"//g;
        $mods{$mod[0]} = {
            id => $mod[0],
            modif => $mod[1],
            key => $mod[2],
            remoteCmd => $mod[3],
            repCnt => $mod[4],
            mouseWindowed => $mod[5],
            appCommand => $mod[6],
            mouseFullscreen => $mod[7],
        };
    }
    return wantarray ? %mods : \%mods;
}

sub setCommandMods {
    my ($self, $mods) = @_;
    $self->setList('Commands2', $mods, 'CommandMod');
    $self->write();
}

1;
