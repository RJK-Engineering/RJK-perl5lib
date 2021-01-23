###############################################################################
=begin TML

---+ package !RJK::TotalCmd::Search

---++ Fields

Fields stored in =totalcmd.ini=
   * =$name= - Name
   * =$SearchFor= - Search mask
   * =$SearchIn= - Directories separated by ";"
   * =$SearchText= - Text to search for in files
   * =$SearchFlags= - Array of flags
   * =$plugin= - Plugin arguments (rules)

Derived fields
   * =@paths= - =SearchIn= split on ";"
   * =%flags= - Hash containing named =SearchFlags=, see: [[?%QUERYSTRING%#SearchFlags][SearchFlags]]
   * =@rules= - List of hashes: {op, plugin, property, unit, value}

Calculated from flags
   * =$mindate= - Unix (epoch) time calculated from ={start}= or from ={time}= and ={timeUnit}=
   * =$maxdate= - Unix (epoch) time calculated from ={end}=
   * =$size= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =0=
   * =$minsize= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =1=
   * =$maxsize= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =2=

For non-regex searches where =SearchFor= contains wildcards:
   * =$search= - =SearchFor= part before "|"
   * =$searchNot= - =SearchFor= part after "|"
   * =@patterns= - =search= split on whitespace and ";"
   * =@patternsNot= - =searchNot= split on whitespace and ";"

---++ Flags
<a name="SearchFlags"></a>

Package variable =@RJK::TotalCmd::Search::flagNames= contains an ordered list of
field names used in the =flags= hash, these are listed in the second column.

| *Position* | *Field* | *Description* | *Format* | *Default* |
| 0 | archives | Search archives | 0=enabled, 1=disabled | 0 |
| 1 | textWord | Find Text: Whole words only | 0=enabled, 1=disabled | 0 |
| 2 | textCase | Find Text: Case sensitive | 0=enabled, 1=disabled | 0 |
| 3 | textAscii | Find Text: Ascii charset | 0=enabled, 1=disabled | 0 |
| 4 | textNot | Find Text: NOT containing text | 0=enabled, 1=disabled | 0 |
| 5 | selected | Only search in selected | 0=enabled, 1=disabled | 0 |
| 6 | compressed | Attribute: Compressed | 0=cleared, 1=set, 2=don't care | 2 |
| 7 | textHex | Find Text: Hex | 0=enabled, 1=disabled | 0 |
| 8 | textUnicode | Find Text: Unicode | 0=enabled, 1=disabled | 0 |
| 9 | regex | Search For: Regex | 0=enabled, 1=disabled | 0 |
| 10 | textRegex | Find Text: Regex | 0=enabled, 1=disabled | 0 |
| 11 | encrypted | Attribute: Encrypted | 0=cleared, 1=set, 2=don't care | 2 |
| 12 | textUtf8 | Find Text: UTF8-Search | 0=enabled, 1=disabled | 0 |
| 13 | start | Date between: Start | d-m-yyyy hh:mm:ss | |
| 14 | end | Date between: End | d-m-yyyy hh:mm:ss | |
| 15 | time | Not older then | Number | |
| 16 | timeUnit | Not older then: Unit | -1=minutes, 0=hours, 1=days, 2=weeks, 3=months, 4=years | |
| 17 | sizeMode | File size: Mode | 1=greater then, 2=less then, else equal to | |
| 18 | size | File size | Number | |
| 19 | sizeUnit | File size: Unit | 0=bytes, 1=kb, 2=mb, 3=gb | |
| 20 | archive | Attribute: Archive | 0=cleared, 1=set, 2=don't care | 2 |
| 21 | readonly | Attribute: Read only | 0=cleared, 1=set, 2=don't care | 2 |
| 22 | hidden | Attribute: Hidden | 0=cleared, 1=set, 2=don't care | 2 |
| 23 | system | Attribute: System | 0=cleared, 1=set, 2=don't care | 2 |
| 24 | directory | Attribute: Directory | 0=cleared, 1=set, 2=don't care | 2 |
| 25 | dupes | Find duplicate files | 0=enabled, 1=disabled | 0 |
| 26 | dupeContent | Find duplicate files: Same content | 0=enabled, 1=disabled | 0 |
| 27 | dupeName | Find duplicate files: Same name | 0=enabled, 1=disabled | 0 |
| 28 | dupeSize | Find duplicate files: Same size | 0=enabled, 1=disabled | 0 |
| 29 | depth | Search depth | Number | |

---++ Plugins

---+++ Available properties of internal plugin tc

string or number:
fullname name ext dosname path comment size
creationdate creationtime writedate writetime accessdate accesstime
attributes attributestr versionstring versionnr random number

flags:
archive "read only" hidden system directory
compressed encrypted sparse offline

choice:
"file type" = file, folder or "reparse point"

---+++ Available size units

Default size unit: bytes
Other available units: kbytes, Mbytes, Gbytes

---+++ Available operators

numbers: > < >= <= = !=
strings: contains !contains cont.(case) !cont.(case) =(case) !=(case) = != regex !regex
boolean: =

---+++ =addRule= examples

<verbatim>
$search->addRule($plugin, $property, $op, $value, $unit)
$search->addRule(qw (tc name contains abc))
$search->addRule(qw (tc size >= 123 Mbytes))
</verbatim>

=cut
###############################################################################

package RJK::TotalCmd::Search;

use strict;
use warnings;

our @timeUnits = qw(
    nanoseconds seconds minutes
    hours days weeks months years
);

my $proto = {
    name => "",
    SearchFor => "",
    SearchIn => "",
    SearchText => "",
    SearchFlags => "",
    plugin => "",

    paths => undef,
    flags => undef,
    rules => undef,

    mindate => undef,
    maxdate => undef,
    size => undef,
    minsize => undef,
    maxsize => undef,

    search => undef,
    searchNot => undef,
    patterns => undef,
    patternsNot => undef,
};

our @flagNames = qw(
    archives textWord textCase textAscii textNot
    selected compressed textHex textUnicode regex textRegex
    encrypted textUtf8 start end time timeUnit
    sizeMode size sizeUnit archive readonly hidden system directory
    dupes dupeContent dupeName dupeSize depth
);

my $flagsProto = {
    compressed => 2,
    encrypted => 2,
    archive => 2,
    readonly => 2,
    hidden => 2,
    system => 2,
    directory => 2,
    depth => 99,
};

###############################################################################
=pod

---++ Constructor

---+++ new() -> $search
Returns a new =RJK::TotalCmd::Search= object.

=cut
###############################################################################

sub new {
    my $self = bless \%$proto, shift;
    $self->{flags} = \%$flagsProto;
    return $self;
}

###############################################################################
=pod

---++ Object methods

---+++ update($search)
Copy unset parameters from other =$search=.

=cut
###############################################################################

sub update {
    my ($self, $search) = @_;
    foreach my $field (keys %$proto) {
        if ($field eq "flags") {
            $self->{flags}{$_} //= $search->{flags}{$_} for @flagNames;
        } else {
            $self->{$field} //= $search->{$field};
        }
    }
}

###############################################################################
=pod

---+++ defaults()
Set defaults for undefined parameters.

=cut
###############################################################################

sub defaults {
    my $self = shift;
    foreach my $field (keys %$proto) {
        if ($field eq "flags") {
            $self->{flags}{$_} //= $flagsProto->{$_} // 0 for @flagNames;
        } else {
            $self->{$field} //= $proto->{$field} || "";
        }
    }
}

###############################################################################
=pod

---+++ addRule($plugin, $property, $op, $value, $unit)
---+++ hasRule($plugin, $property, $op, $value, $unit) -> $boolean

=cut
###############################################################################

sub addRule {
    my ($self, $plugin, $property, $op, $value, $unit) = @_;
    push @{$self->{rules}}, {
        plugin => $plugin,
        property => $property,
        op => $op,
        value => $value,
        unit => $unit || 'bytes'
    };
}

sub hasRule {
    my ($self, $plugin, $property, $op, $value, $unit) = @_;
    $plugin || die "Invalid args";
    foreach (@{$self->{rules}}) {
        next if $plugin ne $_->{plugin};
        next if $property && $property ne $_->{property};
        next if $op && $op ne $_->{op};
        next if defined $value && $value ne $_->{value};
        next if $unit && $unit ne $_->{unit};
        return 1;
    }
    return 0;
}

1;
