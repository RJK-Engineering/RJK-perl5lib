=begin TML

---+ package RJK::TotalCmd::Log

=cut

package RJK::TotalCmd::Log;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Log::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::Log::CorruptLineException' =>
        { isa => 'Exception',
          fields => [qw(line)] },
);


use RJK::TotalCmd::Log::Entry;

our @fields = qw(
    date time operation ok
    source sourcedir sourcefile
    path dir file
    destination destdir destfile
);

###############################################################################
=pod

---+++ traverse($file, $entryCallback, $corruptLineCallback)
   * =$entryCallback= - Traversal is stopped if this sub returns a true value.
   * =$corruptLineCallback= - Optional. Traversal is stopped if this sub returns a true value.
   * throws RJK::TotalCmd::Log::Exception
   * throws RJK::TotalCmd::Log::CorruptLineException, unless
     =$corruptLineCallback= is defined.

=cut
###############################################################################

sub traverse {
    my ($self, $file, $entryCallback, $corruptLineCallback) = @_;

    open(my $fh, '<', $file)
        || throw RJK::TotalCmd::Log::Exception("$!");

    $entryCallback && ref $entryCallback && ref $entryCallback eq "CODE"
        || throw RJK::TotalCmd::Log::Exception("No callback");

    if ($corruptLineCallback) {
        ref $corruptLineCallback && ref $corruptLineCallback eq "CODE"
            or throw RJK::TotalCmd::Log::Exception("Invalid corrupt line callback");
    } else {
        $corruptLineCallback = sub {
            my $line = shift;
            throw RJK::TotalCmd::Log::CorruptLineException(
                error => "Corrupt line: $line",
                line => $line,
            );
        };
    }

    my $firstline = 1;
    while (<$fh>) {
        next unless /\S/;
        chomp;

        # first line (sometimes?) starts with weird chars
        if ($firstline) {
            $firstline = 0;
            if (/^.{1,3}(\d\d-\d\d-\d\d\d\d .*)/)  {
                $_ = $1;
            }
        }

        # Log entry format: [date and time]: [entry]
        my $entry = new RJK::TotalCmd::Log::Entry;
        if (s/^(\d\d-\d\d-\d\d\d\d) (\d\d:\d\d:\d\d): //) {
            $entry->{date} = $1;
            $entry->{time} = $2;
        } else {
            last if $corruptLineCallback->($_);
            next;
        }

        # parse entry
        # Ok:       [op]: [params]
        # Error:    [op](Error: [error]): [params]
        # Skip:     [op](Skipped): [params]
        # Startup:  Program start ([user]) [encoding]
        # Shutdown: Program shutdown ([user])

        # file system plugin operation
        if (s/^FS://) {
            $entry->{fsPluginOp} = 1;
        }

        if (s/^(\w+): //) {
            $entry->{operation} = $1;
            $entry->{ok} = 1;
        } elsif (s/^(\w+)\(Error: (.+)\): //) {
            $entry->{operation} = $1;
            $entry->{error} = $2;
        } elsif (s/^(\w+)\(Skipped\): //) {
            $entry->{operation} = $1;
            $entry->{skipped} = 1;
        } elsif (/^Program start \((.+)\)$/) {
            $entry->{operation} = "Startup";
            $entry->{user} = $2;
        } elsif (/^Program start \((.+)\) (.+)$/) {
            $entry->{operation} = "Startup";
            $entry->{user} = $2;
            $entry->{encoding} = $3;
        } elsif (/^Program shutdown \((.+)\)$/) {
            $entry->{operation} = "Shutdown";
            $entry->{user} = $2;
        } else {
            $corruptLineCallback->($_);
            next;
        }

        # parse params
        if (/^((.+)\\(.+)) -> ((.+)\\(.+))$/) {
            $entry->{source} = $1;
            $entry->{sourcedir} = $2;
            $entry->{sourcefile} = $3;
            $entry->{destination} = $4;
            $entry->{destdir} = $5;
            $entry->{destfile} = $6;
        #~ } elsif (/^(.+) -> (.+)$/) {
        #~     $entry->{source} = $1;
        #~     $entry->{destination} = $2;
        } elsif (/^((.+)\\(.+))$/) {
            $entry->{source} = $1;
            $entry->{sourcedir} = $2;
            $entry->{sourcefile} = $3;
        } else {
            $entry->{source} = $_;
        }

        # aliasses
        if ($entry->{sourcedir}) {
            $entry->{path} = $entry->{source};
            $entry->{dir} = $entry->{sourcedir};
            $entry->{file} = $entry->{sourcefile};
        }

        local $_ = $entry;
        last if $entryCallback->($entry);
    }
    close $fh;
}

1;

__END__

Log entry format: [date and time]: [entry]

[date and time] := [dd]-[mm]-[yyyy] [hh]:[mm]:[ss]

[entry] :=
Ok:       [op]: [params]
Error:    [op](Error: [error]): [params]
Skip:     [op](Skipped): [params]
Startup:  Program start ([user]) [encoding]
Shutdown: Program shutdown ([user])

[op] := FS:[operation] | [operation]
[operation] := Move | Copy | Delete |
               CreateFile | NewFolder | DeleteFolder |
               Pack | Unpack
[error] :=  Aborted | Write error | Failed | Not Found

params for operations:
[operation]              [params]
Move, Copy:              [filepath] -> [filepath] *1 File might be renamed.
Move:                    [dirpath -> dirpath]     *2 Only on same filesystem.
Delete, CreateFile:      [filepath]               *3 A Delete also occurs after a Move to a different filesystem.
NewFolder, DeleteFolder: [dirpath]



NOTES

*1 A file rename is a Move or a Copy to a different filename.

*2 Moving a directory to a different filesystem* is not a Move operation!:

NewFolder: T:\dir
(move stuff inside)
DeleteFolder: S:\dir

*3 Moving a file to a different filesystem* results in a Delete after the Move:

Move: S:\file -> T:\file
Delete: S:\file

Explorer delete of a directory does strange things:

Delete: S:\dir
DeleteFolder: S:\dir

or

Delete(Skipped): S:\dir
(delete stuff inside)

BUG!!!:
A bug in a previous version causes a DeleteFolder and a NewFolder after moving a
directory on the same filesystem*.

* Moving on the same filesystem technically means changing the address of the
file or of the top level directory (which might not work if there is a lock on
the file or if there are locks inside the directory).
