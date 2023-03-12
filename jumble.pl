unshift @INC, ('.');
require 'AnagramUtils.pl';

&LoadAnagramCanons;
$Solveable = 1;
while(<>) {
	chomp;
	$Numbers = $& if s/\d(.*\d)?//;
	$Numbers =~ s/\D+/ /;
	$Numbers =~ s/^\s+|\s+$//g; 
	s/\W+//g;
	if (/\w/) {
		my $canons = $Canons{AnagramCanonize($_)};
		push @Positions, $Numbers;
		if ($canons) {
			push @Data, ($canons);
		} else {
			push @Data, ($_);
			print "No Canons for $_\n";
			$Solveable = 0;
		}
	}
}

unless ($Solveable) {
	print "Not Solveable. Available Canons listed below:\n";
	foreach (@Data) {
		print "$_\n";
	}
}

push @Raw, (join '|', @Data);
while (@Raw) {
	my $tmpl = shift @Raw;
	if ($tmpl =~ s/\w+,[\w,]+/<>/) {
		foreach (split /,/, $&) {
			my $crude = $tmpl;
			$crude =~ s/<>/$_/;
			push @Raw, ($crude);
		}		
	} else {
		push @Candidates, ($tmpl);
	}
}
foreach (@Candidates) {
	my $mixture = '';
	@words = split /\|/;
	for ($index = 0; $index < @words; $index++) {
		@letters = split //, $words[$index];
		foreach (split /\D+/, $Positions[$index]) {
			$mixture .= $letters[$_ - 1]; 
		}
	}
	@vals = FetchMultiwordAnagrams(AnagramCanonize($mixture), $Numbers);
	if (0 < @vals) {
		print "$_\n";
		foreach (@vals) {
			print "\t$_\n";
		}
	}
}