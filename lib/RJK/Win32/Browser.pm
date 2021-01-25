package RJK::Win32::Browser;

use strict;
use warnings;

use RJK::Win32::ProcessList;

my $browsers = {
    default => 'chrome',
    chrome => 'c:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    firefox => 'c:\Program Files\Mozilla Firefox\firefox.exe'
};

# $browser == -1       use default browser
# $browser == 0        detect browser, do not open new browser if none found
# $browser == 1        detect browser, open default browser if none found
# $browser == undef    same as $browser == 1
# $browser == "name"   use browser "name"
sub openUrl {
    my ($self, $url, $browser) = @_;
    if (not defined $browser or $browser =~ /^1$/) {
        $browser = &detect;
        $browser //= $browsers->{default};
    } elsif ($browser =~ /^-1$/) {
        $browser = $browsers->{default};
    } elsif ($browser =~ /^0?$/) {
        $browser = &detect;
        $browser // return;
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
    warn "Can't find browser";
    return undef;
}

1;
