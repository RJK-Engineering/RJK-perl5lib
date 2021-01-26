use strict;
use warnings;

use Data::Dump;
use RJK::Util::TSV;

my $testFile = 'TSV~.tsv';
&writeTestFile;

my $rows = RJK::Util::TSV->read($testFile);
dd $rows;

unlink $testFile;

sub writeTestFile {
    open my $fh, '>', $testFile or die "$!: $testFile";
    for (my $i=1; $i<4; $i++) {
        print $fh "$i-a\t$i-b\n";
    }
    close $fh;
}
