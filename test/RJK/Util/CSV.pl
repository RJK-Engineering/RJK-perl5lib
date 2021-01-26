use strict;
use warnings;

use Data::Dump;
use RJK::Util::CSV;

my $testFile = 'CSV~.csv';
&writeTestFile;

my $rows = RJK::Util::CSV->read($testFile);
dd $rows;

unlink $testFile;

sub writeTestFile {
    open my $fh, '>', $testFile or die "$!: $testFile";
    for (my $i=1; $i<4; $i++) {
        print $fh "$i-a,$i-b\n";
    }
    close $fh;
}
