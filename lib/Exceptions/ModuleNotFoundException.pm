package ModuleNotFoundException;
use parent 'ModuleException';

use Exception::Class (
    'ModuleNotFoundException' => {
        isa => 'ModuleException'
    }
);

1;
