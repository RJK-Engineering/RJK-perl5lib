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
    $self->{mpcMon}->addObserver('Bookmark', 'SnapshotMonitor');
    $self->{mpcMon}->addObserver('Favorites', 'IniMonitor');
    $self->{mpcMon}->addObserver('Positions', 'IniMonitor');
    #~ $self->{mpcMon}->addObserver('CopySnapshotToMediaFileDir', 'SnapshotMonitor');
    $self->{mpcMon}->addObserver('LogRecentFiles', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogFilePosition', 'IniMonitor');
    $self->{mpcMon}->addObserver('LogPlayingStats', 'WebIfMonitor');
    $self->{mpcMon}->addObserver('LogRecentPlaylists', 'MpcplMonitor');
    $self->{mpcMon}->addObserver('LogEvents');
    $self->{mpcMon}->addObserver('Categorize', 'SnapshotMonitor');

    foreach my $observable (values %{$self->{mpcMon}{observables}}) {
        foreach my $observer (@{$observable->{observers}}) {
            print "$observable->{name} => $observer->{name}\n";
        }
    }
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

    $self->status;

    while (1) {
        $self->{mpcMon}->poll;
        $self->handleInput;
    } continue {
        sleep $self->{opts}{pollingInterval};
    }
}

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

sub stop {
    my $self = shift;
    $self->{mpcMon}->finish if $self->{mpcMon};
}

###############################################################################

sub quit {
    my $self = shift;
    print "Bye\n" unless $self->{opts}{quiet};
    exit;
}

sub autoCompleteMode {
    my $self = shift;
    if ($self->{opts}{completeCommand}) {
        $self->switch("Auto complete");
    } else {
        print "No complete command configured\n";
    }
}

sub bookmarkMode {
    my $self = shift;
    $self->switch("Bookmark mode");
}

sub setCategory {
    my $self = shift;
    print "Category: ";
    my $cat = ReadLine();
    return if !$cat;
    if ($self->{prevPath}) {
        $self->{status}{$self->{prevPath}}{cat} = $cat;
    } else {
        print "No history\n";
        Confirm("Apply to all?") || return;
        foreach (keys %{$self->{status}}) {
            $self->{status}{$_}{cat} = $cat;
        }
    }
    $self->writeStatus();
}

sub completeCategory {
    my $self = shift;
    print "Category: ";
    my $cat = ReadLine();
    return if !$cat;

    if (chdir $cat) {
        $self->complete();
        #~ chdir $self->{cwd};
    } else {
        print "$!: $cat\n";
    }
}

sub deleteFiles {
    my $self = shift;
    Confirm("Delete?") || return;

    my %stats = (
        deleteCount => 0,
        deleteSize => 0,
        deleteFailCount => 0,
    );
    while (my ($file, $data) = each %{$self->{status}}) {
        next unless $data->{cat} && $data->{cat} eq "delete";
        my $fsize = -s $file;

        $self->log("Delete $file");
        try {
            $self->unlinkFile($file);
            delete $self->{status}{$file};

            print "Deleted $file\n" if $self->{opts}{verbose};
            $stats{deleteCount}++;
            $stats{deleteSize} += $fsize;

            $self->deleteSnapshots($data->{snapshots});
        } catch {
            print "$_[0]\n";
            $stats{deleteFailCount}++;
        };
    }

    unless ($self->{opts}{quiet}) {
        printf "%u (%s) deleted",
            $stats{deleteCount},
            Number::Bytes::Human::format_bytes($stats{deleteSize});

        if ($stats{deleteFailCount}) {
            print ", $stats{deleteFailCount} failed";
        }
        print "\n";
    }

    $self->writeStatus();
}

sub list {
    my $self = shift;
    my $c = 0;
    my $list = "";
    foreach my $path (sort keys %{$self->{status}}) {
        #~ next unless $self->{status}{$path}{dir};
        my $ss = $self->{status}{$path}{snapshots} // [];
        $self->{status}{$path}{cat} //= $self->getCategory($ss);
        printf "%-10.10s %s\n", $self->{status}{$path}{cat}, $path;
        $list .= "$path\n";
        $c++;
    }
    $self->{clipboard}->Set($list);
    printf "%d file%s\n", $c, $c == 1 ? "" : "s" unless $self->{opts}{quiet};
}

sub openMode {
    my $self = shift;
    $self->switch("Open mode");
}

sub switch {
    my ($self, $switch) = @_;
    if ($self->{opts}{$switch} = ! $self->{opts}{$switch}) {
        print "$switch enabled\n";
    } else {
        print "$switch disabled\n";
    }
    return $self->{opts}{$switch};
}

sub reset {
    my $self = shift;
    Confirm("Reset?") || return;
    %{$self->{status}} = ();
    $self->{prevPath} = undef;
    $self->writeStatus();
    print "Cleared data\n";
}

