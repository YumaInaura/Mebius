
use strict;
use Mebius::HTML;
use Time::HiRes;
package Mebius::Dos;

#-----------------------------------------------------------
# DOS攻撃を記録
#-----------------------------------------------------------
sub AccessFile{

# 宣言
my($type,$addr) = @_;
my($REQUEST_URL) = Mebius::request_url();
my($now_date) = Mebius::now_date_multi();
my($dos_handler,%dos,%dos_flow,@renew_line,$multi_host,$allow_error_flag);
my($time) = time;

	# リターン
	#if($addr eq "" || $addr =~ /[^0-9\.]/){ return(); }

# IPを取得
my $addr_encoded = Mebius::Encode(undef,$addr);

# 何秒に何回アクセスがあれば、DOSアタックとして記録するか？
my $dos_count_border = 20;	# アクセス数
my $dos_second_border = 10;	# 秒

# DOS攻撃の設定
my $dos_alert_border = 3;
my $dos_htaccess_border = 10;
my $verify_max = 3;

# １日あたりの最大総アクセス数の設定
my $all_access_htaccess_border = 3*60*60;
my $all_access_alert_border = $all_access_htaccess_border * 0.90;

# 連続リクエストの設定
my $redun_request_htaccess_border = 180;
my $redun_request_alert_border = $redun_request_htaccess_border * 0.90;

	# ローカル設定
	if(Mebius::alocal_judge() && 1 == 0){
		$dos_count_border = 1;
		$dos_second_border = 1;
		$all_access_htaccess_border = 20;
		$all_access_alert_border = 10;
		$redun_request_htaccess_border = 6;
		$redun_request_alert_border = 3;
	}

	if(Mebius::alocal_judge() && 1 == 0){
		$all_access_alert_border = 3;
		$all_access_htaccess_border = 6;
	}

# ディレクトリ定義
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_dos/";
my $directory2 = "${directory1}_dos_buffer/";
my $file = "${directory2}${addr_encoded}_dos.log";

	# ディレクトリ作成
	if($type =~ /Renew/ && (rand(500) <= 1 || Mebius::alocal_judge())){ Mebius::Mkdir(undef,$directory2); }

	# ファイルを開く
	open($dos_handler,"+<$file") || ($dos{'file_nothing_flag'} = 1);

	# ファイルがない場合は新規作成
	if($type =~ /Renew/ && $dos{'file_nothing_flag'}){
		Mebius::Fileout("Allow-empty",$file);
		$dos{'file_touch_flag'} = 1;
		open($dos_handler,"+<",$file);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($dos_handler,2); }

	# トップデータを分解 (1)
	chomp(my $top1 = <$dos_handler>);
	chomp(my $top2 = <$dos_handler>);
	chomp(my $top3 = <$dos_handler>);
	chomp(my $top4 = <$dos_handler>);
	chomp(my $top5 = <$dos_handler>);
	chomp(my $top6 = <$dos_handler>);

	# トップデータを分解 (2)
	($dos{'key'},$dos{'last_access_time'}) = split(/<>/,$top1);
	($dos{'access_count'},$dos{'access_start_time'},$dos{'last_access_url'},$dos{'last_post_buf'}) = split(/<>/,$top2);
	($dos{'all_access_count'},$dos{'all_access_ymdf'}) = split(/<>/,$top3);
	($dos{'dos_count'},$dos{'last_dos_count_time'},$dos{'dos_all_count'}) = split(/<>/,$top4);
	($dos{'verify_count'},$dos{'verify_time'},$dos{'verify_char'}) = split(/<>/,$top5);
	($dos{'redun_request_count'},$dos{'all_redun_request_count'},$dos{'last_redun_time'}) = split(/<>/,$top6);

	# 一時セーブのための代入
	my(%dos_pure) = (%dos);

	# ファイルが存在する場合
	if(!$dos{'file_nothing_flag'}){ $dos{'f'} = 1; }

	# 前回のDOSカウントから一定時間経過している場合（つまり、しばらく過剰なアクセスがなかった場合）はDOSカウンタをリセットする (A-1)
	if($time > $dos{'last_dos_count_time'} + 6*60*60){
		$dos{'dos_count'} = 0;
	}

	# 規約に同意した場合 (A-2)
	if($type =~ /New-access/ && $main::in{'dos_verify'} eq "verify" && $main::in{'verify_char'} eq $dos{'verify_char'} && $dos{'verify_char'}){
		$dos{'verify_count'}++;
		$dos{'verify_time'} = time;
		$dos{'verify_char'} = "";
		$dos{'access_start_time'} = time;
		$dos{'access_count'} = 1;
		$dos{'sendmail_flag'} = 1;
		$dos{'redun_request_count'} = 0;
		$dos{'deny_type'} = qq( アクセス攻撃の規約に同意しました);
	}

	# ▼DOS判定、警告判定 (A-3)
	if($dos{'dos_count'} >= $dos_alert_border && $dos{'last_dos_count_time'} >= $dos{'verify_time'}){
		$dos{'dos_alert_flag'} = 1;
	}

	# ▼DOS判定、.htaccessでの制限判定 (A-3)
	if($dos{'dos_count'} >= $dos_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( Dos);
	}

	# ▼連続リクエスト判定(警告)
	if($dos{'redun_request_count'} >= $redun_request_alert_border && $dos{'last_redun_time'} >= $dos{'verify_time'}){
		$dos{'redun_request_alert_flag'} = 1;
	}

	# ▼連続リクエスト判定(制限)
	if($dos{'redun_request_count'} >= $redun_request_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( Redun-request);
	}

	# ▼全アクセスカウンタをリセットする場合 (B-1)
	if($dos{'all_access_ymdf'} ne $now_date->{'ymdf'}){
		$dos{'all_access_count'} = 0;
		$dos{'all_access_ymdf'} = qq($now_date->{'ymdf'});
	}

	# ▼全アクセス回数、警告判定 (B-2)
	if($dos{'all_access_count'} >= $all_access_alert_border){
		$dos{'all_access_alert_flag'} = 1;
	}

	# ▼全アクセス回数、.htaccessでの制限判定 (B-2)
	if($dos{'all_access_count'} >= $all_access_htaccess_border){
		$dos{'deny_htaccess_flag'} .= qq( All-access);
	}

	# ●カウントを減らす
	if($type =~ /Redirect-url/){
		$dos{'access_count'} -= 0.5;
		$dos{'all_access_count'} -= 0.5;
	}
	
	# ●新しいアクセス
	if($type =~ /New-access/){

			# ホスト名を取得し、詳細なアクセスデータを記録する場合
			#	（ あらかじめログを取るために、実際の警告境界より少なめの値を設定する ）
			if($dos{'dos_all_count'} >= $dos_alert_border -1 || $dos{'all_access_count'} >= $all_access_alert_border * 0.8 || $dos{'all_redun_request_count'} >= $redun_request_alert_border * 0.8){

				# ホスト名を取得
				($multi_host) = Mebius::GetHostByFileMulti();
				my($access) = Mebius::my_access();

				# IPアドレス/ホスト名の振り分け
				my $host_or_addr = $addr;
					if($multi_host->{'host'}){ $host_or_addr = $multi_host->{'host'}; }

					# 判定対象外の環境の場合
					if($multi_host->{'host_type'} eq "Bot" || ($access->{'bot_flag'} && ($multi_host->{'host'} eq "" || $multi_host->{'addr_to_host_flag'})) || $multi_host->{'myserver_addr_flag'} || $main::k_access){

					}
					# 普通に詳細データを記録する場合
					else{
						(%dos_flow) = Mebius::Dos::FlowFile("New-access Get-alert Renew",$host_or_addr,$multi_host->{'host'},$addr);
						$allow_error_flag = 1;
					}

			}

			# ▼アクセス時間を記録
			$dos{'last_access_time'} = Time::HiRes::time;

			# ▼前回の開始時間から一定時間経過している場合、アクセスカウンタをリセットw
			if($time > $dos{'access_start_time'} + $dos_second_border){
				$dos{'access_count'} = 0;
				$dos{'access_start_time'} = $time;
			}

			# ▼アクセスカウンタを増やす

			if($REQUEST_URL eq $dos{'last_access_url'} && $main::postbuf eq $dos{'last_post_buf'}){
				$dos{'access_count'} += 2;
				$dos{'redun_request_count'} += 1;
				$dos{'all_redun_request_count'} += 1;
				$dos{'last_redun_time'} = time;

					# 初めて連続リクエスト判定で警告を受けた場合
					if($dos{'redun_request_count'} == $redun_request_alert_border && $allow_error_flag){
						# メールフラグを立てる
						$dos{'sendmail_flag'} = 1;
						$dos{'deny_type'} = qq( 連続リクエストの警告を表\示しました);
					}

			}
			else{
				$dos{'access_count'} += 1;
				$dos{'redun_request_count'} = 0;
			}

		# ▼全アクセスカウントを増やす
		$dos{'all_access_count'} += 1;

			# ▼総アクセス回数が警告回数に達した場合
			if($dos{'all_access_count'} == $all_access_alert_border && $allow_error_flag){
				# メールフラグを立てる
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( 総アクセス数の警告を表\示しました);
			}

			# ▼総アクセス回数がキリ番に達した場合
			if($dos{'all_access_count'} >= 1000 && $dos{'all_access_count'} % 1000 == 0 && $allow_error_flag){
				# メールフラグを立てる
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( 総アクセス数が $dos{'all_access_count'} に達しました);
			}

			# ▼ 一時カウンタが溢れた場合、DOSカウンタを増やす
			if($dos{'access_count'} >= $dos_count_border){

				# DOSカウンタを増やす
				$dos{'dos_count'} += 1;
				$dos{'dos_all_count'} += 1;

				# DOSカウンタを増やした最終時刻を記録
				$dos{'last_dos_count_time'} = $time;

				# 一時アクセスデータをリセット
				$dos{'access_count'} = 0;
				$dos{'access_start_time'} = $time;

					# 初めてDOS判定で警告された場合
					if($dos{'dos_count'} == $dos_alert_border && $allow_error_flag){
							# キー追加	
							if($dos{'key'} !~ /Alert-done/){ $dos{'key'} .= qq( Alert-done); }
						# メールフラグを立てる
						$dos{'sendmail_flag'} = 1;
						$dos{'deny_type'} = qq( アクセス攻撃の警告を表\示しました);
					}


			}

			# ▼DOS判定回数、もしくは全アクセス回数が超過している場合、
			#	 .htaccessファイルを編集して、自動的にアクセス制限を課す ( レベル３ )
			if($dos{'deny_htaccess_flag'} && $allow_error_flag){

					# キー追加
					if($dos{'key'} !~ /Htaccess-done/){ $dos{'key'} .= qq( Htaccess-done); }

				# .htacess を編集
				Mebius::Dos::HtaccessFile("New-deny Renew",$addr,$multi_host->{'host'});

				$dos{'all_access_count'} = 0;
				$dos{'dos_count'} = 0;
				$dos{'redun_request_count'} = 0;
				$dos{'sendmail_flag'} = 1;
				$dos{'deny_type'} = qq( .htaccess でアクセス制限をおこないました);

			}

		# 最終アクセスURLなど
		$dos{'last_access_url'} = $REQUEST_URL;
		$dos{'last_post_buf'} = $main::postbuf;

			# 認証用のキー
			if($dos{'verify_char'} eq ""){ $dos{'verify_char'} = int(rand(9999)); }

	}



	# ●ファイルを更新
	if($type =~ /Renew/){

		# 局所化
		my(@renew_line_top);

			# ●ハッシュを調整
			# データが壊れている場合
			{
				my $strange_data_flag;
					if($dos{'dos_count'} && $dos{'dos_count'} =~ /[^\d\.]/){ $strange_data_flag = 1; $dos{'dos_count'} = 0; }
					if($dos{'all_access_count'} && $dos{'all_access_count'} =~ /[^\d\.]/){ $strange_data_flag = 2; $dos{'all_access_count'} = 0; }
					if($dos{'redun_request_count'} && $dos{'redun_request_count'} =~ /[^\d\.]/){ $strange_data_flag = 3; $dos{'redun_request_count'} = 0; }
					if($strange_data_flag){ Mebius::AccessLog(undef,"Dos-strange-data","判定 : $strange_data_flag\n$top1\n$top2\n$top4\n$top4\n$top5\n$top6\n"); }
			}

		# トップデータを追加
		push(@renew_line_top,"$dos{'key'}<>$dos{'last_access_time'}<>\n");
		push(@renew_line_top,"$dos{'access_count'}<>$dos{'access_start_time'}<>$dos{'last_access_url'}<>$dos{'last_post_buf'}<>\n");
		push(@renew_line_top,"$dos{'all_access_count'}<>$dos{'all_access_ymdf'}<>\n");
		push(@renew_line_top,"$dos{'dos_count'}<>$dos{'last_dos_count_time'}<>$dos{'dos_all_count'}<>\n");
		push(@renew_line_top,"$dos{'verify_count'}<>$dos{'verify_time'}<>$dos{'verify_char'}<>\n");
		push(@renew_line_top,"$dos{'redun_request_count'}<>$dos{'all_redun_request_count'}<>$dos{'last_redun_time'}<>\n");
		unshift(@renew_line,@renew_line_top);

		# ファイル更新
		seek($dos_handler,0,0);
		truncate($dos_handler,tell($dos_handler));
		print $dos_handler @renew_line;

	}

close($dos_handler);

	# パーミッション変更
	if($type =~ /Renew/ && ($dos{'file_touch_flag'} || rand(25) < 1)){ Mebius::Chmod(undef,$file); }

	# ●マスターにメールを送信する
	if($dos{'sendmail_flag'}){

		# 局所化
		my($access_log_line);

		# 送信内容を定義
		$access_log_line .= qq(IPアドレス： $addr\n);
		$access_log_line .= qq(ホスト名： $multi_host->{'host'}\n);
		$access_log_line .= qq(Dos判定回数: $dos_pure{'dos_count'} (?)\n);
		$access_log_line .= qq(総アクセス数: $dos_pure{'all_access_count'} (?)\n);
		$access_log_line .= qq(同ページへの連続アクセス数: $dos_pure{'redun_request_count'} / $dos_pure{'all_redun_request_count'} (?)\n);
		$access_log_line .= qq(判定タイプ： $dos{'deny_type'}\n);
		$access_log_line .= qq(ホストタイプ: $multi_host->{'type'}\n);
		$access_log_line .= qq(\nログ：\n);
		$access_log_line .= qq($dos_flow{'access_log'}\n\n);

		# 各種データ取得
		my($server_domain) = Mebius::server_domain();

		# メール送信
		Mebius::Email::send_email("To-master Access-data-view",undef,"$dos{'deny_type'} - $multi_host->{'host'} - $server_domain",$access_log_line);

		# アクセスログを記録
		Mebius::AccessLog(undef,"Dos-email-send");

	}

	# ▼総アクセス数超過の警告を表示する場合
	if($type =~ /New-access/ && $dos{'all_access_alert_flag'} && $allow_error_flag){

		# 局所化
		my($error_line);

		# ログを取る
		Mebius::AccessLog(undef,"Dos-all-access-error");

		$error_line .= qq(<div style="color:red;line-height:1.4;">\n);
		$error_line .= qq(今日の総アクセス数が多すぎます。日を替えてアクセスしなおしてください。<br$main::xclose>);
		$error_line .= qq(このままアクセスを続けると、利用制限がおこなわれる場合があります。);
		$error_line .= qq(</div>\n);

		# HTMLを出力
		Mebius::SimpleHTML({ FromEncoding => "sjis" , Message => $error_line });
	}


	# ▼DOS判定/リクエスト判定の警告を表示する場合
	elsif($type =~ /New-access/ && ($dos{'dos_alert_flag'} || $dos{'redun_request_alert_flag'}) && $allow_error_flag){

		# 局所化
		my($error_line);

		# ログを取る
		Mebius::AccessLog(undef,"Dos-cgi-error");

		$error_line .= qq(<div style="color:red;line-height:1.4;">過剰なアクセス、連続した画面更新や、同じＵＲＬにアクセスし続けることはご遠慮下さい。<br>);
		$error_line .= qq(全てのアクセスログは記録されています。<br>);
		$error_line .= qq(サーバーに負担をかける行為が続く場合、完全なアクセス制限や、<strong>あなたのサービスプロバイダへの連絡</strong>をさせていただく場合があります。<br>);

		# レベル１：警告の場合
		$error_line .= qq(<form action="/" method="post">\n);
		$error_line .= qq(<div>\n);
			foreach(keys %main::in){
				my $key = $_;
				my $value = $main::in{$_};
					if($key =~ /^(verify_char|dos_verify)$/){ next; }
				$error_line .= qq(<input type="hidden" name="$key" value="$value">\n);
			}
		$error_line .= qq(<input type="hidden" name="mode" value="index">\n);
		$error_line .= qq(<input type="hidden" name="dos_verify" value="verify">\n);
		$error_line .= qq(<input type="hidden" name="verify_char" value="$dos{'verify_char'}">\n);
		$error_line .= qq(<input type="submit" value="同意して続ける">\n);
		$error_line .= qq(</div>\n);
		$error_line .= qq(</form>\n);

		$error_line .= qq(</div>);
		#$error_line .= qq(<div style="line-height:1.4;margin:1em;">▼あなたの最近のアクセス▼<br>$dos_flow{'alert_index_line'}</div>);

		# HTMLを出力
		Mebius::SimpleHTML({ FromEncoding => "sjis" ,  Message => $error_line });
	}



	# ファイルを削除する場合
	if($type =~ /Delete-file/){ unlink($file); }


return(%dos);

}

