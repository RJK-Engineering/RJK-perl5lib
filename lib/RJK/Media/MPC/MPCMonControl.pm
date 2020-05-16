package RJK::Media::MPC::MPCMonControl;

use strict;
use warnings;

use File::Copy ();
use Number::Bytes::Human ();
use Try::Tiny;
use Win32::Clipboard;

use RJK::Interactive qw(Ask ReadLine Confirm);
RJK::Interactive::SetClass('Term::ReadKey');
use RJK::Media::MPC::MPCMon;
use RJK::Win32::Console;

sub new {
    my $self = bless {}, shift;
    $self->{opts} = shift;
    return $self;
}

sub utils {
    $_[0]{mpcMon}{utils};
}

sub init {
    my $self = shift;

    $self->{mpcMon} = new RJK::Media::MPC::MPCMon();
    $self->{mpcMon}->init($self->{opts});

    return if $self->{opts}{status};

    $self->addObservers();

    $self->{console} = new RJK::Win32::Console();
    $self->{clipboard} = Win32::Clipboard();
    $self->{actions} = {
        '?' => \&Help,
        1 => sub { $self->status },
        a => sub { $self->autoCompleteMode },
        b => sub { $self->bookmarkMode },
        c => sub { $self->setCategory },
        C => sub { $self->completeCategory },
        d => sub { $self->deleteFiles },
        h => \&Help,
        l => sub { $self->list },
        m => sub { $self->moveToCategory },
        o => sub { $self->openFile },
        O => sub { $self->openMode },
        p => sub { $self->{mpcMon}->pause },
        q => sub { $self->quit },
        r => sub { $self->reset },
        s => sub { $self->{mpcMon}->observerSwitch("CopySnapshotToMediaFileDir") },
        t => sub { $self->tag },
        u => sub { $self->undo },
    };
}

sub addObservers {
    my $self = shift;
    $self->{mpcMon}->addObserver('LogEvents');
    #~ $self->{mpcMon}->addObserver('CopySnapshotToMediaFileDir', 'SnapshotMonitor');
    #~ $self->{mpcMon}->addObserver('Bookmark', 'SnapshotMonitor');
    #~ $self->{mpcMon}->addObserver('Favorites', 'IniMonitor');
    $self->{mpcMon}->addObserver('Categorize', 'SnapshotMonitor');
    $self->{mpcMon}->addObserver('Positions', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogRecentFiles', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogFilePosition', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogPlayingStats', 'WebIfMonitor');
    $self->{mpcMon}->addObserver('LogRecentPlaylists', 'MpcplMonitor');

    foreach my $observable (values %{$self->{mpcMon}{observables}}) {
        foreach my $observer (@{$observable->{observers}}) {
            print "$observable->{name} => $observer->{name}\n";
        }
    }
}

###############################################################################

sub start {
    my $self = shift;

    if ($self->{opts}{status}) {
        $self->status;
        exit;
    }

    $self->{console}->title($self->{opts}{windowTitle});
    if ($self->{opts}{verbose}) {
        printf "Polling every %u second%s\n",
            $self->{opts}{pollingInterval},
            $self->{opts}{pollingInterval} == 1 ? "" : "s";
    }

    $self->status;

    while (1) {
        $self->{mpcMon}->poll;
        $self->handleInput;
    } continue {
        sleep $self->{opts}{pollingInterval};
    }
}

sub stop {
    my $self = shift;
    $self->{mpcMon}->finish if $self->{mpcMon};
}

###############################################################################

sub handleInput {
    my $self = shift;
    while ($self->{console}->getEvents) {
        my @event = $self->{console}->input;
        next if !@event or $event[0] != 1 or !$event[1];
        print "@event\n" if $self->{opts}{debug};
        if ($event[5]) {                                    # ASCII
            $self->quit() if $event[5] == 27;               # Esc
            my $key = chr $event[5];
            if ($self->{actions}{$key}) {
                $self->{actions}{$key}->();
            } elsif ($key =~ /^\w$/) {
                print "Not an action key: $key\n" unless $self->{opts}{quiet};
            }
        } elsif ($event[3] == 112) {                        # F1
            $self->help();
        }
    }
    $self->{console}->flush;                                # empty buffer
}

sub quit {
    my $self = shift;
    print "Bye\n" unless $self->{opts}{quiet};
    exit;
}

sub status {
    my $self = shift;
    print "Categories: @{$self->{opts}{categories}}\n";
    for ('Snapshot monitor','Auto complete','Open mode') {
        print "$_: ", $self->{opts}{$_} ? "on" : "off", "\n";
    }
    if (my $status = $self->utils->getPlayerStatus) {
        return $status->{filepath};
        my $path = $self->getOpenFilePath();
        print "Open: $path\n";
    } else {
        print "No MPC status\n";
    }
}

1;
