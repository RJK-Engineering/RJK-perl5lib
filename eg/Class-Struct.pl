use Class::Struct;

struct Media::Timecode => {
    dateTime => '*DateTime',
    seconds => '$',
    frames => '$',
    fps => '$',
    time => '$',
    duration => '*DateTime::Duration',
}; # no call to init like Class::AccessorMaker does

