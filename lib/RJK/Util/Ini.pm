###############################################################################
=begin TML

---+ package !RJK::Util::Ini
Read and write INI files.

=cut
###############################################################################

package RJK::Util::Ini;

use strict;
use warnings;

use Exceptions;
use OpenFileException;
use RJK::Util::PropertyList;

###############################################################################
=pod

---++ Constructor

---+++ new($path) -> $ini
   * =$path= - path to ini file
   * =$ini= - new =RJK::Util::Ini= object

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{file} = shift;
    $self->{delimiter} = "_";
    return $self;
}

###############################################################################
=pod

---++ INI Sections

---+++ sections() -> @array or \@array
   * =@array= - section names

---+++ totalSections() -> $numberOfSections

---+++ newSection($section) -> $propertyList
   * =$section= - section name
   * =$propertyList= - =RJK::Util::PropertyList= object for new
     section or =undef= if section already exists

---+++ setSection($section, $hash, \@keys) -> $propertyList
   * =$section= - section name
   * =$hash= - property hash
   * =@keys= - optional order of keys
   * =$propertyList= - =RJK::Util::PropertyList= object for the section

Set reference to a section in another =RJK::Util::Ini= object.

---+++ allSections() -> \%hash
   * =%hash= - section => property => value

Return all sections as a hash.

=cut
###############################################################################

sub sections {
    wantarray ? @{$_[0]{sections}} : $_[0]{sections};
}

sub totalSections {
    scalar @{$_[0]{sections}};
}

sub clearSection {
    my ($self, $section) = @_;
    my $pl = $self->{properties}{$section} || return;
    $self->{keys}{$section} = [];
    $pl->clear;
}

sub newSection {
    my ($self, $section) = @_;
    return if $self->{properties}{$section};
    $self->_newSection($section);
}

sub _newSection {
    my ($self, $section) = @_;
    push @{$self->{sections}}, $section if not exists $self->{keys}{$section};
    $self->{keys}{$section} = [];
    return $self->{properties}{$section} = new RJK::Util::PropertyList;
}

sub _getSection {
    $_[0]{properties}{$_[1]} || $_[0]->_newSection($_[1])
}

sub setSection {
    my ($self, $section, $hash, $keys) = @_;
    $keys //= keys %$hash;
    my $pl = $self->_newSection($section);
    $self->{keys}{$section} = $keys;
    $pl->{props} = $hash;
}

sub allSections {
    my ($self, $type) = @_;
    my %all;
    foreach (@{$self->{sections}}) {
        $all{$_} = $self->{properties}{$_}->hash;
    }
    return \%all;
}

###############################################################################
=pod

---++ Section Properties
Properties are key/value pairs.

---+++ getPropertyList($section) -> $propertyList
   * =$section= - section name
   * =$propertyList= - =RJK::Util::PropertyList= object for the section

---+++ getPropertyNames($section) -> \@array
   * =$section= - section name
   * =@array= - key array

---+++ getValues($section) -> \@array
   * =$section= - section name
   * =@array= - value array

---+++ getSection($section) -> \%hash
   * =$section= - section name
   * =%hash= - property hash

---+++ get($section, $key) -> $value
   * =$section= - section name
   * =$key= - key name
   * =$value= - property value

=cut
###############################################################################

sub getPropertyList {
    my $properties = $_[0]{properties};
    exists $properties->{$_[1]} || return;
    return $properties->{$_[1]};
}

sub getKeys {
    $_[0]{keys}{$_[1]};
}

sub getValues {
    my $pl = $_[0]{properties}{$_[1]} || return;
    return $pl->values;
}

sub getSection {
    my $pl = $_[0]{properties}{$_[1]} || return;
    return $pl->hash;
}

sub get {
    my $pl = $_[0]{properties}{$_[1]} || return;
    return $pl->get($_[2]);
}

###############################################################################
=pod

---+++ set($section, $key, $value) -> $value
   * =$section= - section name
   * =$key= - key name
   * =$value= - property value
