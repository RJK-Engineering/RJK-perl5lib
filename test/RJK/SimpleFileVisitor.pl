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
#~ RJK::Files::traverse($path, $visitor);


use RJK::File::Stats;
my $stats = RJK::File::Stats::traverse($path);

$stats = RJK::File::Stats::createStats();
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
#~ RJK::File::Stats::traverse($path, undef, undef, $stats);
RJK::File::Stats::traverse($path, $visitor, undef, $stats);
use Data::Dump;
dd $stats;

__END__

# implementation in module MyVisitor
use MyVisitor; # implements FileVisitorBase
my $visitor = new MyVisitor();

# implementation in anonymous subroutines
use RJK::SimpleFileVisitor; # implements FileVisitorBase
my $visitor = new RJK::SimpleFileVisitor(visitFile => sub {...});

# RJK::Files::traverse simple file tree traversal
use RJK::Files;
RJK::Files::traverse($dir, $visitor);

# RJK::File::Stats::traverse returns stats
use RJK::File::Stats;
my $stats = RJK::File::Stats::traverse($dir, $visitor);
# visitor is optional
my $stats = RJK::File::Stats::traverse($dir);

# RJK::File::Stats::traverse updates stats, MyVisitor uses stats
use RJK::File::Stats;
my $stats = new RJK::File::Stats::createStats();
my $visitor = new MyVisitor($stats);
RJK::File::Stats::traverse($dir, $visitor, $stats);

# generic visitors
my $visitor = new RJK::SimpleFileVisitor::TotalCmdSearch($seachName);
