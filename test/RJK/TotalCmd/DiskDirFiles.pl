use strict;
use warnings;

use FileVisitResult;
use RJK::SimpleFileVisitor;
use RJK::TotalCmd::DiskDirFiles;

my $file = 'DiskDirFiles.test~.lst';
#~ my $file = 'DiskDirFiles.test.noroot~.lst';

RJK::TotalCmd::DiskDirFiles->traverse($file, new RJK::SimpleFileVisitor(
    visitFile => sub {
        my ($file, $stat) = @_;
        #~ print "$_\n";
        print $stat->size, "\t", $stat->modified, "\t$file->{path}\n";
        #~ return FileVisitResult::TERMINATE;
        #~ return FileVisitResult::SKIP_SIBLINGS;
        #~ return FileVisitResult::SKIP_SUBTREE; # same as CONTINUE for visitFile
        #~ return FileVisitResult::CONTINUE; # optional
    },
    preVisitFiles => sub {
        my ($dir, $stat) = @_;
        print "---> $dir->{path}\t", $stat->modified, "\n";
        #~ return FileVisitResult::SKIP_SIBLINGS;
        #~ return FileVisitResult::SKIP_SUBTREE;
        return FileVisitResult::SKIP_SUBTREE if $dir->{name} eq 'INC';
    },
    postVisitFiles => sub {
        my ($dir, $error) = @_;
        print "<--- $dir->{path}\n";
        #~ return FileVisitResult::TERMINATE;
    }
));
