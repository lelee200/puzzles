#!/usr/bin/perl

# input is lines

while(<>) {
	my $line = uc $& if /\w+/;
	my @points = sort split '', $line;
	$line = join '', @points;
	$cnt = @points;
	for (my $i = 0; $i < @points - 1; $i++) {
		for(my $j=$i+1; $j < @points; $j++) {
			my $edge = $points[$i] . $points[$j];
			$Line{$edge} = $line;
			push @Edges, ($edge);
		}
	}
}
@Edges = sort @Edges;

$TriCount = 0;
for($i=0; $i< @Edges - 2; $i++) {
	for($j = $i + 1; $j < @Edges - 1; $j++) {
		for($k = $j + 1; $k < @Edges; $k++) {
			my @points = sort split '', "$Edges[$i]$Edges[$j]$Edges[$k]";
			next if $points[0] eq $points[2];
			next if $points[2] eq $points[4];
			next if $points[0] ne $points[1];
			next if $points[2] ne $points[3];
			next if $points[4] ne $points[5];
			next if $Line{$Edges[$i]} eq $Line{$Edges[$j]};
			next if $Line{$Edges[$j]} eq $Line{$Edges[$k]};
			next if $Line{$Edges[$i]} eq $Line{$Edges[$k]};
			print $points[0].$points[2].$points[4]."\n";
			$TriCount++;
		}
	}
}
print "$TriCount\n";