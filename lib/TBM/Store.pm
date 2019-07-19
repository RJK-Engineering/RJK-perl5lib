package TBM::Store;

use strict;
use warnings;

# create new, generate id if not specified
sub createObject {
    my ($self, $class, $id) = @_;
}

# get by id, optional properties
sub fetchObject {
    my ($self, $class, $id, $properties) = @_;
}

# get by path, optional properties
sub fetchObjectByPath {
    my ($self, $class, $path, $properties) = @_;
}

# placeholder, no data retrieval
sub getObject {
    my ($self, $class, $id) = @_;
}

# placeholder, no data retrieval
sub getObjectByPath {
    my ($self, $class, $path) = @_;
}

1;
