###############################################################################
=begin TML

---+ package RJK::TotalCmd::CompareResult

=cut
###############################################################################

package RJK::TotalCmd::CompareResult;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::CompareResult::Exception' =>
        { isa => 'Exception' },
);

###############################################################################
=pod

---++ Object attributes

Return object attribute value if called with no arguments, set object
attribute value and return the same value otherwise.

---+++ dirs($dirs) -> $dirs
---+++ left($left) -> $left
---+++ right($right) -> $right
---+++ dupes($dupes) -> $dupes
Files which exist on both sides.
---+++ singles($singles) -> $singles
Files which exist on one side only.

=cut
###############################################################################

use Class::AccessorMaker {
    dirs => undef,
    left => undef,
    right => undef,
    dupes => undef,
    singles => undef,
}, "no_new";

###############################################################################
=pod

---++ Object creation

---+++ new($path) -> $compareResult
Returns a new =RJK::TotalCmd::CompareResult= object for compare results
stored in text file =$path=.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift;
    return $self;
}

###############################################################################
=pod

---++ File access

---+++ read() -> $diskDirFile
Read data from file. Returns false on failure, callee on success.

=cut
###############################################################################

sub read {
    my ($self) = @_;

    open (my $fh, '<', $self->{path})
        || throw RJK::TotalCmd::CompareResult::Exception("$!");

    my (%dirs, @left, @right, @dupes, @singles);
    my $dt = '\d\d-\d\d-\d\d \d\d:\d\d:\d\d';

    my $dir = '/';
    while (<$fh>) {
        chomp;
        if (/(.*)\\$/) {
            $dir = $1;
        } elsif (/(.*) (\d+)\s+($dt) (X |!=|= |<-|->|  ) ($dt) (\d+)\s+(.*)/) {
            push @{$dirs{$dir}}, [ $1, $4, $7 ];
            push @dupes, "$dir\\$1";
        } elsif (/^(.*) (\d+)\s+($dt)( X | ->|)()()()/) {
            push @{$dirs{$dir}}, [ $1, $4, $7 ];
            push @left, "$dir\\$1";
            push @singles, "$dir\\$1";
        } elsif (/^()()()            (X |<-|  ) ($dt) (\d+)\s+(.*)/) {
            push @{$dirs{$dir}}, [ $1, $4, $7 ];
            push @right, "$dir\\$7";
            push @singles, "$dir\\$7";
        } elsif (/\S/) {
            throw RJK::TotalCmd::CompareResult::Exception("Unmatched: $_");
        }
    }
    close $fh;

    $self->{dirs} = \%dirs;
    $self->{left} = \@left;
    $self->{right} = \@right;
    $self->{dupes} = \@dupes;
    $self->{singles} = \@singles;

    return $self;
}

1;
