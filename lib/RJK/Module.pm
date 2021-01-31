package RJK::Module;

use strict;
use warnings;

use Exceptions;
use LoadModuleException;
use ModuleNotFoundException;

sub load {
    shift;
    my $module = join "::", @_;
    eval "require $module" && return $module;

    throw ModuleNotFoundException(
        error => "$@",
        module => $module
    ) if $! == 2;

    throw LoadModuleException(
        error => "$@",
        module => $module,
        systemErrno => $!+0,
        systemError => "$!"
    );
}

1;
