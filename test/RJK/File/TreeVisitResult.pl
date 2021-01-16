use strict;
use warnings;

use RJK::File::TreeVisitResult qw(:constants matchesTreeVisitResult);

my $result = undef;
print "fail\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = CONTINUE;
print "fail\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = SKIP_SIBLINGS;
print "ok\n" if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

$result = SKIP_FILES;
print "ok\n" if matchesTreeVisitResult($result, SKIP_FILES);

$result = SKIP_DIRS;
print "ok\n" if matchesTreeVisitResult($result, SKIP_DIRS);
