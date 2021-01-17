use strict;
use warnings;

use RJK::IO::File;

my $dir = 'c:\temp';
my $f = new RJK::IO::File($dir);

my @f = $f->filenames(sub {-f "$dir/$_[0]"});
foreach (@f) {
    print "$_\n";
}

@f = $f->files(sub {$_[0]->isFile});
foreach (@f) {
    print "$_->{path}\n";
}

my $file = 'c:\temp\File.pl.test.file';
$f = new RJK::IO::File($file);
$f->createNewFile();
$f->delete();

my $p = $f->getParentFile;
print "$p->{path}\n";
$p = $p->getParentFile;
print "$p->{path}\n";
$p = $p->getParentFile;
print defined $p ? "defined\n" : "not defined\n";

$dir = 'c:\temp\File.pl.test.dir';
$f = new RJK::IO::File($dir);
use File::Path ();
if (! $f->exists) {
    File::Path::make_path($dir) or die "$!: $dir";
    $f->delete();
}

my $path = RJK::Paths->get($file);
$f = new RJK::IO::File($path, 'sd');
print "$f->{path}\n";
