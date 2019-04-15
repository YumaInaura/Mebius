
use strict;
use Mebius::Export;
use Mebius::MIME;
use Mebius::Time;
package Mebius::Email;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub send_email_to_master{

my $self = shift;
my $subject = shift;
my $message = shift;
send_email("To-master","",$subject,$message);

}

#-----------------------------------------------------------
# メールアドレスの形式チェック
#-----------------------------------------------------------
sub format_error{

my $self = shift;
my $email = shift;
my($error_flag);

	# 書式チェック
	if($email eq "" || $email =~ /^(\x81\x40|\s)+$/) { $error_flag = qq(メールアドレスが入力されていません。); }
	elsif(length($email) > 256) { $error_flag = qq(メールアドレスの文字列が長すぎます。); }
	elsif($email =~ /example\@ne.jp/){ $error_flag = qq(サンプル用のメールアドレス \( ).e($email).qq( \) は使えません。); }
	elsif($email =~ /(\s|　|\x81\x40)/) { $error_flag = qq(メールアドレス \( ).e($email).qq( \) に半角スペース、全角スペースが紛れ込んでいます。); }
	elsif($email =~ /,/) { $error_flag = qq(メールアドレス \( ).e($email).qq( \) に カンマ ( , ) が紛れ込んでいます。ドット ( . ) ではありませんか？); }
	elsif($email =~ /([^\w\-\.\@\+]+)/) { $error_flag = qq(メールアドレス \( ).e($email).qq( \) に使えない文字が ).e($1).qq(含まれています。); }
	elsif($email !~ /^([\w\.\-\+]+)\@([\w\.\-\+]+)\.([a-zA-Z]{2,6})$/) { $error_flag = qq(メールアドレス \( ).e($email).qq( \) の書き方	が間違っています。); }

$error_flag;

}


#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub send{
my $self = shift;
send_email(@_);
}

