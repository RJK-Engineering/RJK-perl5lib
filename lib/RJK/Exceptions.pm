package RJK::File::Exceptions;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::Exception' => {
        isa => 'Exception'
    }
);

1;
