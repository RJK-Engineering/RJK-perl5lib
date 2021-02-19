package RJK::DbTable;

use strict;
use warnings;

use Exceptions;
use DbException;
use SqlException;

use DBI;
my $dbh;

sub connect {
    my ($self, %opts) = @_;
    my $dsn = "dbi:mysql:$opts{db}:$opts{host}:$opts{port}";
    my %attr = (
        mysql_enable_utf8 => 1,
        AutoCommit => 0,
        HandleError => $opts{eventHandlers}{onError} // sub {
            my ($error, $handler) = @_;
            if ($handler->isa('DBI::st')) {
                my $bound = $handler->{ParamValues} // {};
                throw SqlException(
                    error => $error,
                    dsn => $dsn,
                    user => $opts{user},
                    stmt => $handler->{Statement},
                    bound => map { $bound->{$_} } sort keys %$bound
                );
            }
            throw DbException(
                error => $error,
                dsn => $dsn,
                user => $opts{user},
            );
        }
    );
    $dbh = DBI->connect($dsn, $opts{user}, $opts{pass}, \%attr) or throw DbException(
        error => DBI->errstr,
        dsn => $dsn,
        user => $opts{user},
    );
}

sub dbh {
    $dbh;
}

sub disconnect {
    dbh()->disconnect if $dbh;
}

sub commit {
    dbh()->commit if $dbh;
}

sub new {
    my $self = bless {}, shift;
    my %opts = @_;

    $self->{$_} = $opts{$_} for qw(table cols pkCol bless eventHandlers cached static);
    $self->{pkCol} //= "id";
    $self->{static} //= {};

    $self->{eventHandlers}{$_} //= sub {} for qw(
        preInsert postInsert preUpdate postUpdate preDelete postDelete
        onIdentical onDifferent onMissing onChange
    );

    $self->{selectStatement} = "SELECT "
        . join(",", @{$self->{cols}})
        . " FROM $self->{table}";
    $self->{getStatement} = $self->{selectStatement} . " WHERE $self->{pkCol}=?";
    $self->{insertStatement} = "INSERT INTO $self->{table} "
        . "(" . join(",", @{$self->{cols}})
        . ") VALUES (?" . ",?" x (@{$self->{cols}} - 1) . ")";
    $self->{updateStatement} = "UPDATE $self->{table} SET "
        . join(",", map { "$_=?" } grep { $_ ne $self->{pkCol} } @{$self->{cols}})
        . " WHERE $self->{pkCol}=?";
    $self->{deleteStatement} = "DELETE FROM $self->{table}"
        . " WHERE $self->{pkCol}=?";

    return $self;
}

sub getId {
    my ($self, $object) = @_;
    return $object->{$self->{pkCol}};
}

sub select {
    my ($self, $where, $callback) = @_;
    my @cols = keys %$where;

    my $stmt = $self->{selectStatement};
    $stmt .= " WHERE ";
    $stmt .= join " AND ", map { "$_=?" } @cols;

    $self->{sth} = $self->_prepare($stmt);
    $self->{sth}->execute(map { $where->{$_} } @cols);

    while (my $object = $self->{sth}->fetchrow_hashref) {
        $self->_prepareObject($object);
        $callback->($object);
    }
}

sub first {
    my ($self, $where) = @_;
    my $stmt = $self->{selectStatement};
    $stmt .= " WHERE ";
    my @cols = keys %$where;
    $stmt .= join " AND ", map { "$_=?" } @cols;
    my $object = dbh()->selectrow_hashref($stmt, {}, map { $where->{$_} } @cols);
    return $self->_prepareObject($object);
}

sub get {
    my ($self, $id) = @_;
    $self->{sth} = $self->_prepare($self->{getStatement});
    $self->{sth}->execute($id);

    my $object = $self->{sth}->fetchrow_hashref;
    return $self->_prepareObject($object);
}

sub insert {
    my ($self, $object) = @_;
    $self->_getObject(\$object);
    $self->_prepareObject($object);

    $self->{eventHandlers}{preInsert}($object);

    $self->{sth} = $self->_prepare($self->{insertStatement});
    $self->{sth}->execute(map { $object->{$_} } @{$self->{cols}});

    if ($DBI::VERSION ge 1.38) {
        my $pk = dbh()->last_insert_id(
            $self->{catalog} || "",
            $self->{schema} || "",
            $self->{table} || "",
            $self->{pkCol} || "",
        );
        if ($pk) {
            $object->{$self->{pkCol}} = $pk;
        }
    }
    $self->{eventHandlers}{postInsert}($object);

    return $object;
}

