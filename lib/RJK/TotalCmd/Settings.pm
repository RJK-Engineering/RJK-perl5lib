###############################################################################
=begin TML

---+ package RJK::TotalCmd::Settings

=cut
###############################################################################

package RJK::TotalCmd::Settings;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Exception' =>
        { isa => 'Exception' }
);

use Try::Tiny;

use RJK::Env;
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
=RJK::TotalCmd::Settings::Ini= object.
---+++ tcmdinc([$tcmdinc]) -> $tcmdinc
=RJK::TotalCmd::Settings::Inc= object.
---+++ usercmd([$usercmd]) -> $usercmd
=RJK::TotalCmd::Settings::UsercmdIni= object.

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

###############################################################################
=pod

---+++ loadTotalCmdInc([$path]) -> RJK::TotalCmd::Settings::Inc
Returns a =RJK::TotalCmd::Settings::Inc= object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Throws exception if file is not found.
Loads file, throws exception on failure.

=cut
###############################################################################

sub getTotalCmdInc {
    return $_[0]{_tcmdinc} //= loadTotalCmdInc($_[0]{tcmdinc});
}

sub loadTotalCmdInc {
    my $path = shift || RJK::Env->findPath(
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

---+++ loadTotalCmdIni([$path]) -> RJK::TotalCmd::Settings::Ini
Returns a =RJK::TotalCmd::Settings::Ini object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Throws exception if file is not found.
Loads file, throws exception on failure.

=cut
###############################################################################

sub getTotalCmdIni {
    return $_[0]{_tcmdini} //= loadTotalCmdIni($_[0]{tcmdini});
}

sub loadTotalCmdIni {
    my $path = shift || RJK::Env->findPath(
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

---+++ loadUsercmdIni([$path]) -> RJK::TotalCmd::Settings::UsercmdIni
Returns a =RJK::TotalCmd::Settings::UsercmdIni object for =$path=.
Tries to find the file in common locations if =$path= is undefined.
Throws exception if file is not found.
Loads file, throws exception on failure.

=cut
###############################################################################

sub getUsercmdIni {
    return $_[0]{_usercmd} //= loadUsercmdIni($_[0]{usercmd});
}

sub loadUsercmdIni {
    my $path = shift || RJK::Env->findPath(
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
Throws =RJK::TotalCmd::Exception= if command not found.

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
    return $cmd || throw RJK::TotalCmd::Exception("Unknown command: $name");
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
Throws =RJK::TotalCmd::Exception= if command not found.

---++++ getUserCommands() -> @commands or \@commands
Returns user commands.

=cut
###############################################################################

sub getUserCommand {
    my ($self, $nr) = @_;
    $self->getUsercmdIni->getCommand($nr)
        || throw RJK::TotalCmd::Exception("Unknown command: $nr");
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
Throws =RJK::TotalCmd::Exception= if item not found.

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
        || throw RJK::TotalCmd::Exception("Unknown command: $number");
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
        opendir my $dh, $_ or throw RJK::TotalCmd::Exception("$_: $!");
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
