package RJK::TotalCmd::DirMenuItems;

use RJK::TotalCmd::Item::DirMenuItem;

sub fromPathList {
    my ($self, $dirs) = @_;
    my $tree = $self->createTree($dirs);
    my $items = $self->createItems($tree);
}

sub createTree {
    my ($self, $dirs) = @_;
    my $tree = {};
    my $i = 1;
    foreach (@$dirs) {
        s/\\$//;
        addDir($i, $tree, split /\\/);
    }
    return $tree;
}

sub addDir {
    my ($i, $tree, @dir) = @_;
    if (@dir == 1) {
        $tree->{$dir[0]} = $i++;
    } else {
        my $dir = shift @dir;
        my $subtree = $tree->{$dir} //= {"$dir\\", $i++};
        addDir($i, $subtree, @dir);
    }
}

sub createItems {
    my ($self, $tree) = @_;
    my $items = [];
    $self->createSubMenu($items, $tree);
    return $items;
}

sub createSubMenu {
    my ($self, $items, $item, $path) = @_;
    while (my ($name, $item) = each %$item) {
        if (ref $item) {
            my $menuName = $name =~ s/^(\W+)/$1&/r;
            push @$items, new RJK::TotalCmd::Item::DirMenuItem(menu => "-$menuName");
            $self->createSubMenu($items, $item, sprintf("%s%s\\", $path//"", $name));
            push @$items, new RJK::TotalCmd::Item::DirMenuItem(menu => "--");
        } else {
            my $menuName = $name =~ s/^(\W+)/$1&/r;
            $name = "" if $path eq $name;
            push @$items, new RJK::TotalCmd::Item::DirMenuItem(menu => $menuName, cmd => "cd $path$name");
        }
    }
}

1;
