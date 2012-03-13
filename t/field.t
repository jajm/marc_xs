#!/usr/bin/perl

use ExtUtils::testlib;
use Modern::Perl;
use Data::Dumper;
use Test::More;

BEGIN {
	use_ok "MARC::XS";
}

my $tests_done = 1;

my @codes = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z);
my @subfields;
foreach my $code (@codes) {
	push @subfields, $code => "Subfield $code";
}

my $field = MARC::XS::Field->new('200', '1', '2', @subfields);
my $controlfield = MARC::XS::Field->new('009', "DATA");
is(ref($field), 'MARC::XS::Field', 'Field is a MARC::XS::Field');
is(ref($controlfield), 'MARC::XS::Field', 'ControlField is a MARC::XS::Field');
$tests_done += 2;

is($field->tag, '200', 'Field tag is 200');
ok(!$field->is_control_field, 'Field is not a control field');
is($controlfield->tag, '009', 'ControlField tag to 009');
ok($controlfield->is_control_field, 'ControlField is a control field');
$tests_done += 4;

my @field_subf = $field->subfields;
my $all_ok = 1;
foreach my $s (@field_subf) {
	my $code = $s->code;
	my $val = $s->val;
	if($val ne "Subfield $code") {
		$all_ok = 0;
	}
}
is($all_ok, 1, 'All inserted subfields have the good value');
$tests_done++;

foreach my $s (@field_subf) {
	my $val = $s->val;
	$val =~ s/Subfield/Transformed/;
	$s->val($val);
}
@field_subf = $field->subfields;
$all_ok = 1;
foreach my $s (@field_subf) {
	my $code = $s->code;
	my $val = $s->val;
	if($val ne "Transformed $code") {
		$all_ok = 0;
		last;
	}
}
is($all_ok, 1, 'All subfield values have been correctly modified');
$tests_done++;

$all_ok = 1;
foreach my $code (@codes) {
	my @s = $field->subfield($code);
	if(@s != 1) {
		$all_ok = 0;
		say "!= 1";
		last;
	}
	if($s[0]->val ne "Transformed $code") {
		$all_ok = 0;
		say "ne transformed $code";
		last;
	}
	my $s = $field->subfield($code);
	if($s->val ne "Transformed $code") {
		say "scalar ne transforme $code";
		$all_ok = 0;
		last;
	}
}
is($all_ok, 1, 'All subfield values have been correctly retrieved by code');
$tests_done++;

foreach my $s (@field_subf) {
	$s->code('x');
}

@field_subf = $field->subfields;
$all_ok = 1;
foreach my $s (@field_subf) {
	my $code = $s->code;
	if($code ne 'x') {
		$all_ok = 0;
	}
}
is($all_ok, 1, 'All subfield codes have been correctly modified');
$tests_done++;

$all_ok = 1;
foreach my $code (@codes) {
	my @s = $field->subfield($code);
	if($code eq 'x' and @s != @codes) {
		$all_ok = 0;
		last;
	}
	if($code ne 'x' and @s != 0) {
		$all_ok = 0;
		last;
	}
}
is($all_ok, 1, "All 'x' subfields have been retrieved");
$tests_done++;

is($controlfield->data, "DATA", "Retrieving ControlField data");
is($controlfield->data("data"), "data", "Setting ControlField data");
$tests_done += 2;

$field->add_subfields('a', 'abc', 'b', 'bca', 'c', 'cab');
is($field->subfield('a')->val, 'abc');
is($field->subfield('b')->val, 'bca');
is($field->subfield('c')->val, 'cab');
$tests_done += 3;

done_testing($tests_done);
