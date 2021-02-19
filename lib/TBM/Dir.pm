package TBM::Dir;
use parent 'TBM::Object';

use strict;
use warnings;

use TBM::Path;

sub getFiles {
    my ($self) = @_;
    my %files;
    ::table('TBM::Path')->select({tail_id => $self->{id}}, sub {
        my $path = shift;
        $files{$path->{filename}} = $path->head;
        return 0;
    });
    return \%files;
}

sub addFile {
    my ($self, $file) = @_;
    ::table('TBM::Path')->insert({
        head_id => $file->{id},
        head_class => $file->{class},
        tail_id => $self->{id},
        tail_class => $self->{class},
        filename => $file->{name},
    });
}

1;
