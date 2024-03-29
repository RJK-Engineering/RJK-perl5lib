package RJK::Filecheck::CreateSnapshotsVisitor;
use parent 'RJK::FileVisitor';

use strict;
use warnings;

use FileVisitResult;
use RJK::Path;
use RJK::File::Sidecar;
use RJK::Filecheck::Dir;

my $opts;

sub new {
    my $self = bless {}, shift;
    $opts = shift;
    return $self;
}

sub visitFileFailed {
    my ($self, $file, $error) = @_;
    print "$error: $file\n";
}

sub preVisitDir {
    my ($self, $dir, $stat) = @_;
    print "=> $dir\n";
    my $d = new RJK::Filecheck::Dir($dir);
    return FileVisitResult::SKIP_FILES if $d->hasProperty('no.snapshots');
}

sub visitFile {
    my ($self, $file, $stat) = @_;
    return if ! isVideo($file);
    print "$file\n";
    createSnapshots($file);
}

sub createSnapshots {
    my $videoFile = shift;
    my $existingSnapshotsForFile = 0;

    RJK::File::Sidecar->getSidecarFiles($videoFile, sub {
        $existingSnapshotsForFile = 1 if handleSidecarFile($videoFile, @_);
    });

    return if $existingSnapshotsForFile;

    my $time = $opts->{position} =~ s/:/./gr;
    $time .= "s" if $time !~ /\./;
    my $parent = $videoFile->parent;
    my $basename = $videoFile->basename;
    my $snapshot = "$parent\\${basename}_$time.jpg";
    createSnapshot($videoFile, $opts->{position} =~ s/\./:/gr, $snapshot);
}

sub handleSidecarFile {
    return if ! /\.jpg$/i;
    my ($videoFile, $sidecar, $dir, $name, $nameStart) = @_;
    my $existingSnapshot = 1;
    my $sidecarPath = "$dir\\$sidecar";

    if ($sidecar =~ /_(\d\d?s|\d\d?\.\d\d)\.jpg$/i) {
        print "> $sidecar\n";
        handleExistingSnapshot($videoFile, $sidecarPath, $dir, $nameStart, $1);
    } elsif ($sidecar =~ /\.\w+_snapshot_(?:(\d\d)\.)?(\d\d)\.(\d\d)_\[\d{4}\.\d\d\.\d\d_\d\d\.\d\d\.\d\d\]\.jpg$/i) {
        print "> $sidecar\n";
        handleMpcSnapshot($videoFile, $sidecarPath, $dir, $nameStart, $1, $2, $3);
    } else {
        print "! $sidecar\n";
        $existingSnapshot = 0;
    }
    return $existingSnapshot;
}

sub handleExistingSnapshot {
    my ($videoFile, $sidecarPath, $dir, $nameStart, $time) = @_;
    my $info = getImageInfo($sidecarPath);
    print "Comment: $info->{comment}\n" if $opts->{verbose} && $info->{comment};

    if ($info->{height} == $opts->{imageHeight}) {
        print "OK!\n";
    } else {
        print "- $sidecarPath\n";
        unlink $sidecarPath or die "$!: $sidecarPath";
        my $snapshot = "$dir\\${nameStart}_$time.jpg";
        print "+ $snapshot\n";
        createSnapshot($videoFile, $time =~ s/\./:/gr, $snapshot);
    }
}

sub handleMpcSnapshot {
    my ($videoFile, $sidecarPath, $dir, $nameStart, $h, $m, $s) = @_;
    $h = int $h if $h;
    $m = int $m;
    $s = int $s;

    my $time = !$h && !$m ? $s."s" : $h ? sprintf("%u.%02u.%02u", $h, $m, $s) : sprintf("%u.%02u", $m, $s);
    my $newName = "$dir\\${nameStart}_$time.jpg";

    if (-e $newName) {
        print "- $sidecarPath\n";
        unlink $sidecarPath;
    } else {
        print "< $sidecarPath\n";
        print "> $newName\n";
        rename $sidecarPath, $newName;
        handleExistingSnapshot($videoFile, $newName, $dir, $nameStart, $time);
    }
}

sub getImageInfo {
    my ($file) = @_;
    my %info;
    open my $fh, '<:raw', $file or die "$!: $file";
    while (1) {
        read $fh, my $s, 1 or last;
        if (unpack("C", $s) == 0xFF) {
            read $fh, $s, 1 or last;
            if (unpack("C", $s) == 0xFE) {
                read $fh, $s, 2 or last;
                my $length = unpack("n", $s);
                read $fh, $info{comment}, $length-3 or last;
            } elsif (unpack("C", $s) == 0xC0) {
                seek $fh, 3, 1 or last;
                read $fh, $s, 2 or last;
                $info{height} = unpack("n", $s);
                read $fh, $s, 2 or last;
                $info{width} = unpack("n", $s);
                last;
            }
        }
    }
    close $fh;
    return \%info;
}

sub isVideo {
    return $_[0] =~ /\.(mp4|wmv|mpe?g|avi|rm|mkv|webm|flv|rmvb|asf|m4v|divx|mov|part)$/i;
}

sub createSnapshot {
    my ($videoFilePath, $time, $output) = @_;
    my @cmd = (
        ffmpeg => '-n',
        -i => "\"$videoFilePath\"",
        -ss => $time,
        -vf => "\"scale=-1:$opts->{imageHeight}\"",
        -vframes => 1,
        "\"$output\""
    );
    print "@cmd\n" if $opts->{verbose};
    `@cmd >NUL 2>NUL`;
}

1;
