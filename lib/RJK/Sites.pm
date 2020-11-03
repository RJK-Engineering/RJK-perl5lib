package RJK::Sites;

use strict;
use warnings;

use RJK::Util::JSON;

my $sites;

sub get {
    my ($class, $url) = @_;
    _getSites();
    my @sites = values %$sites;
    foreach my $site (@sites) {
        return $site if $url =~ /$site->{host}/i;
    }
}

sub getForId {
    my ($class, $id) = @_;
    _getSites();
    my @sites = sort { ($a->{idRegexPrio}//0) <=> ($b->{idRegexPrio}//0) } values %$sites;
    foreach my $site (@sites) {
        next if ! $site->{idRegex};
        return $site if $id =~ /^$site->{idRegex}$/;
    }
}

sub _getSites {
    return $sites if $sites;
    my $confFilePath = "%LOCALAPPDATA%\\RJK-utils\\sites.json";
    $confFilePath =~ s/%(.+)%/$ENV{$1}/g;
    $sites = RJK::Util::JSON->read($confFilePath);
    while (my ($id, $site) = each %$sites) {
        $site->{id} = $id;
        bless $site, "RJK::Site";
    }
}

1;
