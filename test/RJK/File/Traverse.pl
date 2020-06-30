use strict;
use warnings;

use RJK::Files;
use RJK::SimpleFileVisitor;

my $visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    postVisitFiles => sub {
        my ($dir, $stat, $files, $dirs) = @_;
        printf "%s\nfiles: %u, dirs: %u\n", $dir->{path}, scalar @$files, scalar @$dirs;
    },
    visitFile => sub {
        my ($file, $stat) = @_;
        #~ print "$_\n";
        #~ print "$file->{path}\n";
        #~ printf "%s %s\n", $path->getParent(), $path->getFileName();
    }
);

#~ my $path = 'c:\temp';
my $path = 'c:\temp\jdshow';
#~ my $path = 'c:\temp\a.txt';
#~ my $path = 'fail';
#~ RJK::Files::Traverse($path, $visitor);


use RJK::Files::Stats;
my $stats = RJK::Files::Stats::Traverse($path);

$stats = RJK::Files::Stats::CreateStats();
$visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    postVisitFiles => sub {
        my ($dir, $stat, $files, $dirs) = @_;
        printf "%s\n", $dir->{path};
        #~ printf "dirs: %u, files: %u\n", scalar @$dirs, scalar @$files;
        my $ds = $stats->{dirStats};
        printf "dirs: %u, files: %u, size: %u\n", $ds->{dirs}, $ds->{files}, $ds->{size};
    }
);
#~ RJK::Files::Stats::Traverse($path, undef, undef, $stats);
RJK::Files::Stats::Traverse($path, $visitor, undef, $stats);
use Data::Dump;
dd $stats;

__END__

# implementation in module MyVisitor
use MyVisitor; # implements FileVisitorBase
my $visitor = new MyVisitor();

# implementation in anonymous subroutines
use RJK::SimpleFileVisitor; # implements FileVisitorBase
my $visitor = new RJK::SimpleFileVisitor(visitFile => sub {...});

# RJK::Files::Traverse simple file tree traversal
use RJK::Files;
RJK::Files::Traverse($dir, $visitor);

# RJK::Files::Stats::Traverse returns stats
use RJK::Files::Stats;
my $stats = RJK::Files::Stats::Traverse($dir, $visitor);
# visitor is optional
my $stats = RJK::Files::Stats::Traverse($dir);

# RJK::Files::Stats::Traverse updates stats, MyVisitor uses stats
use RJK::Files::Stats;
my $stats = new RJK::Files::Stats::CreateStats();
my $visitor = new MyVisitor($stats);
RJK::Files::Stats::Traverse($dir, $visitor, $stats);

# generic visitors
my $visitor = new RJK::SimpleFileVisitor::TotalCmdSearch($seachName);
