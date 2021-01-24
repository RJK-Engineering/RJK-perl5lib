package OpenDirException;
use parent 'FileException';

use Exception::Class (
    'OpenDirException' => {
        isa => 'FileException'
    }
);

1;
