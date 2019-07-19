package TBM::Document;
use parent 'TBM::FileObject';

use strict;
use warnings;

sub getContent {
    my $self = shift;
    return $self->{content};
}

sub hasContent {
    my $self = shift;
    return defined $self->{textContent} || defined $self->{content};
}

sub getTextContent {
    my $self = shift;
    my $text = $self->{textContent};

    if (! $text) {
        open my $fh, "<", $self->{path} or die "$!: $self->{path}";
        $text = [ <$fh> ];
        close $fh;
    }

    return wantarray ? @$text : $text;
}

sub setTextContent {
    my ($self, @text) = @_;
    $self->{textContent} = \@text;
}

1;
