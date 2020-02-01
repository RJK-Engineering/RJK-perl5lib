use strict;
use warnings;

package TBM::Factory;

package TBM::Factory::Document;

use TBM::Constants;
use TBM::Document;

sub createInstance {
    my ($store, $class, $id) = @_;
    $store->createObject(TBM::Constants::CLASSNAME_DOCUMENT, $id);
}

sub fetchInstance {
    my ($store, $id, $properties) = @_;
    $store->fetchObject(TBM::Constants::CLASSNAME_DOCUMENT, $id, $properties);
}

sub fetchInstanceByPath {
    my ($self, $store, $path, $properties) = @_;
    $store->fetchObjectByPath(TBM::Constants::CLASSNAME_DOCUMENT, $path, $properties);
}

sub getInstance {
    my ($store, $class, $id) = @_;
    $store->getObject(TBM::Constants::CLASSNAME_DOCUMENT, $id);
}

sub getInstanceByPath {
    my ($store, $class, $path) = @_;
    $store->getObjectByPath(TBM::Constants::CLASSNAME_DOCUMENT, $path);
}

package TBM::Factory::JSON;
our @ISA='TBM::Factory::Document';
#~ use parent 'TBM::Factory::Document';

use TBM::Constants;


package TBM::Factory::Folder;

use TBM::Constants;
use TBM::Folder;

sub createInstance {
    my ($store, $class, $id) = @_;
    $store->createObject(TBM::Constants::CLASSNAME_FOLDER, $id);
}

sub fetchRoot {
    my ($store, $properties) = @_;
    $store->fetchObjectByPath(TBM::Constants::CLASSNAME_FOLDER, "", $properties);
}

sub fetchInstance {
    my ($store, $id, $properties) = @_;
    $store->fetchObject(TBM::Constants::CLASSNAME_FOLDER, $id, $properties);
}

sub fetchInstanceByPath {
    my ($store, $path, $properties) = @_;
    $store->fetchObjectByPath(TBM::Constants::CLASSNAME_FOLDER, $path, $properties);
}

sub getInstance {
    my ($store, $class, $id) = @_;
    $store->getObject(TBM::Constants::CLASSNAME_FOLDER, $id);
}

sub getInstanceByPath {
    my ($store, $class, $path) = @_;
    $store->getObjectByPath(TBM::Constants::CLASSNAME_FOLDER, $path);
}

1;
