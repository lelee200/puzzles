unshift @INC, ('.');
require 'AnagramUtils.pl';

&LoadAnagramCanons;

while(<>) {
	next unless /\w/;
	my $word = uc $& if /\w+/;
	my $canon = AnagramCanonize ($word);
	my $limit = - 1 + length $canon;
	foreach(FetchCanonSubsets($canon,$limit)) {
		my ($subset,$letter) = split /\|/;
		print "$letter - $Canons{$subset}\n";
	}
	print "\n";
}