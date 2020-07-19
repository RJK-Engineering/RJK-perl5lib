=begin TML

---+ package RJK::Media::EMule::PartMet

=cut

package RJK::Media::EMule::PartMet;

use strict;
use warnings;

use constant {
    PARTMET_HASH => 5,
    PARTMET_HASH_SIZE => 16,
    FILENAME_LENGHT_SIZE => 2,
};

###############################################################################
=pod

---+++ read($filename) -> \%data
Read =.part.met= file and return contents.
   * =%data= - keys: ok, filename, size, hash, utf8

=cut
###############################################################################

sub read {
    my $file = shift;
    my $data = {};

    open (my $fh, $file) or die "$!";
    binmode $fh;

    # hash
    seek $fh, PARTMET_HASH, 0 or return;
    CORE::read $fh, my $d, PARTMET_HASH_SIZE or return;
    $data->{ok} = 1;
    $data->{hash} = unpack("H32", $d);

    my $pos = 0xF;
    # 2 byte string size @ byte 0xF + 0x10 * n
    # string @ byte 0x11 + 0x10 * n
    while (1) {
        seek $fh, $pos, 0 or return;
        $pos += 0x10;

        CORE::read $fh, $d, FILENAME_LENGHT_SIZE or return;
        my $c = unpack("s", $d);
        next unless 1024 > $c && $c > 4;
        last if getNameAndSize($fh, $data, $c);
    }
    return $data;
}

sub getNameAndSize {
    my ($fh, $data, $c) = @_;

    my $str = "";
    my $d;
    CORE::read $fh, $d, 1 or return;
    my $v = unpack("C", $d);
    if ($v == 0xEF) {
        #~ UTF-8 BOM EF BB BF
        CORE::read $fh, $d, 1 or return;
        unpack("C", $d) == 0xBB or return;
        CORE::read $fh, $d, 1 or return;
        unpack("C", $d) == 0xBF or return;
        $c -= 3;
        $data->{utf8} = 1;

        CORE::read $fh, $d, $c or return;
        seek $fh, -$c+1, 1 or return;
        $str = join "", map { chr } unpack("(U)*", $d);
    } else {
        # check chars
        while (1) {
            last unless $c--;
            return if !$data->{utf8} && (0x20 > $v || $v > 0x7E);
            $str .= chr($v);
            CORE::read $fh, $d, 1 or return;
            $v = unpack("C", $d);
        }
    }
    $data->{filename} = $str;

    # size
    seek $fh, 3, 1 or return;
    CORE::read $fh, $d, 4 or return;
    $data->{size} = unpack("L", $d);
}

1;
