package RJK::Util::YoutubeDl;

use strict;
use warnings;
use threads;
use threads::shared;
use Thread::Queue;

use Try::Tiny;
use LWP::UserAgent;
use Time::HiRes qw(usleep);

use Exception::Class (
    'Exception',
    'Media::YoutubeDl::Exception' =>
        { isa => 'Exception' },
);

use Class::AccessorMaker {
    executable => 'youtube-dl',
    timeout => 0,
    downloadDir => "",
}, 'new_init';

sub init {
    my $self = shift;
    my $p = "136/135/134"; # h264 profile 'Main'
    $self->{format} = "$p/vl-720/bestvideo";
    $self->{agent} = 'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:37.0) Gecko/20100101 Firefox/37.0';
    $self->{httpTimeout} = 20;

    # Create agent object
    $self->{userAgent} = LWP::UserAgent->new;
    $self->{userAgent}->agent($self->{agent}) if $self->{agent};
    $self->{userAgent}->timeout($self->{httpTimeout});

    # Variables used in download thread
    # FIXME: this is not needed because only one thread!
    share $self->{exitstatus};
    share $self->{pid};
    $self->{downloadDir} //= '.';
    share $self->{downloadDir};

    # Command queue
    $self->{commandQueue} = Thread::Queue->new();
    # Setup download thread
    $self->{downloadThread} = threads->create(
        sub {
            # Thread will loop until no more work
            while (defined(my $cmd = $self->{commandQueue}->dequeue)) {
                $self->{exitstatus} = -1;
                if ($self->{pid} = open (my $fh, '|-', @$cmd)) {
                    chdir $self->{downloadDir};
                    # Closing any piped filehandle causes the parent process to wait for
                    # the child to finish, and returns the status value in $?.
                    close $fh;
                    $self->{exitstatus} = $?;
                } else {
                    throw Media::YoutubeDl::Exception("$!");
                }
                $self->{pid} = undef;
            }
        }
    );
    $self->{downloadThread}->detach;
}

sub stop {
    my ($self) = @_;
    if ($self->{pid}) {
        kill -9, $self->{pid};
        $self->{stopped} = 1;
        $self->{pid} = undef;
    } elsif (defined $self->{pid}) {
        while (! $self->{pid}) {
            print "Waiting for pid...\n";
            sleep 1;
        }
    } else {
        warn "No download has been started";
    }
}

sub setDownloadDir {
    my ($self, $dir) = @_;
    $self->{downloadDir} = $dir;
}

sub download {
    my ($self, %opts) = @_;
    $opts{completed} ||= sub {};
    $opts{stopped} ||= sub {};
    $self->{stopped} = 0;

    my @format = "-f";
    if ($opts{format}) {
        push @format, $opts{format};
    } elsif ($opts{noAudio}) {
        push @format, $self->{format};
    } else {
        my $p = "136+140/135+140/134+140"; # h264 profile 'Main' + 128k aac
        #~ my $p = "134+140";
        push @format, "$p/vl-720/best";
    }
    #~ @format = ("-f", "134+140/vl-720/best");

    my @opts = @{$opts{opts}} if $opts{opts};
    my @cmd = ($self->executable, "-w", @format, @opts, $opts{url});
    #~ print "@cmd\n";

    # Send cmd to download thread
    $self->{commandQueue}->enqueue(\@cmd);
    $self->{pid} = 0; # define pid to indicate a download has been started

    # Wait for download thread to finish
    my $pollingFrequency = 10; # times per second
    my $usleep = 1_000_000 / $pollingFrequency;
    my $counter = ($opts{timeout} || $self->timeout) * $pollingFrequency;
    while (defined $self->{pid}) {
        usleep $usleep;
        unless (--$counter) { # stop will only be called once
            $self->stop();
        }
    }

    if ($self->{stopped}) {
        if ($counter < 1) {
            $opts{stopped}->('onTimeout');
        } else {
            $opts{stopped}->();
        }
    } elsif ($self->{exitstatus} != 0) {
        throw Media::YoutubeDl::Exception(
            "$self->{executable} exit status $self->{exitstatus}"
        );
    } else {
        $opts{completed}->();
    }
}

