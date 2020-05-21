=begin TML

---+ package !RJK::TotalCmd::Search

---++ Fields

Each field has a corresponding accessor/mutator method with the same name,
e.g. get name: =$search->name()=, set name: =$search->name("a name")=.
Package variable =@RJK::TotalCmd::Search::fields= contains an ordered list of field names.

---++ Fields stored in =totalcmd.ini=
   * =name= - Name
   * =SearchFor= - Search mask
   * =SearchIn= - Directories separated by ";"
   * =SearchText= - Text to search for in files
   * =SearchFlags= - Array of flags
   * =plugin= - Plugin arguments

---++ Fields containing derived values
   * =paths= - Array, =SearchIn= split on ";"
   * =flags= - Hash containing named =SearchFlags=, see: [[?%QUERYSTRING%#SearchFlags][SearchFlags]]

Calculated from =flags=:
   * =mindate= - Unix (epoch) time calculated from ={start}= or from ={time}= and ={timeUnit}=.
   * =maxdate= - Unix (epoch) time calculated from ={end}=.
   * =size= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =0=.
   * =minsize= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =1=.
   * =maxsize= - Size in bytes calculated from ={size}= and ={sizeUnit}= if ={sizeMode}= equals =2=.

For regex searches:
   * =regex= - Equal to =SearchFor=

For non-regex searches where =SearchFor= contains wildcards:
   * =search= - =SearchFor= part before "|"
   * =searchNot= - =SearchFor= part after "|"
   * =searchRegex= - =search= transformed to regex
   * =searchNotRegex= - =searchNot= transformed to regex
   * =patterns= - Array, =search= split on whitespace and ";"
   * =patternsNot= - Array, =searchNot= split on whitespace and ";"

For special search types:
   * =specialType= - "file", "dir" or "category"
   * =specialName= - Search name without the first character indicating the type
   * =extensions= - Array, taken from =patterns= in the form "*.txt"
   * =filenames= - Array, taken from =patterns= not containing wildcards "*" and "?"

---++ Field: =SearchFlags=
<a name="SearchFlags"></a>

---+++ Format

<verbatim>
0 1            13            20    25   29
0|000002000020|d|d|n|n|n|n|n|22222|0000|n

0/2 = flag default value
d = date/time, may be empty
n = number, may be empty

The block of flags 20-24 is empty if all the flags in it have the default value:
0|000002000020|d|d|n|n|n|n|n||0000|n

All default:
0|000002000020|||||||||0000|
</verbatim>

---+++ Encoding

Package variable =@RJK::TotalCmd::Search::flagNames= contains a sorted list of
fields used in the =flags= hash, as listed in the second column.

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

---++ Special type: File types
   * =name= format: =.[name]=
   * =SearchFor= contains a list of extensions and/or full filenames separated by whitespace.
   * =SearchFor= example: =*.ext *.ext2 README .inputrc=

File types will be added to the following package variables:
   * =@RJK::TotalCmd::Search::fileTypes= - list of search names
   * =%RJK::TotalCmd::Search::fileTypesByExt= - file extension => list of search names
   * =%RJK::TotalCmd::Search::fileTypesByName= - file name => list of search names

Use =GetFileTypes()= to look up file types.

---++ Special type: Directory types
   * =name= format: =/[name]=
   * =SearchFor= contains a list of directory names seperated by whitespace.
   * =SearchFor= example: =conf config etc.= (Note required '.' if no wilcards used!)

---++ Special type: Categories
   * =name= format: =:[name]=
   * =SearchFor= contains a list of search names seperated by whitespace.
   * =SearchFor= example: =.audio .video=

File types will be added to the package variable =%RJK::TotalCmd::Search::categories=
with structure: category name => search name => Search.

=cut

package RJK::TotalCmd::Search;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Search::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::Search::InvalidPatternException' =>
        { isa => 'RJK::TotalCmd::Search::Exception',
          fields => [qw(pattern)] },
);

use Try::Tiny;

our @timeUnits = qw(
    nanoseconds seconds minutes
    hours days weeks months years
);

my @fieldDefaults;
our @fields;

BEGIN {
    @fieldDefaults = (
        name => "",
        SearchFor => "",
        SearchIn => "",
        SearchText => "",
        SearchFlags => "",
        plugin => "",

        paths => [],
        flags => {},
        mindate => undef,
        maxdate => undef,
        size => undef,
        minsize => undef,
        maxsize => undef,

        regex => undef,
        search => undef,
        searchNot => undef,
        patterns => [],
        patternsNot => [],

        type => undef,
        category => undef,
        extensions => [],
        filenames => [],
    );
    for (my $i=0; $i<@fieldDefaults; $i+=2) {
        push @fields, $fieldDefaults[$i];
    }
}

use Class::AccessorMaker {@fieldDefaults}, "new_init";

our @flagNames = qw(
    archives textWord textCase textAscii textNot
    selected compressed textHex textUnicode regex textRegex
    encrypted textUtf8 start end time timeUnit
    sizeMode size sizeUnit archive readonly hidden system directory
    dupes dupeContent dupeName dupeSize depth
);

my $defaults = {
    compressed => 2,
    encrypted => 2,
    flags => {
        archive => 2,
        readonly => 2,
        hidden => 2,
        system => 2,
        directory => 2,
        depth => 99,
    }
};

our @fileTypes;
our %fileTypesByExt;
our %fileTypesByName;
our %categories;

# called by Class::AccessorMaker
sub init {
    my $self = shift;
    $self->{name} or return;

    # SearchIn split on ";"
    $self->{paths} = [ split /\s*;\s*/, $self->{SearchIn} ];

    # flag array
    my @flags = $self->{SearchFlags} =~
        /^(\d)
        \|(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)
        \|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)
        \|(?:(\d)(\d)(\d)(\d)(\d))?
        \|(\d)(\d)(\d)(\d)\|?(.*)/x
    or throw RJK::TotalCmd::Search::Exception(
        "Error parsing SearchFlags: $self->{SearchFlags}"
    );

    $self->{SearchFlags} = \@flags;

    # flag hash
    my %flags; @flags{@flagNames} = @flags;
    $self->{flags} = \%flags;

    # Calculated from flags
    $self->{mindate} = ParseDate($flags{start}) if $flags{start};
    $self->{maxdate} = ParseDate($flags{end}, 1) if $flags{end};

    if ($flags{size}) {
        my $size = $flags{size} * 1024 ** $flags{sizeUnit};
        if ($flags{sizeMode} == 0) {
            $self->{size} = $size;
        } elsif ($flags{sizeMode} == 1) {
            $self->{minsize} = $size;
        } elsif ($flags{sizeMode} == 2) {
            $self->{maxsize} = $size;
        }
    }

    # regex search
    if ($flags{regex}) {
        $self->{regex} = $self->{SearchFor};

    # no regex search and SearchFor contains wildcards
    } elsif ($self->{SearchFor} =~ /[?*]/) {
        my @s = split /\s*\|\s*/, $self->{SearchFor};
        $self->{search} = $s[0] // "";
        $self->{searchNot} = $s[1] // "";
        warn "Ignoring part after second \"|\": $self->{SearchFor}" if @s > 2;

        for (qw(search searchNot)) {
            my $re = $self->{$_};
            $re =~ s/[\s;]+/|/g;    # separated by |
            $re = quotemeta $re;
            $re =~ s/\\\|/|/g;      # restore |
            $re =~ s/\\\?/./g;      # restore and translate ?
            $re =~ s/\\\*/.*/g;     # restore and translate *
            $self->{$_."Regex"} = $re;
        }

        $self->{patterns} = [ split /[\s;]+/, $self->{search} ];
        $self->{patternsNot} = [ split /[\s;]+/, $self->{searchNot} ];
    }

    # special search type
    if ($self->{name} =~ /^([\.:\/])(.*)/) {
        $self->{specialName} = $2;
        if ($1 eq '.') {
            $self->{specialType} = 'file';
            $self->_loadFileType($2);
        }
        if ($1 eq '/') {
            $self->{specialType} = 'dir';
            #~ TODO $self->_loadDirType($2);
        }
        if ($1 eq ':') {
            $self->{specialType} = 'category';
            $self->_loadCategory($2);
        }
    }
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
    foreach my $field (@fields) {
        if ($field eq "flags") {
            $self->{flags}{$_} //= $search->{flags}{$_}
                foreach @flagNames;
        } else {
            $self->{$field} //= $search->{$field};
        }
    }
}

