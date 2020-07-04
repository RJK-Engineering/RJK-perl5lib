use strict;
use warnings;

use RJK::File::PathUtils qw(RenamedString);

testRenamedString("notes/2.txt", "notes/3.txt", "notes/{2.txt => 3.txt}");
testRenamedString("notes/3.txt", "bandzak/src/3.txt", "{notes => bandzak/src}/3.txt");
testRenamedString("bandzak/src/3.txt", "bandzak/src/nl/3.txt", "bandzak/src/{ => nl}/3.txt");
testRenamedString("notes/3.txt", "notes/2.txt", "notes/{3.txt => 2.txt}");
testRenamedString("bandzak/src/3.txt", "notes/3.txt", "{bandzak/src => notes}/3.txt");
testRenamedString("bandzak/src/nl/3.txt", "bandzak/src/3.txt", "bandzak/src/{nl => }/3.txt");

sub testRenamedString {
    my ($from, $to, $string) = @_;
    my $ren = RenamedString($from, $to);
    print "$from => $to\n$ren\n$string\n\n";
    if ($ren ne $string) {
        die "Incorrect string";
    }
}
