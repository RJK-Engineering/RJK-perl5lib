use strict;
use warnings;

use Data::Dump;
use RJK::TotalCmd::Log;

my $file = 'c:\data\log\totalcmd\totalcmd.log';

my %stats = (
    success => 0,
    error => 0,
    skipped => 0,
    startup => 0,
    shutdown => 0,

    move => 0,
    copy => 0,
    delete => 0,
    createfile => 0,
    newfolder => 0,
    deletefolder => 0,
    pack => 0,
    unpack => 0,
    shortcut => 0,
    unknown => 0,

    readerror => 0,
    writeerror => 0,
    failed => 0,
    notfound => 0,
    invalidname => 0,
    identical => 0,
    crcerror => 0,
    archivebad => 0,
    unknownError => 0,

    fsPluginOp => 0,
);

RJK::TotalCmd::Log->traverse(
    file => $file,
    visitEntry => sub {
        my $entry = shift;
        opStats($entry);
        return 0;
    },
    visitFailed => sub {
        my $line = shift;
        print "Visit Failed: \"$line\"\n";
        return 0;
    },
);

print "\n";
print "$stats{success} success\n";
print "$stats{error} error\n";
print "$stats{skipped} skipped\n";
print "$stats{startup} startup\n";
print "$stats{shutdown} shutdown\n";
print "\n";
print "$stats{move} move\n";
print "$stats{copy} copy\n";
print "$stats{delete} delete\n";
print "$stats{createfile} createfile\n";
print "$stats{newfolder} newfolder\n";
print "$stats{deletefolder} deletefolder\n";
print "$stats{pack} pack\n";
print "$stats{unpack} unpack\n";
print "$stats{shortcut} shortcut\n";
print "$stats{unknown} unknown\n";
print "\n";
print "$stats{aborted} aborted\n";
print "$stats{readerror} readerror\n";
print "$stats{writeerror} writeerror\n";
print "$stats{failed} failed\n";
print "$stats{notfound} notfound\n";
print "$stats{invalidname} invalidname\n";
print "$stats{identical} identical\n";
print "$stats{crcerror} crcerror\n";
print "$stats{archivebad} archivebad\n";
print "$stats{unknownError} unknownError\n";

sub opStats {
    my $entry = shift;

    if ($entry->success) {
        $stats{success}++;
    } elsif ($entry->error) {
        $stats{error}++;
    } elsif ($entry->skipped) {
        $stats{skipped}++;
    }

    if ($entry->operation eq 'Move') {
        $stats{move}++;
    } elsif ($entry->operation eq 'Copy') {
        $stats{copy}++;
    } elsif ($entry->operation eq 'Delete') {
        $stats{delete}++;
    } elsif ($entry->operation eq 'CreateFile') {
        $stats{createfile}++;
    } elsif ($entry->operation eq 'NewFolder') {
        $stats{newfolder}++;
    } elsif ($entry->operation eq 'DeleteFolder') {
        $stats{deletefolder}++;
    } elsif ($entry->operation eq 'Pack') {
        $stats{pack}++;
    } elsif ($entry->operation eq 'Unpack') {
        $stats{unpack}++;
    } elsif ($entry->operation eq 'Shortcut') {
        $stats{shortcut}++;
    } elsif ($entry->operation eq 'Startup') {
        $stats{startup}++;
        print $entry->getOpMsg, "\n";
    } elsif ($entry->operation eq 'Shutdown') {
        $stats{shutdown}++;
        print $entry->getOpMsg, "\n";
    } else {
        $stats{unknown}++;
        print "Unknown operation:\n";
        dd $entry;
    }

    $stats{fsPluginOp}++ if $entry->isFsPluginOp;

    return if ! $entry->error;

    if ($entry->error eq 'Aborted') {
        $stats{aborted}++;
    } elsif ($entry->error eq 'Read error') {
        $stats{readerror}++;
    } elsif ($entry->error eq 'Write error') {
        $stats{writeerror}++;
    } elsif ($entry->error eq 'Failed') {
        $stats{failed}++;
    } elsif ($entry->error eq 'Not found') {
        $stats{notfound}++;
    } elsif ($entry->error eq 'Invalid name') {
        $stats{invalidname}++;
    } elsif ($entry->error eq 'Identical') {
        $stats{identical}++;
    } elsif ($entry->error eq 'CRC error') {
        $stats{crcerror}++;
    } elsif ($entry->error eq 'Archive bad') {
        $stats{archivebad}++;
    } else {
        $stats{unknownError}++;
        print "Unknown error:\n";
        dd $entry;
    }
}
