###############################################################################
=begin TML

---+ package RJK::TotalCmd::ItemList::ButtonBar

=cut
###############################################################################

package RJK::TotalCmd::ItemList::ButtonBar;
use parent RJK::TotalCmd::ItemList::ItemList;

use strict;
use warnings;

use RJK::Util::Ini;
use RJK::TotalCmd::Item::Button;

my $section = 'Buttonbar';

###############################################################################
=pod

---++ Object creation

---+++ new($path) -> RJK::TotalCmd::ItemList::ButtonBar
Returns a new =RJK::TotalCmd::ItemList::ButtonBar= object.
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

---+++ addButton($self, $command)
Add button.

---+++ read()
Read bar file.

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

    push @{$self->{items}}, new RJK::TotalCmd::Item::Button(
        button => $command->{button} // "",
        cmd => $command->{cmd},
        param => $command->{param},
        path => $command->{path},
        iconic => $command->{iconic} || 0,
        menu => $command->{menu} || $tooltip,
    );
}

sub read {
    my $self = shift;
    $self->{ini}->read();
    $self->{items} = scalar $self->{ini}->getHashList(
        $section, {
            key => 'number',
            class => 'RJK::TotalCmd::Item::Button'
        }
    );
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
