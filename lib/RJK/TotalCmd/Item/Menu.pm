=begin TML

---+ package RJK::TotalCmd::Item::Menu

A Total Commander menu contains a list of menu items which describe commands or submenus.

=cut

package RJK::TotalCmd::Item::Menu;

use strict;
use warnings;

use Exception::Class (
    'Exception',
    'TotalCmd::Exception' =>
        { isa => 'Exception' },
);

###############################################################################
=pod

---++ Object Creation

---+++ RJK::TotalCmd::Item::Menu->new(title => $title, items => \@items) -> RJK::TotalCmd::Item::Menu
Returns a new =RJK::TotalCmd::Item::Menu= object.

---++ Items

---+++ getCommands() -> \@commands
Returns all command items (items where {cmd} is not empty).

---+++ findItems(%opts) -> @items

---+++ findItem(%opts) -> $item
Returns nothing if no items found.
Throws RJK::TotalCmd::Exception if multiple items found.

---+++ insertItem(item => $item, position => $position, submenu => $submenu) -> $item

---+++ RJK::TotalCmd::Item::Menu::createItem($template) -> $item

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{title} = $opts{title};
    $self->{items} = $opts{items};
    return $self;
}

sub getCommands {
    return [ grep { $_->{cmd} } @{$_[0]->{items}} ];
}

sub findItems {
    my ($self, %opts) = @_;
    my $submenu = delete $opts{submenu};
    my @items;

    my $start = $submenu ? $submenu->{number} : 0;
    my $l = 0;

    for (my $i=$start; $i<@{$self->{items}}; $i++) {
        my $item = $self->{items}[$i];

        if ($item->{menu} =~ /^--$/) {         # submenu end
            last if $l-- == 0;
        } elsif ($item->{menu} =~ /^"?-(.*)/) {  # submenu start
            $l++;
        } else {
            foreach (keys %opts) {
                next if not exists $item->{$_};
                if ($_ eq 'menu') {
                    my $title = $item->{menu} =~ s/&//gr; # remove access key indicator
                    if ($title =~ /\Q$opts{menu}\E/i) {
                        push @items, $item;
                        last;
                    }
                } elsif ($item->{$_} =~ /\Q$opts{$_}\E/i) {
                    push @items, $item;
                    last;
                }
            }
        }
    }
    return wantarray ? @items : \@items;
}

sub findItem {
    my ($self, %opts) = @_;
    my @items = $self->findItems(%opts);
    return if ! @items;
    throw RJK::TotalCmd::Exception("Found " . scalar @items . " items") if @items > 1;
    return $items[0];
}

sub insertItem {
    my ($self, %opts) = @_;
    my $submenu = delete $opts{submenu};
    if ($opts{position}) {
        # position within submenu
        $opts{position} += $submenu->{number} if $submenu;
    } else {
        # insert at start of menu by default
        $opts{position} = 1;
        # append to end of submenu
        $opts{position} += $self->getLastItemNumber($submenu) if $submenu;
    }

    my $item = createItem($opts{item});
    splice(@{$self->{items}}, $opts{position}-1, 0, $item);
    $self->renumber();

    return $item;
}

sub createItem {
    my $template = shift;
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

###############################################

sub renumber {
    my $i;
    map { $_->{number} = ++$i } @{$_[0]{items}};
}

1;
