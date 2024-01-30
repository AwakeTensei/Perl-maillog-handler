use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use POSIX qw(locale_h);
use DBI;

my $db_name = 'Test_Address';
my $db_host = 'localhost';
my $db_user = 'root';
my $db_pass = 'xtrfkby';

#Подключение к базе данных
my $dbh = DBI->connect("DBI:mysql:database = $db_name; host = $db_host", $db_user, $db_pass)
	or die "Connection refused, invalid password or login data: $DBI::errstr";
my $cgi=CGI->new;

#Проверка поисковой формы, если параметры отсутствуют, то поиск не происходит и страница остается стартовой
if ($cgi->param('address');
	my $address = $cgi->param('address');
	my $request = "SELECT log.created, log.str, message.created, message.str
		       FROM log
		       JOIN message ON log.int_id = message.int_id
		       WHERE log.address = ?
		       ORDER BY log.created, log.int_id
		       LIMIT 100";

	my $sth = $dbh->prepare($request);
	$sth->execute($address);

#Вывод результатов, найденных в БД и проверка количества строк
	print $cgi->header;
	my $row_counter = $sth->rows;
	print "<html><body><table>";

	while (my $row = $sth->fetchrow_arrayref) {
		print "<tr>
		       <td>$row->[0]</td>
		       <td>$row->[1]</td>
		       </tr>";
	}

	if ($row_counter >= 100) {
		print "More than 100 strings were found, only 100 strings will be shown";
	}
	
	print "</table></body></html>";

#Вывод количества данных из скрипта посредством считывания txt файла--------------
	open (my $fh, '<', 'counters.txt') or die "File deleted or corrupted: $!";
		my $message_counter = <$fh>;
		my $log_counter = <$fh>;
	close($fh);

	chomp($message_counter);
	chomp($log_counter);

	print "Strings loaded into message table:$message_conter<br>";
	print "Strings loaded into log table:$log_counter<br>";

	$sth-> finish;
}

else {

#Верстка поисковой страницы----------------------------------
	print $cgi->header;
	print <<HTML;
	<html>
	<head>
		<meta charset = "windows-1251">
		<title>Postlog searching</title>
	</head>
	<body>
		<h1>Load log data into database:</h1>
		<form action = "DB_Loader.pl" method = "GET">
		  <input type = "submit" value = "LoadData">
		</form>
		<h1>Search by address:</h1>
		<form action = "DB_Searcher.pl" method = "GET">
		<laber for = "address">Write address here:</label>
		<input type = "text" 
		       name = "address" 
		       id = "address" 
		       placeholder = "email"
		       pattern = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" required>
		<input type = "submit"
		       value = "Search">
		</form>
		<h1>Clear db tables:</h1>
		<form action = "DB_Cleaner.pl" method = "POST">
			<input type = "submit" name = "delete_button" value = "delete_message_rows">
			<input type = "submit" name = "delete_button" value = "delete_log_rows">
		</form>
	</body>
	</html>
	HTML
}

$dbh->disconnect();
	