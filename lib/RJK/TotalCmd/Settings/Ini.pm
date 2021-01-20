###############################################################################
=begin TML

---+ package RJK::TotalCmd::Settings::Ini
Total Commander =WINCMD.INI= file.

---++ INI sections

---+++ History (numbered)

<verbatim>
[Command line history]
[MkDirHistory] names of created dirs
[RightHistory] rhs path
[LeftHistory] lhs path
[SearchName] file search "Search for"
[SearchIn] file search "Search in"
[SearchText] general search (Ctrl+F / F3)
[Selection] file selection
[RenameTemplates] multi-rename "Rename mask: file name"
[RenameSearchFind] multi-rename "Search for"
[RenameSearchReplace] multi-rename "Replace with"
</verbatim>

---+++ Saved settings (not all)

<verbatim>
[searches] search settings
    [name]_SearchFor, [name]_SearchIn, [name]_SearchText, [name]_SearchFlags
[rename] rename settings
    [name]_name, [name]_ext, [name]_search, [name]_replace, [name]_params
[CustomFields] custom columns
    Widths[i], Headers[i], Contents[i], Options[i],
[Colors] (saved search name, color)
    ColorFilter[i], ColorFilter[i]Color
</verbatim>

---+++ Menu

Submenus start with =menu[i]=-[name]= and end with =menu[i]=--=.

<verbatim>
[user] start menu
    menu[i], cmd[i], param[i], path[i], key[i]
[DirMenu] directory menu
    menu[i], cmd[i]
</verbatim>

---+++ Other

<verbatim>
[1024x600 (8x16)]
[1024x768 (8x16)]
[1152x864 (8x16)]
[1280x1024 (8x16)]
[1280x800 (8x16)]
[1366x768 (8x16)]
[1600x1200 (8x16)]
[640x480 (8x16)]
[800x600 (8x16)]

[left]
[right]
[lefttabs]
[righttabs]

[ContentPlugins]
[FileSystemPlugins]
[Lister]
[ListerPlugins]
[Packer]
[PackerPlugins]

[Associations]
[Buttonbar]
[Configuration]
[Confirmation]
[General]
[Layout]
[PrintDir]
[Shortcuts]
[SplitPerFile]
[Tabstops]
[TweakWC]
</verbatim>

=cut
###############################################################################

package RJK::TotalCmd::Settings::Ini;

use strict;
use warnings;

use RJK::Exception;
use RJK::TotalCmd::Search;
use RJK::TotalCmd::Deserialize::Search;
use RJK::TotalCmd::Item::MenuItem;
use RJK::TotalCmd::ItemList::Menu;
use RJK::Util::Ini;

my $UserMenuNumberStart = 700;

###############################################################################
=pod

---++ Object Creation

---+++ new($path) -> RJK::TotalCmd::Settings::Ini
Returns a new =RJK::TotalCmd::Settings::Ini= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift // $ENV{COMMANDER_INI} // throw RJK::Exception("No path to INI file");
    $self->{ini} = new RJK::Util::Ini($self->{path});
    return $self;
}

sub filepath { $_[0]{path} }

###############################################################################
=pod

---++ INI file

---+++ read([$path]) -> RJK::TotalCmd::Settings::Ini
Read data from file. Returns nothing on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::Settings::Ini
Write data to file. Returns nothing on failure, callee on success.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;
    $file //= $self->{path};

    $self->{ini}->read($file) || return;

    return $self;
}

sub write {
    my ($self, $file) = @_;
    $file //= $self->{path};
    return $self if $self->{ini}->write($file);
}

###############################################################################
=pod

---++ Menus
Total Commander start and directory menus.

=cut
###############################################################################

sub getStartMenu {
    my ($self) = @_;
    return new RJK::TotalCmd::ItemList::Menu(
        title => "StartMenu",
        items => scalar $self->{ini}->getHashList(
            'user', {
                key => 'number',
                class => 'RJK::TotalCmd::Item::StartMenuItem'
            }
        )
    );
}

sub setStartMenu {
    my ($self, $menu) = @_;
    $self->{ini}->setHashList('user', $menu->{items}, [qw(menu cmd param path iconic key)]);
}

