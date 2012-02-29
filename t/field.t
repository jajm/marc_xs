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
is(ref($field), 'MARC::XS::Field', 'Field is a MARC::XS::Field');
$tests_done++;

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
	}
}
is($all_ok, 1, 'All subfield values have been correctly modified');
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

$field->print;

done_testing($tests_done);
