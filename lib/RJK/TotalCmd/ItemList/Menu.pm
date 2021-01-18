###############################################################################
=begin TML

---+ package RJK::TotalCmd::ItemList::Menu

A Total Commander menu contains a list of menu items which describe commands or submenus.

=cut
###############################################################################

package RJK::TotalCmd::ItemList::Menu;
use parent RJK::TotalCmd::ItemList::ItemList;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Exception' =>
        { isa => 'Exception' },
);

###############################################################################
=pod

---++ Object Creation

---+++ RJK::TotalCmd::ItemList::Menu->new(title => $title, items => \@items) -> RJK::TotalCmd::ItemList::Menu
Returns a new =RJK::TotalCmd::ItemList::Menu= object.

---++ Items

---+++ appendItems($items)

---+++ insertItem(item => $item, position => $position, submenu => $submenu) -> $item

---+++ createItem($template) -> $item

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{title} = $opts{title};
    $self->{items} = $opts{items};
    return $self;
}

sub appendItems {
    my ($self, $items) = @_;
    push @{$self->{items}}, @$items;
    $self->renumber();
}

sub insertItem {
    my ($self, %opts) = @_;
    my $submenu = $opts{submenu};
    if ($opts{position}) {
        # position within submenu
        $opts{position} += $submenu->{number} if $submenu;
    } else {
        # insert at start of menu by default
        $opts{position} = 1;
        # append to end of submenu
        $opts{position} += $self->getLastItemNumber($submenu) if $submenu;
    }

    my $item = $self->createItem($opts{item});
    splice(@{$self->{items}}, $opts{position}-1, 0, $item);
    $self->renumber();

    return $item;
}

sub createItem {
    my ($self, $template) = @_;
    $template->{menu} //= $template->{cmd};
    return $template;
}

###############################################################################
=pod

---++ Submenus

---+++ getSubmenu($nr) -> $submenu

---+++ getSubmenuItems($submenu) -> \@items

---+++ getLastItemNumber($submenu) -> $lastItemNumber

---+++ findSubmenus($searchFor) -> \@submenus or @submenus

---+++ findSubmenu($searchFor) -> $submenu
Returns nothing if no submenus found.
Throws RJK::TotalCmd::Exception if multiple submenus found.

---+++ insertSubmenu(%opts) -> $submenu

---+++ deleteSubmenu($submenu) -> $submenu

---+++ replaceSubmenu($submenu, $items) -> $submenu

=cut
###############################################################################

sub getSubmenu {
    my ($self, $nr) = @_;
    my $item = $self->{items}[$nr - 1];
    return if $item->{menu} !~ /^"?-[^-]/;
    $item->{items} = $self->getSubmenuItems($item);
    return $item;
}

sub getSubmenuItems {
    my ($self, $submenu) = @_;
    my @items;

    my $l = 0;
    for (my $i=$submenu->{number}; $i<@{$self->{items}}; $i++) {
        my $o = $self->{items}[$i];
        if ($o->{menu} =~ /^--$/) {         # submenu end
            last if $l-- == 0;
        } elsif ($o->{menu} =~ /^"?-(.*)/) {  # submenu start
            $l++;
        }
        push @items, $o;
    }
    return \@items;
}

sub getLastItemNumber {
    my ($self, $submenu) = @_;

    my $l = 0;
    for (my $i=$submenu->{number}; $i<@{$self->{items}}; $i++) {
        my $o = $self->{items}[$i];
        if ($o->{menu} =~ /^--$/) {         # submenu end
            return $i if $l-- == 0;
        } elsif ($o->{menu} =~ /^"?-(.*)/) {  # submenu start
            $l++;
        }
    }
}

sub findSubmenus {
    my ($self, $searchFor) = @_;
    my @items;
    foreach (@{$self->{items}}) {
        my $title = $_->{menu} =~ s/&//gr; # remove access key indicator
        next if $title !~ /^"?-.*$searchFor/i;
        $_->{items} = $self->getSubmenuItems($_);
        push @items, $_;
    }
    return wantarray ? @items : \@items;
}

sub findSubmenu {
    my ($self, $searchFor) = @_;
    my @submenus = $self->findSubmenus($searchFor);
    return if ! @submenus;
    throw RJK::TotalCmd::Exception("Found " . scalar @submenus . " submenus") if @submenus > 1;
    return $submenus[0];
}

sub insertSubmenu {
    my ($self, %opts) = @_;
    ...;
    $self->renumber();
}

sub deleteSubmenu {
    my ($self, $submenu) = @_;
    ...;
    $self->renumber();
}

sub replaceSubmenu {
    my ($self, $submenu, $items) = @_;
    my @items = @{$self->{items}};
    $self->{items} = [
        @items[0 .. $submenu->{number}-1],
        @$items,
        @items[$self->getLastItemNumber($submenu) .. $#items]
    ];
    $self->renumber();
}

1;
