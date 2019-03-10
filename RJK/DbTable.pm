package RJK::DbTable;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{$_} = $opts{$_} for qw(dbh table cols pkCol eventHandlers);
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

sub invalidate {
    my ($self) = @_;
    if ($self->{sth}) {
        $self->{sth}->finish();
    }
}

sub getId {
    my ($self, $object) = @_;
    return $object->{$self->{pkCol}};
}

sub get {
    my ($self, $id) = @_;
    $self->{sth} = $self->{dbh}->prepare($self->{getStatement});
    $self->{sth}->execute($id);
    return $self->{sth}->fetchrow_hashref;
}

sub insert {
    my ($self, $object) = @_;
    $self->getObject(\$object);

    $self->{eventHandlers}{preInsert}($object);

    $self->{sth} = $self->{dbh}->prepare($self->{insertStatement});
    $self->{sth}->execute(map { $object->{$_} } @{$self->{cols}});

    if ($DBI::VERSION ge 1.38) {
        my $pk = $self->{dbh}->last_insert_id(
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
    $self->getObject(\$object);

    $self->{eventHandlers}{preUpdate}($object);

    $self->{sth} = $self->{dbh}->prepare($self->{updateStatement});
    $self->{sth}->execute(
        map { $object->{$_} }
            (grep { $_ ne $self->{pkCol} } @{$self->{cols}}),
            $self->{pkCol}
    );
    $self->{eventHandlers}{postUpdate}($object);
}

sub delete {
    my ($self, $id) = @_;

    $self->{eventHandlers}{preDelete}($object);

    $self->{sth} = $self->{dbh}->prepare($self->{deleteStatement});
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
        foreach (@{$self->{cols}}) {
            next if $_ eq $self->{pkCol};
            if ($self->updateValue($_, $object->{$_}, $objectInDb->{$_}, $id, \$message)) {
                push @$changes, {
                    update => 1,
                    column => $_,
                    value => $object->{$_},
                    dbValue => $objectInDb->{$_},
                    message => $message,
                };
                $objectInDb->{$_} = $object->{$_};
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
        foreach (@{$self->{cols}}) {
            if (defined $object->{$_}) {
                push @$changes, {
                    insert => 1,
                    column => $_,
                    value => $object->{$_},
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
