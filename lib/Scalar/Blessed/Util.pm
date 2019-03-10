package Scalar::Blessed::Util;

# A selection of general-utility subroutines for blessed scalars.

use Exporter ();
use strict;

our @ISA = qw(Exporter);
our @EXPORT = our @EXPORT_OK = qw(take is_of_type);

sub take (*;$) {
    $_[1] ||= $_;
    return ref $_[1]
        && UNIVERSAL::isa($_[1], $_[0])
        && $_[1];
}

sub is_of_type (*;$) {
    $_[1] ||= $_;
    return ref $_[1]
        && UNIVERSAL::isa($_[1], $_[0]);
}

1;
