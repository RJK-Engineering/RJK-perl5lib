use TotalCmd::Command;
use TotalCmd::CommandExecutor;
use Try::Tiny;

use Data::Dump;

my $cmd = new TotalCmd::Command(
    menu => "Name",
    cmd => "cmd",
    param => "/c dir %P%N",
);

dd $cmd;

try {
    my $ce = TotalCmd::CommandExecutor->new;
    my $exitcode = $ce->execute(
        $cmd, {
            source => "C:\\swapfile.sys",
            target => undef,
            sourceSelection => [],
            targetSelection => [],
            sourceList => undef,
            targetList => undef,
        }, sub {
            my ($cmd, $args) = @_;
            print "$cmd $args\n";
            #~ system "$cmd $args";
        }
    );
} catch {
    if ( $_->isa('TotalCmd::Command::UnsupportedParameterException') ) {
        warn sprintf "UnsupportedParameterException: %s", $_->parameter();
    } elsif ( $_->isa('TotalCmd::Command::ListFileException') ) {
        warn sprintf "ListFileException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::Command::NoSourceException') ) {
        warn sprintf "NoSourceException - %s.", $_->error();
    } elsif ( $_->isa('TotalCmd::Command::NoSourceFileException') ) {
        warn sprintf "NoSourceFileException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::Command::NoSourceSelectionException') ) {
        warn sprintf "NoSourceSelectionException - %s.", $_->error();
    } elsif ( $_->isa('TotalCmd::Command::NoSourceShortNameException') ) {
        warn sprintf "NoSourceShortNameException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::Command::NoTargetException') ) {
        warn sprintf "NoTargetException - %s.", $_->error();
    } elsif ( $_->isa('TotalCmd::Command::NoTargetFileException') ) {
        warn sprintf "NoTargetFileException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::Command::NoTargetSelectionException') ) {
        warn sprintf "NoTargetSelectionException - %s.", $_->error();
    } elsif ( $_->isa('TotalCmd::Command::NoTargetShortNameException') ) {
        warn sprintf "NoTargetShortNameException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::CommandException') ) {
        warn sprintf "CommandException - %s.", $_->error();
    } else {
        die $_;
    }
};
