use strict;
use warnings;

use RJK::TreeVisitResult;

my $result = undef;
print "fail\n" if RJK::TreeVisitResult::isResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = CONTINUE;
print "fail\n" if RJK::TreeVisitResult::isResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = SKIP_SIBLINGS;
print "ok\n" if RJK::TreeVisitResult::isResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);
