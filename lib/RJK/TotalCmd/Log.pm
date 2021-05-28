###############################################################################
=begin TML

---+ package RJK::TotalCmd::Log

=cut
###############################################################################

package RJK::TotalCmd::Log;

use strict;
use warnings;

use Exceptions;
use FileException;
use LineParseException;

our @fields = qw(
    date time
    sourcedir sourcefile source
    targetdir targetfile target
    operation isFsPluginOp
    success error skipped
    user encoding
);

our @operations = qw(
    Move Copy Delete CreateFile NewFolder DeleteFolder
    Pack Unpack Shortcut Startup Shutdown
);

our @errors = (
    'Failed', 'Aborted', 'Not found', 'Identical', 'Read error',
    'Write error', 'Invalid name', 'Packer not found', 'Temp file error',
    'Delete failed', 'CRC error', 'No files', 'Too big', 'Too many files',
    'Bad parameter(s)', 'Archive bad', 'Not supported', 'Encrypted',
    'Module in use', 'File exists', 'Postponed'
);

###############################################################################
=pod

---++ Class methods

---+++ traverse($file, %opts)
   * =$file= - path to log file.
   * =$opts{visitEntry}= - traversal is stopped if this sub returns false.
     Subroutine arguments:
      * =$entry= - =RJK::TotalCmd::Log::Entry= object.
   * =$opts{visitFailed}= - Optional. Traversal is stopped if this sub returns false.
     Subroutine arguments:
      * =$line= - the corrupt line.
   * throws FileException
   * throws LineParseException, unless =$visitFailed= is defined.

=cut
###############################################################################

sub traverse {
    my ($self, %opts) = @_;

    open my $fh, '<', $opts{file}
        or throw FileException(error => "$!", file => $opts{file});

    $opts{visitFailed} //= sub {
        throw LineParseException(
            error => "Corrupt line: $_[0]",
            file => $opts{file},
            line => $_[0]
        );
    };

    my $bom;
    while (<$fh>) {
        $bom //= readUtf8Bom();
        next unless /\S/;
        chomp;

        my $line = $_;
        if (my $entry = &parseEntry) {
            local $_ = $entry;
            last if ! $opts{visitEntry}->($entry);
        } else {
            last if ! $opts{visitFailed}->($line);
        }
    }
    close $fh;
}

sub parseEntry {
    return if not s/^(\d\d-\d\d-\d\d\d\d) (\d\d:\d\d:\d\d): //;
    my $entry = {
        date => $1,
        time => $2
    };

    # parse operation
    # Success:  [op]: [params]
    # Error:    [op](Error: [error]): [params]
    # Skip:     [op](Skipped): [params]
    # Startup:  Program start ([user]) [encoding]
    # Shutdown: Program shutdown ([user])

    # File system plugin [op] starts with "FS:"
    if (s/^FS://) {
        $entry->{isFsPluginOp} = 1;
    }

    if (s/^(\w+): //) {
        $entry->{operation} = $1;
        $entry->{success} = 1;
    } elsif (s/^(\w+)\(Error: (.+)\): //) {
        $entry->{operation} = $1;
        $entry->{error} = $2;
    } elsif (s/^(\w+)\(Skipped\): //) {
        $entry->{operation} = $1;
        $entry->{skipped} = 1;
    } elsif (s/^Program start \((.+)\)//) {
        $entry->{operation} = "Startup";
        $entry->{user} = $1;
        if (/^ (.+)/) {
            $entry->{encoding} = $1;
        }
    } elsif (/^Program shutdown \((.+)\)$/) {
        $entry->{operation} = "Shutdown";
        $entry->{user} = $1;
    } else {
        return;
    }

    # parse params
    if (s/ -> ((.+)\\(.+))//) {
        $entry->{target} = $1;
        $entry->{targetdir} = $2;
        $entry->{targetfile} = $3;
    }
    if (/((.+)\\(.+))/) {
        $entry->{source} = $1;
        $entry->{sourcedir} = $2;
        $entry->{sourcefile} = $3;
    } else {
        $entry->{source} = $_;
    }

    return bless $entry, 'RJK::TotalCmd::Log::Entry';
}

sub readUtf8Bom {
    (s|^(\xEF\xBB\xBF)||)[0] // "";
}

1;

__END__

Log entry format: [date and time]: [entry]

[date and time] := [dd]-[mm]-[yyyy] [hh]:[mm]:[ss]

[entry] :=
Success:  [op]: [params]
Error:    [op](Error: [error]): [params]
Skip:     [op](Skipped): [params]
Startup:  Program start ([user]) [encoding]
Shutdown: Program shutdown ([user])

[op] := FS:[operation] | [operation]
[operation] :=
    Move | Copy | Delete | CreateFile | NewFolder | DeleteFolder |
    Pack | Unpack | Shortcut | Startup | Shutdown
[error] :=
    Failed | Aborted | Not found | Identical | Read error |
    Write error | Invalid name | Packer not found | Temp file error |
    Delete failed | CRC error | No files | Too big | Too many files |
    Bad parameter(s) | Archive bad | Not supported | Encrypted |
    Module in use | File exists | Postponed

params for operations:
[operation]              [params]
Move, Copy:              [filepath] -> [filepath] *1) File might be renamed
Move:                    [dirpath -> dirpath]     *2) Moving a directory on same filesystem
Delete, CreateFile:      [filepath]               *3) A Delete also occurs after a Move to a different filesystem
NewFolder, DeleteFolder: [dirpath]                *2) Also occurs when moving a directory to a different filesystem


NOTES

*1) A file rename is a Move or a Copy to a different filename.

*2) Moving a directory to a different filesystem is not a Move operation!:

NewFolder: T:\dir
(move stuff inside)
DeleteFolder: S:\dir

*3) Moving a file to a different filesystem results in a Delete after the Move:

Move: S:\file -> T:\file
Delete: S:\file

Explorer delete of a directory does strange things:

Delete: S:\dir
DeleteFolder: S:\dir

or

Delete(Skipped): S:\dir
(delete stuff inside)

NB!:
The quickest way of moving a file or directory on the same filesystem
is changing its address, which might not work if there is a lock on
the file or if there are locks inside the directory!

BUG!:
A bug in a previous version causes a DeleteFolder and a NewFolder after moving a
directory on the same filesystem.
