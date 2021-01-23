package Exception;

BEGIN {
    require Exception::Class;
    my $exceptionBaseClass = $Exception::Class::BASE_EXC_CLASS;
    push @ISA, $exceptionBaseClass;
}

1;
