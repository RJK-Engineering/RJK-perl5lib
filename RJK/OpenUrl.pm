package RJK::OpenUrl;

use strict;
use warnings;

use ProcessList;

my $chrome = 'c:\Program Files\Google\Chrome\Application\chrome.exe';
my $firefox = 'c:\Program Files\Mozilla Firefox\firefox.exe';

sub Open {
    my ($url, $detect) = @_;

    my $browser = $firefox;
    if ($detect) {
        my @p = ProcessList::GetProcessList('firefox.exe');
        if (@p) {
            $browser = $firefox;
        } else {
            #~ @p = ProcessList::GetProcessList('chrome.exe');
            #~ $browser = $chrome if @p;
            $browser = $chrome;
        }
    }
    system $browser, $url;
}

1;
