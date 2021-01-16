package RJK::File::TreeVisitResult;
use parent 'RJK::TreeVisitResult';

use strict;
use warnings;

use RJK::TreeVisitResult qw(:constants matchesTreeVisitResult);

use constant {
    SKIP_DIRS => bless([], 'RJK::File::TreeVisitResult'),
    SKIP_FILES => bless([], 'RJK::File::TreeVisitResult'),
};

push our @ISA, 'Exporter';
use Exporter ();
our @EXPORT = (@RJK::TreeVisitResult::EXPORT, qw(SKIP_DIRS SKIP_FILES));
our @EXPORT_OK = (@EXPORT, 'matchesTreeVisitResult');
our %EXPORT_TAGS = (constants => \@EXPORT);

1;
