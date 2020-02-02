package RJK::Util::IniCompareResult;

use strict;
use warnings;

use RJK::Util::PropertyListCompareResult;

use Class::AccessorMaker {
    sections => new RJK::Util::PropertyListCompareResult(),
    properties => {}, # section => RJK::Util::PropertyListCompareResult
};

1;