#-----------------------------------------------------------
# DOS攻撃を記録
#-----------------------------------------------------------
sub FlowFile{

# 宣言
my($type,$host_or_addr,$host,$addr) = @_;
my($REQUEST_URL) = Mebius::request_url();
my($my_access) = Mebius::my_access();
my($now_date) = Mebius::get_date("HiRes");
my($dos_handler,%dos,@renew_line,$i,$host,$file);
my($time) = time;

# ディレクトリ定義
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_dos/";
my $directory2 = "${directory1}_dos_flow/";

# IPアドレスかホスト名かを判定
($dos{'file_type'}) = Mebius::Format::HostAddr(undef,$host_or_addr);

# 汚染チェック
if($host_or_addr eq "" || $host_or_addr =~ m!\.\./|^/!){ return(); }
$file = "$directory2${host_or_addr}_dos_flow.log";

	# ディレクトリ作成
	if($type =~ /Renew/ && (rand(500) <= 1 || Mebius::alocal_judge())){ Mebius::Mkdir(undef,$directory2); }

	# ファイルを開く
	open($dos_handler,"+<$file") || ($dos{'file_nothing_flag'} = 1);

	# ファイルがない場合は新規作成
	if($type =~ /Renew/ && $dos{'file_nothing_flag'}){
		Mebius::Fileout("Allow-empty",$file);
		open($dos_handler,"+<$file");
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($dos_handler,2); }

# トップデータを分解
chomp(my $top1 = <$dos_handler>);
($dos{'key'},$dos{'last_access_time'},$dos{'addr'},$dos{'host'},$dos{'account'},$dos{'cnumber'},$dos{'agent'}) = split(/<>/,$top1);

# ハッシュを調整
if(!$dos{'file_nothing_flag'}){ $dos{'f'} = 1; }

	# ●ファイルを展開
	while(<$dos_handler>){

		# ラウンドカウンタ
		$i++;

		# 行を追加
		chomp;
		my($time2,$date2,$url2,$agent2) = split(/\t/);

			# ▼アラート表示用
			if($type =~ /Get-alert/){
				#$dos{'alert_index_line'} .= qq($date2);
				#$dos{'alert_index_line'} .= qq(<br>\n);
					if($i <= 100){ $dos{'access_log'} .= qq($date2	$url2	$agent2	$addr\n); }
			}

			# ▼ファイル更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i >= 100){ last; }

				# 更新行を追加
				push(@renew_line,"$time2\t$date2\t$url2\t$agent2\n");
			}

	}

	# ▼新規アクセスの場合
	if($type =~ /New-access/){

		# 新しく追加する行
		unshift(@renew_line,"$time\t$now_date->{'date_till_micro_second'}\t$REQUEST_URL\t$my_access->{'multi_user_agent'}\n");

		# トップデータの書き換え
		$dos{'host'} = $host;
		$dos{'account'} = $main::myaccount{'file'};
		$dos{'cnumber'} = $main::cnumber;
		$dos{'agent'} = $my_access->{'multi_user_agent'};
		$dos{'addr'} = $addr;
		$dos{'last_access_time'} = Time::HiRes::time;
		#$dos{'last_access_time'} = $time;
	}

	# ▼ファイル更新
	if($type =~ /Renew/){

		# トップデータを追加
		unshift(@renew_line,"$dos{'key'}<>$dos{'last_access_time'}<>$dos{'addr'}<>$dos{'host'}<>$dos{'account'}<>$dos{'cnumber'}<>$dos{'agent'}<>\n");

		# ファイル更新
		seek($dos_handler,0,0);
		truncate($dos_handler,tell($dos_handler));
		print $dos_handler @renew_line;
		close($dos_handler);

	}

