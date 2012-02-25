#!/usr/bin/perl

use ExtUtils::testlib;
use Modern::Perl;
use Test::More tests => 10;

BEGIN {
    use_ok('MARC::XS');
}

my $subf = new MARC::XS::Subfield('a', "123");
is(ref($subf), "MARC::XS::Subfield", "new MARC::XS::Subfield object");
is($subf->code, 'a', "Retrieve subfield code");
is($subf->val, "123", "Retrieve subfield value");
is($subf->code('b'), 'b', "Set subfield code");
is($subf->val("456"), "456", "Set subfield value");
is($subf->code, 'b', "Retrieve subfield code (again)");
is($subf->val, "456", "Retrieve subfield value (again)");

is(new MARC::XS::Subfield('é', "123"), undef, "wrong subfield code");
is(new MARC::XS::Subfield('a'), undef, "no subfield value");
