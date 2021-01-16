use Data::Dump;
use RJK::File::Stats;

my $testDir = 'c:\temp\1';
die "Testdir does not exist: $testDir" if !-e $testDir;

my $stats = RJK::File::Stats->traverse($testDir);
dd $stats;

RJK::File::Stats->traverse($testDir, undef, undef, $stats);
dd $stats;

$stats = RJK::File::Stats->createStats();
RJK::File::Stats->traverse($testDir, undef, undef, $stats);
dd $stats;
