package Exceptions;

BEGIN {
    my $base = (grep { /RJK-perl5lib/ } @INC)[0];
    push @INC, "$base/RJK/Exceptions";
    require Exception;
}

1;
