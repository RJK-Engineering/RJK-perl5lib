package RJK::Filecheck::Dir;

use strict;
use warnings;

use RJK::Util::JSON;
use RJK::Util::TSV;
use Try::Tiny;

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift;
    return $self;
}

################################################################################
# Directory Properties
################################################################################

sub hasProperty {
    my ($self, $key, $value) = @_;
    $value = undef if _isJsonPropValue($value);
    my $hasProperty;

    if ($self->{tsv}) {
        $hasProperty = defined $self->{tsv}{$key} &&
            (not defined $value or $value eq $self->{tsv}{$key});
    } else {
        $self->_loadTsv(sub {
            $hasProperty = $_[0] eq $key && (not defined $value or $value eq $_[1]);
        });
    }
    return $hasProperty;
}

sub getProperty {
    my ($self, $key) = @_;
    my $value;
    $self->traverseProperties(sub {
        return if $_[0] ne $key;
        $value = $_[1];
        return 1;
    });
    return $value;
}

sub setProperty {
    my ($self, $key, $value) = @_;
    my $props = $self->_loadTsv();

    if ($value eq "") {
        return if not defined $props->{$key};
        $self->_deleteJsonProp($key) if _isJsonPropValue($props->{$key});
        delete $props->{$key};
        $self->{tsvIsDirty} = 1;
    } elsif ($value =~ /\v/) {
        $props->{$key} = "";
        $self->{tsvIsDirty} = 1;
        my $json = $self->_loadJson;
        $json->{$key} = $value;
        $self->{jsonIsDirty} = 1;
    } else {
        $self->_deleteJsonProp($key) if _isJsonPropValue($props->{$key});
        $props->{$key} = $value;
        $self->{tsvIsDirty} = 1;
    }
}

sub _deleteJsonProp {
    my ($self, $key) = @_;
    my $json = $self->_loadJson;
    $self->{jsonIsDirty} //= defined delete $json->{$key};
}

sub _isJsonPropValue {
    defined $_[0] && $_[0] eq ""
}

sub getProperties {
    my ($self) = @_;
    my $props;
    $self->traverseProperties(sub {
        $props->{$_[1]} = $_[2];
        return 0;
    });
    return $props;
}

sub traverseProperties {
    my ($self, $callback) = @_;
    if (my $tsv = $self->{tsv}) {
        foreach (keys %{$self->{tsv}}) {
            my $value = $tsv->{$_};
            $value = $self->_loadJson->{$_} if _isJsonPropValue($value);
            return if $callback->($_, $value);
        }
    } else {
        $self->_loadTsv(sub {
            $_[1] = $self->_loadJson->{$_[0]} if _isJsonPropValue($_[1]);
            $callback->(@_);
        });
    }
}

sub saveProperties {
    my ($self) = @_;
    $self->saveDirProperties();
    $self->saveFileProperties();
}

sub saveDirProperties {
    my ($self) = @_;
    if ($self->{tsvIsDirty}) {
        my @rows;
        foreach (sort {
            $self->{tsv}{$a} eq "" ? (
                $self->{tsv}{$b} eq "" ? $a cmp $b : 1
            ) : $self->{tsv}{$b} eq "" ? -1 : $a cmp $b
        } keys %{$self->{tsv}}) {
            push @rows, [ $_, $self->{tsv}{$_}, $self->{tsv}{$_} eq "" ? "." : () ];
        }
        RJK::Util::TSV->write("$self->{path}/.dir.tsv", \@rows);
    }
    if ($self->{jsonIsDirty}) {
        RJK::Util::JSON->write("$self->{path}/.dir.json", $self->{json});
    }
}

sub _loadTsv {
    my ($self, $callback) = @_;
    return $self->{tsv} if $self->{tsv};
    my $break = not defined $callback;
    try {
        RJK::Util::TSV->read("$self->{path}/.dir.tsv", sub {
            my $row = shift;
            my $v = $row->[1] // "";
            $break = $callback->($row->[0], $v) if ! $break;
            $self->{tsv}{$row->[0]} = $v;
            return 0;
        });
    } catch {};
    return $self->{tsv} //= {};
}

sub _loadJson {
    my ($self) = @_;
    return $self->{json} if $self->{json};
    try {
        $self->{json} = RJK::Util::JSON->read("$self->{path}/.dir.json");
    } catch {};
    return $self->{json} //= {};
}

################################################################################
# File Properties
################################################################################

sub getFileProperty {
    my ($self, $filename, $key) = @_;
    my $value;
    $self->traverseFileProperties(sub {
        return if $_[0] ne $filename || $_[1] ne $key;
        $value = $_[2];
        return 1;
    });
    return $value;
}

