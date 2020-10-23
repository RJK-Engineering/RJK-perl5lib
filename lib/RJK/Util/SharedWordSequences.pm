=begin TML

---+ package !RJK::Util::SharedWordSequences

=cut
###############################################################################

package RJK::Util::SharedWordSequences;

use strict;
use warnings;

###############################################################################
=pod

---+++ get($w1 or \@w1, $w2 or \@w2, [$minLength]) -> \@sequences
   * =$w1= or =@w1= - sentence to extract words from or a list of words.
   * =$w2= or =@w2= - sentence to extract words from or a list of words.
   * =$minLength= - optional minimum sequence length to return, default = 1.
   * =@sequences= - list of list of words.

=cut
###############################################################################

sub get {
    my ($w1, $w2, $minLength) = @_;
    $w1 = [ $w1 =~ /(\w+)/g ] if ! ref $w1;
    $w2 = [ $w2 =~ /(\w+)/g ] if ! ref $w2;
    $minLength //= 1;
    my @sequences;

    for (my $i=0; $i<@$w1; $i++) {
        for (my $j=0; $j<@$w2; $j++) {
            #~ print "$i $j $w1->[$i] $w2->[$j]\n";
            next if $w1->[$i] ne $w2->[$j];
            next if $i && $j && $w1->[$i-1] eq $w2->[$j-1]; # previously matched superset

            my @seq = $w1->[$i];
            for (my $n=1;; $n++) {
                #~ printf "!$n %s %s\n", $w1->[$i+$n]//"undef", $w2->[$j+$n]//"undef";
                last if ! $w1->[$i+$n] || ! $w2->[$j+$n] || $w1->[$i+$n] ne $w2->[$j+$n];
                push @seq, $w1->[$i+$n];
            }
            push @sequences, \@seq if @seq >= $minLength;
        }
    }
    return \@sequences;
}

1;
