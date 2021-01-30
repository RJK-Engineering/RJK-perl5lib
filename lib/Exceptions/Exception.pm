package Exception;

BEGIN {
    require Exception::Class;
    push @ISA, $Exception::Class::BASE_EXC_CLASS;
}

1;
