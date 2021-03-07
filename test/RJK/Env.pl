use strict;
use warnings;

use RJK::Env;

print RJK::Env->subst("%TEMP%"), "\n";

my $byRef1 = "1 %TEMP%";
my $byRef2 = "2 %TEMP%";
print $byRef1, "\t";
print $byRef2, "\n";
RJK::Env->subst(\$byRef1, \$byRef2);
print $byRef1, "\t";
print $byRef2, "\n\n";

my @p = ('C:\asfdsf', 'C:\Program Files');
print '"', join('", "', @p), "\"\n";
@p = RJK::Env->findPath(@p);
print join("\n", @p), "\n\n";

my $p = "RJK-utils/filecheck.properties";
print $p, "\n";
@p = RJK::Env->findLocalFiles($p);
print join("\n", @p), "\n\n";

$p = "Common Files";
print $p, "\n";
@p = RJK::Env->findProgramDirs($p);
print join("\n", @p), "\n";
