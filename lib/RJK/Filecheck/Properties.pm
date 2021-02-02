package RJK::Filecheck::Properties;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{props} = shift // {};
    return $self;
}

sub properties {
    $_[0]{props};
}

sub get {
    $_[0]{props}{$_[1]} // "";
}

sub has {
    defined $_[0]{props}{$_[1]} && $_[0]{props}{$_[1]} ne "";
}

sub set {
    $_[0]{props}{$_[1]} = $_[2];
}

sub delete {
    $_[0]{props}{$_[1]} = "";
}

1;
