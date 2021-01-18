package RJK::Exception;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::Exception' => {
        isa => 'Exception'
    }
);

1;
