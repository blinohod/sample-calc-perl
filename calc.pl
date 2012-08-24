#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

print "Enter expression\n";
print "> ";
my $input = <STDIN>;
chomp $input;

#$input = "  2 * -4 -(5/2) /( 7 * (1 +1)) - 1";

my $to_parse = $input;

my $nested = 0;

my $tokens = get_tokens($input);
unless ("$nested" eq '0') {
	die "Problems with nested brackets!\n";
}

my $res = build_tree( @{$tokens} );
print "= $res\n";

# Check with perl
#eval_native();

# ---------------------------------------
sub get_tokens {

	$nested++;

	my @chain = ();

	my $wait_op = 0;

	while ( $to_parse !~ /^\s*$/ ) {

		$to_parse =~ s/^\s+//;

		# Waiting for operator or closing bracket
		if ($wait_op) {

			# Return on closing bracket
			if ( $to_parse =~ /^\)(.*)/ ) {
				$to_parse = $1;
				last;
			} elsif ( $to_parse =~ /^([\/\*\+\-])(.*)/ ) {
				# operator
				push @chain, $1;
				$to_parse = $2;
			} else {
				die "Error!\n";
			}

		} else {

			#  Waiting for value or opening bracket

			# Open bracket - go deeper
			if ( $to_parse =~ /^\((.*)$/ ) {
				$to_parse = $1;
				push @chain, get_tokens();
			} elsif ( $to_parse =~ /^(\-?\d+(\.\d+)?)(.*)/ ) {
				# Value
				push @chain, $1;
				$to_parse = $3;
			} else {
				die "Error!\n";
			}

		}

		$wait_op = 1 - $wait_op;

	} ## end while ( $to_parse !~ /^\s*$/)

	$nested--;

	return \@chain;

} ## end sub get_tokens

sub build_tree {

	my @tokens = @_;

	# Calculate nested trees first

	my @ret = ();

	foreach (@tokens) {
		if ( ref($_) ) {
			push @ret, build_tree( @{$_} );
		} else {
			push @ret, $_;
		}
	}

	@tokens = @ret;

	# If single value - return
	if ( scalar(@tokens) == 1 ) { return $tokens[0]; }

	my @res = ();
	my ( $lv, $op, $rv ) = ( undef, undef, undef );

	while ( ( $lv, $op, $rv ) = ( shift @tokens, shift @tokens, shift @tokens ) ) {

		unless ($lv) { last; }
		unless ($op) { push @res, $lv; last; }

		if ( $op eq '*' ) {
			unshift @tokens, ( $lv * $rv );
		} elsif ( $op eq '/' ) {
			unless ($rv) { die "Division by zero!\n"; }
			unshift @tokens, ( $lv / $rv );
		} else {
			push @res, ( $lv, $op );
			unshift @tokens, $rv;
		}

	}

	@tokens = @res;
	@res    = ();

	while ( ( $lv, $op, $rv ) = ( shift @tokens, shift @tokens, shift @tokens ) ) {

		unless ($lv) { last; }
		unless ($op) { push @res, $lv; last; }

		if ( $op eq '+' ) {
			unshift @tokens, ( $lv + $rv );
		} elsif ( $op eq '-' ) {
			unshift @tokens, ( $lv - $rv );
		}
	}

	return $res[0];

} ## end sub build_tree

# ---------------------------------------
sub eval_native {

	my $res  = undef;
	my $expr = '$res = ' . $input;

	eval $expr;
	if ($@) {
		print "ERROR! $@\n";
	} else {
		print "RESULT: $res\n";
	}

}

1;
