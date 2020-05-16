package RJK::Media::MPC::MPCMon;

use strict;
use warnings;

use Exception::Class('Exception');
use File::Path ();

use RJK::Media::MPC::IniMonitor;
use RJK::Media::MPC::SnapshotMonitor;
use RJK::Media::MPC::WebIFMonitor;

use RJK::Media::MPC::MPCMonUtils;

use RJK::Util::JSON;
use RJK::Util::LockFile;
use RJK::Win32::ProcessList;

sub new {
    my $self = bless {}, shift;
    $self->{utils} = new RJK::Media::MPC::MPCMonUtils($self);
    return $self;
}

sub init {
    my $self = shift;
    $self->{opts} = shift;

    my $lockFile = $self->{opts}{lockFile} || die "No lock file configured";
    my $lockFileDir = $lockFile =~ s/[\\\/]+[^\\\/]+$//r;
    $self->checkDir($lockFileDir);
    RJK::Util::LockFile::checkExistingLock($lockFile);
    RJK::Util::LockFile::createLock($lockFile);

    $self->checkDir($self->{opts}{snapshotBinDir});

    if ($self->{opts}{statusFile}) {
        $self->{statusFile} = new RJK::Util::JSON($self->{opts}{statusFile})->read;
        $self->{status} = $self->{statusFile}->data;
    }

    $self->setupMonitors();
}

sub finish {
    my $self = shift;
    RJK::Util::LockFile::removeLock($self->{opts}{lockFile});
}

sub setupMonitors {
    my $self = shift;

    $self->{monitors} = [
        $self->{observables}{IniMonitor} = new RJK::Media::MPC::IniMonitor(
            file => $self->{opts}{mpcIni}
        ),
        $self->{observables}{SnapshotMonitor} = new RJK::Media::MPC::SnapshotMonitor(
            snapshotDir => $self->{opts}{snapshotDir},
            unlinkSnapshots => 1
        ),
        $self->{observables}{WebIFMonitor} = new RJK::Media::MPC::WebIFMonitor(
            port => $self->{opts}{port},
            url => $self->{opts}{url},
            requestAgent => $self->{opts}{requestAgent},
            requestTimeout => $self->{opts}{requestTimeout},
        ),
    ];

    foreach my $mon (values %{$self->{observables}}) {
        $mon->init();
        $mon->{name} = ("$mon" =~ /::(\w+)=/)[0];
        $mon->{utils} = $self->{utils};
    }
}

sub addObserver {
    my ($self, $name, $mon) = @_;

    my $class = "RJK::Media::MPC::Observers::$name";
    if (! eval ("require $class")) {
        my $err = $! || (split /\n/, $@)[0];
        print "WARN Invalid Observer: $name ($err)\n";
        return;
    }

    my $observer = $class->new($name);
    my @mons = ref $mon ? @$mon : $mon ? ($mon) : keys %{$self->{observables}};

    foreach $mon (@mons) {
        $self->{observers}{$mon}{$name} = $observer;
        if ($self->{observables}{$mon}) {
            $self->{observables}{$mon}->addObserver($observer);
        } else {
            print "WARN Invalid monitor: $mon\n";
        }
    }
}

sub poll {
    $_->poll() for @{$_[0]{monitors}};
}

###############################################################################

sub nowPlaying {
    my $self = shift;
    return RJK::Win32::ProcessList::GetProcessList("mpc-hc64.exe");
}

sub getPlayerStatus {
    my $self = shift;
    return $self->{observables}{WebIFMonitor}->getStatus();
}

###############################################################################

sub enableObserver {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        print "Enable: $mon => $name\n";
        if ($self->{observables}{$mon}->hasObserver($observer)) {
            print "Observer already enabled: $mon => $name\n";
        } else {
            $self->{observables}{$mon}->addObserver($observer);
        }
    });
}

sub disableObserver {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        print "Disable: $mon => $name\n";
        if (! $self->{observables}{$mon}->removeObserver($observer)) {
            print "Observer already disabled: $mon => $name\n";
        }
    });
}

sub observerSwitch {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        if ($self->{observables}{$mon}->hasObserver($observer)) {
            print "Disabled $name for $mon\n";
            $self->{observables}{$mon}->removeObserver($observer);
        } else {
            print "Enabled $name for $mon\n";
            $self->{observables}{$mon}->addObserver($observer);
        }
    });
}

sub getObservers {
    my ($self, $name, $mon, $callback) = @_;

    if ($mon) {
        if ($self->{observables}{$mon}) {
            if (my $observer = $self->{observers}{$mon}{$name}) {
                $callback->($name, $mon, $observer);
            } else {
                print "WARN Invalid Observer: $name\n";
            }
        } else {
            print "WARN Invalid Monitor: $mon\n";
        }
    } else {
        my $found = 0;
        foreach $mon (keys %{$self->{observables}}) {
            if (my $observer = $self->{observers}{$mon}{$name}) {
                $callback->($name, $mon, $observer);
                $found = 1;
            }
        }
        if (! $found) {
            print "WARN Invalid Observer: $name\n";
        }
    }
}

###############################################################################

sub checkDir {
    my ($self, $dir) = @_;
    if (-e $dir) {
        unless (-d $dir) {
            throw Exception("Not a directory: $dir");
        }
        return 0;
    }
    unless (File::Path::make_path $dir) {
        throw Exception("$!: $dir");
    }
    print "Created $dir\n" if $self->{opts}{verbose};
    return 1;
}

1;
