unshift @INC, ('.');
require 'AnagramUtils.pl';

&LoadAnagramCanons;
$count = 0;
while(<>) {
	next unless /\w+/;
	s/\W+//g;
	my $orig = $_;
	$_ = AnagramCanonize(uc $_);
	print "$orig: $Canons{$_}\n";
	print "\n" if 0==(++$count)%5;
}