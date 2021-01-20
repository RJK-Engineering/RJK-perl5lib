use strict;
use warnings;

use RJK::Sites;
use Data::Dump;

my $sites = RJK::Sites->all();
dd $sites;

my $site = RJK::Sites->get("youtube");
dd $site;

my $site = RJK::Sites->getForUrl("https://www.youtube.com/watch?v=4-TwdBuTR1A&list=PLTOBJKrkhpoMdsT9RUERSDdEVrViykAEQ&index=17");
dd $site;
