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
    ['HELP'],
    Options::Pod::HelpOptions("DESCRIPTION|SYNOPSIS|HELP|POD"),
    ['POD'],
    Options::Pod::Options
);

@ARGV || Options::Pod::pod2usage(
    -sections => "DESCRIPTION|SYNOPSIS|DISPLAY EXTENDED HELP"
);

###############################################################################
