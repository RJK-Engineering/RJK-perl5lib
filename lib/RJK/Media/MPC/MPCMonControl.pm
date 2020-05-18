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
        escape => sub { $self->quit },
        tab => sub { $self->{mpcMon}->settings->list },
        l => sub { $self->{mpcMon}->settings->list },
        enter => sub { $self->listObservers },
        #~ '?' => help,
        1 => sub { $self->status },
        q => sub { $self->quit },
        s => sub { $self->{mpcMon}->observerSwitch("CopySnapshotToMediaFileDir") },
        u => sub { $self->{mpcMon}->settings->undo },
        d => sub { $self->utils->category->delete },
        m => sub { $self->utils->category->move },
    };

    print "\n";
    $self->status();
}

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

    while (1) {
        $self->{mpcMon}->poll;
        $self->handleInput;
        $self->{mpcMon}->settings->save;
    } continue {
        sleep $self->{opts}{pollingInterval};
    }
}

sub stop {
    my $self = shift;
    $self->{mpcMon}->finish if $self->{mpcMon};
}

###############################################################################

sub addObservers {
    my $self = shift;
    $self->{mpcMon}->addObserver('LogEvents');
    $self->{mpcMon}->addObserver('CopySnapshotToMediaFileDir', 'SnapshotMonitor');
    #~ $self->{mpcMon}->addObserver('Bookmark', 'SnapshotMonitor');
    #~ $self->{mpcMon}->addObserver('Favorites', 'IniMonitor');
    $self->{mpcMon}->addObserver('Categorize', 'SnapshotMonitor');
    $self->{mpcMon}->addObserver('Positions', 'IniMonitor');
    $self->{mpcMon}->addObserver('IniDiff', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogRecentFiles', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogFilePosition', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogPlayingStats', 'WebIfMonitor');
    $self->{mpcMon}->addObserver('LogRecentPlaylists', 'MpcplMonitor');

    #~ $self->{mpcMon}->enableObserver('LogEvents');
    $self->{mpcMon}->enableObserver('Categorize');
}

sub listObservers {
    my $self = shift;
    foreach my $observable (values %{$self->{mpcMon}{observables}}) {
        foreach my $observer (@{$observable->{observers}}) {
            print "Observer: $observer->{name} => $observable->{name}\n";
        }
    }
}

###############################################################################

sub handleInput {
    my $self = shift;
    while ($self->{console}->getEvents) {
        my @event = $self->{console}->input;
        next if !@event or $event[0] != 1 or !$event[1];
        if ($event[5]) {                                    # ASCII
            if ($event[5] == 13) {                          # Enter
                $self->{actions}{'enter'}();
                next;
            }
            if ($event[5] == 9) {                           # Tab
                $self->{actions}{'tab'}();
                next;
            }
            $self->{actions}{escape}() if $event[5] == 27;
            my $key = chr $event[5];
            if ($self->{actions}{$key}) {
                $self->{actions}{$key}();
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

    $self->listObservers;

    print "Categories: @{$self->{opts}{categories}}\n";

    if (my $status = $self->utils->getPlayerStatus) {
        print "Open: $status->{filepath}\n";
    } else {
        print "No MPC status\n";
    }
    print "\n";
}

1;
