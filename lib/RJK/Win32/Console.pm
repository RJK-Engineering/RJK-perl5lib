###############################################################################
=begin TML

---+ package RJK::Win32::Console

Console input/output functionality.

=cut
###############################################################################

package RJK::Win32::Console;

use strict;
use warnings;

use Win32::Console;

###############################################################################
=pod

---++ Object creation

---+++ new() -> $console
Returns a new =Console= object.

=cut
###############################################################################

my $echo = 1;
my ($in, $out);

sub new {
    if ($^O eq 'MSWin32') {
        $in = new Win32::Console(STD_INPUT_HANDLE);
        $out = new Win32::Console(STD_OUTPUT_HANDLE);
    } else {
        die "OS not supported";
    }
    return bless {}, shift;
}

###############################################################################
=pod

---++ Info

---+++ columns()
First element in array returned by
=[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::Info=.
---+++ title()
See =[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::Title=.
---+++ getEvents()
See =[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::GetEvents=.

=cut
###############################################################################

sub cursor    {  $out->Cursor(@_)   }
sub columns   { ($out->Info)[0]     }
sub row       { ($out->Cursor)[1]   }
sub title     {  $out->Title($_[1]) }
sub getEvents {  $in->GetEvents()   }

###############################################################################
=pod

---++ Write

---+++ write()
See =[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::Write=.
---+++ input()
See =[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::Input=.
---+++ flush()
See =[[http://search.cpan.org/~jdb/Win32-Console-0.10/Console.pm][Win32::Console]]::Flush=.

=cut
###############################################################################

sub write     { $out->Write($_[1]) }
sub input     { $in->Input() }
sub flush     { $in->Flush() }

###############################################################################
=pod

---+++ pause()
Wait for keyboard key press.

---+++ confirm($question) -> $confirmed
Returns true if "y" or "Y" key is pressed.

---+++ ask($question, \@choices) -> $choice
Waits for choice selection.
   * =$choices= - Array containing choices: [ $key, $displayValue, $returnValue ]
      * If no $returnValue is given $displayValue will be returned.
      * If no $displayValue is given $key will be displayed and returned.

---+++ select($choices) -> $choice
Prints lists of choices and waits for choice selection.
   * =$choices= - Array containing list of choices

---+++ question($question, $value)

=cut
###############################################################################

sub pause {
    while (1) {
        my @event = $in->Input;
        last if $event[0]
            and $event[0] == 1  # keyboard
            and $event[1]       # key pressed
            and $event[5] > 0;  # character key
    }
}

sub readKey {
    while (1) {
        my @event = $in->Input;

        if ($event[0]
        and $event[0] == 1  # keyboard
        and $event[1]       # key pressed
        ) {
            return $event[3];
        }
    }
}

sub readKeyChar {
    while (1) {
        my @event = $in->Input;

        if ($event[0]
        and $event[0] == 1  # keyboard
        and $event[1]       # key pressed
        and $event[5]       # ascii
        ) {
            return chr $event[5];
        }
    }
}

sub confirm {
    my ($self, $question) = @_;

    $out->Write("$question ");
    my $key = &readKeyChar;
    $out->Write("$key\n") if $echo;

    return lc $key eq 'y';
}

sub ask {
    my ($self, $question, $choices) = @_;

    $out->Write("$question (");
    $out->Write(join "/", map { $_->[1] // $_->[0] } @$choices);
    $out->Write(") ");

    my %retvals = map { $_->[0] => $_->[2] // $_->[1] // $_->[0] } @$choices;
    my $key = chr(0);
    do {
        my @event = $in->Input;
        if (@event && $event[0] == 1 and $event[1]) {
            $key = chr $event[5];
        }
    } while (! grep { /$key/ } keys %retvals);

    $out->Write("$key\n");

    my $ret = $retvals{$key};
    return ref $ret && ref $ret eq 'CODE' ? $ret->() : $ret;
}

sub select {
    my ($self, $choices) = (shift, shift);
    my %opts = @_;

    my $i = 0x31;
    foreach (@$choices) {
        $out->Write(chr($i) . ". $_\n");
        die if ++$i > 0x31 + 9; # 1-9
    }

    my $key = 0;
    while (1) {
        my @event = $in->Input;
        if (@event && $event[0] == 1 and $event[1]) {
            $key = $event[5];
            if ($key >= 0x31 and $key < 0x31 + @$choices) {
                $key -= 0x31;
                last;
            } elsif ($key == 27 && ! $opts{required}) {
                $key = undef;
                last;
            }
        }
    }
    return $key;
}

sub question {
    my ($self, $question, $value) = @_;

    my $columns = ($out->Info)[0];
    return if 10 + length $question > $columns; # not enough columns
    $value = substr $value, 0, $columns - 2 - length $question; # chop value to fit on line

    $out->Write($question);
    my @startCursor = $out->Cursor;
    my $homePos = $startCursor[0];

    $out->Write($value);
    my $endPos = $startCursor[0] + length $value;

    my $key = 0;
    my $prevKey = 0;
    do {
        my @event = $in->Input;
        if (@event && $event[0] == 1 and $event[1]) {
            $key = $event[5];
            my @c = $out->Cursor;
            my $pos = $c[0];
            if ($event[3] == 8) { # backspace
                if ($c[0] > $homePos) {
                    my $r = $out->ReadChar($endPos - $c[0] + 1, @c[0..1]);
                    $c[0]--;
                    $out->Cursor(@c);
                    $out->Write($r . " ");
                    $endPos--;
                }
            } elsif ($event[3] == 27) { # escape
                # reset
                $out->Cursor(@startCursor);
                $out->Write(" " x ($endPos - $homePos));
                $out->Cursor(@startCursor);
                $endPos = $startCursor[0];
                if ($prevKey != 27) {
                    $out->Write($value);
                    $endPos += length $value;
                }
                $c[0] = $endPos;
            } elsif ($event[3] == 35) { # end
                $c[0] = $endPos;
            } elsif ($event[3] == 36) { # home
                $c[0] = $homePos;
            } elsif ($event[3] == 37) { # left
                if ($c[0] > $homePos) {
                    $c[0]--;
                }
            } elsif ($event[3] == 39) { # right
                if ($c[0] < $endPos) {
                    $c[0]++;
                }
            } elsif ($event[3] == 46) { # delete
                if ($c[0] < $endPos) {
                    $c[0]++;
                    my $r = $out->ReadChar($endPos - $c[0] + 1, @c[0..1]);
                    $c[0]--;
                    $out->Cursor(@c);
                    $out->Write($r . " ");
                    $endPos--;
                }
            } elsif ($key >= 20) {
                if ($endPos < $columns - 2) { # multi-line edit not supported
                    $out->Write(chr($key) . $out->ReadChar($endPos - $c[0] + 1, @c[0..1]));
                    $c[0]++;
                    $endPos++;
                }
            }
            $out->Cursor(@c);
            $prevKey = $prevKey == 27 ? 0 : $event[3];
        }
    } while ($key != 13); # enter

    my $input = $out->ReadChar($endPos - $homePos, @startCursor[0..1]);
    $out->Write("\n");

    return $input;
}

###############################################################################
=pod

---++ itemFromList($list) -> $answer

=cut
###############################################################################

sub itemFromList {
    my ($self, $list) = @_;
    my $i = 1;
    foreach (@$list) {
        $out->Write($i++ . ") $_\n");
        last if $i==9;
    }
    my $n = &readKeyChar;

    if ($n =~ /^\d+$/ && $n>0 && $n<=@$list) {
        return $list->[$n-1];
    }
}

###############################################################################
=pod

---+++ newLine()
Ensure we're on a new line, i.e. if we're not at the
start of a line, go to the start of the next.

=cut
###############################################################################

sub newLine {
    my @c = $out->Cursor;
    if ($c[0] > 0) {
        $c[0] = 0;
        $c[1]++;
        $out->Cursor(@c);
    }
}

###############################################################################
=pod

---+++ printLine($string, $trim)
Print string after ensuring we're on a new line (see =newLine()=) and move
cursor to the next line.
Trims string to fit on one line if =$trim= has a true value.

=cut
###############################################################################

sub printLine {
    my ($self, $str, $trim) = @_;
    $self->newLine;

    my $columns = ($out->Info)[0];
    $str = substr $str, 0, $columns if $trim;
    $out->Write($str);

    # do not print newline if cursor already on next line because of wrapping
    # after last character, i.e. string fits screen width exactly
    $out->Write("\n") unless length($str) == $columns;
}

###############################################################################
=pod

---+++ updateLine($string, $trim)
Clears current line and prints string from the start of the line.
Trims string to fit on one line if =$trim= has a true value.

=cut
###############################################################################

sub updateLine {
    my ($self, $str, $trim) = @_;

    # get cursor position
    my ($col, $row) = my @c = $out->Cursor;

    # adjust string
    if ($trim || $col) {
        # chomp newlines
        my $chomped = 0;
        $chomped++ while chomp $str;

        my $columns = ($out->Info)[0] - 1;
        my $length = length $str;

        if ($trim) {
            # trim to console width
            if ($columns < $length) {
                $str = substr $str, 0, $columns;
                $length = $columns;
            }
        }

        if ($col) {
            # erase previous text not printed over by new text
            my $n = $col - $length;
            if ($n > 0) {
                $out->FillChar(" ", $n, $length, $row);
            }
            # go to start of line
            $c[0] = 0;
            #~ print  "$length == $columns\n";
            #~ $c[1]-- if $length == $columns;
            $out->Cursor(@c);
        }

        # append chomped newlines
        $str .= "\n" x $chomped;
    }

    $out->Write($str);
}

###############################################################################
=pod

---+++ lineUp([$nrOfLines])
Move cursor up. Defaults to 1 line.

=cut
###############################################################################

sub lineUp {
    my ($self, $nrOfLines) = @_;
    $nrOfLines ||= 1;
    my @c = $out->Cursor;
    $c[1] -= $nrOfLines;
    $out->Cursor(@c);
}

###############################################################################
=pod

---+++ clearLine($row)
---+++ clearCurrentLine()
---+++ getLine($row)
---+++ getCurrentLine()
---+++ getPreviousLine()

=cut
###############################################################################

sub clearLine {
    my ($self, $row) = @_;
    my $col = ($out->Info)[0];
    $out->FillChar(" ", $col, 0, $row);
}

sub clearCurrentLine {
    my $row = ($out->Cursor)[1];
    $_[0]->clearLine($row);
    $out->Cursor(0, $row);
}

sub getLine {
    my ($self, $row) = @_;
    my $col = ($out->Info)[0];
    my $chars = $out->ReadChar($col, 0, $row);
    return $chars =~ s/\s+$//r;
}

sub getCurrentLine {
    my $row = ($out->Cursor)[1];
    return $_[0]->getLine($row);
}

sub getPreviousLine {
    my $row = ($out->Cursor)[1] - 1;
    return $_[0]->getLine($row);
}

sub removeDupeLine {
    return if &getCurrentLine ne &getPreviousLine;
    &clearCurrentLine;
}

1;
