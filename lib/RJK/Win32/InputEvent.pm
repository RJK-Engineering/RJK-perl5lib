package RJK::Win32::InputEvent;

use strict;
use warnings;

# @event
# [0] event type: 1 for keyboard
# [1] key down: TRUE if the key is being pressed, FALSE if the key is being released
# [2] repeat count: the number of times the key is being held down
# [3] -> virtual keycode: the virtual key code of the key
# [4] virtual scancode: the virtual scan code of the key
# [5] char: the ASCII code of the character (if the key is a character key, 0 otherwise)
# [6] -> control key state: the state of the control keys (SHIFTs, CTRLs, ALTs, etc.)

use constant {
    MODIFIER_KEY_ALT => 0x02,
    MODIFIER_KEY_CONTROL => 0x08,
    MODIFIER_KEY_SHIFT => 0x10,
};

sub new {
    my $self = bless {}, shift;
    $self->{event} = [ @_ ] if @_;
    return $self;
}

sub keycode {
    return $_[0]{event}[3];
}

sub keychar {
    return $_[0]{event}[5];
}

sub keyDown {
    my $event = $_[0]{event} || return;
    return $event->[0] == 1 && $event->[1];
}

sub isModifierKey {
    my $vkeycode = $_[0]{event}[3];
    return $vkeycode == 0x10 || $vkeycode == 0x11 || $vkeycode == 0x12;
}

sub isAltPressed {
    return $_[0]{event}[6] & MODIFIER_KEY_ALT;
}

sub isCtrlPressed {
    return $_[0]{event}[6] & MODIFIER_KEY_CONTROL;
}

sub isShiftPressed {
    return $_[0]{event}[6] & MODIFIER_KEY_SHIFT;
}

sub isPressed {
    my ($self, $vkey) = @_;
    return $self->{event}[3] == $vkey->{code};
}

1;
