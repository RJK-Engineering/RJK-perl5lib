=begin TML

---+ package !RJK::TotalCmd::Builder::Search

---++ Flags

<verbatim>
0 1            13            20    25   29
0|000002000020|d|d|n|n|n|n|n|22222|0000|n

0/2 = flag default value
d = date/time, may be empty
n = number, may be empty

The block of flags 20-24 is empty if "Attributes" checkbox is not checked:
0|000002000020|d|d|n|n|n|n|n||0000|n

All default/no flags:
0|000002000020|||||||||0000|
with "Attributes" checkbox checked:
0|000002000020||||||||22222|0000|
</verbatim>

---++ Plugin arguments

<verbatim>
Example plugin arguments:
media.bitrate > 123 | "media.duration (time)" <= 45

rules := [rule] | [allRules] | [anyRules]
allRules := [rule] & [allRules]
anyRules := [rule] | [anyRules]
rule := "[property]" [op] "[value]"     * property and value are only quoted if they contain spaces or double-quotes,
                                        * double-quotes are escaped with a backslash: \"
property := [plugin].[propertyName]
op := [numberOp] | [stringOp] | [booleanOp]
numberOp := > < >= <= = !=
stringOp := contains !contains cont.(case) !cont.(case) =(case) !=(case) = != regex !regex
booleanOp := =                          * for boolean ops the rule value is either 1 for Yes or 0 for No
</verbatim>

=cut
###############################################################################

package RJK::TotalCmd::Builder::Search;

use strict;
use warnings;

use RJK::Exception;
use RJK::TotalCmd::Search;

sub create {
    my ($class, $conf) = @_;
    $conf //= {};
    my $search = new RJK::TotalCmd::Search(%$conf);
    $search->{name} or return $search;

    # SearchIn split on ";"
    $search->{paths} = [ split /\s*;\s*/, $search->{SearchIn} ];

    # flag array
    my @flags = $search->{SearchFlags} =~
        /^(\d)
        \|(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)
        \|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)
        \|(?:(\d)(\d)(\d)(\d)(\d))?
        \|(\d)(\d)(\d)(\d)\|?(.*)/x
    or throw RJK::Exception(
        "Error parsing SearchFlags: $search->{SearchFlags}"
    );

    # flag hash
    my %flags; @flags{@RJK::TotalCmd::Search::flagNames} = @flags;
    $search->{flags} = \%flags;

    # Calculated from flags
    $search->{mindate} = $class->parseDate($flags{start}) if $flags{start};
    $search->{maxdate} = $class->parseDate($flags{end}, 1) if $flags{end};

    if ($flags{size}) {
        my $size = $flags{size} * 1024 ** $flags{sizeUnit};
        if ($flags{sizeMode} == 0) {
            $search->{size} = $size;
        } elsif ($flags{sizeMode} == 1) {
            $search->{minsize} = $size;
        } elsif ($flags{sizeMode} == 2) {
            $search->{maxsize} = $size;
        }
    }

    if ($flags{regex}) {
        $search->{regex} = $search->{SearchFor};

    # SearchFor contains wildcards
    } elsif ($search->{SearchFor} =~ /[?*]/) {
        my @s = split /\s*\|\s*/, $search->{SearchFor};
        $search->{search} = $s[0] // "";
        $search->{searchNot} = $s[1] // "";
        warn "Ignoring part after second \"|\": $search->{SearchFor}" if @s > 2;

        for (qw(search searchNot)) {
            my $re = $search->{$_};
            $re =~ s/[\s;]+/|/g;    # separated by |
            $re = quotemeta $re;
            $re =~ s/\\\|/|/g;      # restore |
            $re =~ s/\\\?/./g;      # restore and translate ?
            $re =~ s/\\\*/.*/g;     # restore and translate *
            $search->{$_."Regex"} = $re;
        }

        $search->{patterns} = [ split /[\s;]+/, $search->{search} ];
        $search->{patternsNot} = [ split /[\s;]+/, $search->{searchNot} ];
    }

    if ($search->{plugin}) {
        my @args =
            map { s/^"//r =~ s/"$//r =~ s/\0/"/r }  # remove surrounding quotes, restore in-string quotes
            $search->{plugin} =~ s/\\"/\0/gr        # replace escaped in-string quotes with null chars
            =~ /(".*?"|\S+)/g;                      # match quoted strings and non-space sequences

        while (my ($prop, $op, $value, $combineOp) = splice @args, 0, 4) {
            my ($plugin, $property, $unit) = split /\./, $prop;
            push @{$search->{rules}}, {
                plugin => $plugin,
                property => $property,
                op => $op,
                value => $value,
                unit => $unit,
            };
            $search->{rulesCombineOp} //= $combineOp;
        }
    }

    return $search;
}

sub parseDate {
    my ($class, $dateTime, $endOfDay) = @_;

    if ($dateTime =~ /^(\d+)-(\d+)-(\d+)(?: (\d+):(\d+):(\d+))?$/) {
        my $year = $3;
        $year += $3 < 70 ? 2000 : 1900 if $3 < 100;
        $year -= 1970;
        my $d = $endOfDay && ! defined $4 ? 1 : 0;
        return 0 + sprintf "%02d%02u%02u%02u%02u%02u", $year, $2, $1+$d, $4//0, $5//0, $6//0;
    }

    throw RJK::Exception("Invalid date/time: $dateTime");
}

1;
