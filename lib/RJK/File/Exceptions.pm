package RJK::File::Exceptions;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::File::Exception' => {
        isa => 'Exception',
        fields => ['file']
    },
    'RJK::File::EmptyFileException' => {
        isa => 'RJK::File::Exception'
    },
    'RJK::File::NoFileException' => {
        isa => 'RJK::File::Exception'
    },
    'RJK::File::OpenFileException' => {
        isa => 'RJK::File::Exception'
    }
);

1;
