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

package RJK::TotalCmd::Settings::Ini;

use strict;
use warnings;

use RJK::TotalCmd::ItemList::Menu;
use RJK::TotalCmd::Search;
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
    $self->{path} = shift;
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
    $self->{searches} = {};          # name => Search

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
Throws =RJK::TotalCmd::Settings::Exception= if =$itemNr= is not a submenu.

=cut
###############################################################################

sub getStartMenu {
    my ($self) = @_;
    return new RJK::TotalCmd::ItemList::Menu(
        title => "StartMenu",
        items => scalar $self->{ini}->getHashList(
            'user', {
                key => 'number',
                class => 'RJK::TotalCmd::Item::MenuItem'
            }
        )
    );
}

sub setStartMenu {
    my ($self, $menu) = @_;
    $self->setMenu('user', $menu->{items});
}

sub getDirMenu {
    my ($self) = @_;
    return new RJK::TotalCmd::ItemList::Menu(
        title => "DirMenu",
        items => scalar $self->{ini}->getHashList(
            'DirMenu', {
                key => 'number',
                class => 'RJK::TotalCmd::Item::MenuItem'
            }
        )
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
        $menu, { key => 'number' }
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
            || throw RJK::TotalCmd::Settings::Exception("Not a submenu");

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
---+++ getSearches() -> %searches or \%searches
---+++ getSearch($name) -> RJK::TotalCmd::Search
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

sub getSearches {
    my $self = shift;
    my $s = $self->_getSearches();
    return wantarray ? values %$s : $s;
}

sub getSearch {
    my ($self, $name) = @_;
    my $s = $self->_getSearches();
    return $s->{$name};
}

sub _getSearches {
    my $self = shift;
    if (! $self->{searches}) {
        foreach (values %{$self->{ini}->getHashes('searches', { key => 'name' })}) {
            $self->{searches}{$_->{name}} = new RJK::TotalCmd::Search(%$_);
        }
    }
    return $self->{searches};
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
