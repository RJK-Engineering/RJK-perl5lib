use strict;
use warnings;

use RJK::Options::Pod;

###############################################################################
=head1 DESCRIPTION

THIS IS A TEMPLATE.

=head1 SYNOPSIS

script.pl [options] [arguments]

=for options start

=cut
###############################################################################

my %opts;
RJK::Options::Pod::GetOptions(
    ['OPTIONS'],
    'v|switch' => \$opts{verbose}, "Description",
    's|string=s' => \$opts{string}, "Description {argumentname}",
    'i|integer=i' => \$opts{integer}, "Description {integer}",
    'e|extendedint=o' => \$opts{extended}, "Description {extendedintegerperlstyle}",
    'f|realnumber=f' => \$opts{float}, "Description {real}",

    ['POD'],
    RJK::Options::Pod::Options,
    ['HELP'],
    RJK::Options::Pod::HelpOptions(['help'])
);

@ARGV || RJK::Options::Pod::ShortHelp;

###############################################################################
