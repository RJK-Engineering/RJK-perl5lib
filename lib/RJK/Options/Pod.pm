=begin TML

---+ package RJK::Options::Pod

---++ Synopsis

<verbatim class="perl">
RJK::Options::Pod::Configure(
    "bundling",                     # if not set, long options will have
                                    # a single dash in generated POD
    "comments_included",            # indicates comments are present in
                                    # GetOptions() configuration
    "tri-state"
);
RJK::Options::Pod::GetOptions(
    ['No argument name'],           # POD: =head2 No argument name
    'option1=s' => ...,             # POD: --option1 [string]
        "Description of option.",
    'option2=i' => ...,             # POD: --option2 [integer]
        "Description of option.",
    'option3=o' => ...,             # POD: --option3 [extended integer]
        "Description of option.",
    'option4=f' => ...,             # POD: --option4 [real number]
        "Description of option.",

    ['Argument name',
        "Additional POD text"
    ],
    'option5=s' => ...,             # POD: --option5 [argument name]
        [ "Set argument name.", "argument name" ],
    'option6=s' => ...,             # POD: --option6 [argument name]
        "{Argument name} in option description.",
    'option7=s' => ...,             # POD: --option7 [arg]
        [ "Set complete option description.", "", "--option7 [arg]" ],
    'tri-state:0' => ...,

    ['Pod'],
    RJK::Options::Pod::Options      # podcheck, pod2html, genpod and writepod options
);
</verbatim>

Command Line:

<verbatim class="bash">
perl script.pl --podcheck
perl script.pl --pod2html
perl script.pl --genpod
perl script.pl --genpod --writepod
perl script.pl +tri-state
</verbatim>

---++ Description

