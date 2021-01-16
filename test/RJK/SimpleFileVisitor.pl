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
    mkdir $testDir;
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

__END__

use RJK::File::Stats;
my $stats = RJK::File::Stats->traverse($path);

$stats = RJK::File::Stats->createStats();
$visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    postVisitFiles => sub {
        my ($dir, $stat) = @_;
        printf "%s\n", $dir->{path};
        #~ printf "dirs: %u, files: %u\n", scalar @$dirs, scalar @$files;
        my $ds = $stats->{dirStats};
        printf "dirs: %u, files: %u, size: %u\n", $ds->{dirs}, $ds->{files}, $ds->{size};
    }
);
#~ RJK::File::Stats->traverse($path, undef, undef, $stats);
RJK::File::Stats->traverse($path, $visitor, undef, $stats);
use Data::Dump;
dd $stats;

__END__

# implementation in module MyVisitor
use MyVisitor; # implements FileVisitorBase
my $visitor = new MyVisitor();

# implementation in anonymous subroutines
use RJK::SimpleFileVisitor; # implements FileVisitorBase
my $visitor = new RJK::SimpleFileVisitor(visitFile => sub {...});

# RJK::Files->traverse simple file tree traversal
use RJK::Files;
RJK::Files->traverse($dir, $visitor);

# RJK::File::Stats->traverse returns stats
use RJK::File::Stats;
my $stats = RJK::File::Stats->traverse($dir, $visitor);
# visitor is optional
my $stats = RJK::File::Stats->traverse($dir);

# RJK::File::Stats->traverse updates stats, MyVisitor uses stats
use RJK::File::Stats;
my $stats = new RJK::File::Stats->createStats();
my $visitor = new MyVisitor($stats);
RJK::File::Stats->traverse($dir, $visitor, $stats);

# TODO generic visitors
my $visitor = new RJK::SimpleFileVisitor::TotalCmdSearch($seachName);
