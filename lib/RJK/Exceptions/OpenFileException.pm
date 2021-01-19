package OpenFileException;

use Exception::Class (
    'OpenFileException' => {
        isa => 'FileException',
        fields => ['mode']
    }
);

1;
