package LoadModuleException;
use parent 'ModuleException';

use Exception::Class (
    'LoadModuleException' => {
        isa => 'ModuleException',
        fields => [qw(systemErrno systemError)]
    }
);

1;
