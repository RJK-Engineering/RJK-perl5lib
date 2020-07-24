use strict;
use warnings;

use RJK::Options::Pod;

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

RJK::Options::Pod::GetOptions(
    # must start with array ref containing section header!
    ['POD'],
    RJK::Options::Pod::Options,
    ['HELP'],
    RJK::Options::Pod::HelpOptions
);

@ARGV || RJK::Options::Pod::pod2usage(
    -sections => "DESCRIPTION|SYNOPSIS|DISPLAY EXTENDED HELP"
);

###############################################################################
