use ExtUtils::MakeMaker;
WriteMakefile( ABSTRACT => "Month calendar CGI script.",
               AUTHOR => 'rkiesling@mainmatter.com' ,
	       NAME => 'App::Calendar::MonthCalendar',
	       VERSION_FROM => 'MonthCalendar.pm' );
WriteMakefile( ABSTRACT => "Calendar Application CGI script.",
               AUTHOR => 'rkiesling@mainmatter.com' ,
	       NAME => 'App::Calendar::CalendarApp',
	       PREREQ_PM => {'Date::Calc' => 0},
	       VERSION_FROM => 'CalendarApp.pm' );
