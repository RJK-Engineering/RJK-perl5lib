use RJK::Util::Properties;

my $p = new RJK::Util::Properties();
$p->load(shift);
use Data::Dump;
dd $p;

$p->save("test~.properties");
