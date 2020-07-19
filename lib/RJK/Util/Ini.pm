=begin TML

---+ package RJK::Util::Ini
Read and write INI files.

=cut

package RJK::Util::Ini;

use strict;
use warnings;

use RJK::File::Exceptions;
use RJK::Util::PropertyList;

###############################################################################
=pod

---++ Object Creation

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

---+++ setSection($ini, $section) -> $propertyList
   * =$ini= - =RJK::Util::Ini= object to reference to
   * =$section= - section name
   * =$propertyList= - =RJK::Util::PropertyList= object for the section

Set reference to a section in another =RJK::Util::Ini= object.

---+++ allSections() -> %hash or \%hash
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
    push @{$self->{sections}}, $section;
    $self->{keys}{$section} = [];
    return $self->{properties}{$section} = new RJK::Util::PropertyList;
}

# no deep copy!
sub setSection {
    my ($self, $section, $ini) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
    $self->{keys}{$section} = $ini->{keys}{$section};
    $self->{properties}{$section} = $ini->{properties}{$section};
}

sub allSections {
    my ($self, $type) = @_;
    my %all;
    foreach my $section (@{$self->{sections}}) {
        $all{$section} = $self->{properties}{$section}->hash;
    }
    return wantarray ? %all : \%all;
}

###############################################################################
=pod

---++ Section Properties
Properties are key/value pairs.

---+++ getPropertyList($section) -> $propertyList
   * =$section= - section name
   * =$propertyList= - =RJK::Util::PropertyList= object for the section

---+++ getPropertyNames($section) -> @array or \@array
   * =$section= - section name
   * =@array= - key array

---+++ getValues($section) -> @array or \@array
   * =$section= - section name
   * =@array= - value array

---+++ getSection($section) -> %hash or \%hash
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

# ordered list
sub getPropertyNames {
    my $props = $_[0]{propertyNames};
    exists $props->{$_[1]} || return;
    return wantarray ? @{$props->{$_[1]}} : $props->{$_[1]};
}

sub getValues {
    my $pl = $_[0]->{properties}{$_[1]} || return;
    return wantarray ? $pl->values : [ $pl->values ];
}

sub getSection {
    my $pl = $_[0]->{properties}{$_[1]} || return;
    return wantarray ? %{$pl->hash} : $pl->hash;
}

sub get {
    my $pl = $_[0]->{properties}{$_[1]} || return;
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
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
    push @{$self->{keys}{$section}}, $key if ! $pl->has($key);
    $pl->set($key, $value);
}

sub prepend {
    my ($self, $section, $key, $value) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
    unshift @{$self->{keys}{$section}}, $key;
    $pl->set($key, $value);
}

sub prependAll {
    my ($self, $section, $hash) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
    while (my ($key, $value) = each %$hash) {
        unshift @{$self->{keys}{$section}}, $key;
        $pl->set($key, $value);
    }
}

sub append {
    my ($self, $section, $key, $value) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
    push @{$self->{keys}{$section}}, $key;
    $pl->set($key, $value);
}

