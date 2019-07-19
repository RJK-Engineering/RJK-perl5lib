package TBM::Folder;
use parent 'TBM::FileObject';

use strict;
use warnings;

use File::Spec::Functions qw(catdir);

sub file {
    my ($self, $doc) = @_;
    my $docName = $doc->getName();
    if ($doc->hasContent && $docName) {
        my $path = catdir($self->{path}, $docName);
        open my $fh, ">", $path or die "$!: $path";
        print $fh $doc->getTextContent;
        close $fh;
    }
}

1;