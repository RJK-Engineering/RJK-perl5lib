package RJK::OpenUrl;

use strict;
use warnings;

use RJK::Win32::ProcessList;

my $chrome = 'c:\Program Files\Google\Chrome\Application\chrome.exe';
my $firefox = 'c:\Program Files\Mozilla Firefox\firefox.exe';

sub Open {
    my ($url, $detect) = @_;

    my $browser = $firefox;
    if ($detect) {
        my @p = RJK::Win32::ProcessList::GetProcessList('firefox.exe');
        if (@p) {
            $browser = $firefox;
        } else {
            #~ @p = RJK::Win32::ProcessList::GetProcessList('chrome.exe');
            #~ $browser = $chrome if @p;
            $browser = $chrome;
        }
    }
    system $browser, $url;
}

1;
