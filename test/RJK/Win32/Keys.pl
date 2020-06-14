use strict;
use warnings;

use RJK::Win32::InputEvent;
use RJK::Win32::VirtualKeys;
use Win32::Console;

my $vkeys = new RJK::Win32::VirtualKeys();
my $keycodes = $vkeys->getKeyCodes();
my $vkeynames = $vkeys->getVirtualKeyNames();
my $wcStdIn = new Win32::Console(STD_INPUT_HANDLE);

while (1) {
    my $event = new RJK::Win32::InputEvent($wcStdIn->Input());

    if ($event->isKeyDown) {
        exit if $event->isPressed($vkeynames->{VK_ESCAPE});
        next if $event->isModifierKey();

        my $combo = "";
        $combo .= "C" if $event->isCtrlPressed();
        $combo .= "A" if $event->isAltPressed();
        $combo .= "S" if $event->isShiftPressed();

        $combo .= "+" if $combo;
        my $key = $keycodes->{$event->keycode};
        $combo .= $key->{name} . " " . $key->{description};

        print "$combo\n";
    }
}
