use Data::Dump;
use RJK::Stats;

my $testDir = 'c:\temp\1';
die "Testdir does not exist: $testDir" if !-e $testDir;

my $stats = RJK::Stats->traverse($testDir);
dd $stats;

RJK::Stats->traverse($testDir, undef, undef, $stats);
dd $stats;

$stats = RJK::Stats->createStats();
RJK::Stats->traverse($testDir, undef, undef, $stats);
dd $stats;
