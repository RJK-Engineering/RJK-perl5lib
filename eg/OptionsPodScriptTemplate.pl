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

=head1 HELP OPTIONS

=over 4

=item B<-h --help -?>

Display this extended help.

=item B<-hh "--help --help" -??>

Display message options.

=item B<-hhh "--help --help --help" -???>

Display POD options.

=item B<-hhhh "--help --help --help --help" -????>

Display complete help.

=back

=head1 CONFIGURATION OPTIONS

=over 4

=item B<-f --force>

Force.

=back

=head1 MESSAGE OPTIONS

=over 4

=item B<-v --verbose>

Be verbose.

=item B<-q --quiet>

Be quiet.

=item B<--debug>

Display debug information.

=back

=head1 POD OPTIONS

=over 4

=item B<--podcheck>

Run podchecker.

=item B<--pod2html --html [path]>

Run pod2html. Writes to [path] if specified. Writes to
F<[path]/{scriptname}.html> if [path] is a directory.
E.g. C<--html .> writes to F<./{scriptname}.html>.

=item B<--genpod>

Generate POD for options.

=item B<--writepod>

Write generated POD to script file.
The POD text will be inserted between C<=for options start> and
C<=for options end> tags.
If no C<=for options end> tag is present, the POD text will be
inserted after the C<=for options start> tag and a
C<=for options end> tag will be added.
A backup is created.

=back

=for options end

=cut
###############################################################################


###############################################################################
=head1 GETOPT LONG

https://perldoc.perl.org/Getopt/Long.html

The argument specification is optional. If omitted, the option is considered
boolean, a value of 1 will be assigned when the option is used.

!   The option does not take an argument and may be negated by prefixing
    it with "no" or "no-". E.g. "foo!" will allow --foo (a value of 1
    will be assigned) as well as --nofoo and --no-foo (a value of 0 will
    be assigned). If the option has aliases, this applies to the aliases
    as well.
    Using negation on a single letter option when bundling is in effect is
    pointless and will result in a warning.

+   The option does not take an argument and will be incremented by 1
    every time it appears on the command line. E.g. "more+" , when used with
    --more --more --more, will increment the value three times, resulting in
    a value of 3 (provided it was 0 or undefined at first).
    The + specifier is ignored if the option destination is not a scalar.

= type [ desttype ] [ repeat ]
    The option requires an argument of the given type. Supported types are:
    s - String. An arbitrary sequence of characters. It is valid for the
        argument to start with - or -- .
    i - Integer. An optional leading plus or minus sign, followed by a
        sequence of digits.
    o - Extended integer, Perl style. This can be either an optional leading
        plus or minus sign, followed by a sequence of digits, or an octal string
        (a zero, optionally followed by '0', '1', .. '7'), or a hexadecimal
        string (0x followed by '0' .. '9', 'a' .. 'f', case insensitive), or a
        binary string (0b followed by a series of '0' and '1').
    f - Real number. For example 3.14 , -6.23E24 and so on.

    The desttype can be @ or % to specify that the option is list or a hash
    valued. This is only needed when the destination for the option value is
    not otherwise specified. It should be omitted when not needed.

    The repeat specifies the number of values this option takes per
    occurrence on the command line.
    It has the format { [ min ] [ , [ max ] ] }.

    min denotes the minimal number of arguments. It defaults to 1 for
    options with = and to 0 for options with : , see below. Note that min
    overrules the = / : semantics.

    max denotes the maximum number of arguments. It must be at least min. If
    max is omitted, but the comma is not, there is no upper bound to the
    number of argument values taken.

: type [ desttype ]
    Like = , but designates the argument as optional. If omitted, an empty
    string will be assigned to string values options, and the value zero to
    numeric options.
    Note that if a string argument starts with - or -- , it will be
    considered an option on itself.

: number [ desttype ]
    Like :i , but if the value is omitted, the number will be assigned.

: + [ desttype ]
    Like :i , but if the value is omitted, the current value for the option
    will be incremented.

=cut
###############################################################################

my %opts = ();
Options::Pod::GetOptions(
    ['HELP OPTIONS'],
    Options::Pod::HelpOptions([
        [ "DESCRIPTION|SYNOPSIS|HELP OPTIONS|CONFIGURATION OPTIONS", "Display this extended help." ],
        [ "MESSAGE OPTIONS", "Display message options." ],
        [ "POD OPTIONS", "Display POD options." ],
        [ "", "Display complete help." ]
    ]),

    ['CONFIGURATION OPTIONS'],
    'f|force' => \$opts{force}, "Force.",

    ['MESSAGE OPTIONS'],
    Options::Pod::MessageOptions(\%opts),

    ['POD OPTIONS'],
    Options::Pod::Options
) || Options::Pod::pod2usage(
    -sections => "DISPLAY EXTENDED HELP",
);

$opts{required} //
@ARGV || Options::Pod::pod2usage(
    -sections => "DESCRIPTION|SYNOPSIS|DISPLAY EXTENDED HELP",
);

# quiet!
$opts{verbose} = 0 if $opts{quiet};

###############################################################################
