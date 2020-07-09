use strict;
use warnings;

use RJK::Util::JSON;

my $file = 'JSON.pm.test.json';
open my $fh, '>', $file or die "$!";
print $fh '{ "key": [ "value1", "value2" ] }';
close $fh;

my $data = RJK::Util::JSON->read($file);
use Data::Dump;
dd $data;

my $file2 = 'JSON.pm.test2.json';
$data = { key => [ qw(value1 value2) ] };
RJK::Util::JSON->write($file2, $data);