sub status {
    my $self = shift;
    print "Categories: @{$self->{opts}{categories}}\n";
    for ('Snapshot monitor','Auto complete','Open mode') {
        print "$_: ", $self->{opts}{$_} ? "on" : "off", "\n";
    }
    if (my $status = $self->{mpcMon}->getPlayerStatus) {
        return $status->{filepath};
        my $path = $self->getOpenFilePath();
        print "Open: $path\n";
    } else {
        print "No MPC status\n";
    }
    #~ print "Working directory: $self->{cwd}\n";
}

sub tag {
    my $self = shift;
    my $tags = ReadLine();
    my @tags = split /\s+/, $tags;
    #~ my $tf = TagFile()->new->add(@tags)->write;
}

sub undo {
    my $self = shift;
    if ($self->{prevPath}) {
        print "Undo $self->{prevPath}\n";
        # remove key from status hash
        delete $self->{status}{$self->{prevPath}};
        $self->writeStatus();
    } else {
        print "No history\n";
    }
}

###############################################################################

sub deleteSnapshots {
    my ($self, $snapshots) = @_;
    # purge snapshots
    foreach (@$snapshots) {
        my $file = "$self->{opts}{snapshotBinDir}\\$_->{filename}";
        try {
            $self->unlinkFile($file);
            print "Deleted $file\n" if $self->{opts}{verbose};
        } catch {
            print "$_[0]\n";
        };
    }
}

sub deleteSnapshot {
    my ($self, $snapshot) = @_;
    my $file = "$self->{opts}{snapshotDir}\\$snapshot->{filename}";
    if ($self->moveToDir($file, $self->{opts}{snapshotBinDir})) {
        print "Snapshot moved to bin\n" if $self->{opts}{verbose};
    } else {
        print "Error moving snapshot to bin\n";
    }
}

sub moveToCategory {
    my $self = shift;

    Confirm("Move files?") || return;

    my %dirs;
    my ($c, $e) = (0)x2;
    while (my ($file, $data) = each %{$self->{status}}) {
        next if $data->{cat} && $data->{cat} eq 'delete';

        my $dir = "$data->{dir}/$data->{cat}";
        if ($self->moveToDir($file, $dir)) {
            print "Move ok: $file -> $dir\n" if $self->{opts}{verbose};

            # remove key from status hash
            delete $self->{status}{$file};
            $self->log("Move $file $dir");

            # remember dir
            $dirs{$dir} = 1;

            $c++;

        } else {
            print "Move failed: $file -> $dir\n" if $self->{opts}{verbose};

            $e++;
        }
    }

    foreach (keys %dirs) {
        if (chdir $_) {
            $self->complete() if $self->{opts}{'Auto complete'};
        } else {
            print "$!: $_\n";
        }
    }

    #~ chdir $self->{cwd};

    unless ($self->{opts}{quiet}) {
        print "$c moved";
        if ($e) {
            print ", $e failed";
        }
        print "\n";
    }

    $self->writeStatus();
}

sub moveToDir {
    my ($self, $file, $dir) = @_;
    print "Move $file -> $dir\n" if $self->{opts}{verbose};
    $self->checkDir($dir);

    unless (File::Copy::move $file, $dir) {
        print "$!: $file -> $dir\n";
        return 0;
    }
    return 1;
}

sub complete {
    my $self = shift;
    if (!$self->{opts}{completeCommand}) {
        print "No complete command configured\n";
        return;
    }
    if (system "start", "cmd", "/c", $self->{opts}{completeCommand}) {
        print "Program execution failed\n";
    }
}

###############################################################################

sub getCategory {
    my ($self, $snapshots) = @_;
    if (@$snapshots <= @{$self->{opts}{categories}}) {
        return $self->{opts}{categories}[@$snapshots-1];
    } else {
        return scalar @$snapshots;
    }
}

sub log {
    my $self = shift;
    return unless defined $self->{opts}{logFile};
    my $text = shift || return;
    my @t = localtime();
    open my $fh, '>>', $self->{opts}{logFile} or die "$!: $self->{opts}{logFile}";
    printf $fh "%02u-%02u-%02u %02u:%02u:%02u %s\n",
        $t[3], $t[4]+1, $t[5]-100, $t[2], $t[1], $t[0], $text;
    close $fh;
}

sub writeStatus {
    my $self = shift;
    $self->{statusFile}->write if $self->{statusFile};
}

###############################################################################

sub openFile {
    my ($self, $file) = @_;
    if (system "cmd", "/c", "of -o \"$file\"") {
        print "Program execution failed\n";
    }
}

sub unlinkFile {
    my ($self, $file) = @_;
    unless (defined $file) {
        throw Exception("No file defined");
    }
    if (-e $file && ! -f $file) {
        throw Exception("Not a file: $file");
    }
    if (! unlink $file) {
        throw Exception("$!: $file");
    }
    return 1;
}

sub bell {
    print chr(7);
}

1;
