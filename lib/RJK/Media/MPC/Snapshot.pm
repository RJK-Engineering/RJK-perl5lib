=begin TML

---+ package RJK::Media::MPC::Snapshot

=cut

package RJK::Media::MPC::Snapshot;

use strict;
use warnings;

###############################################################################
=pod

---++++ filename([$filename]) -> $filename
---++++ mediaFilename([$mediaFilename]) -> $mediaFilename
---++++ position([$position]) -> $position
---++++ date([$date]) -> $date
---++++ time([$time]) -> $time
---++++ datetime([$datetime]) -> $datetime
---++++ datetimeArray([$datetimeArray]) -> $datetimeArray

=cut
###############################################################################

use Class::AccessorMaker {
    filename => "",
    extension => "",
    mediaFilename => "",
    position => "",
    date => "",
    time => "",
    datetime => "",
    datetimeArray => "",
}, "no_new";

###############################################################################
=pod

---+++ new($filename) -> $snapshot
Returns a new =RJK::Media::MPC::Snapshot= object or nothing if =$filename= does
not have the proper format.

Filename format with extracted fields in brackets:
   * ={mediaFilename}_snapshot_{position}_[{date}_{time}].{extension}=
Field formats:
   * ={position}= =hh.mm.ss= or =mm.ss= (object attribute format: =hh:mm:ss=)
   * ={date}= =yyyy.mm.dd= (object attribute format: =dd-mm-yyyy=)
   * ={time}= =hh.mm.ss= (object attribute format: =hh:mm:ss=)
Additional object attributes:
   * ={datetime}= datetime string in sortable format: =yyyymmddhhmmss=
   * ={datetimeArray}= array of date/time fields [yyyy, mm, dd, hh, mm, ss]

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{filename} = shift;

    $self->{filename} =~
        /(.+)_snapshot_([\d\.]+)_\[(\d+)\.(\d+)\.(\d+)_(\d+)\.(\d+)\.(\d+)\]\.(.*)/
        || return;

    $self->{extension} = $9;
    $self->{mediaFilename} = $1;
    $self->{position} = $2;
    $self->{date} = "$5-$4-$3";
    $self->{time} = "$6:$7:$8";
    $self->{datetime} = "$3$4$5$6$7$8";
    $self->{datetimeArray} = [$3, $4, $5, $6, $7, $8];

    my $c = $self->{position} =~ s/\./:/g;
    $self->{position} = "00:$self->{position}" if $c == 1;

    return $self;
}

1;
