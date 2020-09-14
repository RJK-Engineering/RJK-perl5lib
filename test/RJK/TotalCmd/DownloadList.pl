use strict;
use warnings;

use RJK::TotalCmd::DownloadList;

my $dlistfile = 'dlist.txt';

my $dlist = new RJK::TotalCmd::DownloadList();
# Skip all + Skip all which cannot be opened for reading
$dlist->addFlags("136");
$dlist->addCopy("C:\\from", "C:\\to");
$dlist->addCopy("C:\\from");
$dlist->addClearFlags();

$dlist->write($dlistfile);
