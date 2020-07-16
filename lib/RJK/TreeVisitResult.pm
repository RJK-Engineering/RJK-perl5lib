package RJK::TreeVisitResult;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::File::TreeVisitResultException' => {
        isa => 'Exception',
        fields => ['result']
    }
);

use constant {
    CONTINUE => bless([], 'RJK::TreeVisitResult'),
    TERMINATE => bless([], 'RJK::TreeVisitResult'),
    SKIP_SUBTREE => bless([], 'RJK::TreeVisitResult'),
    SKIP_SIBLINGS => bless([], 'RJK::TreeVisitResult'),
};

our @ISA = 'Exporter';
use Exporter ();
our @EXPORT = qw(CONTINUE TERMINATE SKIP_SUBTREE SKIP_SIBLINGS);
our @EXPORT_OK = (@EXPORT, 'matchesTreeVisitResult');
our %EXPORT_TAGS = (constants => \@EXPORT);

sub matchesTreeVisitResult {
    my $result = shift || return 0;
    foreach (@_) {
        return 1 if $_ == $result;
    }
    return 0;
}

1;
