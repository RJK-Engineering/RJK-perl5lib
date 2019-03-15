package RJK::DB::Table;

use strict;
use warnings;
use Exporter ();

use RJK::DB::Collection;

our @ISA = qw(Exporter);
our @EXPORT = our @EXPORT_OK = qw(table);

sub new {
    my $self = bless {}, shift;
    $self->{name} = shift;
    return $self;
}

sub table {
    unshift @_, __PACKAGE__;
    return &new;
}

sub name {
    return shift->{name};
}

1;
