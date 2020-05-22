=begin TML

---+ package RJK::TotalCmd::Settings::UsercmdIni
Total Commander =USERCMD.INI= file.

---++ =usercmd.ini= format

<verbatim>
; start with em_, camel case
[em_CommandName]
; first icon
button=C:\progz\totalcmd\inireloc.exe
; second icon (icon numbers start at 0)
button=C:\progz\totalcmd\inireloc.exe,1
cmd=
param=
path=
; 1=minimize, -1=maximize
iconic=1
; description/tooltip/start menu item title
menu=
</verbatim>

=cut

package RJK::TotalCmd::Settings::UsercmdIni;
use parent 'RJK::TotalCmd::ItemList::ItemList';

use strict;
use warnings;

use Try::Tiny;

use RJK::Util::Ini;
use RJK::TotalCmd::Item::UserCmd;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::Settings::Exception' =>
        { isa => 'RJK::TotalCmd::Exception' },
);

###############################################################################
=pod

---++ Object creation

---+++ new([$path]) -> RJK::TotalCmd::Settings::UsercmdIni
Returns a new =RJK::TotalCmd::Settings::UsercmdIni= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{ini} = new RJK::Util::Ini(shift);
    return $self;
}

###############################################################################
=pod

---++ INI File

---+++ read([$path]) -> RJK::TotalCmd::Settings::UsercmdIni
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::Settings::UsercmdIni
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;

    $self->{ini}->read($file) || return;

    $self->{items} = [];
    $self->{byName} = {};

    my $i = 1;
    foreach my $name ($self->{ini}->sections) {
        try {
            my $cmd = new RJK::TotalCmd::Item::UserCmd(
                ($self->{ini}->getSection($name)),
                name => $name,
                number => $i++,
            );
            push @{$self->{items}}, $cmd;
            $self->{byName}{$name} = $cmd;
        } catch {
            throw RJK::TotalCmd::Settings::Exception("Error creating RJK::TotalCmd::Item::UserCmd object: $_");
        }
    }

    return $self;
}

sub write {
    my ($self, $file) = @_;

    $self->{ini}->write($file) || return;

    return $self;
}

1;