sub getDirMenu {
    my ($self) = @_;
    return new RJK::TotalCmd::ItemList::Menu(
        title => "DirMenu",
        items => scalar $self->{ini}->getHashList(
            'DirMenu', {
                key => 'number',
                class => 'RJK::TotalCmd::Item::DirMenuItem'
            }
        )
    );
}

sub setDirMenu {
    my ($self, $menu) = @_;
    $self->{ini}->setHashList('DirMenu', $menu->{items}, [qw(menu cmd path)]);
}

###############################################################################
=pod

---++ Other object methods

---+++ getSection($section) -> $hash or %hash

---+++ getShortcuts() -> %shortcuts or \%shortcuts
Returns =$keyCombo => $commandName= hash.

---++++ getColors() -> \@colors
   * =@colors= - List of { Color => $color, Search => $search }

---++++ setColors(\@colors)
   * =@colors= - List of { Color => $color, Search => $search }

=cut
###############################################################################

sub getSection {
    my ($self, $section) = @_;
    return $self->{ini}->getSection($section);
}

sub getShortcuts {
    my ($self) = @_;
    my $shortcuts = $self->{ini}->getSection('Shortcuts');
    return wantarray ? %$shortcuts : $shortcuts;
}

sub getKeys {
    my ($self) = @_;
    my %keys;
    while (my ($keys, $command) = each %{$self->getShortcuts}) {
        push @{$keys{$command}}, $keys;
    }
    return wantarray ? %keys : \%keys;
}

sub getColors {
    my ($self) = @_;
    return $self->{ini}->getHashListRHS("Colors", {
        name => "ColorFilter",
        key => "nr",
        defaultKey => "Search",
    });
}

sub setColors {
    my ($self, $colors) = @_;

    my $other = {};
    $self->{ini}->getHashListRHS("Colors", {
        name => "ColorFilter",
        key => "nr",
        defaultKey => "Search",
        otherProps => $other
    });
    $self->{ini}->setHashListRHS("Colors", $colors, {
        name => "ColorFilter",
        keys => [qw(Search Color)],
        defaultKey => "Search"
    });
    $self->{ini}->prependAll("Colors", $other);


    #~ $self->{ini}->replaceHashListRHS("Colors", $colors, {
    #~     name => "ColorFilter",
    #~     keys => [qw(Search Color)],
    #~     defaultKey => "Search"
    #~ });


    $self->{ini}->clearHashListRHS("Colors", $colors, "ColorFilter");
    $self->{ini}->setHashListRHS("Colors", $colors, {
        name => "ColorFilter",
        keys => [qw(Search Color)],
        defaultKey => "Search"
    });
}

###############################################################################
=pod

---+++ history($section) -> @history or \@history
---+++ addToHistory($section, $text) -> ProperyList
---+++ getSearch([$name]) -> $search
Get stored search by name. Returns an empty search object if =$name= is undefined.
---+++ getSearches() -> %searches or \%searches
---+++ report()

=cut
###############################################################################

sub history {
    my ($self, $section) = @_;
    $self->{ini}->getList($section);
}

sub addToHistory {
    my ($self, $section, $text) = @_;
    my $h = $self->{ini}->getList($section);

    pop @$h;
    unshift @$h, $text;
    $self->{ini}->setList($section, $h);
}

sub getSearch {
    my ($self, $name) = @_;
    return new RJK::TotalCmd::Search if ! defined $name;
    my $searches = $self->getSearches(sub {shift->{name} =~ /^\Q$name\E$/}, 1);
    return $searches->{$name};
}

sub getSearches {
    my ($self, $filter, $first) = @_;
    $filter //= sub {1};
    my %searches;

    foreach (values %{$self->{ini}->getHashes('searches', { key => 'name' })}) {
        next if ! $filter->($_);
        $searches{$_->{name}} = RJK::TotalCmd::Deserialize::Search->deserialize($_);
        last if $first;
    }
    return wantarray ? %searches : \%searches;
}

sub report {
    my $self = shift;
    local $, =  " ";
    print scalar keys %{$self->{fileTypeIdxByExt}}, " extensions\n";
    print sort keys %{$self->{fileTypeIdxByExt}}, "\n";
    print scalar keys %{$self->{fileTypeIdxByName}}, " filenames\n";
    print sort keys %{$self->{fileTypeIdxByName}}, "\n";
}

1;
