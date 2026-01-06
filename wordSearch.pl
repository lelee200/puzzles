# input from <>
# 1. matrix of letters
# 2. blank line
# 3. list of words to find
# 4. EOF

#output to stdout
# word, row,col,orientation

#load and populate matrix
while (<>) {
    $_ = uc $_;
    s/[^A-Z]//g;
    last if /^$/;
    $row = [split //];
    if (@matrix && @{$matrix[0]} != @{$row}) {
        die "Inconsistent row lengths in matrix\n";
    }
    push @matrix, $row;
}

$MaxRow = @matrix;
$MaxCol = @{$matrix[0]};

#load word list
%FirstTwoMap = ();
while (<>) {
    chomp;
    $_ = uc $_;
    s/[^A-Z]//g;
    next unless length $_;
    my $ft = substr($_, 0, 2);
    push @{$FirstTwoMap{$ft}}, $_;
}

#build word search index
undef $PrevRow;
$rowIndex = 0;
undef %WordFound;

sub CheckForWords {
    my ($startRow, $startCol, $dir, $firstTwo) = @_;
    my @words = @{$FirstTwoMap{$firstTwo}};
    my $deltaCol = 0;
    my $deltaRow = 0;
    if ($dir =~ /L/) {
        $deltaCol = -1;
    } elsif ($dir =~ /R/) {
        $deltaCol = 1;
    }
    if ($dir =~ /U/) {
        $deltaRow = -1;
    } elsif ($dir =~ /D/) {
        $deltaRow = 1;
    }
    foreach my $word (@words) {
        my $len = length $word;
        next if $startCol + $deltaCol * ( $len ) < 0;
        next if $startCol + $deltaCol * ( $len ) >= $MaxCol;
        next if $startRow + $deltaRow * ( $len ) < 0;
        next if $startRow + $deltaRow * ( $len ) >= $MaxRow;
        my $r = $startRow + 2 * $deltaRow;
        my $c = $startCol + 2 * $deltaCol;
        my $match = 1;
        my @restOfWord = (split //, $word)[2..$len-1];
        foreach my $letter (@restOfWord) {
            if ($matrix[$r][$c] ne $letter) {
                $match = 0;
                last;
            }
            $r += $deltaRow;
            $c += $deltaCol;
        }
        if ($match) {
            $WordFound{$word} = [$startRow, $startCol, $dir];
        }
    }
}

foreach $curRow (@matrix) {
    my $prevCol;
    my $colIndex = 0;
    foreach $col (@$curRow) {
        if (defined $prevCol) {
            my $left = $col.$prevCol;
            my $right = $prevCol.$col;
            CheckForWords($rowIndex, $colIndex, "L", $left) if $FirstTwoMap{$left};
            CheckForWords($rowIndex, $colIndex - 1, "R", $right) if $FirstTwoMap{$right};
        }
        if (defined $PrevRow) {
            my $up = $col.$PrevRow->[$colIndex];
            my $down = $PrevRow->[$colIndex].$col;
            CheckForWords($rowIndex, $colIndex, "U", $up) if $FirstTwoMap{$up};
            CheckForWords($rowIndex - 1, $colIndex, "D", $down) if $FirstTwoMap{$down};
            if (defined $prevCol) {
                my $upLeft = $col.$PrevRow->[$colIndex - 1];
                my $downRight = $PrevRow->[$colIndex - 1].$col;
                CheckForWords($rowIndex, $colIndex, "UL", $upLeft) if $FirstTwoMap{$upLeft};
                CheckForWords($rowIndex - 1, $colIndex - 1, "DR", $downRight) if $FirstTwoMap{$downRight};
            }
            if ($colIndex + 1 < @{$PrevRow}) {
                my $upRight = $col.$PrevRow->[$colIndex + 1];
                my $downLeft = $PrevRow->[$colIndex + 1].$col;
                CheckForWords($rowIndex, $colIndex, "UR", $upRight) if $FirstTwoMap{$upRight};
                CheckForWords($rowIndex - 1, $colIndex + 1, "DL", $downLeft) if $FirstTwoMap{$downLeft};
            }
        }
        $prevCol = $col;
        $colIndex++;
    }
    $PrevRow = $curRow;
    $rowIndex++;
}

@UsedMatrix = ();

foreach my $word (sort keys %WordFound) {
    my ($r, $c, $dir) = @{$WordFound{$word}};
    print sprintf("%s,%d,%d,%s\n", $word, $r+1, $c+1, $dir);
    my $len = length $word;
    my @letters = split //, $word;
    for (my $i = 0; $i < $len; $i++)   {
        $UsedMatrix[$r][$c] = $letters[$i];
        if ($dir =~ /L/) {
            $c--;
        } elsif ($dir =~ /R/) {
            $c++;
        }
        if ($dir =~ /U/) {
            $r--;
        } elsif ($dir =~ /D/) {
            $r++;
        }
    }
}

print "\n";
foreach my $row (@UsedMatrix) {
    my $line = "";
    foreach my $col (@$row) {
        if (defined $col) {
            $line .= $col;
        } else {
            $line .= ".";
        }
    }
    print "$line\n";
}
