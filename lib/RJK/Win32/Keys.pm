package RJK::Win32::Keys;

use strict;
use warnings;

use constant {
    MODIFIER_KEY_ALT => 0x02,
    MODIFIER_KEY_CONTROL => 0x08,
    MODIFIER_KEY_SHIFT => 0x10,
};

my $data;
my @data;
my %value;
my %constant;
my %key;

sub new {
    my $self = bless {}, shift;
    @data = map {
        my @a = split /\t/;
        $a[0] = hex $a[0] if $a[0] =~ /^[\da-f]+$/i;
        \@a;
    } split /\n/, $data if ! @data;
    return $self;
}

sub get {
    shift->_value();
    my $v = shift->[3];
    return wantarray ? @{$value{$v}} : $value{$v};
}

sub getConstant {
    my ($self, $value) = @_;
    $self->_constant();
    return wantarray ? @{$constant{$value}} : $constant{$value};
}

sub getKey {
    my ($self, $value) = @_;
    $self->_key();
    return wantarray ? @{$key{$value}} : $key{$value};
}

sub isModifierKey {
    my $v = $_[1][3];
    return $v == 0x10 || $v == 0x11 || $v == 0x12;
}

sub isAltPressed {
    return $_[1][6] & MODIFIER_KEY_ALT;
}

sub isCtrlPressed {
    return $_[1][6] & MODIFIER_KEY_CONTROL;
}

sub isShiftPressed {
    return $_[1][6] & MODIFIER_KEY_SHIFT;
}

sub isPressed {
    my ($self, $event, $constant) = @_;
    return $event->[3] == $self->getConstant($constant)->[0];
}

sub _value {
    %value = map { $_->[0] => $_ } @data if !%value;
}

sub _constant {
    %constant = map { $_->[1] => $_ } @data if !%constant;
}

sub _key {
    %key = map { $_->[2] => $_ } @data if !%key;
}

