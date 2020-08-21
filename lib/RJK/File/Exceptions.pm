package RJK::File::Exceptions;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::FileException' => {
        isa => 'Exception',
        fields => ['file']
    },
    'RJK::OpenFileException' => {
        isa => 'RJK::FileException',
        fields => ['mode']
    }
);

1;