Set property.
Add property to end of section if it does not exist.

---+++ prepend($section, $key, $value) -> $propertyList
Add property to beginning of section.
Does not check for existing property, may result in duplicates.

---+++ append($section, $key, $value) -> $propertyList
Add property to end of section.
Does not check for existing property, may result in duplicates.

=cut
###############################################################################

sub set {
    my ($self, $section, $key, $value) = @_;
    my $pl = $self->_getSection($section);
    push @{$self->{keys}{$section}}, $key if ! $pl->has($key);
    $pl->set($key, $value);
}

sub prepend {
    my ($self, $section, $key, $value) = @_;
    my $pl = $self->_getSection($section);
    unshift @{$self->{keys}{$section}}, $key;
    $pl->set($key, $value);
}

sub prependAll {
    my ($self, $section, $hash) = @_;
    my $pl = $self->_getSection($section);
    while (my ($key, $value) = each %$hash) {
        unshift @{$self->{keys}{$section}}, $key;
        $pl->set($key, $value);
    }
}

sub append {
    my ($self, $section, $key, $value) = @_;
    my $pl = $self->_getSection($section);
    push @{$self->{keys}{$section}}, $key;
    $pl->set($key, $value);
}

sub appendAll {
    my ($self, $section, $hash) = @_;
    my $pl = $self->_getSection($section);
    while (my ($key, $value) = each %$hash) {
        push @{$self->{keys}{$section}}, $key;
        $pl->set($key, $value);
    }
}

###############################################################################
=pod

---++ INI File

---+++ file() -> $path
Returns the ini file path.

---+++ read($path) -> $self
Uses path passed to =new= if =$path= is <code>undef</code>ined.%BR%
Returns the object it's been called on or =undef= on failure.%BR%

---+++ write($path) -> $self
Uses path passed to =new= if =$path= is <code>undef</code>ined.%BR%
Returns the object it's been called on or =undef= on failure.%BR%

=cut
###############################################################################

sub file {
    return $_[0]{file};
}

