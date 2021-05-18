package RJK::Filecheck::VirtualPath;
use parent 'RJK::Path';

use strict;
use warnings;

sub label { $_[0]{label} }
sub relative { $_[0]{relative} }

1;