#-------------------------------------------------
#  メール送信 
#	注… Cookieセット処理よりも「後」で実行すると、エラーを起こす場合あり ( 処理前に他の print があってはいけない? )
#-------------------------------------------------
sub send_email{

# 局所化
my($basic_init) = Mebius::basic_init();
my($type,$address,$subject,$tbody,$from_adddress) = @_;
my($email,$subject2,$body,$from,%address,$mail_handler,$use);
my($server_domain) = Mebius::server_domain();
my($main_server_domain) = Mebius::main_server_domain();
	if(ref $type eq "HASH"){ $use = $type; } else { $use = {}; }

	if($use->{'source'} eq "utf8" || $type =~ /UTF8/){
		shift_jis($subject,$tbody);
	}

# メールアドレスをエンコード
my($address_enc) = Mebius::Encode(undef,$address);

	# 宛先が定義されていない場合
	if($type =~ /To-master-mobile/){ $address = $basic_init->{'admin_email_mobile'}; }
	elsif($type =~ /To-master/ || $use->{'ToMaster'}){ $address = $basic_init->{'admin_email'}; }

	# 文字コード
	if($use->{'FromEncoding'}){
		Mebius::Encoding::from_to($use->{'FromEncoding'},"sjis",$subject,$tbody);
	}

	# アドレスが指定されていない場合
	if($address eq ""){ return(); }

	# 件名が定義されていない場合
	if($subject eq ""){ $subject = "メビウスリングより"; }

# E-Mail書式チェック
my($format_error_flag) = mail_format(undef,$address);
if($format_error_flag){ return($format_error_flag); }

# メールアドレス単体ファイルから、送信可否をチェックする場合
(%address) = address_file("Get-hash Renew Send-mail",$address);
	if($address{'deny_flag'} && $type !~ /Not-deny-send|Allow-send-all|To-master/ && !$use->{'ToMaster'}){ return($address{'deny_flag'}); }

# 時刻取得（メール用）
my($date_mail) = get_date_for_email();

# 設定、取り込み
my $sendmail = '/usr/sbin/sendmail';
MIME::mimew_init();

$email = "apache\@$main_server_domain";

	# 本文に拒否用のURLを追加
	# $type =~ /Edit-url-plus/ && 
	if($address{'char'}){

		$tbody .= qq(\n\n──────────────────────────────\n\n);


			#if($address{'certified_flag'}){
			$tbody .= qq(こちらからメール送信の一括禁止や、配信許可時間の変更ができます。);
					# 本文に各種情報を追加
					if($address{'allow_hour'}){
						$tbody .= qq( \( 現在の許可時間： $address{'allow_hour_start'}時00分 - $address{'allow_hour_end'}時59分 \) );
					}
			$tbody .= qq(\n);
			$tbody .= edit_address_url(__PACKAGE__,$address,$address{'char'});

	}

	# ●本文に詳細なアクセスデータを追加 ( ループしない場合のみ )
	if($type =~ /To-master|View-access-data/){

		# 局所化
		my($gethost,$encid);

		my($cookie_decoded) = Mebius::Decode(undef,$ENV{'HTTP_COOKIE'});

			# ホスト名関係
			if($type !~ /BlockRoopingGetHost/){
				($encid) = main::id();
				($gethost) = Mebius::get_host_state();
			}


		$tbody .= qq(\n\n----------------------------------------------------------------------\n\n);
		$tbody .= qq(筆名： $main::cnam\n);

			# ID
			if($encid){
				$tbody .= qq(ID: ★$encid\n\n);
			}

			# 管理番号
			if($main::cnumber){
				$tbody .= qq(管理番号: $main::cnumber \n);
				$tbody .= qq(　 ${main::jak_url}index.cgi?mode=cdl&file=$main::cnumber&filetype=number\n\n);
			}

			# アカウント
			if($main::myaccount{'file'}){
				$tbody .= qq(アカウント： ${main::auth_url}$main::myaccount{'file'}/ \n);
					if($type =~ /To-master/){ $tbody .= qq(　 https://mb2.jp/jak/index.cgi?mode=cdl&file=$main::myaccount{'file'}&filetype=account\n\n); }
			}

		$tbody .= qq(IPアドレス： $main::addr \n);
			if($type =~ /To-master/){ $tbody .= qq(　 https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::addr) . qq(&filetype=addr \n\n); }

		# ホスト名取得
		# ループが起こりやすいので注意！
		if($gethost){

					if($gethost){
						$tbody .= qq(ホスト名： $gethost \n);
							if($type =~ /To-master/){ $tbody .= qq(　 https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$gethost) . qq(&filetype=host \n\n); }
					}

					#if($gethost->{'isp'}){
					#	$tbody .= qq(ISP名： $gethost->{'isp'} \n);
					#		if($type =~ /To-master/){ $tbody .= qq(　 ${main::jak_url}index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$gethost->{'isp'}) . qq(&filetype=isp \n\n); }
					#}

		}

		$tbody .= qq(\nUA：\n$main::agent \n);
			if($type =~ /To-master/){ $tbody .= qq(　 https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::agent) . qq(&filetype=agent \n\n); }

		if($main::realagent ne $main::agent){
			$tbody .= qq(\n実UA：\n$main::realagent \n);
				if($type =~ /To-master/){ $tbody .= qq(　 https://mb2.jp/jak/index.cgi?mode=cdl&file=) . Mebius::Encode(undef,$main::realagent) . qq(&filetype=agent \n\n); }
		}

		$tbody .= qq(\nCookie：\n$cookie_decoded \n);
		$tbody .= qq(\nCookie-encoded：\n$main::cookie \n);
			
		my($gethostbyaddr) = Mebius::GetHostByAddr();
		$tbody .=qq(\nGetHostByAddr : $gethostbyaddr\n);

		my($gethostbyname) = Mebius::GetHostByName({ Host => $gethostbyaddr});
		$tbody .=qq(\nGetHostByName : $gethostbyname\n);

		$tbody .= qq(\nRequest-uri: $ENV{'REQUEST_URI'}\n);
		$tbody .= qq(\nReferer: $ENV{'HTTP_REFERER'}\n);
		$tbody .= qq(\nREQUEST_METHOD : $ENV{'REQUEST_METHOD'} \n);

		$tbody .= qq(\n);
		$tbody .= qq(IP管理: ${main::jak_url}index.cgi?mode=cda&file=$main::addr\n);
		$tbody .= qq(IPひろば: http://www.iphiroba.jp/index.php\n);
	}

	# メールソフト受信時の振り分け用
	if($type =~ /Important-message/){
		$tbody .= qq(\n\nImportant-message\n);
	}

	# 送信日時を明記
	if($type !~ /Not-view-send-date/){
		$tbody .= qq(\n\n送信日時： $main::date:$main::thissecf\n);
	}

# URLにスペースを付ける
($tbody) = Mebius::url({ AddSpace => 1 },$tbody);

# Email用のデコード
($tbody) = decode_for_email("Body",$tbody);
($subject) = decode_for_email("Subject",$subject);

# 記録用
my $keep_body = $tbody;
my $keep_subject = $subject;

# 本文エンコード
jcode::convert(\$tbody, 'jis');

# 件名エンコード
$subject2 = MIME::mimeencode2($subject);
$from = MIME::mimeencode2("メビウスリング <$email>");

# 送信内容フォーマット化

$body = "To: $address\n";
$body .= "From: $from\n";

	# From アドレス
#	if($from_adddress){ $body .= "Cc: $from_adddress\n"; }

$body .= "Subject: $subject2\n";
$body .= "MIME-Version: 1.0\n";
$body .= "Content-type: text/plain; charset=iso-2022-jp\n";
$body .= "Content-Transfer-Encoding: 7bit\n";
$body .= "Date: $date_mail\n";
	if($address{'char'}){ $body .= qq(Mebius-char: $address{'char'}\n); }
	#elsif($address{'cer_char'}){ $body .= qq(Mebius-char: $address{'cer_char'}\n); }
$body .= "X-Mailer: Mebi-mail\n";
$body .= "\n";
$body .= "$tbody\n";

# 送信
open($mail_handler,"| $sendmail -t -i") || return("メールが送信できませんでした。");
print $mail_handler "$body\n";
close($mail_handler);

	# ローカルなど、参考情報として送信内容を返す場合
	if($type =~ /Get-mailbody/){
		$keep_body =~ s/\n/<br$main::xclose>/g;
		return(undef,$keep_body);
	}
	if(Mebius::alocal_judge()){
		Mebius::access_log("Send-mail","$keep_subject\nTo: $address\n From: $from\n$keep_body ");
	}

return(undef);

}

#-----------------------------------------------------------
# メール用デコード
#-----------------------------------------------------------
sub decode_for_email{

my($type,$text) = @_;

# 本文変換
$text =~ s/&lt;/</g;
$text =~ s/&gt;/>/g;
$text =~ s/&amp;/&/g;
$text =~ s/&quot;/"/g;
$text =~ s/\0/ /g;
$text =~ s/\.\n/\. \n/g;

	# 改行の処理
	if($type =~ /Body/){
		$text =~ s/(<br>|\r)/\n/g;
		$text =~ s/\r\n/\n/;
	}
	elsif($type =~ /Subject/){
		$text =~ s/(\r|\n|<br>)//g;
	}

# 添付ファイル拒否
$text =~ s/Content-Disposition:\s*attachment;.*//ig;
$text =~ s/Content-Transfer-Encoding:.*//ig;
$text =~ s/Content-Type:\s*multipart\/mixed;\s*boundary=.*//ig;

return($text);

}


#-------------------------------------------------
# メール送信用の時間取得
#-------------------------------------------------
sub get_date_for_email{
	$ENV{'TZ'} = "JST-9";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time);
	my @w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	my @m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

	my $date2 = sprintf("%s, %02d %s %04d %02d:%02d:%02d",
			$w[$wday],$mday,$m[$mon],$year+1900,$hour,$min,$sec) . " +0900";

	return ($date2);

}

#-----------------------------------------------------------
# 受信したメールを処理
#-----------------------------------------------------------
sub catch_mail{

# 宣言
my $self = shift;
my($type) = @_;
my($line,$line2,$from,$unsend_flag,%to,%mail_body,%mail_header,$mailbody_flag,$keep_char,$toomany_flag);
my(%from,%subject,$undelivered_address);

# メール区分のためのカウンタ
my $tag = "main";

	# テスト用
	if($type =~ /Test-mode/){ open(STDIN,"./mail.log"); }

	# メールを受け取り
	while(<STDIN>){

		# 記録用
		$line2 .= qq($_);

		# 行を分解
		chomp;

			# 次のメール区分に到達した場合
			if($_ =~ /^Content-Description: ([\w\s]+)/){ $tag = $1; $mailbody_flag = 0; }

			# 本文に到達した場合 ( 既に本文に到達している場合は、二重改行もそのまま処理する )
			if($_ eq "" && !$mailbody_flag){ $mailbody_flag = 1; next; }

			# 各種送信先を解析
			if($_ =~ /^To: (.+)/){ $to{$tag} = $1; }
			if($_ =~ /^From: (.+)/){ $from{$tag} = $1; }
			if($_ =~ /^Subject: (.+)/){ $subject{$tag} = $1; }

			# メール本文の処理
			if($mailbody_flag){
				$mail_body{$tag} .= qq($_\n);
			}
			# メールヘッダの処理
			else{
				$mail_header{$tag} .= qq($_\n);
			}
	}

	# テスト用
	if($type =~ /Test-mode/){ close(STDIN); }

	# 受信メール内容を無条件に記録
	$line2 .= qq(━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n);
	Mebius::AccessLog(undef,"Catch-mail",$line2);

	# アドレス単体ファイルを開く
	my(%address) = address_file(undef,$to{'Undelivered Message'});

	# メール本文（元のヘッダ）に char が含まれている場合
	if($mail_body{'Undelivered Message'} =~ /Mebius-char: ($address{'char'}|$address{'cer_char'})/){

			# 記録用
			$keep_char = $1;

			# 送信レポート部分から、未着メールかどうかを判定
			if($mail_body{'Delivery report'} =~ /Diagnostic-Code: smtp; (421|452)(.+)/){ $toomany_flag = "送信数オーバー？ $1$2"; }
			elsif($mail_body{'Delivery report'} =~ /Diagnostic-Code: (.{1,50})?(bad address syntax|Host or domain name not found)/i){ $unsend_flag = "各種エラー $1$2"; }
			elsif($mail_body{'Delivery report'} =~ /Diagnostic-Code: smtp; (550|554)(.+)/){ $unsend_flag = "未着 $1$2"; }
			# Recipient's mailbox is full, message returned to sender. (#5.2.2)


	}

	# ▼未着メールアドレスの単体ファイルを更新
	if($toomany_flag){
		address_file("Renew Undelivered-later",$to{'Undelivered Message'});
		$undelivered_address = $to{'Undelivered Message'};
	}

	# ▼未着メールアドレスの単体ファイルを更新
	elsif($unsend_flag){
		address_file("Renew Undelivered",$to{'Undelivered Message'});
		$undelivered_address = $to{'Undelivered Message'};
	}

	# ▼EZWEBでの未着
	elsif($from{'main'} =~ /^Postmaster\@ezweb\.ne\.jp$/ && ($subject{'main'} =~ /Mail System Error - Returned Mail/i || $type =~ /Test-mode/)){
		$unsend_flag = $&;
			if($mail_body{'main'} =~ /<([\w_\.\-\@]+?)>/){
					my $address = $1;
					my($mail_format_error) = mail_format(undef,$address);
					if(!$mail_format_error){
						address_file("Renew Undelivered",$address);
						$undelivered_address = $address;
					}
			}
	}

	# 確認用のログを記録
	if($undelivered_address){
		$line .= qq(To: $undelivered_address\n);
		$line .= qq(状態： $unsend_flag $toomany_flag\n);
		$line .= qq(Char: $keep_char\n);
		$line .= qq(━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n);
		Mebius::AccessLog(undef,"Undelivered-mail",$line);
	}

	# テスト用
	if($type =~ /Test-mode/){
		my $print = qq(OK! / アドレス： $undelivered_address / 状態： $unsend_flag);
		Mebius::Template::gzip_and_print_all({},$print);
	}

	# メッセージを返す
	else{
		print qq($line ok!);
	}

exit;

}


#-----------------------------------------------------------
# 自分のアドレス情報を取得
#-----------------------------------------------------------
sub my_address{

# Near State （呼び出し） 2.30
my $StateName1 = "my_address";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

# クッキーを取得
#my($my_cookie) = Mebius::my_cookie_main_logined(); # こちらだと無限ループに？
my($my_cookie) = Mebius::my_cookie_main();

# アドレス情報ファイルを取得
my(%address) = Mebius::Email::address_file("Get-hash-detail",$my_cookie->{'email'});

	# Near State （保存） 2.30
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%address); }

	if($address{'myaddress_flag'}){ return(\%address); }
	else{ return(); }

}


#-----------------------------------------------------------
# メールアドレス毎の単体記録ファイル
#-----------------------------------------------------------
sub address_file{

# 宣言
my($type,$address,%renew) = @_;
my($address_handler,%address,@renew_line,@top,$i);
#my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
my($my_account) = Mebius::my_account();
my $times = new Mebius::Time;

# アドレス排他チェック
$address =~ s/"//g;

# エンコード
my($address_enc) = Mebius::Encode(undef,$address);

# ファイルを定義
my $directory = "${share_directory}_address/${address_enc}/";
my $file = "${directory}address.dat";


	# ファイルを開く
	if($type =~ /File-check/){ 
		open($address_handler,"<",$file) || return();
	}
	else{
		open($address_handler,"<",$file) || ($address{'file_nothing_flag'} = 1);
	}

	if($type =~ /Renew/){ flock($address_handler,1); }

chomp(my $top1 = <$address_handler>);
chomp(my $top2 = <$address_handler>);
chomp(my $top3 = <$address_handler>);
chomp(my $top4 = <$address_handler>);
chomp(my $top5 = <$address_handler>);
close($address_handler);

# データを分解
($address{'concept'},$address{'address'},$address{'char'},$address{'firstsend_time'},$address{'lastsend_time'},$address{'block_time'}) = split(/<>/,$top1);
($address{'allsend_count'},$address{'undelivered_count'},$address{'mail_type'},$address{'allow_hour'}) = split(/<>/,$top2);
($address{'addr'},$address{'host'},$address{'cnumber'},$address{'agent'},$address{'account'}) = split(/<>/,$top3);
($address{'cer_lastsend_time'},$address{'cer_char'},$address{'cer_type'},$address{'cer_count'}) = split(/<>/,$top4);
($address{'cer_addr'},$address{'cer_host'},$address{'cer_cnumber'},$address{'cer_agent'},$address{'cer_account'},$address{'xip'}) = split(/<>/,$top5);

# ハッシュ調整
if(!$address{'file_nothing_flag'}){ $address{'f'} = 1; }

# ●ハッシュを追加定義
	# 送信禁止
	if($address{'concept'} =~ /Deny-send/){
		$address{'deny_flag'} = $address{'permanent_deny_flag'} = qq(このメールアドレス ( $address ) への送信は禁止されています。);
	} elsif($address{'undelivered_count'} >= 5 && $type !~ /Skip-undelivered-count/){
		$address{'deny_flag'} = qq(未着メールが多いため、このアドレス ( $address ) へのメール送信は停止中です。再開するには、マイページで確認メールを再送信してください。);
	} elsif(time < $address{'block_time'}){
		my $left_time = $address{'block_time'} - time;
		my($how_long_left) = Mebius::SplitTime(undef,$address{'block_time'} - time);
		$address{'deny_flag'} = qq(このメールアドレス ( $address ) には一時的に送信できません。あと $how_long_left 後に再送信してください。);
	}

	# 送信禁止時刻
	if($address{'allow_hour'} =~ /^([0-9]{1,2})-([0-9]{1,2})$/){

		$address{'allow_hour_start'} = $1;
		$address{'allow_hour_end'} = $2;

		my($hour,$allow_flag,$i);

		my $allow_hours = $times->foreach_hours($address{'allow_hour_start'},$address{'allow_hour_end'});
			foreach my $hour (@{$allow_hours}){
				if($hour == $main::thishour){ $allow_flag = 1; }
			}

			if(!$allow_flag){
					if(!$address{'deny_flag'}){
						$address{'deny_flag'} = qq(このアドレス ( $address ) に送信できるのは $address{'allow_hour_start'}:00-$address{'allow_hour_end'}:59 の間だけです。);
					}
				$address{'deny_hour_flag'} = 1;
			}
	}

	# 確認メールの配信可否
	if(time < $address{'cer_lastsend_time'} + 24*60*60){ $address{'cer_count'} = 0; }
	if($address{'cer_count'} >= 5){
		$address{'deny_sendcermail_flag'} = qq(確認メールを連続で送りすぎです。いちど認証を済ませるか、１日ほど待ってからメールを再発行してください。);
	}

	if(time < $address{'cer_lastsend_time'} + 1*60 && $main::myadmin_flag < 5){
		$address{'deny_sendcermail_flag'} = qq(短時間での確認メールの連続送信は出来ません。);
	}

	# 認証済みか否か
	if($address{'concept'} =~ /Certified/){ $address{'certified_flag'} = 1; }

	# 詳細データを確認
	if($type =~ /Get-hash-detail/){
			# 自分の認証アドレスかどうかをチェック
			if($address{'addr'} && $address{'addr'} eq $main::addr){ $address{'myaddress_flag'} = 1; }
			if($address{'host'} && $address{'host'} eq $main::host){ $address{'myaddress_flag'} = 1; }
			if($address{'cnumber'} && $address{'cnumber'} eq $main::cnumber){ $address{'myaddress_flag'} = 1; }
			if($main::k_acess && $address{'agent'} && $address{'agent'} eq $main::agent){ $address{'myaddress_flag'} = 1; }
			if($address{'account'} && $address{'account'} eq $main::pmfile){ $address{'myaddress_flag'} = 1; }
			# 自分の認証アドレスかどうかをチェック ( 確認メールの段階 )
			if($address{'cer_addr'} && $address{'cer_addr'} eq $main::addr){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_host'} && $address{'cer_host'} eq $main::host){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_cnumber'} && $address{'cer_cnumber'} eq $main::cnumber){ $address{'cer_myaddress_flag'} = 1; }
			if($main::k_acess && $address{'cer_agent'} && $address{'cer_agent'} eq $main::agent){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_account'} && $address{'cer_account'} eq $main::pmfile){ $address{'cer_myaddress_flag'} = 1; }
			if($address{'cer_xip'} && $address{'cer_xip'} eq $main::xip){ $address{'cer_myaddress_flag'} = 1; }
			# 認証待ちかどうかをチェック
			if($address{'concept'} =~ /Cer-wait/ && $address{'cer_char'} && time < $address{'cer_lastsend_time'} + 24*60*60){
				$address{'waitcer_flag'} = 1;
			}
	}

	# ●ファイルを更新
	if($type =~ /Renew/){

			# 自由な値で更新する
			foreach ( keys %renew ){

					if(defined($renew{$_})){ $address{$_} = $renew{$_}; }
			}

			# Charがない場合は自動定義
			if($address{'char'} eq ""){ ($address{'char'}) = Mebius::Crypt->char(30); }

			# メールタイプを自動定義する場合
			if($address{'mail_type'} eq ""){
				my(undef,$mail_type) = mail_format(undef,$address);
					if($mail_type eq "mobile"){ $address{'mail_type'} = "mobile"; }
					elsif($mail_type eq "normal"){ $address{'mail_type'} = "normal"; }
			}

			# メール送信許可時刻を自動定義する場合
			if($address{'allow_hour'} eq ""){
					if($address{'mail_type'} eq "normal"){ $address{'allow_hour'} = "0-23"; }
					elsif($address{'mail_type'} eq "mobile"){ $address{'allow_hour'} = "8-23"; }
			}

			# ▼新規送信の場合
			if($type =~ /Send-mail/){
					if($address{'deny_flag'}){ return(%address); }	# Mebius::DBI->); より
				if($address{'firstsend_time'} eq ""){ $address{'firstsend_time'} = time; }
				$address{'lastsend_time'} = time;
				$address{'allsend_count'}++;
			}

			# ▼未着メールが返ってきた場合
			if($type =~ /Undelivered/){
					# 送信履歴（ファイル自体）がない場合はリターン
					if(!$address{'f'}){ return(); }
					# 前回の送信から時間が経過しすぎている場合はリターン ( 偽装防止 )
					if($address{'lastsend_time'} && time > $address{'lastsend_time'} + 5*60){ return(); }
				$address{'undelivered_count'}++;
					#if($address{'undelivered_count'} >= 5){
					#	
					#}
				#$address{'lastsend_time'} = undef;
			}

			# ▼未着メールが返ってきた場合 ( Too Many ~ エラーで一時的に送信を停止する )
			if($type =~ /Undelivered-later/){
				$address{'block_time'} = time + 1*60*60;
			}

			# 今後の送信を禁止する場合
			if($type =~ /Deny-send/ && $address{'concept'} !~ /Deny-send/){
				$address{'concept'} =~ s/ Cer-wait//g;
				$address{'concept'} .= qq( Deny-send);
			}

			# 今後の送信を禁止する場合
			if($type =~ /Allow-send/){
				$address{'concept'} =~ s/ Deny-send//g;
				$address{'undelivered_count'} = 0;
				$address{'block_time'} = 0;
			}

			# 自分の接続データを記録する場合
			if($type =~ /(Cer-finished|Renew-myaccess)/){
				$address{'addr'} = $main::addr;
					if($main::host){ $address{'host'} = $main::host; }
					if($main::cnumber){ $address{'cnumber'} = $main::cnumber; }
					if($main::agent){ $address{'agent'} = $main::agent; }
					if($main::pmfile){ $address{'account'}  = $my_account->{'id'}; }
			}

			# 確認メールを配信した場合
			if($type =~ /Send-cermail/){
					if($address{'cer_char'} eq ""){ ($address{'cer_char'}) = Mebius::Crypt::char(undef,30); }
				$address{'cer_addr'} = $main::addr;
				$address{'cer_host'} = $main::host;
				$address{'cer_cnumber'} = $main::cnumber;
				$address{'cer_agent'} = $main::agent;
				$address{'cer_account'}  = $main::pmfile;
				$address{'cer_lastsend_time'} = time;
				$address{'undelivered_count'} = 0;
				$address{'cer_count'}++;
				$address{'block_time'} = undef;
				$address{'concept'} =~ s/ (Cer-wait|Deny-send)//g;
				$address{'concept'} .= " Cer-wait";
			}

			# メール認証(本人確認)に成功した場合
			if($type =~ /Cer-finished/){
				$address{'char'} = $address{'cer_char'};
				$address{'cer_char'} = "";
				$address{'cer_lastsend_time'} = "";
				$address{'cer_type'} = "";
				$address{'cer_count'} = "";
				$address{'cer_addr'} = "";
				$address{'cer_host'} = "";
				$address{'cer_cnumber'} = "";
				$address{'cer_agent'} = "";
				$address{'cer_account'} = "";
				$address{'cer_xip'} = "";
				$address{'concept'} =~ s/ Cer-wait//g;
					if($address{'concept'} !~ /Certified/){ $address{'concept'} .= qq( Certified); }
				$address{'concept'} =~ s/ Deny-send//g;
			}

		# 更新行を定義
		push(@renew_line,"$address{'concept'}<>$address<>$address{'char'}<>$address{'firstsend_time'}<>$address{'lastsend_time'}<>$address{'block_time'}<>\n");
		push(@renew_line,"$address{'allsend_count'}<>$address{'undelivered_count'}<>$address{'mail_type'}<>$address{'allow_hour'}<>\n");
		push(@renew_line,"$address{'addr'}<>$address{'host'}<>$address{'cnumber'}<>$address{'agent'}<>$address{'account'}<>\n");
		push(@renew_line,"$address{'cer_lastsend_time'}<>$address{'cer_char'}<>$address{'cer_type'}<>$address{'cer_count'}<>\n");
		push(@renew_line,"$address{'cer_addr'}<>$address{'cer_host'}<>$address{'cer_cnumber'}<>$address{'cer_agent'}<>$address{'cer_account'}<>$address{'xip'}<>\n");

		# 更新を実行
		Mebius::Mkdir(undef,$directory);
		Mebius::Fileout(undef,$file,@renew_line);
	}

	# ●ハッシュをリターン
	if($type =~ /Get-hash/){ return(%address); }

# リターン
return(%address);

}


#-----------------------------------------------------------
# メールアドレスの書式をチェック
#-----------------------------------------------------------
sub mail_format{

# 宣言
my($type,$mailto) = @_;
my($error_flag,$mail_type);
my $email_object = new Mebius::Email;
#my $encoding = new Mebius::Encoding;

my $error_flag = $email_object->format_error($mailto);
	if($error_flag){
		#$encoding->shift_jis($error_flag);
	}

	# モバイル判定
	if($mailto =~ /(\@|\.)(docomo|ezweb|softbank|pdx|vodafone|disney|emnet|ido|i\.softbank)(\.ne)?\.jp$/){ $mail_type = "mobile"; }
	elsif($mailto =~ /(\@|\.)(willcom)(\.com)$/){ $mail_type = "mobile"; }
	else{ $mail_type = "normal"; }

	# すぐにエラーを表示する場合
	if($error_flag && $type =~ /(ERROR|Error-view)/){ main::error("$error_flag"); }

return($error_flag,$mail_type);

}

#-----------------------------------------------------------
# フォーマットチェック ( 別の書き方が出来るように )
#-----------------------------------------------------------
sub email_format_error_check{

my(@self) = mail_format(undef,$_[0]);

}


#-----------------------------------------------------------
# メールの送信禁止 / 再開 フォーム
#-----------------------------------------------------------
sub AllowDenyForm{

# 宣言
my($line);

$line .= qq(<form action=""$main::sikibetu>);
$line .= qq(<div>\n);
$line .= qq(<input type="hidden" name="mode" value="mail"$main::xclose>\n);
$line .= qq(<input type="hidden" name="char" value="$main::in{'char'}"$main::xclose>\n);
$line .= qq(<input type="hidden" name="type" value="deny_address"$main::xclose>\n);
$line .= qq(<input type="submit" value="送信を禁止する"$main::xclose>\n);

$line .= qq(</div>\n);
$line .= qq(</form>\n);


#HTML
my $print = $line;

Mebius::Template::gzip_and_print_all({ source => "utf8" },$print);

exit;

}

#-----------------------------------------------------------
# 信頼出来るアドレスかどうか
#-----------------------------------------------------------
sub confidence_address{

my $self = shift;
my $address = shift;
my $flag;

	if($address =~ /\.(jp|com)$/ && 
		$address !~ /
			(\@|\.)
			(
			(inter7|supermailer|sute)\.jp|
			(deadesu|rtrtr|temp15qm|meltmail|guerrillamailblock|mailmetrash)\.com
			)$
		/x){
		$flag = 1;
	} else {
		0;
	}




$flag;

}

#-----------------------------------------------------------
# メール配信設定ページのURL
#-----------------------------------------------------------
sub edit_address_url{

my $self = shift;
my $address = shift;
my $char = shift;
my($basic_init) = Mebius::basic_init();

# メールアドレスをエンコード
my($address_enc) = Mebius::Encode(undef,$address);

my $url = qq($basic_init->{'top_domain_url'}_main/?mode=address&type=form_edit_address&char=$char&email=$address_enc);

$url;

}





1;
