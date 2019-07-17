=begin TML

---+ package TotalCmd::Utils
Total Commander utility functions.

=cut

package TotalCmd::Utils;

use strict;
use warnings;

###############################################################################
=pod

---++ sendCommand($commandName)
   * http://ahkscript.org - https://autohotkey.com
   * http://www.ghisler.ch/wiki/index.php/AutoHotkey:_Send_a_command_to_Total_Commander
   * =SendCommand.exe= cm_LoadSelectionFromClip
   * commands are listed in =totalcmd.inc=
   * =SendCommand.exe= needs to be in PATH environment variable.

=cut
###############################################################################

sub sendCommand {
    my ($cm) = @_;
    my $exe = 'SendTCCommand.exe';
    system $exe, $cm;
}

###############################################################################
=pod

---++ setPaths($left, $right)

See topic "Command line parameters" in Total Commander help.

| /O   | If Total Commander is already running, activate it and pass the path(s) in the command line to that instance (overrides the settings in the configuration dialog to have multiple windows) ||
| /L=  | Set path in left window ||
| /R=  | Set path right window ||
| /T   | Opens the passed dir(s) in new tab(s). Now also works when Total Commander hasn't been open yet. ||
| /P=  | Sets the active panel at program start: /P=L left, /P=R right. Overrides wincmd.ini option ActiveRight=. ||
| /S=L | Start Lister directly, pass file name to it for viewing (requires full name including path). May include bookmark in html files, e.g. c:\test\test.html#bookmark ||
|      | Accepts additional parameters separated by a colon, e.g. /S=L:AT1C1250 ||
|      | A      | ANSI/Windows text |
|      | S      | ASCII/DOS text |
|      | V      | Variable width text |
|      | T1..T7 | View mode 1-7 (1: Text, 2: Binary, 3: Hex, 4: Multimedia, 5: HTML, 6:Unicode, 7: UTF-8) |
|      | C<nr>  | Codepage, e.g. C1251 for Cyrillic |
|      | N      | Auto-detect, but no multimedia or plugins allowed |
|      | P<x>   | As LAST parameter: Choose plugin, e.g. /S=L:Piclview for iclview plugin (As shown in Lister title) |

=cut
###############################################################################

sub setPaths {
    my ($left, $right) = @_;
    my @args = ("totalcmd.exe", "/O", "/L=\"$left\"");
    push @args, "/R=\"$right\"" if $right;
    system @args;
}

###############################################################################
=pod

---++ pathListfromArguments(@args)
Take paths from Total Commander list file or from arguments.

=cut
###############################################################################

sub pathListfromArguments {
    my (@args) = @_;

    my $pathList = new File::PathList();
    foreach (@args) {
        if (/^(.+[\\\/]+)?CMD\w{3,4}.tmp$/) {
            $pathList->loadFromFile(file => $_) || return;
        } else {
            $pathList->add($_);
        }
    }
    return $pathList;
}

###############################################################################
=pod

---++ findPath(@paths)
Look in common locations with environment variable substitution.

=cut
###############################################################################

sub findPath {
    my @paths = @_;
    my $path;
    foreach (@paths) {
        s|%(\w+)%|$ENV{$1}//''|ge;
        next unless -e;
        $path = $_;
        last;
    }
    return $path;
}

###############################################################################
=pod

---++ tempFile([$extension]) -> ($handle, $filename)
Returns =undef= for =$filename= if no file location can be found.
Returns =undef= for =$handle= if file can not be opened.
=$extension= defaults to "tmp".

=cut
###############################################################################

sub tempFile {
    my $extension = shift // "tmp";
    my $tempDir = findPath('%TEMP%') || return;
    my $file;

    do {
        $file = "$tempDir/CMD";
        $file .= sprintf "%X", int rand(16) for 1..4;
        $file .= ".$extension";
    } while (-e $file);

    open (my $fh, '>', $file) || return (undef, $file);
    return ($fh, $file);
}

###############################################################################
=pod

---++ setLeftRightPaths()

=cut
###############################################################################

sub setLeftRightPaths {
    my ($l, $r) = @_;
    my @args = ("totalcmd", "/O");
    push @args, "/L=\"$l\"" if $l;
    push @args, "/L=\"$r\"" if $r;
    system @args;
}


###############################################################################
=pod

---++ setSourceTargetPaths()

=cut
###############################################################################

sub setSourceTargetPaths {
    my ($s, $t) = @_;
    my @args = ("totalcmd", "/O", "/S");
    push @args, "/L=\"$s\"" if $s;
    push @args, "/L=\"$t\"" if $t;
    #~ print "@args\n";
    system @args;
}

1;
