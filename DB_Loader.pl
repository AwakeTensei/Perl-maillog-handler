use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $db_name = 'Test_Address';
my $db_host = 'localhost';
my $db_user = 'root';
my $db_pass = 'xtrfkby';

#Функции для генерации уникальных ID для строк, где ID отсутствует----------------
sub generate_uniq_id {
	my $timestamp_id = time();
	my $random_str = join '', ('a'..'z', 'A'..'Z', 0..9)[map rand(62), 1..12];
	return "${timestamp_id}_${random_str}";
}

#Функции для получения id из строки лога---------
sub get_id_value {
	my ($other_info) = @_;
	my ($id) = $other_info =~ /id=([^@\s]+)/;
	return $id || generate_uniq_id();
}

my $message_counter = 0;
my $log_counter = 0;

#Подключение к базе данных
my $dbh = DBI->connect("DBI:mysql: database = $db_name; host = $db_host", $db_user, $db_pass)
	or die "Connection refused, invalid password or login data: $DBI::errstr";

#Чтение файла почтового лога
my $log_file = 'maillog';
	open(my $fh, '<', $log_file) or die "Logfile is missing or currupted";

#Цикл для разделения строчек лога по параметрам
while (my $line = <$fh>) {
	chomp $line;
	my ($date, $time, $int_id, $flag, $address, $other_info) = split (/\s+/, $line, 6);

#Если сообщение передано успешно, данные строки заносятся в таблицу "message"
	if ($flag eq '<=') {
		my $message_insert = $dbh->prepare(qq{
			INSERT INTO message (created, id, int_id, str, status)
			VALUES (?,?,?,?,?)
		});

		$message_insert->execute("$date $time", get_id_value($other_info), $int_id, $other_info, 1);
		$message_counter++;

#Во всех иных случаях данные строки заносятся в таблицу "log"
	} else {
		unless ($address =~ /\@/) {
			$address = 'null';
		}

		my $log_insert = $dbh->prepare(qq{
			INSERT INTO log (created, int_id, str, address)
			VALUES (?,?,?,?)
		});

		$log_insert->execute("$date $time", $int_id, $other_info, $address);
		$log_counter++;
	}
}

print "Content-Type: text/html\n\n";
print "<html><body>Data uploaded to the DB<br></body></html>";
print "<html><body>Strings loaded into message: $message_counter<br></body></html>";
print "<html><body>Strings loaded into log: $log_counter</body></html>";
close($fh);

$dbh->disconnect();
#Запись счетчиков загрузок в таблицы message и log в текстовый файл
open($fh, '>', 'counters.txt') or die "Не удалось открыть файл: $!";
print $fh "message_counter\n$log_counter";
close($fh);
