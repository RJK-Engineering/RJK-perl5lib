package RJK::Filecheck::Properties;

use strict;
use warnings;

sub get {
    $_[0]{$_[1]} // "";
}

sub has {
    defined $_[0]{$_[1]} && $_[0]{$_[1]} ne "";
}

sub set {
    $_[0]{$_[1]} = $_[2];
}

sub delete {
    $_[0]{$_[1]} = "";
}

1;
