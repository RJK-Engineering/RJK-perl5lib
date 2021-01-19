package FileException;

use Exception::Class (
    'FileException' => {
        isa => 'Exception',
        fields => ['file']
    }
);

1;
