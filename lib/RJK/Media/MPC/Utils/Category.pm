package RJK::Media::MPC::Utils::Category;
use parent 'RJK::Media::MPC::Util';

sub switch {
    my ($self, $file) = @_;

    my $categories = $self->opts->{categories};
    my $currCat = $self->settings->get($file, "category");

    if (defined $currCat) {
        my $newCat;
        for (my $i=0; $i<@$categories; $i++) {
            if ($categories->[$i] eq $currCat) {
                $newCat = $categories->[$i+1];
                last;
            }
        }
        if (defined $newCat) {
            $currCat = $newCat;
        } elsif ($currCat =~ /^\d+$/) {
            $currCat++;
        } else {
            $currCat = @$categories;
        }
    } else {
        $currCat = $categories->[0];
    }

    $self->settings->set($file, "category", $currCat);
    print "Category: $currCat\n";
}

1;
