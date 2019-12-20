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

Options::Pod::GetOptions(
    # must start with array ref containing section header!
    ['POD'],
    Options::Pod::Options,
    ['HELP'],
    Options::Pod::HelpOptions
);

@ARGV || Options::Pod::pod2usage(
    -sections => "DESCRIPTION|SYNOPSIS|DISPLAY EXTENDED HELP"
);

###############################################################################
