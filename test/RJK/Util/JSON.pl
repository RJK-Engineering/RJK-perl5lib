use strict;
use warnings;

use RJK::Util::JSON;

my $testDir = 'c:\temp\root';
my $file = "$testDir/JSON.pm.test.json";
createFile($file, '{ "key": [ "value1", "value2" ] }');

my $data = RJK::Util::JSON->read($file);
use Data::Dump;
dd $data;
unlink $file;

$file = "$testDir/JSON.pm.test2.json";
$data = { key => [ qw(value1 value2) ] };
RJK::Util::JSON->write($file, $data);
RJK::Util::JSON->read($file);
unlink $file;

sub createFile {
    my ($file, $content) = @_;
    open my $fh, '>', $file or die "$!: $file";
    print $fh $content;
    close $fh;
}
