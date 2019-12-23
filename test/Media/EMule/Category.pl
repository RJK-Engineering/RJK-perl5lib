use strict;
use warnings;

use Media::EMule::Category;
use RJK::LocalFile;

my %opts;
$opts{categoryIni} = '';

if (! $opts{categoryIni}) {
    my $file = 'eMule\config\Category.ini';
    $opts{categoryIni} = RJK::LocalFile::GetLocalFile($file)
        or die "Category.ini not found";
}

use Data::Dump;

my $c = new Media::EMule::Category($opts{categoryIni});
dd $c->ini->sections;
