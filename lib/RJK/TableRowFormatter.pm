package RJK::TableRowFormatter;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->setFormat($_[0]) if $_[0];
    $self->{delimiter} = "\t";
    return $self;
}

sub setFormat {
    my ($self, $format) = @_;
    # insert missing type specifications
    $format =~ s/(%\w+|%'[\w\s]+')([^=\w])/$1=s$2/g;
    $format =~ s/(%\w+|%'[\w\s]+')$/$1=s/;

    my @fields;
    my $precision = '-?\d*(?:\.(\d+))?';
    my $i = 0;
    # optional precision
    # optional type, defaults to "s"
    # additional type "r": trim left side (show [r]ight) instead of right side when string exceeds max width
    while ($format =~ s/%(\w+|'[\w\s]+')=($precision)?([abcdefgilnoprsuvx])?/
            "%" . ($2||"") . ($4 && $4 eq "r" && "s" || $4 || "s") /e  #/
    ) {
        push @fields, $1;
        $self->{width}[$i] = $3;
        $self->{ltrim}[$i++] = $4 && $4 eq "r";

        $fields[-1] =~ s/'//g;
    }

    $self->{format} = $format;
    $self->{fields} = \@fields;
}

sub format {
    my ($self, $hash, @fields) = @_;
    my $format;
    if (@fields) {
        my @keys = keys %$hash;
        my @match;
        foreach my $field (@fields) {
            if ($field =~ /[?*]/) {
                $field =~ s/\?/./g;
                $field =~ s/\*/.*/g;
            }
            push @match, sort grep { /^$field$/ } @keys;
        }
        @fields = @match;
        $format = join $self->{delimiter}, ("%s")x@fields;
    } else {
        @fields = @{$self->{fields}};
        $format = $self->{format};
    }

    my @values = map { $hash->{$_} // "" } @fields;
    for (my $i=0; $i<@values; $i++) {
        if ($self->{ltrim}[$i] && $self->{width}[$i]) {
            $values[$i] = substr $values[$i], -$self->{width}[$i];
        }
    }

    return sprintf $format, @values;
}

1;

