#!/usr/bin/perl

##
## Tests for Petal::Utils :default set
##

use blib;
use strict;
#use warnings;

use Test::More qw(no_plan);

use Carp;
use Petal;
use File::Spec;

use Petal::Utils qw( :default :hash Dump );

my $base_dir = File::Spec->catdir(qw( t data ));

# Petal's global settings
$Petal::DISK_CACHE   = 0;
$Petal::MEMORY_CACHE = 0;
$Petal::TAINT        = 1;
$Petal::BASE_DIR     = $base_dir;
$Petal::INPUT        = "XHTML";
$Petal::OUTPUT       = "XHTML";

# Assign data to be passed to Petal in a hashref
my $hash = {
	date   => 1,
	date1  => '2003-09-05',
	date2  => '2003/09/05',
	date3  => '20030905',
	first  => 0,
	second => 1,
	array_ref => [ 1..3 ],
	hash_ref => {
		key1 => 'value1',
		key2 => 'value2',
		key3 => 'value3',
	},
	first_name => "William",
	last_name => "McKee",
	email => 'william@knowmad.com',

#	arrayref => [ {foo => 'bar'}, {foo => 'James'} ],
#	petal => { version => $Petal::VERSION },
#	error_message => "Kilroy was Here",
#	boolean => '1',
#	pg_boolean => 't',
#	pg_boolean_false => 'f',
#	students => [ { student_id => '1',
#					first_name => 'William',
#					last_name => 'McKee',
#					email => 'william@knowmad.com',
#					},
#				  { student_id => '2',
#					  first_name => 'Elizabeth',
#					  last_name => 'McKee',
#					  email => 'elizabeth@knowmad.com',
#					},
#				],
#	html_string => '<h1 align="center">Header1 Centered</h1>',
};

# Create a Petal object
my $template = Petal->new('basic.html');

# Process the template using the data from '$hash'
my $out = $template->process($hash);

#diag( "\n---------\nOutput:\n$out\n----------\n" );

# Now test the output and look for strings defined above but modified
# according to the modifiers.

# Strings:
like($out, qr/lc: all_caps/, 'lc');
like($out, qr/uc: ALL_LOWER/, 'uc');
like($out, qr/uc_first: William mckee/, 'uc_first');

# Dates:
like($out, qr|date = \w+\s+\d+ \d+ (?:\d+\:?)+|, 'date');
like($out, qr|date1 = 09/05/2003|, 'us_date');
like($out, qr|date2 = 09/05/2003|, 'us_date');
like($out, qr|date3 = 09/05/2003|, 'us_date');
# DYNAMICALLY SETTING SEPARATOR IS NOT WORKING AT PRESENT
#like($out, qr|date4 = 09-05-2003|, 'us_date');

like($out, qr/first = 0/, 'first');
like($out, qr/second = 1/, 'second');

# Comparisons
like($out, qr/first or second = 1/, 'or');
like($out, qr/first and second = 0/, 'and');
like($out, qr/first eq second = 0/, 'equal');
like($out, qr/first_name like regex = 1/, 'like');

# Hash keys - NOT WORKING AT PRESENT
#like($out, qr/key1 = value1/, 'keys');
#like($out, qr/key2 = value1/, 'keys');

# Hash keys
like($out, qr/key1 => value1/, 'keys');
like($out, qr/key2 => value2/, 'keys');

# Sort
like($out, qr/sort:.+?1.+2.+3/, 'sort');

# Debugging
like($out, qr/dump first_name: \$VAR1/, 'dump');

