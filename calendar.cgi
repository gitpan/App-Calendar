#!/usr/bin/perl

# Parameters - 
# None - Display calendar for current month and year.
# month, year - Display calendar for the month and year.
# Next, Prev - Display calendar for the next or previous 
# month or year, after retrieving cookie data with the month 
# and year of the currently displayed calendar.

use CGI;
use App::Calendar::CalendarApp;

my $q = new CGI;
my $monthparam = $q -> param('month');
my $yearparam = $q -> param('year');
my $buttonparam = $q -> param('calendar');

$month = (localtime)[4] + 1;
$year = (localtime)[5] + 1900;

if ($buttonparam ne '') {
    &App::Calendar::CalendarApp::App(button=>$buttonparam,
				     month=>$month,
				     year=>$year);
} else {
    if ($monthparam ne '' and $yearparam ne '') {
	$month = 0;
	foreach my $mon (@months) {
	    last if ($monthparam eq $mon);
	    $month++;
	}
	$year = $yearparam;
    }
    &App::Calendar::CalendarApp::App(month=>$month, year =>$year);
}



