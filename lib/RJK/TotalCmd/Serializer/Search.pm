package RJK::TotalCmd::Serializer::Search;

use strict;
use warnings;

sub searchFlags {
    my ($class, $search) = @_;
    return sprintf "%u|%u%u%u%u%u%u%u%u%u%u%u%u|%s|%s|%s|%s|%s|%s|%s|%s%s%s%s%s|%u%u%u%u|%s\n",
        map { $search->{flags}{$_}//"" } @RJK::TotalCmd::Search::flagNames;
}

sub pluginArguments {
    my ($class, $search) = @_;
    join " $search->{rulesCombineOp} ",
        map {
            my $prop = "$_->{plugin}.$_->{property}";
            $prop = "\"$prop\"" if $prop =~ /\s/;
            my $value = $_->{value};
            my $value = $_->{value} =~ s/"/\\"/gr;
            $value = "\"$value\"" if $value eq "" || $value =~ /["\s]/;
            "$prop $_->{op} $value";
        } @{$search->{rules}};
}

1;
