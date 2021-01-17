use strict;
use warnings;

use RJK::ListFiles;
use RJK::SimpleFileVisitor;

my $file;

setup();

my $paths = RJK::ListFiles->getPaths($file);
foreach my $path (@$paths) {
    next if RJK::ListFiles->isDir($path);
    print "$path\n";
}

$paths = RJK::ListFiles->getDirs($file);
print join("\n", @$paths), "\n";

$paths = RJK::ListFiles->getFiles($file);
print join("\n", @$paths), "\n";

my $visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    preVisitDir => sub {
        my ($dir) = @_;
        print "$dir->{path}\n";
    },
    visitFile => sub {
        my ($file) = @_;
        print "$file->{path}\n";
    }
);

RJK::ListFiles->traverse($file, $visitor);

tearDown();

sub setup {
    $file = "$ENV{TEMP}\\ListFile.txt";
    open my $fh, '>', $file or die "$!: $file";
    print $fh "C:\\dir\\\n";
    print $fh "C:\\file\n";
    close $fh;
}

sub tearDown {
    unlink $file;
}
