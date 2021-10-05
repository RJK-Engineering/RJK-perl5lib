package RJK::TotalCmd::LogMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use File::Copy;
use RJK::Event;
use RJK::Stat;
use RJK::TotalCmd::Log;
use RJK::Util::FileMonitor;

sub new {
    my $self = bless {}, shift;
    $self->{opts} = shift;
    $self->{file} = $self->{opts}{totalcmdLogFile};
    return $self;
}

sub init {
    my $self = shift;
    $self->{fileMon} = new RJK::Util::FileMonitor;
    $self->{fileMon}->setFile($self->{file});
    $self->{fileMon}->addObserver(sub {
        my $event = shift;
        $event->type eq 'FileChangeEvent' or return;
        $self->{lastChange} = time;
        $self->{lastStat} = $event->{payload}{stat};
    });
    $self->{prevSize} = -s $self->{file};
}

sub doPoll {
    my $self = shift;
    $self->{fileMon}->poll();
    return
        if not $self->{lastChange}
        or time - $self->{lastChange} < $self->{opts}{timeoutAfterLogChange};

    $self->{lastChange} = undef;
    $self->visitNewEntries();
}

sub visitNewEntries {
    my $self = shift;
    my $tempFile = "$self->{file}~";
    copy $self->{file}, $tempFile or die "$!: $self->{file} -> $tempFile";

    open my $fh, '<', $tempFile or die "$!: $tempFile";

    if ($self->{prevSize} < $self->{lastStat}->size) {
        seek $fh, $self->{prevSize}, 0 or die "$!: $tempFile";
    } else {
        chomp ($_ = readline $fh);
        RJK::TotalCmd::Log->readUtf8Bom;
        $self->visitEntry(RJK::TotalCmd::Log->parseEntry);
    }

    while (<$fh>) {
        chomp;
        $self->visitEntry(RJK::TotalCmd::Log->parseEntry);
    }
    close $fh;

    $self->{prevSize} = $self->{lastStat}->size;
}

sub visitEntry {
    my ($self, $entry) = @_;
    if ($entry) {
        $self->notifyObservers("LogEntryEvent", payload => $entry);
    } else {
        $self->notifyObservers("CorruptLogEntryEvent", payload => $_);
    }
}

1;
