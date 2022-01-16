package RJK::Filecheck::Store::DiskDirFiles;
#~ use parent 'RJK::Filecheck::Store';

use strict;
use warnings;

use File::Path ();

use RJK::Path;
use RJK::Paths;
use RJK::Filecheck::Config;
use RJK::TotalCmd::DiskDirFile;
use RJK::TotalCmd::DiskDirFiles;

my $activeDiskDirFile;
my $activeDiskDirFilePath;
my $activeVolumes;

sub commit {
    commitDiskDirFile() if $activeDiskDirFile;
}

sub commitDiskDirFile {
    my $dir = RJK::Paths->get($activeDiskDirFilePath)->parent;
    File::Path::make_path($dir);
    $activeDiskDirFile->write($activeDiskDirFilePath);
}

sub getFiles {
    my ($self, $volumeLabel, $dir) = @_;
    my $diskDirFile = $self->getDiskDirFile($volumeLabel, $dir);
    return $diskDirFile->getFiles("$dir->{directories}\\$dir->{name}" =~ s/^\\//r);
}

sub updateFile {
    my ($self, $volumeLabel, $file, $stat) = @_;
    my $diskDirFile = $self->getDiskDirFile($volumeLabel, $file);
    $diskDirFile->setFile($file->path, $stat);
}

sub getDiskDirFile {
    my ($self, $file, $volumeLabel) = @_;
    my $diskDirFilePath = $self->getDiskDirFilePath($volumeLabel, $file);
    if ($activeDiskDirFile) {
        return $activeDiskDirFile if $activeDiskDirFilePath eq $diskDirFilePath;
        $self->commit;
    }
    $activeDiskDirFile = RJK::TotalCmd::DiskDirFile->new($file->parent);
    $activeDiskDirFile->read($diskDirFilePath) if -e $diskDirFilePath;
    $activeDiskDirFilePath = $diskDirFilePath;
    return $activeDiskDirFile;
}

sub traverse {
    my ($self, $visitor, $volumeLabel, $dir) = @_;
    my $file = "$dir\\file" if $dir;
    my $diskDirFilePath = $self->getDiskDirFilePath($volumeLabel, $file);
    RJK::TotalCmd::DiskDirFiles->traverse($diskDirFilePath, $visitor, { nostat => 0 });
}

sub getDiskDirFilePath {
    my ($self, $volumeLabel, $file) = @_;
    $volumeLabel //= $file->volume if $file;
    my $ddfLstDir = RJK::Filecheck::Config->get('ddf.lst.dir');
    return "$ddfLstDir\\$volumeLabel.lst";
    #~ return "$ddfLstDir\\$volumeLabel$file->{directories}.lst";
}

1;