# value, constant, key, description (tab delimited)
$data = <<EOF;
01	VK_LBUTTON		Left mouse button
02	VK_RBUTTON		Right mouse button
03	VK_CANCEL		Control-break processing
04	VK_MBUTTON		Middle mouse button (three-button mouse)
05	VK_XBUTTON1		X1 mouse button
06	VK_XBUTTON2		X2 mouse button
07			Undefined
08	VK_BACK	BACK	BACKSPACE key
09	VK_TAB	TAB	TAB key
0A-0B			Reserved
0C	VK_CLEAR	CLEAR	CLEAR key
0D	VK_RETURN	ENTER	ENTER key
0E-0F			Undefined
10	VK_SHIFT	SHIFT	SHIFT key
11	VK_CONTROL	CTRL	CTRL key
12	VK_MENU	ALT	ALT key
13	VK_PAUSE	PAUSE	PAUSE key
14	VK_CAPITAL	CAPS LOCK	CAPS LOCK key
15	VK_HANGUL		IME Hangul mode
16			Undefined
17	VK_JUNJA		IME Junja mode
18	VK_FINAL		IME final mode
19	VK_KANJI		IME Kanji mode
1A			Undefined
1B	VK_ESCAPE	ESC	ESC key
1C	VK_CONVERT		IME convert
1D	VK_NONCONVERT		IME nonconvert
1E	VK_ACCEPT		IME accept
1F	VK_MODECHANGE		IME mode change request
20	VK_SPACE	SPACE	SPACEBAR
21	VK_PRIOR	PGUP	PAGE UP key
22	VK_NEXT	PGDN	PAGE DOWN key
23	VK_END	END	END key
24	VK_HOME	HOME	HOME key
25	VK_LEFT	LEFT	LEFT ARROW key
26	VK_UP	UP	UP ARROW key
27	VK_RIGHT	RIGHT	RIGHT ARROW key
28	VK_DOWN	DOWN	DOWN ARROW key
29	VK_SELECT	SELECT	SELECT key
2A	VK_PRINT	PRINT	PRINT key
2B	VK_EXECUTE	EXECUTE	EXECUTE key
2C	VK_SNAPSHOT	PRINT SCREEN	PRINT SCREEN key
2D	VK_INSERT	INS	INS key
2E	VK_DELETE	DEL	DEL key
2F	VK_HELP	HELP	HELP key
30		0	0 key
31		1	1 key
32		2	2 key
33		3	3 key
34		4	4 key
35		5	5 key
36		6	6 key
37		7	7 key
38		8	8 key
39		9	9 key
3A-40			Undefined
41		A	A key
42		B	B key
43		C	C key
44		D	D key
45		E	E key
46		F	F key
47		G	G key
48		H	H key
49		I	I key
4A		J	J key
4B		K	K key
4C		L	L key
4D		M	M key
4E		N	N key
4F		O	O key
50		P	P key
51		Q	Q key
52		R	R key
53		S	S key
54		T	T key
55		U	U key
56		V	V key
57		W	W key
58		X	X key
59		Y	Y key
5A		Z	Z key
5B	VK_LWIN	Left Windows	Left Windows key (Natural keyboard)
5C	VK_RWIN	Right Windows	Right Windows key (Natural keyboard)
5D	VK_APPS	Applications	Applications key (Natural keyboard)
5E			Reserved
5F	VK_SLEEP	Computer Sleep	Computer Sleep key
60	VK_NUMPAD0	Numeric keypad 0	Numeric keypad 0 key
61	VK_NUMPAD1	Numeric keypad 1	Numeric keypad 1 key
62	VK_NUMPAD2	Numeric keypad 2	Numeric keypad 2 key
63	VK_NUMPAD3	Numeric keypad 3	Numeric keypad 3 key
64	VK_NUMPAD4	Numeric keypad 4	Numeric keypad 4 key
65	VK_NUMPAD5	Numeric keypad 5	Numeric keypad 5 key
66	VK_NUMPAD6	Numeric keypad 6	Numeric keypad 6 key
67	VK_NUMPAD7	Numeric keypad 7	Numeric keypad 7 key
68	VK_NUMPAD8	Numeric keypad 8	Numeric keypad 8 key
69	VK_NUMPAD9	Numeric keypad 9	Numeric keypad 9 key
6A	VK_MULTIPLY	Multiply	Multiply key
6B	VK_ADD	Add	Add key
6C	VK_SEPARATOR	Separator	Separator key
6D	VK_SUBTRACT	Subtract	Subtract key
6E	VK_DECIMAL	Decimal	Decimal key
6F	VK_DIVIDE	Divide	Divide key
70	VK_F1	F1	F1 key
71	VK_F2	F2	F2 key
72	VK_F3	F3	F3 key
73	VK_F4	F4	F4 key
74	VK_F5	F5	F5 key
75	VK_F6	F6	F6 key
76	VK_F7	F7	F7 key
77	VK_F8	F8	F8 key
78	VK_F9	F9	F9 key
79	VK_F10	F10	F10 key
7A	VK_F11	F11	F11 key
7B	VK_F12	F12	F12 key
7C	VK_F13	F13	F13 key
7D	VK_F14	F14	F14 key
7E	VK_F15	F15	F15 key
7F	VK_F16	F16	F16 key
80	VK_F17	F17	F17 key
81	VK_F18	F18	F18 key
82	VK_F19	F19	F19 key
83	VK_F20	F20	F20 key
84	VK_F21	F21	F21 key
85	VK_F22	F22	F22 key
86	VK_F23	F23	F23 key
87	VK_F24	F24	F24 key
88-8F			Unassigned
90	VK_NUMLOCK	NUM LOCK	NUM LOCK key
91	VK_SCROLL	SCROLL LOCK	SCROLL LOCK key
92-96			OEM specific
97-9F			Unassigned
A0	VK_LSHIFT	Left SHIFT	Left SHIFT key
A1	VK_RSHIFT	Right SHIFT	Right SHIFT key
A2	VK_LCONTROL	Left CONTROL	Left CONTROL key
A3	VK_RCONTROL	Right CONTROL	Right CONTROL key
A4	VK_LMENU	Left MENU	Left MENU key
A5	VK_RMENU	Right MENU	Right MENU key
A6	VK_BROWSER_BACK	Browser Back	Browser Back key
A7	VK_BROWSER_FORWARD	Browser Forward	Browser Forward key
A8	VK_BROWSER_REFRESH	Browser Refresh	Browser Refresh key
A9	VK_BROWSER_STOP	Browser Stop	Browser Stop key
AA	VK_BROWSER_SEARCH	Browser Search	Browser Search key
AB	VK_BROWSER_FAVORITES	Browser Favorites	Browser Favorites key
AC	VK_BROWSER_HOME	Browser Start and Home	Browser Start and Home key
AD	VK_VOLUME_MUTE	Volume Mute	Volume Mute key
AE	VK_VOLUME_DOWN	Volume Down	Volume Down key
AF	VK_VOLUME_UP	Volume Up	Volume Up key
B0	VK_MEDIA_NEXT_TRACK	Next Track	Next Track key
B1	VK_MEDIA_PREV_TRACK	Previous Track	Previous Track key
B2	VK_MEDIA_STOP	Stop Media	Stop Media key
B3	VK_MEDIA_PLAY_PAUSE	Play/Pause Media	Play/Pause Media key
B4	VK_LAUNCH_MAIL	Start Mail	Start Mail key
B5	VK_LAUNCH_MEDIA_SELECT	Select Media	Select Media key
B6	VK_LAUNCH_APP1	Start Application 1	Start Application 1 key
B7	VK_LAUNCH_APP2	Start Application 2	Start Application 2 key
B8-B9			Reserved
BA	VK_OEM_1	;:	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ';:' key
BB	VK_OEM_PLUS	+	For any country/region, the '+' key
BC	VK_OEM_COMMA	,	For any country/region, the ',' key
BD	VK_OEM_MINUS	-	For any country/region, the '-' key
BE	VK_OEM_PERIOD	.	For any country/region, the '.' key
BF	VK_OEM_2	/?	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '/?' key
C0	VK_OEM_3	`~	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '`~' key
C1-D7			Reserved
D8-DA			Unassigned
DB	VK_OEM_4	[{	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '[{' key
DC	VK_OEM_5	\|	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '\|' key
DD	VK_OEM_6	]}	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ']}' key
DE	VK_OEM_7	'"	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ''"' key
DF	VK_OEM_8		Used for miscellaneous characters; it can vary by keyboard.
E0			Reserved
E1			OEM specific
E2	VK_OEM_102		Either the angle bracket key or the backslash key on the RT 102-key keyboard
E3-E4			OEM specific
E5	VK_PROCESSKEY	IME PROCESS	IME PROCESS key
E6			OEM specific
E7	VK_PACKET		Used to pass Unicode characters as if they were keystrokes. TheVK_PACKET key is the low word of a 32-bit Virtual Key value used for
E8			Unassigned
E9-F5			OEM specific
F6	VK_ATTN	Attn	Attn key
F7	VK_CRSEL	CrSel	CrSel key
F8	VK_EXSEL	ExSel	ExSel key
F9	VK_EREOF	Erase EOF	Erase EOF key
FA	VK_PLAY	Play	Play key
FB	VK_ZOOM	Zoom	Zoom key
FC	VK_NONAME		Reserved
FD	VK_PA1	PA1	PA1 key
FE	VK_OEM_CLEAR	Clear	Clear key
EOF

1;
