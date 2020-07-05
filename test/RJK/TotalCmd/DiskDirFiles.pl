use strict;
use warnings;

use RJK::SimpleFileVisitor;
use RJK::TotalCmd::DiskDirFiles;
use RJK::TreeVisitResult;

my $file = 'DiskDirFiles.test~.lst';

RJK::TotalCmd::DiskDirFiles->traverse($file, new RJK::SimpleFileVisitor(
    visitFile => sub {
        my ($file, $stat) = @_;
        #~ print "$_\n";
        print "$stat->{size}\t$stat->{modified}\t$file->{path}\n";
        #~ return TERMINATE;
        #~ return SKIP_SUBTREE; # invalid for visitFile
        #~ return CONTINUE; # optional
    },
    preVisitDir => sub {
        my ($dir, $stat, $files, $dirs) = @_;
        print "---> $dir->{path}\t$stat->{modified}\n";
    },
    postVisitDir => sub {
        my ($dir, $error, $files, $dirs) = @_;
        print "<--- $dir->{path}\n";
    }
));
