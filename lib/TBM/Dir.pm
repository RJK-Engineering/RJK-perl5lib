package TBM::Dir;
use parent 'TBM::Object';

use strict;
use warnings;

use TBM::Factory;
use TBM::Path;
use TBM::Search;

#~ sub getSubdirs {
#~     my ($self) = @_;
#~     return {};
#~ }

sub getFiles {
    my ($self) = @_;
    my %files;
    TBM::Search->fetch('TBM::Path', {tail => $self}, sub {
        my $path = shift;
        $files{$path->{filename}} = $path->head;
        return 0;
    });
    return \%files;
}

sub addFile {
    my ($self, $file) = @_;
    my $path = TBM::Factory->Path->create();
    $path->setDir($self);
    $path->setFile($file);
    $path->setFilename($file->{name});
    $path->save();
}

1;
