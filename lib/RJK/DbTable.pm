package RJK::DbTable;

use strict;
use warnings;

use DBI;

my $dbh;

sub connect {
    my ($self, %opts) = @_;
    my $dsn = "dbi:mysql:$opts{db}:$opts{host}:$opts{port}";
    $dbh = DBI->connect($dsn, $opts{user}, $opts{pass}, {
        mysql_enable_utf8 => 1,
        AutoCommit => 0
    }) or die "Couldn't connect to database: " . DBI->errstr;

    if ($opts{eventHandlers}{onError}) {
        $dbh->{HandleError} = $opts{eventHandlers}{onError};
    }
}

sub disconnect {
    $dbh->disconnect if $dbh;
}

sub commit {
    $dbh->commit if $dbh;
}

sub new {
    my $self = bless {}, shift;
    my %opts = @_;

    $self->{$_} = $opts{$_} for qw(table cols pkCol bless eventHandlers);
    $self->{pkCol} //= "id";

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

    $self->{sth} = $dbh->prepare($stmt);
    $self->{sth}->execute(map { $where->{$_} } @cols);

    while (my $object = $self->{sth}->fetchrow_hashref) {
        bless $object, $self->{bless} if $self->{bless};
        $callback->($object);
    }
}

sub first {
    my ($self, $where) = @_;
    my $stmt = $self->{selectStatement};
    $stmt .= " WHERE ";
    $stmt .= join " AND ", map {
        "$_=" . ($where->{$_} =~ /^(?:\d+|\d*\.\d+)$/ ? $where->{$_} : "\"$where->{$_}\"")
    } keys %$where;
    my $object = $dbh->selectrow_hashref($stmt);
    bless $object, $self->{bless} if $self->{bless};
    return $object;
}

sub get {
    my ($self, $id) = @_;
    $self->{sth} = $dbh->prepare($self->{getStatement});
    $self->{sth}->execute($id);

    my $object = $self->{sth}->fetchrow_hashref;
    bless $object, $self->{bless} if $self->{bless};
    return $object;
}

sub insert {
    my ($self, $object) = @_;
    $self->getObject(\$object);

    $self->{eventHandlers}{preInsert}($object);

    $self->{sth} = $dbh->prepare($self->{insertStatement});
    $self->{sth}->execute(map { $object->{$_} } @{$self->{cols}});

    if ($DBI::VERSION ge 1.38) {
        my $pk = $dbh->last_insert_id(
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

    bless $object, $self->{bless} if $self->{bless};
    return $object;
}

sub update {
    my ($self, $object) = @_;
    $self->getObject(\$object);

    $self->{eventHandlers}{preUpdate}($object);

    $self->{sth} = $dbh->prepare($self->{updateStatement});
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

    $self->{sth} = $dbh->prepare($self->{deleteStatement});
    my $id = $self->getId($object);
    $self->{sth}->execute($id);

    $self->{eventHandlers}{postDelete}($object);
}

sub getObject {
    my ($self, $ref) = @_;
    if (ref $$ref eq 'ARRAY') {
        $$ref = $self->getObjectFromArray($$ref);
    }
}

sub getObjectFromArray {
    my ($self, $array) = @_;
    my $object = {};
    for (0 .. $#{$self->{cols}}) {
        $object->{$self->{cols}[$_]} = $array->[$_];
    }
    return $object;
}

sub sync {
    my ($self, $object) = @_;
    $self->getObject(\$object);

    my $id = $self->getId($object);
    my $objectInDb = $self->get($id);
    my $changes = [];
    if ($objectInDb) {
        my $message;
        foreach my $col (@{$self->{cols}}) {
            next if $col eq $self->{pkCol};
            if ($self->updateValue($col, $object->{$col}, $objectInDb->{$col}, $id, \$message)) {
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

sub updateValue {
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

1;
