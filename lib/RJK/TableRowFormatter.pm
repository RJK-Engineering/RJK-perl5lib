package RJK::TableRowFormatter;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = @_ == 1 ? (format => $_[0]) : @_;
    $self->setFormat($opts{format}) if $opts{format};
    $self->{filters} = $opts{filters};
    $self->{header} = $opts{header};
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
    # additional type "h": convert size in bytes to human-readable format
    #~ while ($format =~ s/%(\w+|'[\w\s]+')=($precision)?([abcdefghilnoprsuvx])?/
    #~         "%" . ($2||"") . ($4 && ($4 eq "h" || $4 eq "r") && "s" || $4 || "s") /e  #/
    # additional type "r": trim left side (show [r]ight) instead of right side when string exceeds max width
    while ($format =~ s/%(\w+|'[\w\s]+')=($precision)?([abcdefgilnoprsuvx])?/
            "%" . ($2||"") . ($4 && $4 eq "r" && "s" || $4 || "s") /e  #/
    ) {
        push @fields, $1;
        $self->{width}[$i] = $3;
        $self->{ltrim}[$i++] = $4 && $4 eq "r";

        $fields[-1] =~ s/'//g;
    }

    $self->{format} = "$format\n";
    $self->{fields} = \@fields;
}

sub header {
    my $self = shift;
    return sprintf $self->{format}, map {
        $self->{header}{$_} // ucfirst $_
    } @{$self->{fields}};
}

sub format {
    my ($self, $hash) = @_;
    my @fields = @{$self->{fields}};
    my @values = map { $hash->{$_} // "" } @fields;

    for (my $i=0; $i<@values; $i++) {
        if ($self->{ltrim}[$i] && $self->{width}[$i]) {
            $values[$i] = substr $values[$i], -$self->{width}[$i];
        }
        if ($self->{filters}{$fields[$i]}) {
            $values[$i] = $self->{filters}{$fields[$i]}($values[$i]);
        }
    }

    return sprintf $self->{format}, @values;
}

1;
