=begin TML

---+ package RJK::TotalCmd::Item::ButtonBar

=cut

package RJK::TotalCmd::Item::ButtonBar;

use strict;
use warnings;

use RJK::Util::Ini;

my $section = 'Buttonbar';

###############################################################################
=pod

---++ Object creation

---+++ new($path) -> RJK::TotalCmd::Item::ButtonBar
Returns a new =RJK::TotalCmd::Item::ButtonBar= object.
   * =$path= - Path to bar path.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift;
    $self->{ini} = new RJK::Util::Ini($self->{path});
    $self->{name} = ($self->{path} =~ /([^\\\/]+)\.bar$/)[0];
    $self->{items} = undef;
    return $self;
}

###############################################################################
=pod

---++ Object methods

---+++ addButton($self, $command, $iconFile, $iconNr, $iconic)
Add button.

---+++ getItems() -> \@items
Returns all items.

---+++ getButtons() -> \@buttons
Returns all button items (items where {button} is not empty).

---+++ write()
Write bar file.

=cut
###############################################################################

sub addButton {
    my ($self, $command) = @_;

    my $tooltip;
    if ($command->{shortcuts}) {
        $tooltip = "[$command->{shortcuts}] ";
        $tooltip .= $command->{menu} // "";
    }

    push @{$self->{items}}, {
        button => $command->{button} // "",
        cmd => $command->{cmd},
        param => $command->{param},
        path => $command->{path},
        iconic => $command->{iconic} || 0,
        menu => $command->{menu} || $tooltip,
    };
}

sub getItems {
    return $_[0]{items} //= $_[0]{ini}->getHashList($section);
}

sub getButtons {
    return [ grep { $_->{button} } @{$_[0]->getItems} ];
}

sub read {
    my $self = shift;
    $self->{ini}->read();
    $self->{items} = undef;
    return $self;
}

sub write {
    my $self = shift;
    my $items = $self->{items} || return;
    @$items || return;

    my @keys = qw(button cmd param path iconic menu);

    $self->{ini}->setHashList($section, $items, \@keys);
    $self->{ini}->prepend($section, 'Buttoncount', scalar @$items);
    $self->{ini}->write();
}

1;
