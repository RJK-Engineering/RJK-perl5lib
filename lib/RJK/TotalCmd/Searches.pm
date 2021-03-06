###############################################################################
=begin TML

---+ package !RJK::TotalCmd::Searches

=cut
###############################################################################

package RJK::TotalCmd::Searches;

use strict;
use warnings;

use Exceptions;
use RJK::Path;
use RJK::IO::File;
use RJK::TotalCmd::Search;

my $_pluginMatchers = {
    tc => \&_matchTcRule,
    perl => \&_matchPerlRule,
};

my $_numericRuleMatchers = {
    '='  => sub { $_[1] == $_[0] },
    '!=' => sub { $_[1] != $_[0] },
    '>=' => sub { $_[1] >= $_[0] },
    '<=' => sub { $_[1] <= $_[0] },
    '>'  => sub { $_[1] > $_[0] },
    '<'  => sub { $_[1] < $_[0] },
};

my $_stringRuleMatchers = {
    '='            => sub { $_[1] =~ /^\Q$_[0]\E$/i },
    '!='           => sub { $_[1] !~ /^\Q$_[0]\E$/i },
    'contains'     => sub { $_[1] =~  /\Q$_[0]\E/i },
    '!contains'    => sub { $_[1] !~  /\Q$_[0]\E/i },
    'cont.(case)'  => sub { $_[1] =~  /\Q$_[0]\E/ },
    '!cont.(case)' => sub { $_[1] !~  /\Q$_[0]\E/ },
    'regex'        => sub { $_[1] =~    /$_[0]/i },
    '!regex'       => sub { $_[1] !~    /$_[0]/i },
    '=(case)'      => sub { $_[1] eq     $_[0] },
    '!=(case)'     => sub { $_[1] ne     $_[0] },
    # these don't exist in totalcmd
    're.(case)'    => sub { $_[1] =~    /$_[0]/ },
    '!re.(case)'   => sub { $_[1] !~    /$_[0]/ },
};

###############################################################################
=pod

---++ Class methods

---+++ match($search, $path, $stat) -> $result
   * =$search= - =RJK::TotalCmd::Search= object.
   * =$path= - =RJK::Path= object.
   * =$stat= - =RJK::Stat= object.
   * =$result= - true if matched, array ref containing matched groups if regex search.

=cut
###############################################################################

sub match {
    my ($class, $search, $path, $stat) = @_;
    my $result = 1;
    my $flags = $search->{flags};

    # name
    my $name = $path->{name};
    if ($search->{for}) {
        if ($flags->{regex}) {
            return if $name !~ /$search->{for}/i;
            $result = [ $name =~ /$search->{for}/i ];
        } else {
            return if $name !~ /\Q$search->{for}\E/i;
        }
    } else {
        #~ return if $search->{searchRegex} &&
        #~     $name !~ /^(?:$search->{searchRegex})$/i;
        #~ return if $search->{searchNotRegex} &&
        #~     $name =~ /^(?:$search->{searchNotRegex})$/i;
    }

    # flags
    if ($flags->{directory} == 0) {
        return if $stat->isDir;
    } elsif ($flags->{directory} == 1) {
        return if ! $stat->isDir;
    }

    # size
    if ($stat->isFile) {
        return if $search->{size} && $stat->size != $search->{size};
        return if $search->{minsize} && $stat->size < $search->{minsize};
        return if $search->{maxsize} && $stat->size > $search->{maxsize};
    }

    # date
    my $date = $stat->modified;
    if (defined $date) {
        return if $search->{mindate} && $date < $search->{mindate};
        return if $search->{maxdate} && $date > $search->{maxdate};
        my $not = NotOlderThanTime($flags);
        return if $not && $date < $not;
    }

    foreach (@{$search->{rules}}) {
        next if _matchRule($_, $path, $stat);
        return;
    }

    # text
    if ($search->{text} && $search->{text} ne "") {
        my $file = new RJK::IO::File($path);

        my $fh = $file->open;

        my $re = $search->{textRegex} ?
            qr/$search->{text}/ :
            qr/\Q$search->{text}\E/;

        my $match;
        while (<$fh>) {
            next if $_ !~ $re;
            $match = 1;
            last;
        }
        close $fh;

        return unless $match;
    }

    return $result;
}

sub _matchRule {
    my ($rule, $path, $stat) = @_;
    my $matcher = $_pluginMatchers->{$rule->{plugin}}
        or die "Unsupported plugin: $rule->{plugin}";
    return $matcher->($rule, $path, $stat);
}

# rules not available in totalcmd
sub _matchPerlRule {
    my ($rule, $path, $stat) = @_;
    my $prop = $rule->{property};

    if ($prop eq "text") {
        return 0 if $rule->{value} ? !-T $path->{path} : -T $path->{path};
    } elsif ($prop eq "binary") {
        return 0 if $rule->{value} ? !-B $path->{path} : -B $path->{path};
    } elsif ($prop eq "parent") {
        my $parent = $path->parent;
        return 0 if ! $parent;
        my $matcher = $_stringRuleMatchers->{$rule->{op}}
            or die "Unsupported operation: $rule->{op}";
        return 0 if ! $matcher->("$rule->{value}\\", $parent);
    }
    return 1;
}

sub _matchTcRule {
    my ($rule, $path, $stat) = @_;

    my $prop = $rule->{property};
    my $matchVal;
    my $numeric;

    if ($prop eq 'name') {
        $matchVal = $path->basename;
    } elsif ($prop eq 'fullname') {
        $matchVal = $path->{name};
    } elsif ($prop eq 'ext') {
        $matchVal = $path->extension;
    } elsif ($prop eq 'path') {
        $matchVal = $path->{path};
    } elsif ($prop eq 'size') {
        $matchVal = $stat->size;
        $numeric = 1;
    } elsif ($prop eq 'directory') {
        $matchVal = $stat->isDir ? 1 : 0;
        $numeric = 1;
    } elsif ($prop eq 'creationdate') {
        $matchVal = _getDate($stat->created);
    } elsif ($prop eq 'creationtime') {
        $matchVal = _getTime($stat->created);
    } elsif ($prop eq 'writedate') {
        $matchVal = _getDate($stat->modified);
    } elsif ($prop eq 'writetime') {
        $matchVal = _getTime($stat->modified);
    } elsif ($prop eq 'accessdate') {
        $matchVal = _getDate($stat->accessed);
    } elsif ($prop eq 'accesstime') {
        $matchVal = _getTime($stat->accessed);
    } elsif ($prop eq 'read only') {
        $matchVal = $stat->isReadable && ! $stat->isWritable ? 1 : 0;
        $numeric = 1;
    } else {
        die "Unsupported property: $prop";
    }

    my $matcher;
    if ($numeric) {
        $matcher = $_numericRuleMatchers->{$rule->{op}}
            or die "Unsupported operation: $rule->{op}";
    } else {
        $matcher = $_stringRuleMatchers->{$rule->{op}}
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
    return;
    die "FIXME";
    my $flags = shift;
    return unless $flags->{time};

    my $timeUnit = $flags->{timeUnit};
    if ($timeUnit < -1 || $timeUnit > 4) {
        throw Exception("Invalid time unit: $timeUnit");
    }

    my $unit = $RJK::TotalCmd::Search::timeUnits[ $timeUnit + 3 ];
    return DateTime->now->
        subtract($unit => $flags->{time})->epoch;
}

1;
