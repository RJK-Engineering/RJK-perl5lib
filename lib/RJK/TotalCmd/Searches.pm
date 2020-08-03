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

my $_matchNumericRule = {
    '=' => sub { $_[1] == $_[0] },
    '!=' => sub { $_[1] != $_[0] },
    '>' => sub { $_[1] > $_[0] },
    '<' => sub { $_[1] < $_[0] },
    '>=' => sub { $_[1] >= $_[0] },
    '<=' => sub { $_[1] <= $_[0] },
};

my $_matchStringRule = {
    '=' => sub { $_[1] =~ /^\Q$_[0]\E$/i },
    '!=' => sub { $_[1] !~ /^\Q$_[0]\E$/i },
    'contains' => sub { $_[1] =~ /\Q$_[0]\E/i },
    '!contains' => sub { $_[1] !~ /\Q$_[0]\E/i },
    'regex' => sub { $_[1] =~ /$_[0]/i },
    '!regex' => sub { $_[1] !~ /$_[0]/i },
    'cont.(case)' => sub { $_[1] =~ /\Q$_[0]\E/ },
    '!cont.(case)' => sub { $_[1] !~ /\Q$_[0]\E/ },
    '=(case)' => sub { $_[1] eq $_[0] },
    '!=(case)' => sub { $_[1] ne $_[0] },
    # these don't exist in totalcmd
    're.(case)' => sub { $_[1] =~ /$_[0]/ },
    '!re.(case)' => sub { $_[1] !~ /$_[0]/ },
};

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

    # flags
    my $flags = $search->{flags};
    if ($flags->{directory}) {
        return if ! $stat->{isDir};
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

        if ($prop eq "text") {
            return 0 if $rule->{value} ? !-T $path->{path} : -T $path->{path};
        } elsif ($prop eq "binary") {
            return 0 if $rule->{value} ? !-B $path->{path} : -B $path->{path};
        } elsif ($prop eq "parent") {
            return 0 if ! $path->{dir};
            my $matcher = $_matchStringRule->{$rule->{op}}
                or die "Unsupported operation: $rule->{op}";
            return 0 if ! $matcher->("$rule->{value}\\", $path->{dir});
        }
    }
    return 1;
}

sub _matchTcRule {
    my ($result, $rule, $search, $path, $stat) = @_;

    my $prop = $rule->{property};
    my $matchVal;
    my $numeric;

    if ($prop eq 'name') {
        $matchVal = $path->{basename};
    } elsif ($prop eq 'fullname') {
        $matchVal = $path->{name};
    } elsif ($prop eq 'ext') {
        $matchVal = $path->{extension};
    } elsif ($prop eq 'path') {
        $matchVal = $path->{path};
    } elsif ($prop eq 'size') {
        $matchVal = $stat->{size};
        $numeric = 1;
    } elsif ($prop eq 'directory') {
        $matchVal = $stat->{isDir} ? 1 : 0;
        $numeric = 1;
    } elsif ($prop eq 'creationdate') {
        $matchVal = _getDate($stat->{created});
    } elsif ($prop eq 'creationtime') {
        $matchVal = _getTime($stat->{created});
    } elsif ($prop eq 'writedate') {
        $matchVal = _getDate($stat->{modified});
    } elsif ($prop eq 'writetime') {
        $matchVal = _getTime($stat->{modified});
    } elsif ($prop eq 'accessdate') {
        $matchVal = _getDate($stat->{accessed});
    } elsif ($prop eq 'accesstime') {
        $matchVal = _getTime($stat->{accessed});
    } elsif ($prop eq 'read only') {
        $matchVal = $stat->{isReadable} && ! $stat->{isWritable} ? 1 : 0;
        $numeric = 1;
    } else {
        die "Unsupported property: $prop";
    }

    my $matcher;
    if ($numeric) {
        $matcher = $_matchNumericRule->{$rule->{op}}
            or die "Unsupported operation: $rule->{op}";
    } else {
        $matcher = $_matchStringRule->{$rule->{op}}
            or die "Unsupported operation: $rule->{op}";
    }
    return $matcher->($rule->{value}, $matchVal);
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
