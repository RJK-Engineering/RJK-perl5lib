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
    $self->{controller} = shift;
    $self->{opts} = $self->{controller}{opts};
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

    $self->{monitorList} = [
        $self->{monitors}{IniMonitor} = new RJK::Media::MPC::IniMonitor(
            file => $self->{opts}{mpcIni}
        ),
        $self->{monitors}{SnapshotMonitor} = new RJK::Media::MPC::SnapshotMonitor(
            snapshotDir => $self->{opts}{snapshotDir},
            unlinkSnapshots => 1
        ),
        $self->{monitors}{WebIFMonitor} = new RJK::Media::MPC::WebIFMonitor(
            port => $self->{opts}{port},
            url => $self->{opts}{url},
            requestAgent => $self->{opts}{requestAgent},
            requestTimeout => $self->{opts}{requestTimeout},
        ),
    ];

    foreach (@{$self->{monitorList}}) {
        $_->init();
        $_->{name} = (/::(\w+)=/)[0];
    }
}

sub poll {
    $_->poll() for @{$_[0]{monitorList}};
}

###############################################################################

sub getObserver {
    $_[0]{observers}{$_[1]}
}

sub addObserver {
    my ($self, $name, $mon) = @_;

    my $class = "RJK::Media::MPC::Observers::$name";
    if (! eval ("require $class")) {
        my $err = $! || (split /\n/, $@)[0];
        print "WARN Invalid Observer: $name ($err)\n";
        return;
    }

    $self->{observers}{$name} = $class->new($name, $self->{controller});
    my @mons = ref $mon ? @$mon : $mon ? ($mon) : keys %{$self->{monitors}};
    foreach (@mons) {
        $self->{observerRegistry}{$_}{$name} = $self->{observers}{$name};
    }
}

sub enableObserver {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        print "Enable: $name => $mon\n";
        if ($self->{monitors}{$mon}->hasObserver($observer)) {
            print "Observer already enabled: $mon => $name\n";
        } else {
            $self->{monitors}{$mon}->addObserver($observer);
        }
    });
}

sub disableObserver {
    my ($self, $name, $mon) = @_;
    $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        print "Disable: $mon => $name\n";
        if (! $self->{monitors}{$mon}->removeObserver($observer)) {
            print "Observer already disabled: $mon => $name\n";
        }
    });
}

sub observerSwitch {
    my ($self, $name, $mon) = @_;
    return $self->getObservers($name, $mon, sub {
        my ($name, $mon, $observer) = @_;
        if ($self->{monitors}{$mon}->hasObserver($observer)) {
            print "Disable: $mon => $name\n";
            $self->{monitors}{$mon}->removeObserver($observer);
            return 0;
        } else {
            print "Enable: $mon => $name\n";
            $self->{monitors}{$mon}->addObserver($observer);
            return 1;
        }
    });
}

sub getObservers {
    my ($self, $name, $mon, $callback) = @_;
    my $retval;

    if ($mon) {
        if ($self->{monitors}{$mon}) {
            if (my $observer = $self->{observerRegistry}{$mon}{$name}) {
                $retval = $callback->($name, $mon, $observer);
            } else {
                print "WARN Invalid Observer: $name\n";
            }
        } else {
            print "WARN Invalid Monitor: $mon\n";
        }
    } else {
        my $observer;
        foreach $mon (keys %{$self->{monitors}}) {
            if ($observer = $self->{observerRegistry}{$mon}{$name}) {
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
    return $self->{monitors}{WebIFMonitor}->getStatus();
}

sub checkDir {
    my ($self, $dir) = @_;
    print "Created $dir\n" if RJK::File::Path::Util::checkdir($dir) && $self->{opts}{verbose};
}

1;
