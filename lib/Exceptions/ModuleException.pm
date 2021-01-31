package ModuleException;

use Exception::Class (
    'ModuleException' => {
        isa => 'Exception',
        fields => [qw(module)]
    }
);

1;
