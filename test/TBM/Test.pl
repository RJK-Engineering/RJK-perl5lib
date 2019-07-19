use strict;
use warnings;

use JSON;

use TBM::Store::FileSystem;
use TBM::Factory;

use Data::Dump;

my $json = JSON->new->allow_nonref->convert_blessed->canonical->pretty;
my $store = new TBM::Store::FileSystem(root => "C:\\temp");

my $file = "index.json";
my $doc = TBM::Factory::Document::fetchInstanceByPath($store, $file);

if ($doc) {
    dd $doc;
    my $text = join "", $doc->getTextContent();
    my $data = $json->decode($text);
    dd $data;
} else {
    $doc = TBM::Factory::Document::createInstance($store);
    $doc->setName($file);
    my $data = {};
    $doc->setTextContent($json->encode($data));
    #~ $doc->save();
    my $root = TBM::Factory::Folder::fetchRoot($store);
    $root->file($doc);
}
