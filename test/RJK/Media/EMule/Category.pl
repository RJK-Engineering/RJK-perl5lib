use strict;
use warnings;

use RJK::Env;
use RJK::Media::EMule::Category;

my %opts;
$opts{categoryIni} = '';

if (! $opts{categoryIni}) {
    my $file = 'eMule\config\Category.ini';
    $opts{categoryIni} = RJK::Env->findLocalFile($file)
        or die "Category.ini not found";
}

use Data::Dump;

my $c = new RJK::Media::EMule::Category($opts{categoryIni});
dd $c->ini->sections;
