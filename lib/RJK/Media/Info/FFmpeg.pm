package RJK::Media::Info::FFmpeg;

use strict;
use warnings;

our $executable = 'ffprobe';

my $info;
my $fh;

sub info {
    my ($self, $file) = @_;
    $info = bless {}, 'RJK::Media::Info';
    close $fh if $fh;

    open $fh, "$executable \"$file\" 2>&1|" or die "$!";
    &parseOutput;
    close $fh;
    $fh = undef;

    postProcessing();
    return $info;
}

my @lines;
sub readLine {
    $_ = pop @lines // readline $fh;
}
sub pushLine {
    push @lines, $_;
}

sub parseOutput {
    while (&readLine) {
        if (/^Input #0, (.+) from '.+':$/) {
            $info->{format} = $1 =~ s/,$//r;
            &parseInputInfo;
            last;
        }
    }
}

sub parseInputInfo {
    while (&readLine) {
        if (/^(\s*)Metadata:/) {
            $info->{metadata} = &parseMetadata($1);
        } elsif (/^\s*Duration: (\d+):(\d+):(\d+\.\d+), start: (-?\d+\.\d+), bitrate: (\d+)/) {
            $info->{duration} = $1 * 3600 + $2 * 60 + $3;
            $info->{start} = $4+0;
            $info->{bitrate} = $5;
            &parseStreams;
        }
    }
}

sub parseMetadata {
    my $indent = $_[0].'  ';
    my %md;
    while (&readLine) {
        if (/^$indent(\w+)\s*: (.*)/) {
            $md{$1} = $2;
        } else {
            &pushLine;
            last;
        }
    }
    return \%md;
}

sub parseStreams {
    while (&readLine) {
        my $stream;
        if (s/^\s*(\w+) #(\d+).(\d+)(?:\((.+)\)|\[.+?\])?: //) {
            $stream = { pid => $2, sid => $3, language => $4 };
            if ($1 eq 'Stream') {
                parseStream($stream);
            } elsif ($1 eq 'Chapter') {
                push @{$info->{chapters}}, parseChapter($stream);
            } else {
                $stream->{description} = $_;
                push @{$info->{otherInfo}}, $stream;
            }
        } elsif (/^(\s*)Metadata:/) {
            $stream->{metadata} = &parseMetadata($1);
        }
    }
}

sub parseStream {
    my ($stream) = @_;
    if (s/^Audio: //) {
        parseAudioStream($stream);
        push @{$info->{audio}}, $stream;
    } elsif (s/^Video: //) {
        parseVideoStream($stream);
        push @{$info->{video}}, $stream;
    } else {
        $stream->{description} = $_;
        push @{$info->{otherStreams}}, $stream;
    }
}

sub parseChapter {
    my ($stream) = @_;
    my $chapter = {};

    if (/start (\S+), end (\S+)/) {
        $chapter->{start} = $1+0;
        $chapter->{end} = $2+0;
    }

    &readLine;
    if (/^(\s*)Metadata:/) {
        my $md = &parseMetadata($1);
        $chapter->{title} = $md->{title};
    }
    return $chapter;
}

sub parseAudioStream {
    my ($stream) = @_;

    parseFormat($stream);

    parseFrequency: {
        if (s/^, (\d+) Hz//) {
            $stream->{frequency} = $1;
        }
    }
    parseChannels: {
        if (s/^, ([^,]+)//) {
            $stream->{channels} = $1 eq 'stereo' ? 2 : $1 eq 'mono' ? 1 : $1;
        }
    }
    s/^, (\w+)//; # sample format?
    parseBitrate($stream);
    parseNote($stream);
}

sub parseBitrate {
    my ($stream) = @_;
    if (s/, (\d+) kb\/s//) {
        $stream->{bitrate} = $1;
    }
}

sub parseNote {
    my ($stream) = @_;
    if (s/[\s,]*\((.+?)\)\s*$//) {
        $stream->{note} = $1;
    } else {
        s/[\s,]+$//;
    }
    s/^[\s,]+//;
    $stream->{UNPARSED} = $_ if $_;
}

sub parseVideoStream {
    my ($stream) = @_;

    parseFormat($stream);

    parseColorspace: {
        if (s/^, (\w+)(?: ?\(.+?\))?//) {
            $stream->{colorspace} = $1;
        }
    }
    parseDimensions: {
        if (s/^, (\d+)x(\d+)//) {
            $stream->{width} = $1;
            $stream->{height} = $2;
        }
        if (s/ SAR (.+?) DAR ([^,]+)// || s/\[SAR (.+?) DAR (.+?)\]//) {
            $stream->{sar} = $1;
            $stream->{dar} = $2;
        }
        s/\[SAR .+? DAR .+?\]//; # sometimes there's dupe AR info
    }
    parseBitrate($stream);

    parseFramerate: {
        while (s/, (\S+) (tb.|fps)//) {
            $stream->{$2} = $1;
        }
    }
    parseNote($stream);
}

sub parseFormat {
    my ($stream) = @_;
    if (s/^([^, ]+)//) {
        $stream->{format} = $1;
    }
    if (s/^ \((.+?)\)//) {
        $stream->{profile} = $1;
    }
    if (s/^ \((.+?)(?: \/ .+?)?\)//) {
        $stream->{codec} = $1;
    }
}

sub postProcessing {
    $info->{audio} //= [];
    $info->{video} //= [];
    foreach my $vi (@{$info->{video}}) {
        $vi->{framerate} ||= $vi->{tbr};
        if ($vi->{dar}) {
            $vi->{aspect} = $vi->{dar};
        } else {
            my $w = $vi->{width};
            my $h = $vi->{height};
            if ($w && $h) {
                my $gcf = gcf($w, $h);
                $vi->{aspect} = $w/$gcf .":". $h/$gcf;
            }
        }
    }
}

# greatest common factor
sub gcf {
  my ($x, $y) = @_;
  ($x, $y) = ($y, $x % $y) while $y;
  return abs $x;
}

1;
