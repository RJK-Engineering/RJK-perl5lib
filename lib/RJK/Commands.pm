package RJK::Commands;

use strict;
use warnings;

my $commands;
my $aliases;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $commands = $opts{commands};
    $aliases = $opts{aliases};
    return $self;
}

sub execute {
    my ($self, $cmd, @args) = @_;
    $cmd = $aliases->{$cmd} if $aliases->{$cmd};
    if (! ($cmd = $commands->{$cmd})) {
        print "Pardon?\n";
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
