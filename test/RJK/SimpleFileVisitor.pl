use Data::Dump;
use RJK::File::Stats;
use RJK::SimpleFileVisitor;

my $testDir = 'c:\temp\1';
die "Testdir does not exist: $testDir" if !-e $testDir;

my $stats = RJK::File::Stats->traverse($testDir);
dd $stats;

$stats = RJK::File::Stats->createStats();
my $visitor = new RJK::SimpleFileVisitor(
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
#~ RJK::File::Stats->traverse($testDir, undef, undef, $stats);
RJK::File::Stats->traverse($testDir, $visitor, undef, $stats);
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
