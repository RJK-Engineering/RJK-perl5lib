use strict;
use warnings;

use RJK::TableRowFormatter;

my $format = '%size=5.5 %name';
my $formatter = new RJK::TableRowFormatter($format);
my $hash = {
    size => '4M',
    name => 'str'
};
print $formatter->format($hash), "\n";