sub setFileProperty {
    my ($self, $filename, $key, $value) = @_;
    my $props = $self->_loadFileTsv()->{$filename} //= {};

    if ($value eq "") {
        return if not defined $props->{$key};
        $self->_deleteFileJsonProp($filename, $key) if _isJsonPropValue($props->{$key});
        delete $props->{$key};
        delete $self->{fileTsv}{$filename} if ! keys %$props;
        $self->{fileTsvIsDirty} = 1;
    } elsif ($value =~ /\v/) {
        $props->{$key} = "";
        $self->{fileTsvIsDirty} = 1;
        my $json = $self->_loadFileJSON;
        $json->{$filename}{$key} = $value;
        $self->{fileJsonIsDirty} = 1;
    } else {
        $self->_deleteFileJsonProp($filename, $key) if _isJsonPropValue($props->{$key});
        $props->{$key} = $value;
        $self->{fileTsvIsDirty} = 1;
    }
}

sub _deleteFileJsonProp {
    my ($self, $filename, $key) = @_;
    my $json = $self->_loadFileJSON;
    return if not defined delete $json->{$filename}{$key};
    $self->{fileJsonIsDirty} = 1;
    delete $json->{$filename} if ! keys %{$json->{$filename}};
}

sub getFileProperties {
    my ($self, $filename) = @_;
    my $props;
    my $hit;
    $self->traverseFileProperties(sub {
        return $hit if $_[0] ne $filename;
        $hit = 1;
        $props->{$_[1]} = $_[2];
        return 0;
    });
    return $props;
}

sub setFileProperties {
    my ($self, $filename, $props) = @_;
    $self->setFileProperty($filename, $_, $props->{$_}) for keys %$props;
}

sub traverseFileProperties {
    my ($self, $callback) = @_;

    if (my $tsv = $self->{fileTsv}) {
        foreach my $filename (keys %$tsv) {
            foreach (keys %{$tsv->{$filename}}) {
                my $value = $tsv->{$filename}{$_};
                $value = $self->_getJsonFilePropValue($filename, $_) if _isJsonPropValue($value);
                return if $callback->($filename, $_, $value);
            }
        }
    } else {
        $self->_loadFileTsv(sub {
            $_[2] = $self->_getJsonFilePropValue(@_) if _isJsonPropValue($_[2]);
            $callback->(@_);
        });
    }
}

sub _getJsonFilePropValue {
    my ($self, $filename, $key) = @_;
    my $f = $self->_loadFileJSON->{$filename};
    return $f->{$key} if $f;
}

sub saveFileProperties {
    my ($self) = @_;
    if ($self->{fileTsvIsDirty}) {
        my @rows;
        my $tsv = $self->{fileTsv};
        foreach my $filename (sort keys %$tsv) {
            push @rows, [ $filename ];
            foreach (sort {
                $tsv->{$filename}{$a} eq "" ? (
                    $tsv->{$filename}{$b} eq "" ? $a cmp $b : 1
                ) : $tsv->{$filename}{$b} eq "" ? -1 : $a cmp $b
            } keys %{$tsv->{$filename}}) {
                push @rows, [ $_, $tsv->{$filename}{$_}, $tsv->{$filename}{$_} eq "" ? "." : () ];
            }
        }
        RJK::Util::TSV->write("$self->{path}/.files.tsv", \@rows);
    }
    if ($self->{fileJsonIsDirty}) {
        RJK::Util::JSON->write("$self->{path}/.files.json", $self->{fileJson});
    }
}

sub _loadFileTsv {
    my ($self, $callback) = @_;
    return $self->{fileTsv} if $self->{fileTsv};
    my $break = not defined $callback;
    try {
        my $filename;
        RJK::Util::TSV->read("$self->{path}/.files.tsv", sub {
            my $row = shift;
            if (not defined $row->[1]) {
                $filename = $row->[0];
                return;
            }
            my $v = $row->[1] // "";
            $break = $callback->($filename, $row->[0], $v) if ! $break;
            $self->{fileTsv}{$filename}{$row->[0]} = $v;
            return 0;
        });
    } catch {};
    return $self->{fileTsv} //= {};
}

sub _loadFileJSON {
    my ($self) = @_;
    return $self->{fileJson} if $self->{fileJson};
    try {
        $self->{fileJson} = RJK::Util::JSON->read("$self->{path}/.files.json");
    } catch {};
    return $self->{fileJson} //= {};
}

1;
