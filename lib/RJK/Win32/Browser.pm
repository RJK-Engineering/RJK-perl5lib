package RJK::Win32::Browser;

use strict;
use warnings;

use RJK::Win32::ProcessList;

my $browsers = {
    default => 'firefox',
    chrome => 'c:\Program Files\Google\Chrome\Application\chrome.exe',
    firefox => 'c:\Program Files\Mozilla Firefox\firefox.exe'
};

sub openUrl {
    my ($self, $url, $browser) = @_;
    $browser ||= $browsers->{default} || 'detect';
    if ($browser eq 'detect') {
        $browser = &detect;
        if (! $browser) {
            warn "Can't find browser";
            return;
        }
    }
    if (! $browsers->{$browser}) {
        warn "Unknown browser: $browser";
        return;
    }
    system $browsers->{$browser}, $url;
}

sub detect {
    if (RJK::Win32::ProcessList->processExists('firefox.exe')) {
        return 'firefox';
    } elsif (RJK::Win32::ProcessList->processExists('chrome.exe')) {
        return 'chrome';
    }
}

1;
