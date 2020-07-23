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
    date time
    sourcedir sourcefile source dir file path
    destdir destfile destination
    operation isFsPluginOp
    success error skipped
    user encoding
);

###############################################################################
=pod

---+++ traverse($file, %opts)
   * =$file= - path to log file.
   * =$opts{visitEntry}= - traversal is stopped if this sub returns a true value.
     Subroutine arguments:
      * =$entry= - =RJK::TotalCmd::Log::Entry= object.
   * =$opts{visitFailed}= - Optional. Traversal is stopped if this sub returns a true value.
     Subroutine arguments:
      * =$line= - the corrupt line.
   * throws RJK::TotalCmd::Log::Exception
   * throws RJK::TotalCmd::Log::CorruptLineException, unless =$visitFailed= is defined.

=cut
###############################################################################

sub traverse {
    my ($self, %opts) = @_;

    open my $fh, '<', $opts{file}
        or throw RJK::TotalCmd::Log::Exception("$!");

    $opts{visitEntry} && ref $opts{visitEntry} && ref $opts{visitEntry} eq "CODE"
        or throw RJK::TotalCmd::Log::Exception("No callback");

    if ($opts{visitFailed}) {
        ref $opts{visitFailed} && ref $opts{visitFailed} eq "CODE"
            or throw RJK::TotalCmd::Log::Exception("Invalid corrupt line callback");
    } else {
        $opts{visitFailed} = sub {
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
        my $line = $_;

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
            last if $opts{visitFailed}->($line);
            next;
        }

        # parse operation
        # Success:  [op]: [params]
        # Error:    [op](Error: [error]): [params]
        # Skip:     [op](Skipped): [params]
        # Startup:  Program start ([user]) [encoding]
        # Shutdown: Program shutdown ([user])

        # file system plugin operation
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
        } elsif (/^Program start \((.+)\)$/) {
            $entry->{operation} = "Startup";
            $entry->{user} = $1;
        } elsif (/^Program start \((.+)\) (.+)$/) {
            $entry->{operation} = "Startup";
            $entry->{user} = $1;
            $entry->{encoding} = $2;
        } elsif (/^Program shutdown \((.+)\)$/) {
            $entry->{operation} = "Shutdown";
            $entry->{user} = $1;
        } else {
            last if $opts{visitFailed}->($line);
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
        } elsif (/^((.+)\\(.+))$/) {
            $entry->{source} = $1;
            $entry->{sourcedir} = $2;
            $entry->{sourcefile} = $3;
        } else {
            $entry->{source} = $_;
        }

        # aliases
        if ($entry->{sourcedir}) {
            $entry->{path} = $entry->{source};
            $entry->{dir} = $entry->{sourcedir};
            $entry->{file} = $entry->{sourcefile};
        }

        local $_ = $entry;
        last if $opts{visitEntry}->($entry);
    }
    close $fh;
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
[operation] := Move | Copy | Delete |
               CreateFile | NewFolder | DeleteFolder |
               Pack | Unpack | Shortcut
[error] :=  Aborted | Read error | Write error | Failed | Not found
            Invalid name | Identical | CRC error | Archive bad

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
