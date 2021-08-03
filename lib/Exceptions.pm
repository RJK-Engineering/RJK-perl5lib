package Exceptions;

BEGIN {
    my @dirs;

    foreach (@INC) {
        next if /Exceptions$/;
        my $dir = "$_/Exceptions";
        push @dirs, $dir if -e $dir;
    }

    push @INC, @dirs;

    require Exception;
    Exception->Trace(1);
}

1;
