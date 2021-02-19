package SqlException;
use parent 'DbException';

use Exception::Class (
    'SqlException' => {
        isa => 'DbException',
        fields => [qw'stmt bound']
     }
);

1;
