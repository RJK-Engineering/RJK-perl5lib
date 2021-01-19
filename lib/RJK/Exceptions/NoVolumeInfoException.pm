package NoVolumeInfoException;
use parent 'Exception';

use Exception::Class (
    'NoVolumeInfoException' =>
        { isa => 'Exception' },
);

1;
