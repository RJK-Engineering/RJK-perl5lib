=begin TML

---+ package RJK::TotalCmd::Settings

=cut

package RJK::TotalCmd::Settings;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Exception' =>
        { isa => 'Exception' },
    'TotalCmd::NotFoundException' =>
        { isa => 'RJK::TotalCmd::Exception' },
);

use Try::Tiny;

use RJK::File::PathFinder;
use RJK::TotalCmd::ItemList::ButtonBar;
use RJK::TotalCmd::Settings::Inc;
use RJK::TotalCmd::Settings::Ini;
use RJK::TotalCmd::Settings::UsercmdIni;

###############################################################################
=pod

---++ Object attributes

Return object attribute value if called with no arguments, set object
attribute value and return the same value otherwise.

---+++ tcmdini([$tcmdini]) -> $tcmdini
=TotalCmd::Ini= object.
---+++ tcmdinc([$tcmdinc]) -> $tcmdinc
=TotalCmd::Inc= object.
---+++ usercmd([$usercmd]) -> $usercmd
=TotalCmd::UsercmdIni= object.

=cut
###############################################################################

use Class::AccessorMaker {
    tcmdini => undef,
    tcmdinc => undef,
    usercmd => undef,
}, "new_init";

my @barDirs;

###############################################################################
=pod

---++ Object creation

---+++ new(%attrs) -> $tcmd
Returns a new =RJK::TotalCmd::Settings= object.

=cut
###############################################################################

sub init {
    my $self = shift;
    SetBarDirs($ENV{COMMANDER_INI});
}

sub ini { $_[0]{_tcmdini} }
sub inc { $_[0]{_tcmdinc} }
sub user { $_[0]{_usercmd} }

###############################################################################
=pod

---+++ GetTotalCmdInc([$path]) -> RJK::TotalCmd::Settings::Inc
Returns a =TotalCmd::Inc= object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Returns nothing if file is not found.
Loads =totalcmd.inc=, throws a =RJK::TotalCmd::Exception= on failure.

=cut
###############################################################################

sub getTotalCmdInc {
    return $_[0]{_tcmdinc} || $_[0]->loadTotalCmdInc();
}

sub loadTotalCmdInc {
    my $path = $_[0]{tcmdinc} || RJK::File::PathFinder::FindPath(
        "%COMMANDER_PATH%/TOTALCMD.INC",
        "%APPDATA%/GHISLER/TOTALCMD.INC",
        "%LOCALAPPDATA%/TOTALCMD.INC",
        "%LOCALAPPDATA%/TotalCommander/TOTALCMD.INC",
    ) || throw RJK::TotalCmd::Exception("Could not find totalcmd.inc");

    return RJK::TotalCmd::Settings::Inc->new($path)->read()
        || throw RJK::TotalCmd::Exception("Error loading totalcmd.inc");
}

###############################################################################
=pod

---+++ GetTotalCmdIni([$path]) -> RJK::TotalCmd::Settings::Ini
Returns a =TotalCmd::Ini object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Returns nothing if file is not found.
Loads =totalcmd.ini=, throws a =RJK::TotalCmd::Exception= on failure.

=cut
###############################################################################

sub getTotalCmdIni {
    return $_[0]{_tcmdini} || $_[0]->loadTotalCmdIni();
}

sub loadTotalCmdIni {
    my $path = $_[0]{tcmdini} || RJK::File::PathFinder::FindPath(
        "%COMMANDER_INI%",
        "%APPDATA%/GHISLER/wincmd.ini",
        "%LOCALAPPDATA%/wincmd.ini",
        "%LOCALAPPDATA%/totalcmd.ini",
        "%LOCALAPPDATA%/TotalCommander/wincmd.ini",
        "%LOCALAPPDATA%/TotalCommander/totalcmd.ini",
    ) || throw RJK::TotalCmd::Exception("Could not find totalcmd.ini");

    return RJK::TotalCmd::Settings::Ini->new($path)->read()
        || throw RJK::TotalCmd::Exception("Error loading totalcmd.ini");
}

###############################################################################
=pod

---+++ GetUsercmdIni([$path]) -> RJK::TotalCmd::Settings::UsercmdIni
Returns a =TotalCmd::UsercmdIni object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Returns nothing if file is not found.
Loads =usercmd.ini=, throws a =RJK::TotalCmd::Exception= on failure.

=cut
###############################################################################

sub getUsercmdIni {
    return $_[0]{_usercmd} || $_[0]->loadUsercmdIni();
}

sub loadUsercmdIni {
    my $path = $_[0]{usercmd} || RJK::File::PathFinder::FindPath(
        "%COMMANDER_PATH%/usercmd.ini",
        "%APPDATA%/GHISLER/usercmd.ini",
        "%LOCALAPPDATA%/usercmd.ini",
        "%LOCALAPPDATA%/TotalCommander/usercmd.ini",
    ) || throw RJK::TotalCmd::Exception("Could not find usercmd.ini");

    return RJK::TotalCmd::Settings::UsercmdIni->new($path)->read()
        || throw RJK::TotalCmd::Exception("Error loading usercmd.ini");
}

sub SetBarDirs {
    my @paths = @_;
    my @dirs;
    foreach (@paths) {
        next unless $_;
        if (-d) {
            s/\\*$//;       # remove trailing slashes
            push @dirs, $_;
            if (-d "$_\\bars") {
                push @dirs, "$_\\bars";
            }
        } else {
            s/\\[^\\]*$//;  # remove slashes and file portion
            if (-d) {
                push @dirs, $_;
                if (-d "$_\\bars") {
                    push @dirs, "$_\\bars";
                }
            }
        }
    }
    @barDirs = @dirs;
}

###############################################################################
=pod

---++ Commands

