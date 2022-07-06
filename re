#! /bin/perl

if (scalar(@ARGV) != 2) {
	print "usage: <string to test> <re pattern>\n";
	exit 1;
}

my $test = $ARGV[0];
my $patt = $ARGV[1];

if ($test =~ m"$patt") {
	print "match !\n";
} else {
	print "doesn't match.\n";
}

exit 0;
