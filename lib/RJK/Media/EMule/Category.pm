package RJK::Media::EMule::Category;

use strict;
use warnings;

use RJK::Util::Ini;

sub new {
    my $self = bless {}, shift;
    $self->{ini} = new RJK::Util::Ini(shift)->read;
    return $self;
}

sub ini { shift->{ini} }

1;
