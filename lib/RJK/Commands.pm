package RJK::Commands;

use strict;
use warnings;

my $commands;
my $aliases;
my %opts;

sub new {
    my $self = bless {}, shift;
    %opts = @_;
    $opts{noCommandMessage} //= 'Pardon?';
    return $self;
}

sub execute {
    my ($self, $cmd, @args) = @_;
    $cmd = $opts{aliases}{$cmd} if $opts{aliases}{$cmd};
    if (! ($cmd = $opts{commands}{$cmd})) {
        print "$opts{noCommandMessage}\n" if defined $opts{noCommandMessage};
        return;
    }

    my $class = ref $cmd;
    if (! $class) {
        $cmd->execute(@args);
    } elsif ($class eq 'CODE') {
        $cmd->(@args);
    } elsif ($cmd->isa('Command')) {
        $cmd->execute(@args);
    }
}

1;
