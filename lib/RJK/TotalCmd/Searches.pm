=begin TML

---+ package !RJK::TotalCmd::Searches

=cut
###############################################################################

package RJK::TotalCmd::Searches;

use strict;
use warnings;

use RJK::Exceptions;
use RJK::IO::File;
use RJK::TotalCmd::Search;

###############################################################################
=pod

---+++ RJK::TotalCmd::Searches->match($search, $path, $stat) -> \%result
   * =$search= - =RJK::TotalCmd::Search= object.
   * =$path= - =RJK::File::Path= object.
   * =$stat= - =RJK::File::Stat= object.
   * =%result= - result hash.
      * =$result{matched}= true if matched, false otherwise.
      * =$result{captured}= reference to captured regex groups.

=cut
###############################################################################

sub match {
    my ($class, $search, $path, $stat) = @_;
    my $result = {};

    # name
    my $name = $path->{name};
    $name =~ s|.*[\\/]||;

    if ($search->{regex}) {
        return $result if $name !~ /$search->{regex}/i;
        $result->{captured} = [ $name =~ /$search->{regex}/i ];
    } elsif ($search->{SearchFor}) {
        return $result if $name !~ /\Q$search->{SearchFor}\E/i;
    } else {
        #~ return $result if $search->{searchRegex} &&
        #~     $name !~ /^(?:$search->{searchRegex})$/i;
        #~ return $result if $search->{searchNotRegex} &&
        #~     $name =~ /^(?:$search->{searchNotRegex})$/i;
    }

    # size
    if (defined $path->{size}) {
        return $result if $search->{size} && $path->{size} != $search->{size};
        return $result if $search->{minsize} && $path->{size} < $search->{minsize};
        return $result if $search->{maxsize} && $path->{size} > $search->{maxsize};
    }

    # date - TODO: creation/access date
    my $date = $path->{modified};
    if (defined $date) {
        return $result if $search->{mindate} && $date < $search->{mindate};
        return $result if $search->{maxdate} && $date > $search->{maxdate};
        my $not = NotOlderThanTime($search->{flags});
        return $result if $not && $date < $not;
    }

    foreach (@{$search->{rules}}) {
        next if _matchRule($result, $_, $search, $path, $stat);
        return $result;
    }

    # text
    if ($search->{SearchText} && $search->{SearchText} ne "") {
        my $file = new RJK::IO::File($path);

        my $fh = $file->open;

        my $re = $search->{textRegex} ?
            qr/$search->{SearchText}/ :
            qr/\Q$search->{SearchText}\E/;

        my $match;
        while (<$fh>) {
            next if $_ !~ $re;
            $match = 1;
            last;
        }
        close $fh;

        return $result unless $match;
    }

    $result->{matched} = 1;
    return $result;
}

sub _matchRule {
    my ($result, $rule, $search, $path, $stat) = @_;
    my $plugin = $rule->{plugin};

    if ($plugin eq "tc") {
        return 0 if ! _matchTcRule($result, $rule, $search, $path, $stat);
    }

    # special rules not available in totalcmd
    if ($plugin eq "perl") {
        my $prop = $rule->{property};
        my $val = $rule->{value};

        if ($prop eq "text") {
            return 0 if $val ? !-T $path->{path} : -T $path->{path};
        }
        if ($prop eq "binary") {
            return 0 if $val ? !-B $path->{path} : -B $path->{path};
        }
    }
    return 1;
}

sub _matchTcRule {
    my ($result, $rule, $search, $path, $stat) = @_;

    my $prop = $rule->{property};
    my $op = $rule->{op};
    my $rv = $rule->{value};
    my $pv;
    my $numeric;

    if ($prop eq 'name') {
        $pv = $path->{basename};
    } elsif ($prop eq 'fullname') {
        $pv = $path->{name};
    } elsif ($prop eq 'ext') {
        $pv = $path->{extension};
    } elsif ($prop eq 'path') {
        $pv = $path->{path};
    } elsif ($prop eq 'size') {
        $pv = $stat->{size};
        $numeric = 1;
    } elsif ($prop eq 'directory') {
        $pv = $stat->{isDir} ? 1 : 0;
        $numeric = 1;
    } elsif ($prop eq 'creationdate') {
        $pv = _getDate($stat->{created});
    } elsif ($prop eq 'creationtime') {
        $pv = _getTime($stat->{created});
    } elsif ($prop eq 'writedate') {
        $pv = _getDate($stat->{modified});
    } elsif ($prop eq 'writetime') {
        $pv = _getTime($stat->{modified});
    } elsif ($prop eq 'accessdate') {
        $pv = _getDate($stat->{accessed});
    } elsif ($prop eq 'accesstime') {
        $pv = _getTime($stat->{accessed});
    } elsif ($prop eq 'read only') {
        $pv = $stat->{isReadable} && ! $stat->{isWritable} ? 1 : 0;
        $numeric = 1;
    } else {
        die "Unsupported property: $prop";
    }

    if ($op eq "=") {
        return 0 if $numeric ? $pv != $rv : $pv !~ /^\Q$rv\E$/i;
    } elsif ($op eq "!=") {
        return 0 if $numeric ? $pv == $rv : $pv =~ /^\Q$rv\E$/i;
    } elsif ($op eq ">") {
        return 0 if $pv <= $rv;
    } elsif ($op eq "<") {
        return 0 if $pv >= $rv;
    } elsif ($op eq ">=") {
        return 0 if $pv < $rv;
    } elsif ($op eq "<=") {
        return 0 if $pv > $rv;
    } elsif ($op eq "contains") {
        return 0 if $pv !~ /\Q$rv\E/i;
    } elsif ($op eq "!contains") {
        return 0 if $pv =~ /\Q$rv\E/i;
    } elsif ($op eq "regex") {
        return 0 if $pv !~ /$rv/i;
    } elsif ($op eq "!regex") {
        return 0 if $pv =~ /$rv/i;
    } elsif ($op eq "cont.(case)") {
        return 0 if $pv !~ /\Q$rv\E/;
    } elsif ($op eq "!cont.(case)") {
        return 0 if $pv =~ /\Q$rv\E/;
    } elsif ($op eq "=(case)") {
        return 0 if $pv ne $rv;
    } elsif ($op eq "!=(case)") {
        return 0 if $pv eq $rv;
    # these don't exist in totalcmd
    } elsif ($op eq "re.(case)") {
        return 0 if $pv !~ /$rv/;
    } elsif ($op eq "!re.(case)") {
        return 0 if $pv =~ /$rv/;
    } else {
        die "Unsupported operation: $op";
    }

    return 1;
}

###############################################################################
=pod

---+++ !NotOlderThanTime($flags) -> $time
   * =$flags= - Search flag hash.
   * =$time= - Unix (epoch) time.

=cut
###############################################################################

sub NotOlderThanTime {
    die "FIXME";
    my $flags = shift;
    return unless $flags->{time};

    my $timeUnit = $flags->{timeUnit};
    if ($timeUnit < -1 || $timeUnit > 4) {
        throw RJK::Exception("Invalid time unit: $timeUnit");
    }

    my $unit = $RJK::TotalCmd::Search::timeUnits[ $timeUnit + 3 ];
    return DateTime->now->
        subtract($unit => $flags->{time})->epoch;
}

1;
