package TBM::Tables;

use strict;
use warnings;

use RJK::DbTable;

my $classes = {
    'TBM::Object' => {
        cols => [qw'id date_created date_last_update'],
        readOnly => [qw'id date_created date_last_update'],
    },
    'TBM::Path' => {
        table => 'path',
        cols => [qw'head_id head_class tail_id tail_class filename'],
    },
    'TBM::Dir' => {
        table => 'directory',
        cols => ['path'],
    },
    'TBM::File' => {
        table => 'file',
        cols => [qw'name size created modified crc'],
    },
    'TBM::Volume' => {
        table => 'volume',
        cols => [qw'label cluster_size size_gb size_formatted free_space drive type'],
    },
};

my $tables;
my $objectCols = $classes->{'TBM::Object'}{cols};

foreach my $className (keys %$classes) {
    my $class = $classes->{$className};
    next if ! $class->{table};

    $tables->{$className} = new RJK::DbTable(
        table => $class->{table},
        cols => [@$objectCols, @{$class->{cols}}],
        bless => $className,
        static => { class => $className },
        cached => 1
    );
};

package main;

sub table {
    my ($class) = @_;
    return $tables->{$class};
}

1;
