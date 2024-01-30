use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $db_name = 'Test_Address';
my $db_host = 'localhost';
my $db_user = 'root';
my $db_pass = 'xtrfkby';

#Подключение к базе данных-------------------------------------------------------------------
my $dbh = DBI->connect("DBI:mysql: database = $db_name; host = $db_host", $db_user, $db_pass)
	or die "Connection refused, invalid password or login data: $DBI::errstr";

#Функция для очистки таблицы message-------
sub delete_message_rows {
	my $sql = "DELETE FROM message";
	my $sth = $dbh->prepare($sql);
	return $sth->execute();
}

#Функция для очистки таблицы log-------
sub delete_log_rows {
	my $sql = "DELETE FROM log";
	my $sth = $dbh->prepare($sql);
	return $sth->execute();	
}

$dbh->disconnect();
