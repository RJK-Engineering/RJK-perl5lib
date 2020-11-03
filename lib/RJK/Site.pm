package RJK::Site;

use strict;
use warnings;

sub getDownloadUrl {
    my ($self, $id) = @_;
    return sprintf "$self->{protocol}://$self->{host}/$self->{downloadPath}", $id;
}

sub getSearchUrl {
    my ($self, $query) = @_;
    return sprintf "$self->{protocol}://$self->{host}/$self->{searchPath}", $query;
}


1;
