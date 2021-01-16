use strict;
use warnings;

use RJK::TreeVisitResult qw(:constants matchesTreeVisitResult);

my $result = undef;
print "fail\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = CONTINUE;
print "fail\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = SKIP_SIBLINGS;
print "ok\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);