###############################################################################
=pod

---+++ defaults()
Set defaults for undefined parameters

=cut
###############################################################################

sub defaults {
    my $self = shift;
    foreach my $field (@fields) {
        if ($field eq "flags") {
            $self->{flags}{$_} //= $defaults->{flags}{$_} // 0
                foreach @flagNames;
        } else {
            $self->{$field} //= $defaults->{$field} || "";
        }
    }
}

###############################################################################
=pod

---+++ match($file) -> $matched
Returns true if matched, false if not.

=cut
###############################################################################

sub match {
    my ($self, $file) = @_;

    # name
    my $name = $file->{path};
    $name =~ s|.*[\\/]||;

    undef $self->{captured};
    if ($self->{regex}) {
        return 0 if $name !~ /$self->{regex}/i;
        $self->{captured} = [ $name =~ /$self->{regex}/i ];
    } else {
        return 0 if $self->{searchRegex} &&
            $name !~ /^(?:$self->{searchRegex})$/i;
        return 0 if $self->{searchNotRegex} &&
            $name =~ /^(?:$self->{searchNotRegex})$/i;
    }

    # size
    if (defined $file->{size}) {
        return 0 if $self->{size} && $file->{size} != $self->{size};
        return 0 if $self->{minsize} && $file->{size} < $self->{minsize};
        return 0 if $self->{maxsize} && $file->{size} > $self->{maxsize};
    }

    # date - TODO: creation/access date
    my $date = $file->{modified};
    if (defined $date) {
        return 0 if $self->{mindate} && $date < $self->{mindate};
        return 0 if $self->{maxdate} && $date > $self->{maxdate};
        my $not = NotOlderThanTime($self->{flags});
        return 0 if $not && $date < $not;
    }

    # text
    if ($self->SearchText ne "") {
        if (!-r $file->{path}) {
            throw RJK::TotalCmd::Search::Exception("Not readable: $file->{path}");
        }

        # TODO search-binary flag
        if (-T $file->{path}) {
            open my $fh, '<', $file->{path}
                or throw RJK::TotalCmd::Search::Exception("$file->{path}: $!");

            my $re = $self->{textRegex} ? qr/$self->{SearchText}/ :
                                          qr/\Q$self->{SearchText}\E/;
            my $match;
            while (<$fh>) {
                next if $_ !~ $re;
                $match = 1;
                last;
            }
            close $fh;

            return 0 unless $match;
        }
    }

    return 1;
}

