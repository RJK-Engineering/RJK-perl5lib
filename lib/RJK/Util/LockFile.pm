package RJK::Util::LockFile;

sub checkExistingLock {
    my $lockFile = shift;
    if (-e $lockFile) {
        open my $fh, '<', $lockFile or die "$!: $lockFile";
        my $pid = <$fh>;
        chomp $pid;
        close $fh;

        my $proc = RJK::Win32::ProcessList::GetPid($pid);
        if ($proc) {
            # TODO show process name
            # TODO option to force start
            print "$0 is already running.\n";
            undef $lockFile; # do not remove file when calling finish()
            exit 1;
        } else {
            print "$0 was not closed properly, old lock file found.\n";
            unlink $lockFile;
        }
    }
}

sub createLock {
    my $lockFile = shift;
    open my $fh, '>', $lockFile or die "$!: $lockFile";
    print $fh $$; # write pid
    close $fh;
}

sub removeLock {
    my $lockFile = shift;
    unlink $lockFile;
}

1;
