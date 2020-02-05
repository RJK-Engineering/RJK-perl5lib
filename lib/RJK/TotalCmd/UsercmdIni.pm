=begin TML

---+ package RJK::TotalCmd::UsercmdIni
Total Commander =usercmd.ini= file functionality.

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

package RJK::TotalCmd::UsercmdIni;

use Try::Tiny;

use RJK::Util::Ini;
use RJK::TotalCmd::Command;

use Exception::Class (
    'Exception',
    'TotalCmd::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::UsercmdIni::Exception' =>
        { isa => 'TotalCmd::Exception' },
);

###############################################################################
=pod

---++ Object creation

---+++ new([$path]) -> RJK::TotalCmd::UsercmdIni
Returns a new =RJK::TotalCmd::UsercmdIni= object.

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

---+++ read([$path]) -> RJK::TotalCmd::UsercmdIni
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::UsercmdIni
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;

    $self->{ini}->read($file) || return;

    $self->{commands} = [];
    $self->{byName} = {};

    my $i = 1;
    foreach my $name ($self->{ini}->sections) {
        try {
            my $cmd = new RJK::TotalCmd::Command(
                ($self->{ini}->getSection($name)),
                source => 'UserCommand',
                name => $name,
                number => $i++,
            );
            push @{$self->{commands}}, $cmd;
            $self->{byName}{$name} = $cmd;
        } catch {
            throw RJK::TotalCmd::UsercmdIni::Exception("Error creating RJK::TotalCmd::Command object: $_");
        }
    }

    return $self;
}

sub write {
    my ($self, $file) = @_;

    $self->{ini}->write($file) || return;

    return $self;
}

###############################################################################
=pod

---++ Other object methods.

---+++ getCommands() -> \@command or @command
Get all commands.

---+++ getCommand($nr) -> \%cmd
Get command.

---+++ getCommandByName($name) -> \%cmd
Get command by name.

=cut
###############################################################################

sub getCommands {
    my $commands = shift->{commands};
    return wantarray ? @$commands : $commands;
}

sub getCommand {
    my ($self, $nr) = @_;
    return $self->{commands}[$nr-1];
}

sub getCommandByName {
    my ($self, $name) = @_;
    return $self->{byName}{$name};
}

1;