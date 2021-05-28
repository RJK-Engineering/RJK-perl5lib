use strict;
use warnings;

use Data::Dump;
use RJK::TotalCmd::Log;
use RJK::TotalCmd::Log::Entry;

my $file = 'c:\data\log\totalcmd\totalcmd.log';

my %stats;

RJK::TotalCmd::Log->traverse(
    file => $file,
    visitEntry => sub {
        my $entry = shift;
        opStats($entry);
        return 1;
    },
    visitFailed => sub {
        my $line = shift;
        print "Visit Failed: \"$line\"\n";
        return 1;
    },
);

print "\n";
dd \%stats;

sub opStats {
    my $entry = shift;

    if ($entry->success) {
        $stats{_status}{success}++;
    } elsif ($entry->error) {
        $stats{_status}{error}++;
    } elsif ($entry->skipped) {
        $stats{_status}{skipped}++;
    }

    my $found = 0;
    foreach (@RJK::TotalCmd::Log::operations) {
        next if $entry->operation ne $_;
        $stats{$_}++;
        $found = 1;
        last;
    }
    if (! $found) {
        $stats{_unknown}++;
        print "Unknown operation:\n";
        dd $entry;
    }

    $stats{_fsPluginOp}++ if $entry->isFsPluginOp;

    return if ! $entry->error;

    $found = 0;
    foreach (@RJK::TotalCmd::Log::errors) {
        next if $entry->error ne $_;
        $stats{_errors}{$_}++;
        $found = 1;
        last;
    }
    if (! $found) {
        $stats{_unknownError}++;
        print "Unknown error:\n";
        dd $entry;
    }
}