| *Command Source*    | *INI File [section]*   |
| User command        | usercmd.ini            |
| Start menu item     | totalcmd.ini [user]    |
| Directory menu item | totalcmd.ini [DirMenu] |
| Button              | bar file [Buttonbar]   |
| Internal            | -                      |

All methods return a single or an array of =TotalCmd::Command= objects.

---+++ getCommand($name) -> $command
Returns command by name.
Throws =TotalCmd::NotFoundException= if command not found.

---+++ getNamedCommands() -> @commands or \@commands
Returns UserCommands and Internal commands.

---+++ getCustomCommands() -> @commands or \@commands
Returns StartMenuItems, DirMenuItems, UserCommands and Buttons.

---+++ getAllCommands() -> @commands or \@commands
Returns StartMenuItems, DirMenuItems, UserCommands, Buttons and
internal commands.

=cut
###############################################################################

sub getCommand {
    my ($self, $name) = @_;
    my $cmd;
    if ($name =~ /^((?:(em)|(cm))_.*)/) {
        $cmd = $self->getUsercmdIni->getCommandByName($1) if $2;
        $cmd = $self->getTotalCmdInc->getCommandByName($1) if $3;
    }
    return $cmd || throw RJK::TotalCmd::NotFoundException("Unknown command: $name");
}

sub getCustomCommands {
    my ($self) = @_;

    my @cmds = $self->getMenuItems('user');
    push @cmds, $self->getMenuItems('DirMenu');
    push @cmds, $self->getUserCommands;

    my @bars = $self->getButtonBars();
    foreach my $bar (@bars) {
        push @cmds, @{$self->getButtonBar($bar)->items};
    }

    return wantarray ? @cmds : \@cmds;
}

sub getAllCommands {
    my ($self) = @_;

    my $cmds = $self->getCustomCommands;
    push @$cmds, @{$self->getInternalCommands};

    return wantarray ? @$cmds : $cmds;
}

###############################################################################
=pod

---+++ User commands

---++++ getUserCommand($nr) -> $command
Returns user command.
Throws =TotalCmd::NotFoundException= if command not found.

---++++ getUserCommands() -> @commands or \@commands
Returns user commands.

=cut
###############################################################################

sub getUserCommand {
    my ($self, $nr) = @_;
    $self->getUsercmdIni->getCommand($nr)
        || throw RJK::TotalCmd::NotFoundException("Unknown command: $nr");
}

sub getUserCommands {
    shift->getUsercmdIni();
}

###############################################################################
=pod

---+++ Menu items

Two menus are available, "user" for the start menu,
"DirMenu" for the directory menu.

---++++ getMenuItem($menu, $nr) -> $command
Returns menu item by item number.
Throws =TotalCmd::NotFoundException= if item not found.

---++++ getMenuItems($menu, [$submenuNr]) -> @commands or \@commands
Returns menu items.
Returns all items if =$item= is undefined.
Returns root items if =$item= is =0=.
Throws =RJK::TotalCmd::Exception= if =$itemNr= is not a submenu.

---++++ getSubmenus($menu) -> @commands or \@commands
Returns submenus.

=cut
###############################################################################

sub getMenuItem {
    my ($self, $menu, $number) = @_;
    $self->getTotalCmdIni->getMenuItem($menu, $number)
        || throw RJK::TotalCmd::NotFoundException("Unknown command: $number");
}

sub getMenuItems {
    my ($self, $menu, $submenuNr) = @_;
    $self->getTotalCmdIni->getMenuItems($menu, $submenuNr);
}

sub getSubmenus {
    my ($self, $menu) = @_;
    $self->getTotalCmdIni->getSubmenus($menu);
}

###############################################################################
=pod

---++ Other methods

---+++ getCommandCategories() -> @names or \@names
Returns command category names.

---+++ getShortcuts() -> ( $key => $commandName ) or { $key => $commandName }
Returns shortcut keys.

---+++ getKeys() -> ( $commandName => \@keys  ) or { $commandName => \@keys  }
Returns shortcut keys.

---+++ getButtonBar($name) -> $buttonBar
Returns new or existing =RJK::TotalCmd::ItemList::ButtonBar=.

---+++ getButtonBars() -> @names or \@names
Returns button bar names.

=cut
###############################################################################

sub getDirMenu {
    shift->getTotalCmdIni->getDirMenu();
}

sub getStartMenu {
    shift->getTotalCmdIni->getStartMenu();
}

sub getCommandCategories {
    shift->getTotalCmdInc->categories();
}

sub getShortcuts {
    shift->getTotalCmdIni->getShortcuts();
}

sub getKeys {
    shift->getTotalCmdIni->getKeys();
}

sub getButtonBar {
    my ($self, $name) = @_;
    $name || return new RJK::TotalCmd::ItemList::ButtonBar();
    my $bar;
    @barDirs || die "No bar directories defined";
    foreach my $dir (@barDirs) {
        -d $dir || die "Not a directory: $dir";
        my $path = "$dir\\$name.bar";
        next if ! -e $path;
        $bar = new RJK::TotalCmd::ItemList::ButtonBar($path)->read;
    }
    return $bar;
}

sub getButtonBars {
    my ($self) = @_;

    my @bars;
    foreach (@barDirs) {
        opendir(my $dh, $_)
            || throw RJK::TotalCmd::Exception("$_: $!");
        push @bars, (grep { s/\.bar$//i } readdir $dh);
    }

    return wantarray ? @bars : \@bars;
}

###############################################################################
=pod

---+++ Internal commands

---++++ getInternalCommands() -> $tcmdinc
Returns =RJK::TotalCmd::Settings::Inc= object.

=cut
###############################################################################

sub getInternalCommands {
    shift->getTotalCmdInc;
}

1;
