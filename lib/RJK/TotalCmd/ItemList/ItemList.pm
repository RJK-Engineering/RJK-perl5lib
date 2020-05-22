=begin TML

---+ package RJK::TotalCmd::ItemList::ItemList
List of =RJK::TotalCmd::Item::Item= objects.

=cut

package RJK::TotalCmd::ItemList::ItemList;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{items} = shift;
    return $self;
}

###############################################################################
=pod

---++ Object methods

---+++ getItems() -> \@items
Returns all items.

---+++ getItem($nr) -> $item
Returns RJK::TotalCmd::Item::Item with number =$nr=.

---+++ getButtons() -> \@buttons
Returns button items.

---+++ getCommands() -> \@commands
Returns command items (items where {cmd} is not empty).

---+++ byName() -> \%items
Returns items hashed by name (items where {name} is not empty,
only internal command and user command items have a name).

---+++ findItems(%opts) -> @items

---+++ findItem(%opts) -> $item
Returns nothing if no items found.
Throws RJK::TotalCmd::Exception if multiple items found.

=cut
###############################################################################

sub getItems {
    return $_[0]{items};
}

sub getItem {
    return $_[0]{items}[$_[1]-1];
}

sub getButtons {
    return [ grep { $_->{button} } @{$_[0]{items}} ];
}

sub getCommands {
    return [ grep { $_->{cmd} } @{$_[0]{items}} ];
}

sub byName {
    return { map { $_->{name} => $_ } grep { $_->{name} } @{$_[0]{items}} };
}

sub findItems {
    my ($self, %opts) = @_;
    my @items;
    my $l = 0;

    for (my $i=0; $i<@{$self->{items}}; $i++) {
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

sub renumber {
    my $i;
    map { $_->{number} = ++$i } @{$_[0]{items}};
}

1;
