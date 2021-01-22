package RJK::Media::Info::FFmpeg;

use strict;
use warnings;

use Exporter ();
our @ISA = qw(Exporter);
our @EXPORT = our @EXPORT_OK = qw(probe);

use RJK::Media::Info;

our $executable = 'ffmpeg';

sub probe {
    __PACKAGE__->info(shift);
}

sub info {
    my ($self, $file) = @_;

    my $info = new RJK::Media::Info;

    open my $fh, "$executable -i \"$file\" 2>&1|"
        or die "$!";
    while (<$fh>) {
        if (/^    (\w+)\s*: (.*)/) {
            #~ print "$1: $2\n";
            $info->{meta}{$1} = $2;
        } elsif (/Input #0, (.+?), from/) {
            $info->{container} = $1;
        } elsif (/Duration: (\d+):(\d+):(\d+\.\d+), start: (-?\d+\.\d+), bitrate: (\d+)/) {
            $info->{duration} = $1 * 3600 + $2 * 60 + $3;
            $info->{start} = $4;
            $info->{bitrate} = $5;
        } elsif (/    Stream #(\d+).(\d+).*: (\w+): (.*)/) {
            #~ print "$1=$2=$3=$4\n";
            my $s = {};
            $s->{pid} = $1; # program id
            $s->{sid} = $2; # stream id
            $s->{type} = $3;
            $s->{descr} = $4;
            my @si = split /, /, $4;

            # parse stream info
            #~ print "@si\n";
            $s->{format} = shift @si;

            # video: mpeg4 (Simple Profile) (XVID / 0x44495658)
            # audio: wmav2 (a[1][0][0] / 0x0161)
            if ($s->{type} eq 'Video') {
                if ($s->{format} =~ s/ \((.+?)\)//) {
                    $s->{profile} = $1;
                }
                $s->{cspace} = shift @si;
            }

            if ($s->{format} =~ s/ \((.+?) .+\)//) {
                $s->{codec} = $1;
            }

            foreach (@si) {
                if (/(\d+)x(\d+)(?: \[(.*)\])?/) {
                    $s->{width} = $1;
                    $s->{height} = $2;
                    $s->{dar} = "";
                    if ($3) {
                        $s->{ars} = $3;
                        my @a = split / /, $s->{ars};
                        my $v;
                        while ($v = shift @a) {
                            if ($v eq "DAR") {
                                $s->{dar} = shift @a;
                            }
                        }
                    }
                } elsif (my ($val, $unit) = /([\d\.]+) (.*)/) {
                    if ($unit =~ m{^kb/s}) {
                        $s->{kbps} = $val;
                    } else {
                        $s->{$unit} = $val;
                    }
                } else {
                    if ($s->{$_}) {
                        warn "Double flag: $_";
                    } else {
                        $s->{$_} = 1;
                    }
                    push @{$s->{flags}}, $_;
                }
            }

            # set stream
            if ($s->{type} eq 'Video') {
                push @{$info->{video}}, $s;
            } elsif ($s->{type} eq 'Audio') {
                $s->{freq} = $s->{Hz};
                $s->{channels} = 1 if $s->{mono};
                $s->{channels} = 2 if $s->{stereo};
                push @{$info->{audio}}, $s;
            #~ } elsif (! grep /$s->{type}/, ('Data')) {
            #~ } elsif ($s->{type} ne 'Data') {
                #~ die "Unknown stream type: $s->{type}";
            }
        }
    }
    close $fh;

    # lookup missing values
    foreach my $vi (@{$info->{video}}) {
        $vi->{fps} ||= $vi->{tbr} || $vi->{tbn} || $vi->{tbc};
        $info->{fps} ||= $vi->{fps};

        if (! $vi->{dar}) {
            my $w = $vi->{width};
            my $h = $vi->{height};
            if ($w && $h) {
                my $gcf = gcf($w, $h);
                $vi->{dar} = $w/$gcf .":". $h/$gcf;
            }
        }
    }

    return $info;
}

# greatest common factor
sub gcf {
  my ($x, $y) = @_;
  ($x, $y) = ($y, $x % $y) while $y;
  return abs $x;
}

1;

__END__

Metadata:
  major_brand     : isom
  minor_version   : 512
  compatible_brands: isomiso2avc1mp41
  encoder         : Lavf53.24.0
Duration: 00:03:37.75, start: 0.000000, bitrate: 2077 kb/s
  Stream #0.0(und): Video: h264, yuv420p, 1280x720 [PAR 1:1 DAR 16:9], 2006 kb/s, 29.97 fps, 29.97 tbr, 29974 tbn, 59.94 tbc
  Stream #0.1(und): Audio: aac, 44100 Hz, mono, s16, 63 kb/s

tbn = the time base in AVStream that has come from the container
tbc = the time base in AVCodecContext for the codec used for a particular stream
tbr = tbr is guessed from the video stream and is the value users want to see when they look for the video frame rate

$VAR1 = {
    'fps' => '29.97',
    'bitrate' => '728',
    'duration' => '45.05',
    'start' => '0.000000',
    'meta' => $meta,
    'video' => [ $video ],
    'audio' => [ $audio ],
}
'meta' = {
    'creation_time' => '2015-07-08 17:17:27',
    'minor_version' => '0',
    'compatible_brands' => 'isommp42',
    'major_brand' => 'mp42'
}
$audio = {
   'freq' => '44100',
   'channels' => 2,
   'flags' => [
                'stereo',
                'fltp'
              ],
   'type' => 'Audio',
   'stereo' => 1,
   'descr' => 'aac (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 96 kb/s',
   'kbps' => '96',
   'pid' => '0',
   'sid' => '1',
   'format' => 'aac',
   'Hz' => '44100',
   'fltp' => 1
}
'video' = {
   'kbps' => '629',
   'type' => 'Video',
   'height' => '320',
   'fps' => '29.97',
   'sid' => '0',
   'pid' => '0',
   'flags' => [
                '30k tbn'
              ],
   'cspace' => 'yuv420p',
   'descr' => 'h264 (Constrained Baseline) (avc1 / 0x31637661), yuv420p, 426x320 [SAR 1:1 DAR 213:160], 629 kb/s, 29.97 fps, 29.97 tbr, 30k tbn, 59.94 tbc',
   'dar' => '213:160',
   'tbr' => '29.97',
   '30k tbn' => 1,
   'ars' => 'SAR 1:1 DAR 213:160',
   'width' => '426',
   'format' => 'h264',
   'tbc' => '59.94'
}
