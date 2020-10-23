use strict;
use warnings;

use RJK::TotalCmd::DiskDirFile;
use Data::Dump;

my $filepath = 'DiskDirFile.test~.lst';

my $ddf = new RJK::TotalCmd::DiskDirFile();
$ddf->read($filepath);

foreach (@{$ddf->getDirectories}) {
    print "$_->[0]\n";
}
foreach (@{$ddf->getFiles('.')}) {
    print "$_->[0]\n";
}

$filepath = 'DiskDirFile.test.write~.lst';
$ddf->write($filepath);

$ddf->setRoot("c:\\test");
$filepath = 'DiskDirFile.test.setRoot~.lst';
$ddf->write($filepath);

my $file = 'c:\\test\\BLUEMAX1.T64';
print $ddf->hasFile($file) ? "yes\n" : "fail\n";
$file = 'c:\\test\\new.txt';
print ! $ddf->hasFile($file) ? "no\n" : "fail\n";

my $dir = 'c:\\test';
print $ddf->hasDir($dir) ? "yes\n" : "fail\n";

$dir = 'c:\\test\\new';
print ! $ddf->hasDir($dir) ? "no\n" : "fail\n";

print ! $ddf->getDir($dir) ? "ok\n" : "fail\n";
$dir = 'c:\\test\\QB';
dd $ddf->getDir($dir);

print ! $ddf->getFile($file) ? "ok\n" : "fail\n";
$file = 'c:\\test\\BLUEMAX1.T64';
dd $ddf->getFile($file);

$ddf->deleteFile($file);
$ddf->deleteDir('c:\\test\\QB\rob');
$filepath = 'DiskDirFile.test.delete~.lst';
$ddf->write($filepath);

use Try::Tiny;

$ddf->setRoot("c:\\temp");

try {
    $file = 'c:\\temp\\filedoesntexist';
    $ddf->setFile($file);
} catch {
    if ($_->isa('RJK::File::Exception')) {
        print "$_->{message}: $_->{file}\n";
    }
};

try {
    $file = 'c:\\temp\\dirdoesntexist\\a.txt';
    $ddf->setFile($file);
} catch {
    if ($_->isa('RJK::File::Exception')) {
        print "$_->{message}: $_->{file}\n";
    }
};

try {
    $dir = 'c:\\notinroot\\sljdf';
    $ddf->setDir($dir);
} catch {
    if ($_->isa('Exception')) {
        print "$_->{message}\n";
    }
};

$file = 'c:\\temp\\1\\2\\3\\a.txt';
$ddf->setFile($file);

$filepath = 'DiskDirFile.test.new~.lst';
$ddf->write($filepath);

__END__

my ($d, $f) = (0, 0);
foreach (@{$dd->dirs}) {
    my ($dir, $size, $date, $time) = @$_;
    print "@$_\n" if ++$d <= 0;

    foreach ($dd->getFiles($dir)) {
        print "\t@$_\n" if $d <= 0;
        $f++;
    }
}
print "$d dirs, $f files\n";

my @results = $dd->search("tour 2010");
foreach (@results) {
    print "$_->{modified}\n";
    print "$_->{parent}->{modified} $_->{path}\n";
}