sub _loadFileType {
    my ($self, $type) = @_;
    push @fileTypes, $self->{name};

    foreach my $pattern (@{$self->{patterns}}) {
        # slashes are invalid
        if ($pattern =~ /[\\\/]/) {
            throw RJK::TotalCmd::Search::InvalidPatternException(
                error => sprintf("Invalid pattern: %s for %s", $pattern, $self->{name}),
                pattern => $pattern,
            );

        # extension
        } elsif ($pattern =~ /^\*\.([^\.\s]+)$/) {
            my $ext = GetExtensionIdent($pattern);
            push @{$fileTypesByExt{$ext}}, $self->{name};
            push @{$self->{extensions}}, $ext;

        # full filename
        } elsif ($pattern !~ /[*?]/) {
            push @{$fileTypesByName{lc $pattern}}, $self->{name};
            push @{$self->{filenames}}, $pattern;

        }
    }
}

sub _loadCategory {
    my ($self, $name) = @_;

    my $searchFor = $self->{SearchFor};
    while ($searchFor =~ s/"(.+?)"|(\S+)//) {
        $categories{$name}{$1 || $2} = $self;
    }
}

###############################################################################
=pod

---++ Class methods

---+++ !GetFileTypes($filename) -> $types or @types
Lookup file types in file type specifications.

=cut
###############################################################################

sub GetFileTypes {
    my $filename = shift;
    my $ext = GetExtensionIdent($filename);
    my $types = $ext && $fileTypesByExt{$ext}
        || $fileTypesByName{lc $filename}
        || return;
    return wantarray ? @$types : $types;
}

###############################################################################
=pod

---+++ !GetExtensionIdent($filename) -> $ident
Get extension identity e.g.
=GetExtensionIdent("filename.ext")= equals
=GetExtensionIdent("FILENAME.EXT")=.

=cut
###############################################################################

sub GetExtensionIdent {
    my ($ident) = $_[0] =~ /\.([^\.\s]+)$/;
    $ident = lc $ident if $ident;
    return $ident;
}

###############################################################################
=pod

---+++ !ParseDate($dateTime, $endOfDay) -> $number
   * =$dateTime= - String in format: =d-m-y h:m:s= or without time: =d-m-y=
                   (single digits allowed).
   * =$number= - A number that can be used to compare dates.
   * =$endOfDay= - Take epoch at the end of the day if no time is specified
                   (for matching a date up-to-and-including).

=cut
###############################################################################

sub ParseDate {
    my ($dateTime, $endOfDay) = @_;

    if ($dateTime =~ /^(\d+)-(\d+)-(\d+)(?: (\d+):(\d+):(\d+))?$/) {
        my $year = $3;
        $year += $3 < 70 ? 2000 : 1900 if $3 < 100;
        $year -= 1970;
        my $d = $endOfDay && ! defined $4 ? 1 : 0;
        return 0 + sprintf "%02d%02u%02u%02u%02u%02u", $year, $2, $1+$d, $4//0, $5//0, $6//0;
    }

    throw RJK::TotalCmd::Search::Exception("Invalid date/time: $dateTime");
}

###############################################################################
=pod

---+++ !NotOlderThanTime($flags) -> $time
   * =$flags= - Search flag hash.
   * =$time= - Unix (epoch) time.

=cut
###############################################################################

sub NotOlderThanTime {
    die "FIXME";
    my $flags = shift;
    return unless $flags->{time};

    my $timeUnit = $flags->{timeUnit};
    if ($timeUnit < -1 || $timeUnit > 4) {
        throw RJK::TotalCmd::Search::Exception("Invalid time unit: $timeUnit");
    }

    my $unit = $timeUnits[ $timeUnit + 3 ];
    return DateTime->now->
        subtract($unit => $flags->{time})->epoch;
}

1;
