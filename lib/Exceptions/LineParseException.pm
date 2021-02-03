package LineParseException;

use Exception::Class (
    'LineParseException' => {
        isa => 'Exception',
        fields => ['file', 'line']
    }
);

1;
