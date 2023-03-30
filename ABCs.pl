#!/usr/bin/perl
use File::Spec::Functions 'catfile';

foreach ('A'..'Z') {
    $Letters{$_} = 1;
}

while (<>) {
    next unless /\w/;
    s/[^\w:]+//g;
    $_ = uc $_;
    if (/:/) {
        my @l1 = split //, $`;
        my @l2 = split //, $';
        for (my $iter = 0; $iter < @l1; $iter++) {
            delete $Letters{"$l2[$iter]"} if '_' eq $l1[$iter];
        }
    } else {
        my $expr = $_;
        $expr =~ s/_/./g;
        $Candidates{$_} = [$expr];
    }
}

$LettersExpr = '['.(join '', sort keys %Letters).']';
print "$LettersExpr\n";
foreach $item (values %Candidates) {
    $item->[0] =~ s/\./$LettersExpr/g;
    $item->[0] = '\A'.$item->[0].'\Z';
}

$wlPath = $ENV{WORDLIST_PATH};
$wlPath = '.' unless $wlPath =~ /\w/;
$fname = "english3.txt";
$fqName = catfile($wlPath, $fname);
open INFILE, "$fqName" or die "Could not load Anagrams list: $fqName\n";
while(<INFILE>) {
    s/\W+//g;
    my $word = uc $_;
    foreach $list (values %Candidates) {
        my $expr = $list->[0];
        push @$list, ($word) if $word =~ /$expr/;
    }
}

foreach (keys %Candidates) {
    $list = $Candidates{$_};
    print "$_: ".join '|', @{$list}[1..$#$list];
    print "\n";
}