close($dos_handler);

	# パーミッション変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$file); }

	# ファイルを削除する場合
	if($type =~ /Delete-file/){ unlink($file); }

return(%dos);


}

#-----------------------------------------------------------
# Apacheのアクセス制限用ファイル
#-----------------------------------------------------------
sub HtaccessFile{


# 宣言
my($type,$addr,$host) = @_;
my($deny_handler,$i,$log_file,@renew_line,$rebety_time,$new_deny_time,%deny,$htaccess_file);
my($htaccess_handler,@renew_htaccess_line,$directory,%self);
my($time) = (time);

# アクセスを制限する期間
$new_deny_time = 1*24*60*60;

	# 汚染チェック
	if($addr eq "" || $addr =~ /[^0-9\.]/){ return(); }

# ディレクトリ
my($init_directory) = Mebius::BaseInitDirectory();
my($server_domain) = Mebius::server_domain();
my($now_date) = Mebius::now_date();

	# ファイル定義 (ローカル)
	if(Mebius::alocal_judge()){
		$directory = "${init_directory}_htaccess/";
		$log_file = "${directory}htaccess.log";
		$htaccess_file = "${init_directory}../cgi-bin/.htaccess";
	}
	# ファイル定義 (サーバー)
	else{
		$directory = "${init_directory}_htaccess/";
		$log_file = "${directory}htaccess.log";
		$htaccess_file = "/var/www/$server_domain/public_html/.htaccess";
	}


# ファイルを開く
	# ファイルを開く
	my($deny_handler,$read_write) = Mebius::File::read_write($type,$log_file,[$directory]);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

	# ▼ファイルを展開
	while(<$deny_handler>){

		# 局所化
		my($line_flag,$addr2,$data_line);

		# ラウンドカウンタ
		$i++;

		# データ行を分解
		chomp;
		my($key2,$addr2,$host2,$deny_time2,$deny_date2) = split(/<>/);

			# ▼新しい制限用
			if($type =~ /New-deny/){

					# 同じIPアドレスの場合
					if($addr2 eq $addr){ next; }

					# 制限期間が過ぎている場合
					if($time > $deny_time2){ next; }

			}

			# 特定アドレスの削除
			if($type =~ /Delete-addr/){

					if($addr2 eq $addr){ next; }

			}

			# ▼ファイル更新用
			if($type =~ /Renew/){

					# 最大記録行数に達した場合
					if($i >= 500){ last; }

					# 更新行を追加する
					push(@renew_line,"$key2<>$addr2<>$host2<>$deny_time2<>$deny_date2<>\n");
			}

			# ▼ .htaccess 用の行定義
			push(@renew_htaccess_line,"# $host2 $deny_date2\n");
			push(@renew_htaccess_line,"Deny from $addr2\n");

	}


	# ▼新しい制限
	if($type =~ /New-deny/){

		# 制限終了時刻
		my($rebety_time);
		my $rebety_time = $time + $new_deny_time;
		my (%rebety_time) = Mebius::Getdate("Get-hash",$rebety_time);

		# 新しく追加する行
		unshift(@renew_line,"<>$addr<>$host<>$rebety_time<>$rebety_time{'date'}<>\n");

		# ▼ .htaccess 用の行定義
		unshift(@renew_htaccess_line,"Deny from $addr\n");
		unshift(@renew_htaccess_line,"# $host $now_date\n");

	}

	# ▼ファイル更新 ( ログファイル )
	if($type =~ /Renew/){	Mebius::File::truncate_print($deny_handler,@renew_line); }

close($deny_handler);

	# パーミッション変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$log_file); }

	# ● .htaccess ファイルを実際に書き込み
	if($type =~ /Renew/){ 

		unshift(@renew_htaccess_line,qq(Allow from all\n));
		unshift(@renew_htaccess_line,qq(Order allow,deny\n));

		# ファイル更新
		Mebius::Fileout(undef,$htaccess_file,@renew_htaccess_line);
	}

}

1;
