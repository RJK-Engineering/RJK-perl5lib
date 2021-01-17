use strict;
use warnings;

use RJK::Files;
use RJK::SimpleFileVisitor;

#~ my $path = 'c:\temp';
my $path = 'c:\temp\1';
#~ my $path = 'c:\temp\a.txt';
#~ my $path = 'fail';

my $total = RJK::Files->traverseWithStats($path);
my $stats = RJK::Files->createStats();
displayStats();

my $visitor = new RJK::SimpleFileVisitor(
    visitFileFailed => sub {
        my ($file, $error) = @_;
        print "$error: $file->{path}\n";
    },
    postVisitFiles => sub {
        displayStats();
    }
);

RJK::Files->traverse($path, $visitor, undef, $stats);
displayStats();

use Data::Dump;
dd $stats;

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
