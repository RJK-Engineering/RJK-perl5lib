package Media::EMule::Category;

use strict;
use warnings;

use File::Ini;

sub new {
    my $self = bless {}, shift;
    $self->{ini} = new File::Ini(shift)->read;
    return $self;
}

sub ini { shift->{ini} }

1;
