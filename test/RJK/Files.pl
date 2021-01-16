use strict;
use warnings;

use RJK::Files;
use RJK::SimpleFileVisitor;
use RJK::File::TreeVisitResult;

my $visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
        #~ return TERMINATE;
    },
    preVisitDir => sub {
        my ($dir, $stat) = @_;
        printf ">D %s\n", $dir->{path};
        #~ return TERMINATE;
        #~ return SKIP_SUBTREE if $dir->{name} eq 'dir1';
        #~ return SKIP_SIBLINGS if $dir->{name} eq 'dir1';
        #~ return SKIP_FILES if $dir->{name} eq 'dir1';
        #~ return SKIP_DIRS if $dir->{name} eq 'dir1';
    },
    postVisitDir => sub {
        my ($dir, $stat) = @_;
        printf "<D %s\n", $dir->{path};
        #~ return TERMINATE;
        #~ return SKIP_SIBLINGS if $dir->{name} eq 'dir1';
    },
    postVisitFiles => sub {
        my ($dir, $stat) = @_;
        printf "<F %s\n", $dir->{path};
        #~ return TERMINATE;
        #~ return SKIP_SIBLINGS if $dir->{name} eq 'dir1';
        #~ return SKIP_DIRS if $dir->{name} eq 'dir1';
    },
    visitFile => sub {
        my ($file, $stat) = @_;
        print "   $file->{path}\n";
        #~ return TERMINATE;
        #~ return SKIP_SIBLINGS if $file->{name} eq 'file1';
        #~ return SKIP_SIBLINGS if $file->{name} eq 'file2';
        #~ return SKIP_FILES if $file->{name} eq 'file1';
    }
);

my $testDir = 'c:\temp\root';
createFileTree($testDir);

my $path = $testDir;
#~ my $path = 'fail';

my $terminated = RJK::Files->traverse($path, $visitor, {sort=>1});
print "TERMINATEd\n" if $terminated;

sub createFileTree {
    die "Testdir does not exist: $testDir" if !-e $testDir;
    die "Testdir is not writeable: $testDir" if !-w $testDir;
    mkdir "$testDir/dir1";
    mkdir "$testDir/dir1/dir2";
    mkdir "$testDir/dir3";
    createFile("$testDir/file1");
    createFile("$testDir/dir1/file2");
}

sub createFile {
    my $file = shift;
    open my $fh, '>', $file or return;
    close $fh;
}
