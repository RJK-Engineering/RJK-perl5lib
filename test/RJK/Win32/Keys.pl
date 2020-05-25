use strict;
use warnings;

use RJK::Win32::Keys;
use Win32::Console;

my $vk = new RJK::Win32::Keys();
my $wcStdIn = new Win32::Console(STD_INPUT_HANDLE);

while (1) {
    my @event = $wcStdIn->Input();
    if (@event && $event[0] == 1 and $event[1]) {
        exit if $vk->isPressed(\@event, 'VK_ESCAPE');
        next if $vk->isModifierKey(\@event);

        my $combo = "";
        $combo .= "C" if $vk->isCtrlPressed(\@event);
        $combo .= "A" if $vk->isAltPressed(\@event);
        $combo .= "S" if $vk->isShiftPressed(\@event);

        $combo .= "+" if $combo;
        # value, constant, key, description
        $combo .= $vk->get(\@event)->[2];

        print "$combo\n";
    }
}
