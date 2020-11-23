package RJK::Media::MPC::MPCMon;

use strict;
use warnings;

use RJK::File::Path::Util;
use RJK::Media::MPC::IniMonitor;
use RJK::Media::MPC::SnapshotMonitor;
use RJK::Media::MPC::WebIFMonitor;
use RJK::Util::LockFile;

sub new {
    my $self = bless {}, shift;
    $self->{opts} = shift;
    return $self;
}

sub init {
    my $self = shift;

    my $lockFile = $self->{opts}{lockFile} || die "No lock file configured";
    my $lockFileDir = $lockFile =~ s/[\\\/]+[^\\\/]+$//r;
    $self->checkDir($lockFileDir);
    RJK::Util::LockFile::checkExistingLock($lockFile);
    RJK::Util::LockFile::createLock($lockFile);

    $self->checkDir($self->{opts}{snapshotBinDir});

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

    foreach (@{$self->{monitors}}) {
        $_->init();
        $_->{name} = (/::(\w+)=/)[0];
        $_->{utils} = $self->{utils};
    }
}

sub poll {
    $_->poll() for @{$_[0]{monitors}};
}

###############################################################################

sub addObserver {
    my ($self, $name, $mon) = @_;

    my $class = "RJK::Media::MPC::Observers::$name";
    if (! eval ("require $class")) {
        my $err = $! || (split /\n/, $@)[0];
        print "WARN Invalid Observer: $name ($err)\n";
        return;
    }

    my $observer = $class->new($name, $self->{utils});
    my @mons = ref $mon ? @$mon : $mon ? ($mon) : keys %{$self->{observables}};

    foreach (@mons) {
        $self->{observers}{$_}{$name} = $observer;
    }
}

sub enableObserver {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        print "Enable: $name => $mon\n";
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
    return $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        if ($self->{observables}{$mon}->hasObserver($observer)) {
            print "Disable: $mon => $name\n";
            $self->{observables}{$mon}->removeObserver($observer);
            return 0;
        } else {
            print "Enable: $mon => $name\n";
            $self->{observables}{$mon}->addObserver($observer);
            return 1;
        }
    });
}

sub getObservers {
    my ($self, $name, $mon, $callback) = @_;
    my $retval;

    if ($mon) {
        if ($self->{observables}{$mon}) {
            if (my $observer = $self->{observers}{$mon}{$name}) {
                $retval = $callback->($name, $mon, $observer);
            } else {
                print "WARN Invalid Observer: $name\n";
            }
        } else {
            print "WARN Invalid Monitor: $mon\n";
        }
    } else {
        my $observer;
        foreach $mon (keys %{$self->{observables}}) {
            if ($observer = $self->{observers}{$mon}{$name}) {
                $retval = $callback->($name, $mon, $observer);
                last;
            }
        }
        if (! $observer) {
            print "WARN Invalid Observer: $name\n";
        }
    }
    return $retval;
}

###############################################################################

sub getStatus {
    my $self = shift;
    return $self->{observables}{WebIFMonitor}->getStatus();
}

sub checkDir {
    my ($self, $dir) = @_;
    print "Created $dir\n" if RJK::File::Path::Util::checkdir($dir) && $self->{opts}{verbose};
}

1;