sub read {
    my ($self, $file) = @_;
    $file //= $self->{file};

    open my $in, '<', $file
        or throw OpenFileException(error => "$!: $file", file => $file, mode => '<');
    $self->clear();

    my ($pl, $keys, $section, $comment);
    while (<$in>) {
        $self->{bom} //= readUtf8Bom();
        chomp;
        if (/^([;#].*)/) {
            $comment .= "$1\n";
        } elsif (/^(.+?)=(.*)/) {
            if ($comment) {
                $self->{comments}{$section}{$1} = $comment;
                $comment = undef;
            }
            $pl->set($1, $2);
            push @$keys, $1;
        } elsif (/^\[(.+)\]/) {
            $section = $1;
            if ($comment) {
                $self->{sectionComments}{$section} = $comment;
                $comment = undef;
            }
            $pl = $self->_newSection($section);
            $keys = $self->{keys}{$section};
        }
    }
    close $in;
    return $self;
}

sub readUtf8Bom {
    (s|^(\xEF\xBB\xBF)||)[0] // "";
}

sub clear {
    my $self = shift;
    $self->{sections} = [];   # sections
    $self->{keys} = {};       # section => [ keys ]
    $self->{properties} = {}; # section => RJK::Util::PropertyList{key => value}
    return $self;
}

sub write {
    my ($self, $file, $sort) = @_;
    $file //= $self->{file} // \*STDOUT;

    my $fh;
    if (ref $file && ref $file eq 'GLOB') {
        $fh = $file;
    } else {
        open $fh, '>', $file
           or throw OpenFileException(error => "$!: $file", file => $file, mode => '>');
    }

    print $fh $self->{bom}//"";
    foreach my $section ($sort ? sort @{$self->{sections}} : @{$self->{sections}}) {
        my $pl = $self->{properties}{$section};
        print $fh $self->{sectionComments}{$section}//"";
        print $fh "[$section]\n" or return;
        foreach (@{$self->{keys}{$section}}) {
            printf $fh "%s=%s\n", $_, $pl->get($_);
            print $fh $self->{comments}{$section}{$_}//"";
        }
    }
    return $self;
}

###############################################################################
=pod

---++ Data Structures

---+++ parse($section, $opts) -> $data
   * =$section= - section name
   * =$opts= - options hash:
               key => name of key to add to hashes, pointing to its key if it's in a hash-of-hashes
                      or its index if it's in a list-of-hashes
               defaultHash => default key/value pairs to add to hashes
               defaultKey => default key for values in a hash that don't have a key name in the INI
               name => name of the requested list or hash
               class => bless hash
               otherProps => reference to a hash where extra properties in the section not
                             belonging to the requested list or hash will be stored

Interprets four kinds of data structures within a section.%BR%
Returns a hash with the following keys: =namedLists hashList hashListRHS array namedHashes namedHashesLHS=
containing the interpreted data.

   1. array (anonymous list)
      [index]=[value]
      example: 0=val1 1=val2 ...
      result: [val1, val2]
      access: getList(section)->[index]
   2. named lists
      [name][index]=[value]
      example: foo0=val1 foo1=val2 bar0=val3 bar1=val4 ...
      result: { foo=>[val1, val2]
                bar=>[val3, val4] }
      access: getLists(section)->{name}[index]
      or:     getList(section, name)->[index]
   3. list of hashes
      3(a). key on lhs
         [key][delimiter][index]=[value]
         example: foo0=val1 bar0=val2 foo1=val3 bar1=val4 ...
         result: [ { foo=>val1, bar=>val2 },
                   { foo=>val3, bar=>val4 } ]
         access: getHashList(section)->[index]{key}
      3(b). key on rhs
         [name][index][delimiter][key]=[value]
         example: name1=val1 name1bar=val2 name2=val3 name2bar=val4
                  (name="name", no delimiter, default key used for val1 and val3)
         result: [ { default=>val1, bar=>val2 },
                   { default=>val3, bar=>val4 } ]
         example: 0_foo=val1 0_bar=val2 1_foo=val3 1_bar=val4
                  (no name, delimiter="_")
         result: [ { foo=>val1, bar=>val2 },
                   { foo=>val3, bar=>val4 } ]
         access: getHashListRHS(section)->[index]{key}
   4. named hashes
      4(a). key on rhs
         [name][delimiter][key]=[value]
         example: foo_f00=val1 foo_baz=val2 bar_f00=val1 bar_baz=val2 ...
         result: { foo=>{f00=val1, baz=val2}
                   bar=>{f00=val3, baz=val4} }
         access: getHashes(section)->{name}{key}
         or:     getHash(section, name)->{key}
      4(b). key on lhs
         [key][delimiter][name]=[value]
         example: f00_foo=val1 baz_foo=val2 f00_bar=val1 baz_bar=val2 ...
         result: { foo=>{f00=val1, baz=val2}
                   bar=>{f00=val3, baz=val4} }
         access: getHashesLHS(section)->{name}{key}
         or:     getHashLHS(section, name)->{key}

=cut
###############################################################################

sub parseList {
    my ($self, $section, $name, $otherProps, $otherPropsKeys) = @_;
    $name = $name ? quotemeta $name : '.*?';
    my $pl = $self->{properties}{$section} || return;
    my $data;

    foreach (@{$self->{keys}{$section}}) {
        my $value = $pl->get($_);
        if (/^ (?<name>$name) \ ? (?<index>\d+) $/x) {
            if ($+{name}) {
                # 2) name => [ values ]
                $data->{namedLists}{$+{name}}[$+{index}] = $value;
            } else {
                # 1) [ values ]
                $data->{array}[$+{index}] = $value;
            }
        } else {
            $otherProps->{$_} = $value if $otherProps;
            push @{$otherPropsKeys}, $_ if $otherPropsKeys;
        }
    }
    return $data;
}

sub parseHash {
    my ($self, $section, $opts) = @_;
    $opts //= {};
    my $defaultHash = $opts->{defaultHash} || {};
    my $pl = $self->{properties}{$section} || return;
    my $data;

    foreach (@{$self->{keys}{$section}}) {
        my $value = $pl->get($_);
        if (/^ (.+) $self->{delimiter} (.+) $/x) {
            # 4) name => key => value
            if (! $data->{namedHashes}{$1} && $defaultHash) {
                $data->{namedHashes}{$1} = {%$defaultHash};
                $data->{namedHashesLHS}{$2} = {%$defaultHash};
            }
            $data->{namedHashes}{$1}{$2} = $value;
            $data->{namedHashesLHS}{$2}{$1} = $value;
            next if ! $opts->{key};
            $data->{namedHashes}{$1}{$opts->{key}} = $1;
            $data->{namedHashesLHS}{$2}{$opts->{key}} = $2;
        } else {
            $opts->{otherProps}{$_} = $value if $opts->{otherProps};
            push @{$opts->{otherPropsKeys}}, $_ if $opts->{otherPropsKeys};
        }
    }
    return $data;
}

sub parseHashList {
    my ($self, $section, $opts) = @_;
    $opts //= {};
    my $defaultHash = $opts->{defaultHash} || {};
    my $defaultKey = $opts->{defaultKey} // '_default';
    my $name = $opts->{name} ? quotemeta $opts->{name} : '.*?';
    my $pl = $self->{properties}{$section} || return;
    my $data;

    foreach (@{$self->{keys}{$section}}) {
        my $value = $pl->get($_);
        if (/^ (?<name>$name) (?<index>\d+) $self->{delimiter}? (?<key>.*) $/x) {
            if ($+{name} || $+{key}) {
                # 3) [ key => value ]
                if (! $data->{hashList}[$+{index}]) {
                    $data->{hashList}[$+{index}] = {%$defaultHash};
                    $data->{hashListRHS}[$+{index}] = {%$defaultHash};
                    if ($opts->{key}) {
                        $data->{hashList}[$+{index}]{$opts->{key}} = $+{index};
                        $data->{hashListRHS}[$+{index}]{$opts->{key}} = $+{index};
                    }
                    if ($opts->{class}) {
                        bless $data->{hashList}[$+{index}], $opts->{class};
                        bless $data->{hashListRHS}[$+{index}], $opts->{class};
                    }
                }
                $data->{hashList}[$+{index}]{$+{name}} = $value;
                my $key = $+{key} || $defaultKey;
                $data->{hashListRHS}[$+{index}]{$key} = $value;
            }
        } else {
            $opts->{otherProps}{$_} = $value if $opts->{otherProps};
            push @{$opts->{otherPropsKeys}}, $_ if $opts->{otherPropsKeys};
        }
    }
    return $data;
}

###############################################################################
=pod

---+++ getList($section, $name) -> \@array
   * =$section= - section name
   * =$name= - list name
   * =@array= - the list

Get values from a section containing an anonymous or a named list.%BR%
Get values from a named list if =$name= is defined.%BR%
Returns a list of values.%BR%

---+++ getLists($section) -> { $name => $array }
Returns a hash of lists.%BR%

---+++ getHashList($section) -> [ $hash ]
Returns a list of hashes.%BR%

---+++ getHashListRHS($section) -> [ $hash ]
Returns a list of hashes.%BR%

---+++ getHash($section, $opts) -> \%hash
Returns a hash of values.%BR%

---+++ getHashLHS($section, $opts) -> \%hash
Returns a hash of values.%BR%

---+++ getHashes($section, $opts) -> { $name => $hash }
Returns a hash of hashes.%BR%

---+++ getHashesLHS($section, $opts) -> { $name => $hash }
Returns a hash of hashes.%BR%

---+++ setList($section, $array, $name) -> $propertyList
Create an anonymous or a named list with the values from =$array=.%BR%
Creates a named list if =$name= is defined.%BR%
Returns a =RJK::Util::PropertyList= object for the section.%BR%

---+++ setHashList($section, $array, \@keys) -> $propertyList
Create a hash list with the values from =$array=.%BR%
Only use keys in =\@keys= if defined, order is preserved.%BR%
Returns a =RJK::Util::PropertyList= object for the section.%BR%

=cut
###############################################################################

sub getList {
    my ($self, $section, $name) = @_;
    my $data = $self->parseList($section, $name) || return;
    if ($name) {
        exists $data->{namedLists}{$name} || return;
        return $data->{namedLists}{$name};
    }
    return $data->{array};
}

sub getLists {
    my ($self, $section) = @_;
    my $data = $self->parseList($section) || return;
    return $data->{namedLists};
}

sub getHashList {
    my ($self, $section, $opts) = @_;
    my $data = $self->parseHashList($section, $opts) || return;
    $data = $data->{hashList};
    return $data unless defined $data->[0]; # when list starts at 1
}

sub getHashListRHS {
    my ($self, $section, $opts) = @_;
    my $data = $self->parseHashList($section, $opts) || return;
    $data = $data->{hashListRHS};
    return $data unless defined $data->[0]; # when list starts at 1
}

sub getHash {
    my ($self, $section, $name) = @_;
    my $data = $self->parseHash($section) || return;
    exists $data->{namedHashes}{$name} || return;
    return $data->{namedHashes}{$name};
}

sub getHashLHS {
    my ($self, $section, $name) = @_;
    my $data = $self->parseHash($section) || return;
    exists $data->{namedHashesLHS}{$name} || return;
    return $data->{namedHashesLHS}{$name};
}

sub getHashes {
    my ($self, $section, $opts) = @_;
    my $data = $self->parseHash($section, $opts) || return;
    return $data->{namedHashes};
}

sub getHashesLHS {
    my ($self, $section, $opts) = @_;
    my $data = $self->parseHash($section, $opts) || return;
    return $data->{namedHashesLHS};
}

sub setList {
    my ($self, $section, $array, $name) = @_;
    my $pl = $self->_getSection($section);

    my @keys = $name ? map { "$name$_" } 0 .. @$array-1
                     :                   0 .. @$array-1;
    $self->{keys}{$section} = \@keys;

    $pl->clear;
    for (my $i=0; $i<@$array; $i++) {
        $pl->set($keys[$i], $array->[$i]);
    }
    return $pl;
}

sub setHashList {
    my ($self, $section, $array, $keys) = @_;
    my $pl = $self->_getSection($section);
    $pl->clear;
    my @propertyKeys;
    for (my $i=1; $i<=@$array; $i++) {
        my $hash = $array->[$i-1];
        foreach ($keys ? @$keys : keys %$hash) {
            $hash->{$_} // next;
            $pl->set("$_$i", $hash->{$_});
            push @propertyKeys, "$_$i";
        }
    }
    $self->{keys}{$section} = \@propertyKeys;
    return $pl;
}

sub setHashListRHS {
    my ($self, $section, $array, $opts) = @_;
    my $pl = $self->_getSection($section);
    $pl->clear;
    return if ! @$array;

    my $name = $opts->{name} // "";
    my $defaultKey = $opts->{defaultKey} // "";
    my @keys = @{$opts->{keys}} if $opts->{keys};
    my @props;

    for (my $i=1; $i<=@$array; $i++) {
        my $hash = $array->[$i-1];
        foreach (@keys ? @keys : keys %$hash) {
            my $value = $hash->{$_} // next;
            my $prop = /^$defaultKey$/i ? "$name$i" : "$name$i$_";
            $pl->set($prop, $value);
            push @props, $prop;
        }
    }
    $self->{keys}{$section} = \@props;
    return $pl;
}

1;
