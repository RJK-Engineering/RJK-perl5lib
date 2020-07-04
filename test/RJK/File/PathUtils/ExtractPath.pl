use strict;
use warnings;

use RJK::File::PathUtils qw(ExtractPath);

print ExtractPath('ksdjf=c:sdf'), "\n";
print ExtractPath(' c:/sdf'), "\n";
print ExtractPath(' c:/sdf//'), "\n";
print ExtractPath(' c:/sdf//ee\ggg'), "\n";
print ExtractPath('ksdjf=/sdf'), "\n";
print ExtractPath(' /sdf'), "\n";
print ExtractPath(' /sdf//'), "\n";
print ExtractPath(' /sdf//ee\ggg'), "\n";
