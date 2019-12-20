use strict;
use warnings;

use Options::Pod;

###############################################################################
=head1 DESCRIPTION

THIS IS A TEMPLATE.

=head1 SYNOPSIS

script.pl [options] [arguments]

=head1 DISPLAY EXTENDED HELP

script.pl -h

=for options start

=cut
###############################################################################

my %opts;
Options::Pod::GetOptions(
    # must start with array ref containing section header!
    ['OPTIONS'],
    'v|switch' => \$opts{verbose}, "Description",
    's|string=s' => \$opts{string}, "Description {argumentname}",
    'i|integer=i' => \$opts{integer}, "Description {integer}",
    'e|extendedint=o' => \$opts{extended}, "Description {extendedintegerperlstyle}",
    'f|realnumber=f' => \$opts{float}, "Description {real}",

    ['POD'],
    Options::Pod::Options,
    ['HELP'],
    Options::Pod::HelpOptions("DESCRIPTION|SYNOPSIS|OPTIONS|POD|HELP")
);

@ARGV || Options::Pod::pod2usage(
    -sections => "DESCRIPTION|SYNOPSIS|DISPLAY EXTENDED HELP"
);

###############################################################################
