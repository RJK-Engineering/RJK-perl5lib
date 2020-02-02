package RJK::Media::Humax::Hmt;

use strict;

use Exception::Class (
    'Exception',
    'RJK::Media::Humax::HmtException' =>
        { isa => 'Exception' },
);

use constant {
    HMT_START         => 0x0000, # Start HMT buffer
    HMT_BOOKM_COUNT   => 0x0009,
    HMT_CHANNEL       => 0x000F, # Channel number
    HMT_TIME_START    => 0x0019, # DateTime stamp start
    HMT_TIME_END      => 0x001d, # DateTime stamp end
    HMT_PATHNAME      => 0x0021, # Linux pathname on /media/sda1/*
    HMT_EVENTNAME     => 0x0120, # Event name
    HMT_SERVICENAME   => 0x0220, # Service name
    HMT_RECORDING_OK  => 0x0242, # Recording is OKee
    HMT_ICON_NEW      => 0x0243, # NEW icon :=> 0x0010, #.0000
    HMT_BOOKMARKS     => 0x0269,
    HMT_SRVSID        => 0x02f3, # Service ID
    HMT_PMTPID        => 0x02f5, # PMT
    HMT_VIDPID        => 0x02f7, # Video PID
    HMT_AUDPID        => 0x02f9, # Audio PID
    HMT_PCRPID        => 0x02fb, # PCR PID (mostly in the Video)
    HMT_TTXPID        => 0x02fd, # Sub-Picture PID (DVB-TTX)
    HMT_UNKPID        => 0x02ff, # ??
    HMT_PLAYBACK_POS  => 0x0305,
    #HMT_TIME_RESTART  => 0x0307, # Playback start in seconds
    HMT_XXXX_RESTART  => 0x030c, # Playback start index

    HMT_PF_COUNT      => 0x1000, # Size of Present/Following data
    #HMT_PF_COUNT      => 4101, # Size of Present/Following data
    HMT_PF_EVENTS     => 0x1004, # Events 1
    # Next Event Offset = 0x1004+0x220+Size1
    #HMT_LONGDESCR_END => 0x2000, # EOF

    HMT_PF_NR          => 0x000, # Event ID
    HMT_PF_DATA        => 0x002, # Unknown data
    HMT_PF_1        => 0x004, # int
    HMT_PF_2        => 0x008, # int
    HMT_PF_3        => 0x00C, #
    HMT_PF_4        => 0x010, # 00 00 00 00
    HMT_PF_NAME        => 0x014, # Event name

    HMT_PF_DESCR_SIZE1 => 0x21c, # Event descriptor size
    HMT_PF_DESCR_SIZE2 => 0x220, # Twice
    HMT_PF_DESCR_HDR   => 0x224, # Event Descriptor header
    HMT_PF_DESCR_TEXT  => 0x236, # Event Descriptor
};

my $hmtString = {
    HMT_PATHNAME      => 0x0021, # Linux pathname on /media/sda1/*
    HMT_EVENTNAME     => 0x0120, # Event name
    HMT_SERVICENAME   => 0x0220, # Service name
};
my $hmtInt = {
    HMT_TIME_START    => 0x0019, # DateTime stamp start
    HMT_TIME_END      => 0x001d, # DateTime stamp end
    HMT_PLAYBACK_POS  => 0x0305,
    HMT_CHANNEL       => 0x000F, # Channel number
};
my $hmtShort = {
    HMT_BOOKM_COUNT   => 0x000A,
};

my $fh;

sub GetInfo {
    my $file = shift;
    my $info = {};

    open ($fh, $file) or throw RJK::Media::Humax::HmtException("$!");
    binmode $fh;

    $info->{channel} = readInt(HMT_CHANNEL);
    $info->{start} = readInt(HMT_TIME_START);
    $info->{end} = readInt(HMT_TIME_END);
    $info->{path} = readString(0xFF, HMT_PATHNAME);
    $info->{title} = readString(0xFF, HMT_EVENTNAME);
    $info->{service} = readString(0x1F, HMT_SERVICENAME);
    $info->{playbackPosition} = readInt(HMT_PLAYBACK_POS);

    my $bookmarkCount = readShort(HMT_BOOKM_COUNT);
    if ($bookmarkCount > 31) {
        throw RJK::Media::Humax::HmtException("Bookmark count exceeds 31");
    }

    my $pos = HMT_BOOKMARKS;
    $info->{bookmarks} = [];
    for (1..$bookmarkCount) {
        my $i = readInt($pos);
        my $s = readShort($pos+3);
        if ($s < $i && $info->{bookmarks}[-1] < $s
                    && $s != 2 ** 8
                    && $s != 2 ** 10) {
            $i = $s;
            $pos += 5;
        } else {
            $pos += 4;
        }
        push @{$info->{bookmarks}}, $i;
    }

    my $eventCount = readInt(HMT_PF_COUNT);
    if ($eventCount > 31) {
        throw RJK::Media::Humax::HmtException("Event count exceeds 31");
    }

    $info->{events} = [];
    my $offset = HMT_PF_EVENTS;

    for (1..$eventCount) {
        my $e = getEvent($offset);
        push @{$info->{events}}, $e;
        $offset += $e->{length};
    }

    close $fh;
    return $info;
}

sub getEvent {
    my $offset = shift;
    my $event = {};
#~ printf "! %x\n", $offset;

    $event->{name} = readString(0xFF, $offset + HMT_PF_NAME);

    my $size1 = readInt($offset + HMT_PF_DESCR_SIZE1);
    my $size2 = readInt();
    if ($size1 && $size1 == $size2) {
        my $blockCount = readInt($offset + HMT_PF_DESCR_HDR);
        if ($blockCount > 31) {
            throw RJK::Media::Humax::HmtException("Block count exceeds 31");
        }

        $event->{info} = "";
        for (1..$blockCount) {
            seek $fh, 0xD, 1; # skip stuff with lang
            my $c = readByte(); # string length
            $event->{info} .= readString($c);
        }
        $event->{length} = 0x220 + $size1;
    } else {
        $event->{info} = readString(0xFF, $offset + 0x114);
        $event->{length} = 0x21C;
    }

    return $event;
}

sub readInt {
    my $pos = shift;
    seek $fh, $pos, 0 if $pos;
    my $i;
    read $fh, $i, 4;
    return unpack("N", $i);
}

sub readShort {
    my $pos = shift;
    seek $fh, $pos, 0 if $pos;
    my $s;
    read $fh, $s, 2;
    return unpack("n", $s);
}

sub readByte {
    my $pos = shift;
    seek $fh, $pos, 0 if $pos;
    my $b;
    read $fh, $b, 1;
    return unpack("C", $b);
}

sub readString {
    my ($length, $pos) = @_;
    my $s;
    seek $fh, $pos, 0 if $pos;
    read $fh, $s, $length;

    my $c = unpack("C", substr $s, 0, 1);
    $s = substr $s, 1 if $c == 5;
    #~ $s = substr $s, 1 if $c == 10;

    return substr $s, 0, index($s, "\0");
}

1;