sub update {
    my ($self, $object) = @_;
    $self->_getObject(\$object);

    $self->{eventHandlers}{preUpdate}($object);

    $self->{sth} = $self->_prepare($self->{updateStatement});
    $self->{sth}->execute(
        map { $object->{$_} }
            (grep { $_ ne $self->{pkCol} } @{$self->{cols}}),
            $self->{pkCol}
    );
    $self->{eventHandlers}{postUpdate}($object);
}

sub delete {
    my ($self, $object) = @_;

    $self->{eventHandlers}{preDelete}($object);

    $self->{sth} = $self->_prepare($self->{deleteStatement});
    my $id = $self->getId($object);
    $self->{sth}->execute($id);

    $self->{eventHandlers}{postDelete}($object);
}

sub sync {
    my ($self, $object) = @_;
    $self->_getObject(\$object);

    my $id = $self->getId($object);
    my $objectInDb = $self->get($id);
    my $changes = [];
    if ($objectInDb) {
        my $message;
        foreach my $col (@{$self->{cols}}) {
            next if $col eq $self->{pkCol};
            if ($self->_updateValue($col, $object->{$col}, $objectInDb->{$col}, $id, \$message)) {
                push @$changes, {
                    update => 1,
                    column => $col,
                    value => $object->{$col},
                    dbValue => $objectInDb->{$col},
                    message => $message,
                };
                $objectInDb->{$col} = $object->{$col};
            }
        }
        if (@$changes) {
            unless ($self->{eventHandlers}{onDifferent}($id, $object, $objectInDb, $changes)) {
                $self->update($objectInDb);
            }
        } else {
            $self->{eventHandlers}{onIdentical}($id, $object, $objectInDb, $changes);
        }
    } else {
        foreach my $col (@{$self->{cols}}) {
            if (defined $object->{$col}) {
                push @$changes, {
                    insert => 1,
                    column => $col,
                    value => $object->{$col},
                };
            }
        }
        unless ($self->{eventHandlers}{onMissing}($id, $object, $changes)) {
            $self->insert($object);
        }
    }

    if (@$changes) {
        $self->{eventHandlers}{onChange}($id, $object, $objectInDb, $changes);
    }

    return $changes;
}

sub _updateValue {
    my ($self, $column, $dataInValue, $dbValue, $id, $message) = @_;
    my $changed = 0;
    if (! defined $dataInValue) {
        if (defined $dbValue) {
            if ($dbValue eq '') {
                $$message = "Overwrite empty string value for $column with NULL";
                $changed = 1;
            } else {
                $$message = "Not overwriting $column = $dbValue with NULL";
            }
        }
    } elsif ($dataInValue eq '') {
        if (defined $dbValue) {
            if ($dbValue eq '') {
                $$message = "Empty string value for $column";
            } else {
                $$message = "Overwrite $column = $dbValue with empty string value";
                $changed = 1;
            }
        }
    } else {
        if (defined $dbValue) {
            if ($dbValue eq '') {
                $$message = "Overwrite empty string value for $column with $dataInValue";
                $changed = 1;
            } elsif ($dataInValue ne $dbValue) {
                $$message = "Overwrite $column = $dbValue with $dataInValue";
                $changed = 1;
            }
        } else {
            $$message = "Update $column = $dataInValue";
            $changed = 1;
        }
    }
    return $changed;
}

sub _getObject {
    my ($self, $ref) = @_;
    if (ref $$ref eq 'ARRAY') {
        $$ref = $self->_getObjectFromArray($$ref);
    }
}

sub _getObjectFromArray {
    my ($self, $array) = @_;
    my $object = {};
    for (0 .. $#{$self->{cols}}) {
        $object->{$self->{cols}[$_]} = $array->[$_];
    }
    return $object;
}

sub _prepareObject {
    my ($self, $object) = @_;
    bless $object//{}, $self->{bless} if $self->{bless};
    map { $object->{$_} = $self->{static}{$_} } keys %{$self->{static}};
    return $object;
}

sub _prepare {
    my ($self, $stmt) = @_;
    if ($self->{cached}) {
        dbh()->prepare_cached($stmt);
    } else {
        dbh()->prepare($stmt);
    }
}

1;
