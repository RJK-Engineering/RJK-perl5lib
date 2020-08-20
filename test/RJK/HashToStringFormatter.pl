use strict;
use warnings;

use RJK::HashToStringFormatter;

my $format = '%size=5.5 %name';
my $formatter = new RJK::HashToStringFormatter($format);
my $hash = {
    size => '4M',
    name => 'name'
};
print $formatter->format($hash), "\n";
