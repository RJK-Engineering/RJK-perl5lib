package RJK::Module;

use strict;
use warnings;

use Exceptions;
use LoadModuleException;
use ModuleNotFoundException;

sub load {
    shift;
    my $module = join "::", @_;
    my $file = (join "/", @_) . ".pm";
    eval "require $module" && return $module;

    if ($! == 2 && ! grep { -e "$_/$file" } @INC) {
        throw ModuleNotFoundException(
            error => "$@",
            module => $module
        );
    }

    throw LoadModuleException(
        error => "$@",
        module => $module,
        systemErrno => $!+0,
        systemError => "$!"
    );
}

1;
