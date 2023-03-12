unshift @INC, ('.');
require 'AnagramUtils.pl';

&LoadAnagramCanons;
$count = 0;
while(<>) {
	$_ = AnagramCanonize(uc $&) if /\w+/;
	print "$Canons{$_}\n";
	print "\n" if 0==(++$count)%5;
}