package OpenFileException;
use parent 'FileException';

use Exception::Class (
    'OpenFileException' => {
        isa => 'FileException',
        fields => ['mode']
    }
);

1;
