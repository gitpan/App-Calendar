package App::Calendar::MonthCalendar;
$VERSION='0.01';

use CGI;

my (@mon) = (0,
   31, 29, 31, 30,
   31, 30, 31, 31,
   30, 31, 30, 31);

my (@months) = ("", "January", "February", "March", "April", "May",
		 "June", "July", "August", "September", "October",
		 "November", "December");
my (@abbrevdays) =  ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
my (@fulldays) = ("Sunday", "Monday", "Tuesday", "Wednesday",
		   "Thursday", "Friday", "Saturday");

# Returns the HTML calendar as text scalar.
sub MonthCalendar {
    my (@args) = @_;
    my (%argh, $startday,$totaldays,$posixdate,$monthname,$i,$j);
    my $q = new CGI;
    my $buf = '';

    # Unflatten the arg hash.
    for ($i = 0; $i < $#args; $i += 2) {
	$argh{$args[$i]} = $args[$i+1];
    }
    my $month = $argh{-month};
    my $year = $argh{-year};

    $monthname = $months[$month];
    $startday = &first_day_of_month ($year, $month);
    $totaldays = @mon[$month];
    if ( $month == 2 ) {
	if ( ( $year % 4 ) == 0 ) {
	    $totaldays = 29;
	} else {
	    $totaldays = 28;
	}
    }
    $buf .= $q -> header;
    $buf .= $q -> start_html("$monthname $year")."\n";
    $buf .= "<body bgcolor=\"#FFFFFF\" TEXT=\"#000000\">\n";
    $buf .= qq|<center><h3>$monthname $year</h3></center>\n|;
    $buf .= qq|<table align="center" cols="7" border="2" rules="all">\n|;
    $buf .= qq|<colgroup>\n|;
    for ($i = 0; $i < 7; $i++) {
	$buf .= qq|<col width="90">\n|;
    }
    $buf .= qq|<tr>\n|;
    for ($i = 0; $i < 7; $i++) {
	$buf .= qq|<td><center>\n|;
	$buf .= $fulldays[$i]."\n";
	$buf .= qq|</center></td>\n|;
    }
    $buf .= qq|</tr>\n|;
    $day = 1;
    for ($i = 0; $i < 7; $i++) {
	$buf .= qq|<td align="right">\n|;
	if ($i >= ($startday-1)) {
	    $buf .= qq|<h4>$day</h4><br><br><br>\n|;
	    $day++;
	} else {
	    $buf .= qq|<br>\n|;
	}
	$buf .= qq|</td>\n|;
    }
    $buf .= qq|</tr>\n|;
    for ($j = 0; $j < 5; $j++ ) {
	$buf .= qq|<tr>\n|;
	for ($i = 0; $i < 7; $i++) {
	    $buf .= qq|<td align="right">\n|;
	    if ($day <= $totaldays) {
		$buf .= qq|<h4>$day</h4><br><br><br>|;
		$day++;
	    } else {
		$buf .= qq|<h4>&nbsp;</h4><br><br><br>\n|;
	    }
	    $buf .= qq|</td>\n|;
	}
	$buf .= qq|</tr>\n|;
    }
    $buf .= qq|</colgroup>\n</table>\n|;
    $buf .= $q -> end_html;
    return $buf;
}

# adapted from xcalendar.c
# returns day of week of Jan1 of given year, 1-7
sub first_day_of_year {
    my ($y) = @_;
    my $d;
    $d = 4 + $y + ($y + 3)/4;
    if ( $y > 1800 ) {
	$d -= ( $y - 1701 ) / 100;
	$d += ( $y - 1601 ) / 400;
    }
    if ( $y > 1752 ) {
	$d += 3;
    }
    return($d%7);
}


sub first_day_of_month{
    my ($y, $m) = @_;
    my $d;
    my $i;
    my $x;

    $mon[2] = 29;
    $mon[9] = 30;

    $d = &first_day_of_year($y);
    $x = ((&first_day_of_year( $y + 1 )  + 7 - $d ) % 7 );

    if ( $x == 1 ) { $mon[2] = 28 }
    elsif ( $x == 2 ) {  }
    else { $mon[9] = 19 }
    for ( $i = 1; $i < $m; $i = $i + 1 )
    {
	$d += $mon[$i];
    }

    $d = $d % 7;
    if ( $d > 0 ) {
    }
    else {
	$d = 7;
    }
    $d = $d + 1 - 7;
    if ( $d > 0 ) {
	return($d);
    }
    else
    {
	return (7 + $d);
    }
}

1;

__END__
