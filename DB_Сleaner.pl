use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBFunctions;

my $cgi = CGI->new;
my $button_name = $cgi->param('delete_button');

my $dbh = DBFunctions::connect_to_database();

if ($button_name eq 'delete_message_rows') {
    DBFunctions::delete_message_rows($dbh);
} elsif ($button_name eq 'delete_log_rows') {
    DBFunctions::delete_log_rows($dbh);
}

$dbh->disconnect();