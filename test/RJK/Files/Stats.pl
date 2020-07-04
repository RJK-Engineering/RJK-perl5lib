use strict;
use warnings;

use RJK::Files::Stats;
use RJK::SimpleFileVisitor;

#~ my $path = 'c:\temp';
my $path = 'c:\temp\jdshow';
#~ my $path = 'c:\temp\a.txt';
#~ my $path = 'fail';

my $total = RJK::Files::Stats::Traverse($path);
my $stats = RJK::Files::Stats::CreateStats();
my $visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    postVisitFiles => sub {
        displayStats();
    }
);

RJK::Files::Stats::Traverse($path, $visitor, undef, $stats);
displayStats();

sub displayStats {
    printf "dirs: %u/%u/%u, files: %u/%u/%u, size: %u/%u/%u\n",
        $stats->{preVisitDir},
        $total->{preVisitDir} - $stats->{preVisitDir},
        $total->{preVisitDir},
        $stats->{visitFile},
        $total->{visitFile} - $stats->{visitFile},
        $total->{visitFile},
        $stats->{size},
        $total->{size} - $stats->{size},
        $total->{size};
}