package FileException;
use parent 'Exception';

use Exception::Class (
    'FileException' => {
        isa => 'Exception',
        fields => ['file']
    }
);

1;
