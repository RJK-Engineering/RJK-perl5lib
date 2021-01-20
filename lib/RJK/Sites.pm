package RJK::Sites;

use strict;
use warnings;

use RJK::Util::JSON;
use RJK::Filecheck::Config;

my $sites;

sub all {
    my ($class, $url) = @_;
    &_getSites;
    return wantarray ? values %$sites : $sites;
}

sub get {
    my ($class, $name) = @_;
    &_getSites;
    return $sites->{$name};
}

sub getForUrl {
    my ($class, $url) = @_;
    &_getSites;

    foreach my $site (values %$sites) {
        return $site if $url =~ /$site->{host}/i;
    }
}

sub getForId {
    my ($class, $id) = @_;
    &_getSites;
    my @sites = sort { ($a->{idRegexPrio}//999) <=> ($b->{idRegexPrio}//999) } values %$sites;

    foreach my $site (@sites) {
        next if ! $site->{idRegex};
        return $site if $id =~ /^$site->{idRegex}$/;
    }
}

sub _getSites {
    return $sites if $sites;

    my $confFilePath = RJK::Filecheck::Config->get('sites.conf.file');
    $sites = RJK::Util::JSON->read($confFilePath);

    while (my ($id, $site) = each %$sites) {
        $site->{id} = $id;
        bless $site, "RJK::Site";
    }
}

1;
