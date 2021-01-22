use strict;
use warnings;

use RJK::Env;

print RJK::Env->subst("%TEMP%"), "\n";

my $byRef1 = "1 %TEMP%";
my $byRef2 = "2 %TEMP%";
RJK::Env->subst(\$byRef1, \$byRef2);
print $byRef1, "\n";
print $byRef2, "\n";
