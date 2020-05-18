package RJK::Media::MPC::Observers::IniDiff;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

use Text::Diff;

sub handleFileChangedEvent {
    my ($self, $ini) = @_;

    if ($self->{content}) {
        my $diff = diff \$self->{content}, $ini->{file}, {
            STYLE => "Context"  # "Unified", "Context", "OldStyle"
        };
        print $diff;
    }

    local $/ = undef;
    open my $fh, "<", $ini->{file} or return;
    $self->{content} = <$fh>;
    close $fh;
}

1;
