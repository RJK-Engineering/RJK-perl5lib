package RJK::Filecheck;

use strict;
use warnings;
no warnings 'redefine';

use RJK::Filecheck::NameParser;
use RJK::Util::JSON;

sub createNameParser {
    my ($self, $filenamesConfDir) = @_;
    my $nameParser = new RJK::Filecheck::NameParser();

    opendir my $dh, $filenamesConfDir or die "$!: $filenamesConfDir";
    while (readdir $dh) {
        next unless /\.json$/;
        my $conf = RJK::Util::JSON->read("$filenamesConfDir/$_");
        $nameParser->addConf($conf);
    }
    closedir $dh;

    return $nameParser;
}

1;