This package adds the following functionality using
[[http://perldoc.perl.org/Getopt/Long.html][Getopt::Long]]:

   * Option to call [[http://perldoc.perl.org/podchecker.html][podchecker]].
   * Option to call [[http://perldoc.perl.org/pod2html.html][pod2html]].
   * Option to generate POD from [[http://perldoc.perl.org/Getopt/Long.html][Getopt::Long]] configuration.
   * Option to write generated POD to the script it was generated from.
   * Tri-state options.

---++ Tri-state options

When the =tri-state= option is enabled the value of options starting
with a =+= will be set to =1=.

Example:

<verbatim>
RJK::Options::Pod::Configure("tri-state");
my @options = ('tri-state:0' => ...);
</verbatim>

| *Option*      | *Value*                           | *Meaning*  |
| =-tri-state=  | =0= (argument specification ":0") | disabled   |
| =+tri-state=  | =1=                               | enabled    |
| not specified | =undef= or a default value        | don't care |

---++ TODO

<verbatim>

add "default: .." if option specifies ":<value>"
- default for
   - string values = ""
   - numeric values = 0
   - "+" = increments

</verbatim>

=cut

package RJK::Options::Pod;

use strict;
use warnings;

use Getopt::Long qw();
use Pod::Checker qw(podchecker);
use Pod::Html    qw(pod2html);
use Pod::Usage   qw();

my %conf = (
    'tri-state' => 0,
    comments_included => 1,
);
my %getoptConf = (
    bundling => 1,
);

my %opts;
my $optConf;
my $helpLevels = [[]];

my $optionSectionStart = '=for options start';
my $optionSectionEnd = '=for options end';

###############################################################################
=pod

---++ Functions

---+++ Configure(@options)

See: [[http://perldoc.perl.org/Getopt/Long.html#Configuring-Getopt%3a%3aLong][Configuring Getopt::Long]]

Additional options:

   * =comments_included= - Every 3rd element in the configuration array
     contains comments. This will be used for POD generation.
   * =tri-state= - Enable tri-state options.

=cut
###############################################################################

sub Configure {
    my @opts = @_;
    foreach (@opts) {
        if (exists $conf{$_}) {
            $conf{$_} = 1;
        } else {
            $getoptConf{$_} = 1
        }
    }
    return;
}

###############################################################################
=pod

---+++ Options() -> @configuration

Returns POD functionality options.

=cut
###############################################################################

sub Options {
    return
    'podcheck' => sub {
        my $r = podchecker($0);
        print "$0 pod syntax OK.\n" unless $r;
        exit $r;
    }, $conf{comments_included} ?
        "Run podchecker." : (),

    'pod2html|html:s' => sub {
        my $outfile = $_[1];
        if (-d $outfile) {
            my $filename = $0;
            $filename =~ s|^.*[\\\/]||;
            $filename =~ s|\.pl$||;
            $outfile = "$outfile/$filename.html";
        }
        pod2html($0, $outfile ? "--outfile=$outfile" : ());
        unlink 'pod2htmd.tmp';
        exit;
    }, $conf{comments_included} ? [
        "Run pod2html. Writes to [path] if specified. Writes to\n".
        "F<[path]/{scriptname}.html> if [path] is a directory.\n".
        "E.g. C<--html .> writes to F<./{scriptname}.html>.", "path" ] : (),

    'genpod' => \$opts{generatePod}, $conf{comments_included} ?
        "Generate POD for options." : (),
    'writepod' => \$opts{writePod}, $conf{comments_included} ?
        "Write generated POD to script file.\n".
        "The POD text will be inserted between C<$optionSectionStart> and\n".
        "C<$optionSectionEnd> tags.\n".
        "If no C<$optionSectionEnd> tag is present, the POD text will be\n".
        "inserted after the C<$optionSectionStart> tag and a\n".
        "C<$optionSectionEnd> tag will be added.\n".
        "A backup is created." : ()
}

sub HelpOptions {
    $helpLevels = shift;
    my $optionNames = shift || 'h|help';

    if (ref $helpLevels) {
        $helpLevels = [ $helpLevels ] if ! ref $helpLevels->[0];
    } elsif (defined $helpLevels) {
        die "Invalid parameters to ".__PACKAGE__."::HelpOptions";
    } else {
        $helpLevels = [
            [ "OPTIONS", "Display program options." ],
            [ "HELP", "Display help options." ],
            [ "POD", "Display POD options." ],
            [ "", "Display complete help." ]
        ];
    }

    my $repeat = @$helpLevels > 1 ? "+" : "";
    return
    "$optionNames|?$repeat" => \$opts{help}, $conf{comments_included} ? "Display extended help." : ();
}

sub MessageOptions {
    my $opts = shift;
    return
    'v|verbose' => \$opts->{verbose}, $conf{comments_included} ? "Be verbose." : (),
    'q|quiet' => \$opts->{quiet}, $conf{comments_included} ? "Be quiet." : (),
    'debug' => \$opts->{debug}, $conf{comments_included} ? "Display debug information." : ();
}

###############################################################################
=pod

---+++ !GetOptions(@configuration or \@configuration)

See: [[http://perldoc.perl.org/Getopt/Long.html][Getopt::Long]]

=cut
###############################################################################

sub GetOptions {
    @$optConf = @_;

    Getopt::Long::Configure(grep { $getoptConf{$_} } keys %getoptConf);

    if ($conf{'tri-state'}) {
        # values: 0=disabled, 1=enabled, 2=don't care
        # "-option" = disable option = value 0 (getopt spec: 'option:0')
        # "+option" = enable option = value 1
        # option not specified = default value $opts{option} = 2
        @ARGV = map { /^\+/ ? ($_, 1) : $_ } @ARGV;
    }

    my @getoptOptConf;
    my $paramsPerOption = $conf{comments_included} ? 3 : 2;
    for (my $i=0; $i<@$optConf; $i+=$paramsPerOption) {
        if (ref $optConf->[$i]) {
            $i -= $paramsPerOption - 1;
            next;
        }
        push @getoptOptConf, $optConf->[$i], $optConf->[$i+1];
    }

    my $go = Getopt::Long::GetOptions(@getoptOptConf);
    if ($go) {
        HandleOptions();
    } else {
        pod2usage(-sections => "DISPLAY EXTENDED HELP");
    }

    return $go;
}

###############################################################################
=pod

---+++ !HandleOptions()

Handle configured options.

=cut
###############################################################################

sub HandleOptions {
    my $sections;
    my $exitstatus;

    if ($opts{help}) {
        $sections = $helpLevels ? $helpLevels->[$opts{help} - 1][0] : "";
        $sections ||= "DESCRIPTION|SYNOPSIS|OPTIONS";
    } elsif ($opts{generatePod}) {
        if ($optConf) {
            if ($opts{writePod}) {
                WritePod();
            } else {
                print GeneratePod();
            }
        } else {
            die "No configuration, use ".__PACKAGE__."::GetOptions(..configuration..)";
        }
        exit;
    } elsif ($opts{writePod}) {
        print "Option --writepod without --genpod.\n";
        $sections = "POD";
    }

    if ($sections) {
        Pod::Usage::pod2usage(
            -verbose => 99,
            defined $exitstatus ? (-exitstatus => $exitstatus) : (),
            -sections => $sections,
        );
    }
    return;
}

sub pod2usage {
    my %opts = @_;
    $opts{-verbose} //= 99;
    return Pod::Usage::pod2usage(%opts);
}

sub WritePod {
    my ($sectStart, $sectEnd);

    # look for start and end strings
    open my $fh, '<', $0 or die "$!";
    while (<$fh>) {
        if (/^$optionSectionStart$/) {
            $sectStart = 1;
        } elsif (/^$optionSectionEnd$/) {
            $sectEnd = 1;
            last;
        }
    }
    close $fh;

    if (!$sectStart) {
        print STDERR "Section start tag not found, use \"$optionSectionStart\" where POD should be inserted.\n";
        return;
    }

    local ($^I, @ARGV) = ('.orig', $0);
    my $inSection;
    while (<>) {
        if ($inSection) {
            next if !/^$optionSectionEnd$/;
            print;
            undef $inSection;
        } else {
            print;
            next if !/^$optionSectionStart$/;
            print "\n", GeneratePod();
            if ($sectEnd) {
                # do not print until end tag encountered
                $inSection = 1;
            } else {
                # add missing end tag and continue printing
                print "$optionSectionEnd\n";
            }
        }
    }
    return 1;
}

###############################################################################
=pod

---+++ !GeneratePod() -> $success

Generate POD for command line options.

=cut
###############################################################################

sub GeneratePod {
    my $pod;
    my $paramsPerOption = $conf{comments_included} ? 3 : 2;
    for (my $i=0; $i<@$optConf; $i+=$paramsPerOption) {
        my $ref = $optConf->[$i];
        if (ref $ref) {
            $pod .= "=back\n\n" if $i;
            if (ref $ref->[0]) {
                $pod .= "=head2 $ref->[0][0]\n\n";
            } else {
                $pod .= "=head1 $ref->[0]\n\n";
            }
            $pod .= "=over 4\n\n";
            if ($ref->[1]) {
                # additional pod text
                $ref->[1] =~ s/==/=/g; # unescape
                $pod .= "$ref->[1]\n\n";

                $pod .= "=back\n\n";
                $pod .= "=over 4\n\n";
            }
            $i -= $paramsPerOption - 1;
            next;
        }

        my $doubleDash = $conf{bundling} ? "--" : "-";

        if ($optConf->[$i] eq 'h|help|?+' and $helpLevels) {
            for (my $l=0; $l<@$helpLevels; $l++) {
                my ($podSections, $comment) = @{$helpLevels->[$l]};
                my $q = $l ? '"' : "";
                $pod .= sprintf "=item B<-h%s $q${doubleDash}help%s$q -?%s>\n\n",
                        "h" x $l, " ${doubleDash}help" x $l, "?" x $l;
                $pod .= "$comment\n\n";
            }
            next;
        }

        my ($optSpec, $typeSpec) = split /[!+=:]/, $optConf->[$i];
        my $comment = $conf{comments_included} ? $optConf->[$i+2] : "";
        my $opts;

        if (ref $comment) {
            ($comment, $typeSpec, $opts) = @$comment;
        } elsif ($comment =~ s/{(.+?)}/$1/g) {
            $typeSpec = lc $1;
        } elsif ($typeSpec) {
            $typeSpec =~ s/^s/string/;
            $typeSpec =~ s/^i/integer/;
            $typeSpec =~ s/^o/extended integer/;
            $typeSpec =~ s/^f/real number/;
        }

        $pod .= "=item B<";
        $pod .= $opts // join " ", map {
            length > 1 ? "$doubleDash$_" : "-$_"
        } split /\|/, $optSpec;
        $pod .= " [$typeSpec]" if $typeSpec;
        $pod .= ">\n\n";
        $pod .= "$comment\n\n" if $comment;
    }

    $pod .= "=back\n\n";
    return $pod;
}

1;
