package App::Calendar::CalendarApp;
$VERSION='0.01';

=head1 NAME

  CalendarApp.pm - HTML calendar application.

=head1 SYNOPSIS

    use CGI;
    use Date::Calc;
    use App::Calendar::MonthCalendar;

    my $monthparam = $q -> param('month');
    my $yearparam = $q -> param('year');
    my $buttonparam = $q -> param('calendar');

    my $domain = 'your.web.servers.domain';
    my $exp = '+15m';   # How long the browser should maintain
                        # the app's cookie.

    &App::Calendar::CalendarApp::App(month=> $month, 
                                     year => $year,
                                     button => $buttonparam);

=head1 DESCRIPTION

CalendarApp.pm uses CGI to format HTML calendars for viewing in
a web browser.  The calendar.cgi script shows an example usage
for calling from a web browser.  

=head1 VERSION AND LICENSING

Initial release, Version 0.01.

Refer to the file "Artistic" for licensing information.

Please send all comments and bug reports to the author,
rkiesling@mainmatter.com.

=cut

use CGI;
use Date::Calc;
use App::Calendar::MonthCalendar;

#
# Set the domain name of the Web server that calls CaledarApp;
#
my $domain = 'aardvark.mainmatter.com';

my $q = new CGI;

my $buttons = <<'end-of-form';
<form action="calendar.cgi">
  <input type="submit" name="button" value="Prev">
  <input type="submit" name="button" value="Next">
</form>
end-of-form

my ($tmpdate, $monthyear, $buf, $buttonval, $month, $year);

sub App {
    my (@args) = @_;
    for ($i = 0; $i < $#args; $i += 2)  {
	$q->param(-name => $args[$i],-value => $args[$i+1]);
    }

    if ($q -> param('button') ne '') {
	$buttonval = $q -> param('button');
	$monthyear = $q -> cookie(-name => 'calendar', -domain => $domain);
	if ($monthyear ne '') {
	    $month = substr $monthyear, 0, 2;
	    $year = substr $monthyear, 2, 4;
	} else {
	    $month = $q -> param('month');
	    $year = $q -> param('year');
	}
	if ($buttonval =~ /Next/) {
	    $month++;
	    if ($month > 12) {
		$month = 1;
		$year++;
	    }
	} elsif ($buttonval =~ /Prev/) {
	    $month--;
	    if ($month < 1) {
		$month = 12;
		$year--;
	    }
	}

	$buf =  &App::Calendar::MonthCalendar::MonthCalendar 
	    (-month => $month, -year => $year);
	my $month1 = sprintf "%02d", $month;
	my $year1 = sprintf "%04d", $year;
	$monthyear = "$month1$year1";
    } else {
	$buf =  &App::Calendar::MonthCalendar::MonthCalendar 
	    ( -month => $q -> param('month'),
	      -year => $q -> param('year'));
	$monthyear = $q -> param('month').$q -> param('year');
    }

    $tmpdate = &HTTPExp ($exp);
    $buf =~ s/Content-Type: text\/html//ms;
    $buf = "\n" . $buf;
    $buf = "Set-Cookie: calendar=$monthyear; expires=$tmpdate; path=/; domain=aardvark.mainmatter.com\n" . $buf;
    $buf = "Content-Type: text/html\n" . $buf;
    $buf =~ s/(\<body.*?\>)/$1\n$buttons/;
    print $buf;
}


my @weekdays = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
	      'Sep', 'Oct', 'Nov', 'Dec');

#
#  Return an absolute HTTP time for the cookie. This is from the 
#  CGI.pm POD documentation.
#
#  As an interval from the current time:
#             +30s                              30 seconds from now
#             +10m                              ten minutes from now
#             +1h                               one hour from now
#             -1d                               yesterday (i.e. "ASAP!")
#             now                               immediately
#             +3M                               in three months
#             +10y                              in ten years time
#
#  Or an absolute time and date:
#             Thursday, 25-Apr-1999 00:40:33 GMT 
#

sub HTTPExp {
    my ($lifetime) = @_;
    my ($interval, $sign, $unit, $expdate);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    my ($sec1, $min1, $hour1, $mday1, $year1);
    my ($dsec, $dmin, $dhour, $dmday, $dmon, $dyear);

    # Just return formatted time and date.
    if ($lifetime =~ /\w\w\w, \d\d-\w\w\w-\d\d\d\d \d\d:\d\d:\d\d \w\w\w/) {
	return $lifetime;
    } elsif ($lifetime =~ /now/) {
	$sec1 = sprintf "%02d", $sec;
	$min1 = sprintf "%02d", $min;
	$mday1 = sprintf "%02d", $mday;
	$hour1 = sprintf "%02d", $hour;
	$year1 = sprintf "%04d", $year + 1900;
	$expdate = @weekdays[$wday].', '.$mday1.'-'.
	    @months[$mon].'-'.$year1.' '.$hour1.':'.$min1.':'.$sec1.' '
		.'GMT';
    } elsif ($lifetime =~ /[+-]/) {
	($interval, $unit) = ($lifetime =~ /([\+\-]\d*)(\w)/i);
	if ($unit eq 's') {
	    ($dyear, $dmon, $dmday, $dhour, $dmin, $dsec) =
	      Date::Calc::Add_Delta_DHMS ($year+1900, $mon, $mday,
		  $hour, $min, $sec, 0, 0, 0, $interval);
	}
	if ($unit eq 'm') {
	    ($dyear, $dmon, $dmday, $dhour, $dmin, $dsec) =
	      Date::Calc::Add_Delta_DHMS ($year+1900, $mon, $mday,
		  $hour, $min, $sec, 0, 0, $interval, 0);
	}
	if ($unit eq 'h') {
	    ($dyear, $dmon, $dmday, $dhour, $dmin, $dsec) =
	      Date::Calc::Add_Delta_DHMS ($year+1900, $mon, $mday,
		  $hour, $min, $sec, 0, $interval, 0, 0);
	}
	if ($unit eq 'd') {
	    ($dyear, $dmon, $dmday, $dhour, $dmin, $dsec) =
	      Date::Calc::Add_Delta_DHMS ($year+1900, $mon, $mday,
		  $hour, $min, $sec, $interval, 0, 0, 0);
	}
	if ($unit eq 'M') {
	    ($dyear, $dmon, $dmday) =
	      Date::Calc::Add_Delta_YMD ($year+1900, $mon, $mday,
					 $interval, 0, 0, 0);
	    $dhour = $hour;
	    $dmin = $min;
	    $dsec = $sec;
	}
	if ($unit eq 'y') {
	    ($dyear, $dmon, $dmday) =
	      Date::Calc::Add_Delta_YMD ($year+1900, $mon, $mday,
					 $interval, 0, 0, 0);
	    $dhour = $hour;
	    $dmin = $min;
	    $dsec = $sec;
	}
	$sec1 = sprintf "%02d", $dsec;
	$min1 = sprintf "%02d", $dmin;
	$hour1 = sprintf "%02d", $dhour;
	$mday1 = sprintf "%02d", $dmday;
	$year1 = sprintf "%04d", $dyear;
	$expdate = @weekdays[$wday].', '.$mday1.'-'.
	    @months[$dmon].'-'.$year1.' '.$hour1.':'.$min1.':'.$sec1.' '
		.'GMT';
    }
    return $expdate;
}

1;

__END__
