package DbException;

use Exception::Class (
    'DbException' => {
        isa => 'Exception',
        fields => [qw'dsn user']
     }
);

1;