sub appendAll {
    my ($self, $section, $hash) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
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

---+++ read($path) -> $ini
Uses path passed to =new= if =$path= is <code>undef</code>ined.%BR%
Returns the object it's been called on or =undef= on failure.%BR%

---+++ write($path) -> $ini
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
        or throw RJK::File::OpenFileException(error => "$!", file => $file, mode => '<');
    $self->clear();

    my ($pl, $keys);
    while (<$in>) {
        chomp;
        if (/^\[(.+)\]/) {
            $pl = $self->_newSection($1);
            $keys = $self->{keys}{$1};
        } else {
            if (/^(.+?)=(.*)/) {
                # scalar property
                $pl->set($1, $2);
                push @$keys, $1;
            }
        }
    }
    close $in;
    return $self;
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
           or throw RJK::File::OpenFileException(error => "$!", file => $file, mode => '>');
    }

    my @sections = $sort ? sort @{$self->{sections}}
                         : @{$self->{sections}};

    foreach my $section (@sections) {
        my $pl = $self->{properties}{$section} || return;
        print $fh "[$section]\n" or return;
        foreach my $name (@{$self->{keys}{$section}}) {
            printf $fh "%s=%s\n", $name, $pl->get($name) or return;
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

sub parse {
    my ($self, $section, $opts) = @_;

    $opts //= {};
    my $key = $opts->{key};
    my $defaultHash = $opts->{defaultHash} || {};
    my $defaultKey = $opts->{defaultKey} // '_default';
    my $name = $opts->{name} // '.*?';

    my $pl = $self->{properties}{$section} || return;
    my $keys = $self->{keys}{$section};
    my $data;

    foreach (@$keys) {
        my $value = $pl->get($_);
        # lists
        if (/^ (?<name>$name) (?<index>\d+) $self->{delimiter}? (?<key>.*) $/x) {
            if ($+{name} || $+{key}) {
                # 2) name => [ values ]
                $data->{namedLists}{$+{name}}[$+{index}] = $value;
                # 3) [ key => value ]
                if (! $data->{hashList}[$+{index}]) {
                    $data->{hashList}[$+{index}] = {%$defaultHash};
                    $data->{hashListRHS}[$+{index}] = {%$defaultHash};
                    if ($key) {
                        $data->{hashList}[$+{index}]{$key} = $+{index};
                        $data->{hashListRHS}[$+{index}]{$key} = $+{index};
                    }
                    if ($opts->{class}) {
                        bless $data->{hashList}[$+{index}], $opts->{class};
                        bless $data->{hashListRHS}[$+{index}], $opts->{class};
                    }
                }
                $data->{hashList}[$+{index}]{$+{name}} = $value;
                my $key = $+{key} || $defaultKey;
                $data->{hashListRHS}[$+{index}]{$key} = $value;
            } else {
                # 1) [ values ]
                $data->{array}[$+{index}] = $value;
            }
        # hashes
        } elsif (/^ (.+) $self->{delimiter} (.+) $/x) {
            # 4) name => key => value
            if (! $data->{namedHashes}{$1} && $defaultHash) {
                $data->{namedHashes}{$1} = {%$defaultHash};
                $data->{namedHashesLHS}{$2} = {%$defaultHash};
            }
            $data->{namedHashes}{$1}{$2} = $value;
            $data->{namedHashesLHS}{$2}{$1} = $value;
            if ($key) {
                $data->{namedHashes}{$1}{$key} = $1;
                $data->{namedHashesLHS}{$2}{$key} = $2;
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

---+++ getList($section, $name) -> @array or \@array
   * =$section= - section name
   * =$name= - list name
   * =@array= - the list

Get values from a section containing an anonymous or a named list.%BR%
Get values from a named list if =$name= is defined.%BR%
Returns a list of values.%BR%

---+++ getLists($section) -> ( $name => $array ) or { $name => $array }
Returns a hash of lists.%BR%

---+++ getHashList($section) -> ( $hash ) or [ $hash ]
Returns a list of hashes.%BR%

---+++ getHashListRHS($section) -> ( $hash ) or [ $hash ]
Returns a list of hashes.%BR%

---+++ getHash($section, $opts) -> %hash or \%hash
Returns a hash of values.%BR%

---+++ getHashLHS($section, $opts) -> %hash or \%hash
Returns a hash of values.%BR%

---+++ getHashes($section, $opts) -> ( $name => $hash ) or { $name => $hash }
Returns a hash of hashes.%BR%

---+++ getHashesLHS($section, $opts) -> ( $name => $hash ) or { $name => $hash }
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
    my $data = $self->parse($section) || return;
    if ($name) {
        exists $data->{namedLists}{$name} || return;
        $data = $data->{namedLists}{$name};
    } else {
        $data = $data->{array};
    }
    return wantarray ? @$data : $data;
}

sub getLists {
    my ($self, $section) = @_;
    my $data = $self->parse($section) || return;
    $data = $data->{namedLists};
    return wantarray ? @$data : $data;
}

sub getHashList {
    my ($self, $section, $opts) = @_;
    my $data = $self->parse($section, $opts) || return;
    $data = $data->{hashList};
    shift @$data unless defined $data->[0]; # when list starts at 1
    return wantarray ? @$data : $data;
}

sub getHashListRHS {
    my ($self, $section, $opts) = @_;
    my $data = $self->parse($section, $opts) || return;
    $data = $data->{hashListRHS};
    shift @$data unless defined $data->[0]; # when list starts at 1
    return wantarray ? @$data : $data;
}

sub getHash {
    my ($self, $section, $name) = @_;
    my $data = $self->parse($section) || return;
    exists $data->{namedHashes}{$name} || return;
    $data = $data->{namedHashes}{$name};
    return wantarray ? %$data : $data;
}

sub getHashLHS {
    my ($self, $section, $name) = @_;
    my $data = $self->parse($section) || return;
    exists $data->{namedHashesLHS}{$name} || return;
    $data = $data->{namedHashesLHS}{$name};
    return wantarray ? %$data : $data;
}

sub getHashes {
    my ($self, $section, $opts) = @_;
    my $data = $self->parse($section, $opts) || return;
    $data = $data->{namedHashes};
    return wantarray ? %$data : $data;
}

sub getHashesLHS {
    my ($self, $section, $opts) = @_;
    my $data = $self->parse($section, $opts) || return;
    $data = $data->{namedHashesLHS};
    return wantarray ? %$data : $data;
}

sub setList {
    my ($self, $section, $array, $name) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);

    my @keys = $name ? map { "$name$_" } 0 .. @$array-1
                     :                   0 .. @$array-1;
    $self->{keys}{$section} = \@keys;

    $pl->clear;
    for (my $i=0; $i<@$array; $i++) {
        $pl->set($keys[$i], $array->[$i]) foreach @$array;
    }
    return $pl;
}

sub setHashList {
    my ($self, $section, $array, $keys) = @_;
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
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
    my $pl = $self->{properties}{$section} || $self->_newSection($section);
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
            my $prop = /^$defaultKey$/i ? "$name$i" : "$name$i$_";      # ini prop names are case-insensitive
            $pl->set($prop, $value);
            push @props, $prop;
        }
    }
    $self->{keys}{$section} = \@props;
    return $pl;
}

1;
