###############################################################################
=begin TML

---+ package RJK::TotalCmd::Utils
Total Commander utility functions.

=cut
###############################################################################

package RJK::TotalCmd::Utils;

use strict;
use warnings;

###############################################################################
=pod

---++ Class methods

---+++ sendCommand($commandName)
   * http://ahkscript.org - https://autohotkey.com
   * http://www.ghisler.ch/wiki/index.php/AutoHotkey:_Send_a_command_to_Total_Commander
   * =SendCommand.exe= cm_LoadSelectionFromClip
   * commands are listed in =totalcmd.inc=
   * =SendCommand.exe= needs to be in PATH environment variable.

=cut
###############################################################################

sub sendCommand {
    my ($self, $cm) = @_;
    my $exe = 'SendTCCommand.exe';
    system $exe, $cm;
}

###############################################################################
=pod

---+++ setPath(%opts)
   * =%opts= - Options:
      * newInstance => $boolean
      * newTab => $boolean
      * left => $path
      * right => $path
      * source => $path
      * target => $path

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

sub setPath {
    my ($self, %opts) = @_;
    my @args = ($ENV{COMMANDER_EXE}, '/O');
    push @args, '/N' if $opts{newInstance};
    push @args, '/T' if $opts{newTab};
    push @args, '/S' if $opts{source} || $opts{target};
    push @args, '/L='.($opts{source} || $opts{left}) if $opts{source} || $opts{left};
    push @args, '/R='.($opts{target} || $opts{right}) if $opts{target} || $opts{right};
    system @args;
}

###############################################################################
=pod

---+++ tempFile($extension) -> ($handle, $filename, $error)
   * =$extension= - optional temp file extension, defaults to "tmp"
   * =$handle= - file handle for the temp file
   * =$filename= - path of the temp file
   * =$error= - contains error message if an error occurred

Create a temp file in =$ENV{TEMP}= and return a file handle for it.

=cut
###############################################################################

sub tempFile {
    my ($self, $extension) = @_;
    $extension //= "tmp";

    unless (exists $ENV{TEMP} && defined $ENV{TEMP}) {
        return (undef, undef, "Environment variable TEMP not defined");
    }

    my $dir = $ENV{TEMP};
    unless (-d $dir) {
        return (undef, undef, "Not a directory: $dir");
    }
    unless (-r $dir) {
        return (undef, undef, "Directory not readable: $dir");
    }

    my $file;
    do {
        $file = "$dir/CMD";
        $file .= sprintf "%X", int rand(16) for 1..4;
        $file .= ".$extension";
    } while (-e $file);

    open (my $fh, '>', $file) || return (undef, $file, "$!");
    return ($fh, $file);
}

###############################################################################
=pod

---+++ isListFile($listFilePath) -> $boolean

=cut
###############################################################################

sub isListFile {
    defined $_[1] and $_[1] =~ /^(.*[\\\/])?CMD\w{3,4}.tmp$/;
}

1;
