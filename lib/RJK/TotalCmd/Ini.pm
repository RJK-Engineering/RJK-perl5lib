=begin TML

---+ package RJK::TotalCmd::Ini
Total Commander INI file functionality.

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
[DirMenu] directory hotlist
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

package RJK::TotalCmd::Ini;

use v5.16; # enables fc feature
use strict;
use warnings;

use RJK::TotalCmd::Menu;
use RJK::TotalCmd::Search;
use RJK::Util::Ini;

use Exception::Class (
    'Exception',
    'TotalCmd::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::Ini::Exception' =>
        { isa => 'TotalCmd::Exception' },
    'RJK::TotalCmd::Ini::SubmenuException' =>
        { isa => 'RJK::TotalCmd::Ini::Exception' },
);

my $UserMenuNumberStart = 700;

###############################################################################
=pod

---++ Object Creation

---+++ new($path) -> RJK::TotalCmd::Ini
Returns a new =RJK::TotalCmd::Ini= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift;
    $self->{ini} = new RJK::Util::Ini($self->{path});
    $self->{searches} = {};          # name => Search
    return $self;
}

sub filepath { $_[0]{path} }

###############################################################################
=pod

---++ INI file

---+++ read([$path]) -> RJK::TotalCmd::Ini
Read data from file. Returns nothing on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::Ini
Write data to file. Returns nothing on failure, callee on success.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;
    $file //= $self->{path};

    $self->{ini}->read($file) || return;
    $self->_loadSearches();

    return $self;
}

sub write {
    my ($self, $file) = @_;
    $file //= $self->{path};
    return $self if $self->{ini}->write($file);
}

###############################################################################
=pod

---++ Menu items

Two menus are available, "user" for the start menu,
"DirMenu" for the directory menu.

---+++ getMenuItem($nr) -> $command
Get menu item by item number.

---+++ getMenuItems([$submenuNr]) -> @commands or \@commands
Get menu items.
Get all items if =$submenuNr= is undefined.
Get root items if =$submenuNr= is =0=.

---+++ getSubmenus($menu) -> @commands or \@commands
Get submenus.

---+++ _getSubmenu($items, $itemNr) -> @commands or \@commands
Get submenu items.
Get root items if =$item= is =0=.
Throws =RJK::TotalCmd::Ini::SubmenuException= if =$itemNr= is not a submenu.

=cut
###############################################################################

sub getStartMenu {
    my ($self) = @_;
    return new RJK::TotalCmd::Menu(
        title => "StartMenu",
        items => scalar $self->{ini}->getHashList(
            'user', 'number',
            { source => 'StartMenu' }
        )
    );
}

sub setStartMenu {
    my ($self, $menu) = @_;
    $self->setMenu('user', $menu->{items});
}

sub getDirMenu {
    my ($self) = @_;
    return $self->{ini}->getHashList(
        'DirMenu', 'number',
        { source => 'DirMenu' }
    );
}

sub getMenuItem {
    my ($self, $menu, $number) = @_;
    my $items = $self->getMenuItems($menu);
    return $items->[$number-1];
}

sub getMenuItems {
    my ($self, $menu, $submenuNr) = @_;
    $submenuNr = $submenuNr->{number} if ref $submenuNr;
    my @items = $self->{ini}->getHashList(
        $menu, 'number',
        { source => $menu eq 'user' ? 'StartMenu' : $menu }
    );
    if (defined $submenuNr) {
        @items = $self->_getSubmenu(\@items, $submenuNr);
    }
    return wantarray ? @items : \@items;
}

sub getSubmenus {
    my ($self, $menu) = @_;
    my @items;
    foreach (@{$self->getMenuItems($menu)}) {
        push @items, $_ if $_->{menu} =~ /^-[^-]/;
    }
    return wantarray ? @items : \@items;
}

sub _getSubmenu {
    my ($self, $items, $itemNr) = @_;
    if ($itemNr) {
        $items->[$itemNr-1] &&
            $items->[$itemNr-1]->{menu} =~ /^-[^-]/
            || throw RJK::TotalCmd::Ini::SubmenuException("Not a submenu");

        $items = [ @$items[$itemNr..@$items-1] ];
    }

    my @items;
    while (my $o = shift @$items) {
        if ($o->{menu} =~ /^--$/) {         # submenu end
            last;
        } elsif ($o->{menu} =~ /^-(.*)/) {  # submenu start
            push @items, $o;
            $self->_getSubmenu($items);
        } else {
            push @items, $o;
        }
    }
    return @items;
}

sub setMenu {
    my ($self, $menu, $items) = @_;
    $self->{ini}->setHashList($menu, $items, [qw(menu cmd param path iconic key)]);
}

###############################################################################
=pod

---++ Other object methods

---+++ getSection($section) -> $hash or %hash

---+++ getShortcuts() -> %shortcuts or \%shortcuts
Get =$keyCombo => $commandName= hash.

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
---+++ searches() -> %searches or \%searches
---+++ nonSpecialSearches() -> @searches
List of non special searches sorted by name.
---+++ getSearch($name) -> RJK::TotalCmd::Search
---+++ fileTypes() -> $types or @types
---+++ getFileTypes($filename) -> $types or @types
---+++ matchFileType($type, $filename) -> $boolean
---+++ inCategory($filename, $category) -> $boolean
---+++ _loadSearches()
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

sub searches {
    my $self = shift;
    return wantarray ?
        values %{$self->{searches}} : $self->{searches};
}

sub searchNames {
    my $self = shift;
    return keys %{$self->{searches}};
}

sub nonSpecialSearches {
    my $self = shift;
    return
        map { $self->{searches}{$_} }
        sort { fc $a cmp fc $b }
        grep { ! /^(?:attr|category|dirs|type):/ }
        keys %{$self->{searches}};
}

sub getSearch {
    my ($self, $name) = @_;
    return $self->{searches}{$name};
}

sub fileTypes {
    my $self = shift;
    return @RJK::TotalCmd::Search::fileTypes;
}

sub getFileTypes {
    my ($self, $filename) = @_;
    return RJK::TotalCmd::Search::GetFileTypes($filename);
}

sub matchFileType {
    my ($self, $type, $filename) = @_;
    my $types = $self->getFileTypes($filename);
    return grep { $_ eq $type } @$types;
}

sub inCategory {
    my ($self, $filename, $category) = @_;
    my $types = $self->getFileTypes($filename);
    foreach (@$types) {
        return 1 if $self->{categoryIdx}{$category}{$_};
    }
    return 0;
}

sub _loadSearches {
    my $self = shift;
    my %s = $self->{ini}->getHashes('searches', { key => 'name' });
    foreach (values %s) {
        $self->{searches}{$_->{name}} = new RJK::TotalCmd::Search(%$_);
    }
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