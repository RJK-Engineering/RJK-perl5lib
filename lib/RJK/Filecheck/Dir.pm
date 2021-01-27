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

    if ($self->{tsv}) {
        $value = $self->{tsv}{$key};
    } else {
        $self->_loadTsv(sub {
            return if $_[0] ne $key;
            defined($value = $_[1]);
        });
    }
    return $value if not defined $value or $value ne "";

    my $json = $self->_loadJson;
    return $json->{$key} if $json;
}

sub setProperty {
    my ($self, $key, $value) = @_;
    my $props = $self->_loadTsv();

    if ($value eq "") {
        return if not defined $props->{$key};
        $self->_deleteJsonProp($key) if _isJsonPropValue($props->{$key});
        delete $props->{$key};
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

sub traverseProperties {
    my ($self, $callback) = @_;
    my $skipJson = 1;

    if (my $tsv = $self->{tsv}) {
        foreach (keys %{$self->{tsv}}) {
            if (_isJsonPropValue($tsv->{$_})) {
                $skipJson = 0;
            } elsif ($callback->($_, $tsv->{$_})) {
                $skipJson = 1;
                last;
            }
        }
    } else {
        $self->_loadTsv(sub {
            if (_isJsonPropValue($_[1])) {
                $skipJson = 0;
            } else {
                $callback->(@_) || return;
                $skipJson = 1;
            }
        });
    }
    return if $skipJson;

    my $json = $self->_loadJson;
    foreach (keys %$json) {
        last if $callback->($_, $json->{$_});
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
    my $break = ! defined $callback;
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

    if ($self->{fileTsv}) {
        $value = $self->{fileTsv}{$filename}{$key};
    } else {
        $self->_loadFileTsv(sub {
            return if $_[0] ne $filename;
            return if $_[1] ne $key;
            defined($value = $_[2]);
        });
    }
    return $value if not defined $value or $value ne "";

    my $json = $self->_loadFileJSON;
    return $json->{$filename}{$key} if $json;
}

sub setFileProperty {
    my ($self, $filename, $key, $value) = @_;
    my $props = $self->_loadFileTsv()->{$filename} //= {};

    if ($value eq "") {
        return if not defined $props->{$key};
        $self->_deleteFileJsonProp($filename, $key) if _isJsonPropValue($props->{$key});
        delete $props->{$key};
        delete $self->{fileTsv}{$filename} if ! keys %$props;
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

sub traverseFileProperties {
    my ($self, $callback) = @_;
    my $skipJson = 1;

    if (my $tsv = $self->{fileTsv}) {
        FILES: foreach my $filename (keys %$tsv) {
            foreach (keys %{$tsv->{$filename}}) {
                if (_isJsonPropValue($tsv->{$filename}{$_})) {
                    $skipJson = 0;
                } elsif ($callback->($filename, $_, $tsv->{$filename}{$_})) {
                    $skipJson = 1;
                    last FILES;
                }
            }
        }
    } else {
        $self->_loadFileTsv(sub {
            if (_isJsonPropValue($_[1])) {
                $skipJson = 0;
            } else {
                $callback->(@_) || return;
                $skipJson = 1;
            }
        });
    }
    return if $skipJson;

    my $json = $self->_loadFileJSON;
    FILES: foreach my $filename (keys %$json) {
        foreach (keys %{$json->{$filename}}) {
            last FILES if $callback->($filename, $_, $json->{$filename}{$_});
        }
    }
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
    my $break = ! defined $callback;
    try {
        my $filename;
        RJK::Util::TSV->read("$self->{path}/.files.tsv", sub {
            my $row = shift;
            if (! defined $row->[1]) {
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