sub parseIds {
    my ($self, $html, $baseUrl) = @_;

    my %ids;
    while ($html =~ s/\Q$baseUrl\E(.+?)[&"]//) {
        unless ($ids{$1}) {
            print "$1\n";
            $ids{$1} = 1;
        }
    }
    return \%ids;
}

sub getHtml {
    my ($self, $url) = @_;

    my $req = HTTP::Request->new(GET => $url);
    my $res = $self->{userAgent}->request($req);

    # Check the outcome of the response
    my $html;
    if ($res->is_success) {
        $html = $res->content;
    } else {
        throw Media::YoutubeDl::Exception($res->status_line);
    }
    return $html;
}

sub getIds {
    my ($self, $url) = @_;
    my %ids;

    my $video;
    my $addId = sub {
        $video || return;
        print "$video->{website} $video->{id}\n";
        $ids{$video->{id}} = 1;
    };

    if (open my $fh, '-|', $self->executable, '-i', -s => $url) {
        while (<$fh>) {
            if (/^\[(.+)\] (.+): Downloading video/) {
                $video = { website => $1, id => $2 };
                $addId->();
                $video = undef;
            } elsif (/^\[(.+)\] (.+): Downloading webpage/) {
                $addId->(); # when no "Downloading video" after "Downloading webpage"
                $video = { website => $1, id => $2 };
            }
        }
        close $fh;
        $addId->(); # when no "Downloading video" after "Downloading webpage"
    } else {
        throw Media::YoutubeDl::Exception("$!");
    }

    #~ if ($? != 0) {
        #~ %ids = ();
        #~ throw Media::YoutubeDl::Exception("Exit status $?");
    #~ }
    return \%ids;
}

sub getFormats {
    my ($self, $url) = @_;
    my %formats;

    if (open my $fh, '-|', $self->executable, -F => $url) {
        my $listStart;
        while (<$fh>) {
            if ($listStart) {
                if (my ($code, $ext, $note) = /^(\S+)\s+(\S+)\s+(.*)/) {
                    $formats{$code} = {
                        code => $code,
                        extension => $ext,
                        note => $note,
                    };
                }
            } elsif (/^format/) {
                $listStart = 1;
            }
        }
        close $fh;
    }

    if ($? != 0) {
        throw Media::YoutubeDl::Exception("Exit status $?");
    }
    return \%formats;
}

sub getBestFormat {
    my ($self, $formats) = @_;
    my $best;
    my $max = 0;
    foreach (values %$formats) {
        if ($_->{code} =~ /(\d+)/i) {
            $_->{value} = $1;
         #~ || $_->{code} =~ /-(\d+)/) {
            if ($1 > $max) {
                $best = $_;
                $max = $1;
            }
            print "$max $_->{code}\n";
        } else {
            warn "No value";
        }
    }
    return $best;
}

sub getTitle {
    my ($self, $url) = @_;
    my $title;
    try {
        $title = $self->execute($url, "-e");
    } catch {
        $_->rethrow;
    };
    return $title;
}

sub getFirstId {
    my ($self, $url, $baseUrl) = @_;

    my $html;
    try {
        $html = $self->getHtml($url);
    } catch {
        $_->rethrow;
    };

    if ($html =~ s/\Q$baseUrl\E(.+?)[&"]//) {
        return $1;
    }
}

sub getFilename {
    my ($self, $url) = @_;
    my $filename;
    try {
        $filename = $self->execute($url, "--get-filename");
    } catch {
        #~ warn $_;
        $_->rethrow;
    };
    $filename =~ s/\.(webm|mp4)$//;
    return $filename;
}

sub execute {
    my ($self, @opts) = @_;

    #~ unshift @opts, '--no-continue';
    unshift @opts, $self->executable;
    my $output = `@opts`;
    if ($? != 0) {
        throw Media::YoutubeDl::Exception("Exit status $?");
    }
    chomp $output;

    return $output;
}


1;
