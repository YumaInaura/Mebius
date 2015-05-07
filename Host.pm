
# 宣言
use strict;
use Mebius::Getpage;
use Mebius::Server;
package Mebius::Host;

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
sub my_isp{

my $self = shift;
my $host = Mebius::get_host_state();
my $isp = Mebius::Isp(undef,$host);


	if(Mebius::alocal_judge()){
		$isp = "localhost.jp";
	}

$isp;

}

package Mebius;


#-----------------------------------------------------------
# ホスト名の取得
#-----------------------------------------------------------
sub get_host{

my $server = new Mebius::Server;
my($host);

	if($server->local_machine_lan_judge()){
		$host = $server->local_machine_lan_addr();
	} else {
		$host = gethostbyaddr(pack("C4", split(/\./, $ENV{'REMOTE_ADDR'})), 2);
	}


$host;

}

#-----------------------------------------------------------
# ホスト名の取得
#-----------------------------------------------------------
sub get_host_state{


# Near State （呼び出し） 2.30
my $HereName1 = "gethostbyaddr_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my ($host) = Mebius::get_host(@_);

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$host); }

$host;

}

#-----------------------------------------------------------
# IPアドレスからホスト名を取得する 
#-----------------------------------------------------------
sub GetHostByAddr{

# 宣言
my($use) = @_;
my($Addr,$gethostbyaddr);

	# 処理振り分け
	# 任意のIPアドレスを指定する場合
	if(exists $use->{'Addr'}){
			if(defined $use->{'Addr'}){
				$Addr = $use->{'Addr'};
			}
			else{
				die("Perl Die!  Addr is empty.");
			}
	}
	# 自分のIPアドレスを使う場合
	else{
		$Addr = $ENV{'REMOTE_ADDR'};
	}

# Near State ( 呼び出し ) 
my $StateName1 = "GetHostByAddr";
my $StateKey1 = $Addr; # IPアドレスによってキーを変える
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }

	# IPアドレスのフォーマットが正しければ、逆引きを実行
	if(Mebius::AddrFormat({ Addr => $Addr })){
		$gethostbyaddr = Mebius::get_host_state($Addr);
	}

	# ローカルではホスト名を書き換え
	if(Mebius::alocal_judge() && $gethostbyaddr =~ /^([\w\-]+)$/){ $gethostbyaddr = "localhost"; }

	# Near State ( 保存 )
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$gethostbyaddr); }

return($gethostbyaddr);

}


#-----------------------------------------------------------
# ホスト名からIPアドレスを”正”引き
#-----------------------------------------------------------
sub GetHostByName{

# 宣言
my($use) = @_;
my($addr_gethostbyname,$host);

	# 検索するホスト名を指定する場合
	if(exists $use->{'Host'}){ $host = $use->{'Host'}; }
	# 自分のアクセスから情報を取得する場合
	else{ ($host) = Mebius::GetHostByAddr(); }

	# 必須項目をチェック
	if(!defined $host){ return(); }

# Near State （呼び出し） 2.20
my $StateName1 = "GetHostByName";
my $StateKey1 = $host;
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

	# ホスト名から正引き
	if(Mebius::HostFormat({ Host => $host })){
		$addr_gethostbyname = join(".",unpack C4=>(gethostbyname $host)[4]);
	}
	else{
		$addr_gethostbyname = "";
	}

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,$addr_gethostbyname); }

return($addr_gethostbyname);

}




#-----------------------------------------------------------
# ホスト名を取得 ( 記録ファイルの値は代入しないけど、参考にする )
#-----------------------------------------------------------
sub GetHostWithFile{

# Near State （呼び出し）
my $StateName1 = "GetHostWithFile";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

my($host) = &GetHostSelect({ Addr => $ENV{'REMOTE_ADDR'} , "REMOTE_HOST" => $ENV{'REMOTE_HOST'} , TypeWithFile => 1 });

	# Near State （保存）
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$host); }

return($host);

}

#-----------------------------------------------------------
# ホスト名を取得 ( 記録ファイルを優先的に使う )
#-----------------------------------------------------------
sub GetHostByFile{

# Near State （呼び出し）
my $StateName1 = "GetHostByFile";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

my($host) = &GetHostSelect({ Addr => $ENV{'REMOTE_ADDR'} , Host => $ENV{'REMOTE_HOST'} , TypeByFile => 1 , Debug => 1 });

	# Near State （保存）
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$host); }

return($host);

}

#-----------------------------------------------------------
# ホスト名に加えて ISP 名前などを同時に取得 ( 逆引きする )
#-----------------------------------------------------------
sub GetHostWithFileMulti{

# 宣言
my($use) = @_;
my($multi_host);

# Near State （呼び出し） 2.10
my $StateName1 = " GetHostWithFileMulti";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# ホスト情報を取得
($multi_host) = Mebius::GetHostMulti({ TypeWithFile => 1 });

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$multi_host); }

return($multi_host);

}


#-----------------------------------------------------------
# ホスト名に加えて ISP 名前などを同時に取得 ( ファイル情報を優先 )
#-----------------------------------------------------------
sub GetHostByFileMulti{

# 宣言
my($use) = @_;
my($multi_host);

# Near State （呼び出し） 2.10
my $StateName1 = "GetHostByFileMulti";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateName1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateName1); }

# ホスト情報を取得
($multi_host) = Mebius::GetHostMulti({ TypeByFile => 1 });

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateName1,$multi_host); }

return($multi_host);

}


#-----------------------------------------------------------
# ホスト名に加えて ISP 名前などを同時に取得
#-----------------------------------------------------------
sub GetHostMulti{

# 宣言
my($use) = @_;
my(%multi_host,$StateName1);

	# ホスト名を取得してハッシュに代入
	if($use->{'TypeWithFile'}){

			# IPアドレスを指定
			if(exists $use->{'Addr'}){ ($multi_host{'host'}) = Mebius::GetHostSelect({ TypeWithFile => 1 , Addr => $use->{'Addr'} }); }
			# 自分のアクセス	# &GetHostSelect にしてしまうと、Stateが効かない？
			else{ ($multi_host{'host'}) = Mebius::GetHostWithFile(); }

	}
	# ホスト名を取得してハッシュに代入
	elsif($use->{'TypeByFile'}){

			# IPアドレスを指定
			if(exists $use->{'Addr'}){ ($multi_host{'host'}) = Mebius::GetHostSelect({ TypeByFile => 1 , Addr => $use->{'Addr'} }); }
			# 自分のアクセス
			else{ ($multi_host{'host'}) = Mebius::GetHostByFile(); }

	}
	# ホスト名を取得してハッシュに代入
	elsif($use->{'TypeByCache'}){

		if(exists $use->{'Addr'}){
			die;
		} else{
			($multi_host{'host'}) = Mebius::Host::gethostbyaddr_cache();
		}

	}

	else{
		die("Perl Die!  Type is empty.");
	}

	# ホストからISPを抽出
	($multi_host{'isp'},$multi_host{'second_domain'},$multi_host{'first_domain'}) = Mebius::Isp("",$multi_host{'host'});

	# ホスト名のタイプを判定
	my($host_type) = Mebius::HostType({ Host => $multi_host{'host'} });
	$multi_host{'host_type'} = $host_type->{'type'};
	$multi_host{'mobile_id'} = $host_type->{'mobile_id'};

	# 逆引き出来なかったけれど Who is 検索等で許可したホストの場合
	if($multi_host{'host'} =~ /\.mb2.jp$/){ $multi_host{'addr_to_host_flag'} = 1; }

	# 自サーバーかどうかを判定 # FIXFIX
	foreach(@main::server_addrs){
		if($_ eq $ENV{'REMOTE_ADDR'}){ $multi_host{'myserver_addr_flag'} = 1; }
	}

return(\%multi_host);

}


#-----------------------------------------------------------
# ホストの取得 ( 自分のアクセス用 )
#-----------------------------------------------------------
sub GetHostSelect{

# 宣言
my($use) = @_;
my($basic_init) = Mebius::basic_init();
my($filehandle1,$host);
my($error_message,$plustype_hostcheck);
my($REMOTE_ADDR,$REMOTE_HOST,%data,$ADDR_FILE_RENEW_FLAG,$GETHOSTBYNAME_STRANGE_FLAG,$addr_gethostbyname);

	# 必須項目をチェック
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty."); }

# ループ処理を予防 (ブロックとセット) 1.1
my $HereName = "GetHostSelect";
my $HereKey = $use->{'Addr'};
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName,$HereKey);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName,$HereKey); }

	# タイプ指定を判定
	if($use->{'TypeWithFile'}){ }
	elsif($use->{'TypeByFile'}){ }
	else{ die('Type is empty'); }

	# 任意のIPアドレスを指定する場合
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty value."); }

	# IPアドレスのフォーマットを確認
	if(Mebius::AddrFormat({ Addr => $use->{'Addr'} })){ $REMOTE_ADDR = $use->{'Addr'}; }
	else{ die("Perl Die!  Addr Format '$use->{'Addr'}' is wrong."); }

# アドレスファイルからデータを取得
my($addr) = Mebius::Host::select_addr_data_from_main_table($REMOTE_ADDR);
my($flag) = Mebius::Host::get_flag($addr);

#my($addr) = Mebius::AddrFile({ TypeGetFlag => 1 },$REMOTE_ADDR);
#	if(!$addr->{'Flag'}){ die("Perl Die!  Addr File's Flag is not got. Please fix script."); }

	# ●ファイルから優先的に取得する場合で、ホスト名が既に記録されている場合は、その値をすぐに代入
	if($use->{'TypeByFile'} && $flag->{'trusted_host'} && Mebius::HostFormat({ Host => $addr->{'host'} })){
			$host = $addr->{'host'};
	}

	# $ENV{'REMOTE_HOST'} をサブルーチンの外から指定している場合 ( 自分のアクセス用 )
	if(!defined $host){
			if(exists $use->{'REMOTE_HOST'} && Mebius::HostFormat({ Host => $use->{'REMOTE_HOST'} })){
				$REMOTE_HOST = $use->{'REMOTE_HOST'};
			}
		$ADDR_FILE_RENEW_FLAG = 1;
	}


	# ●ホストが取得できなかった場合、IPアドレスから逆引き A-1
	# 前回の逆引き結果が空の場合は、一定時間逆引きしない
	if(($use->{'TypeWithFile'} && !defined $host && (time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60) || $addr->{'host'}) )
		# ファイルから取得する場合は、一定時間経過していないと、逆引き自体を行わない
		|| ($use->{'TypeByFile'} && !defined $host && time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60))){

		# 逆引きを実行
		($REMOTE_HOST) = Mebius::GetHostByAddr({ Addr => $use->{'Addr'} });
		$ADDR_FILE_RENEW_FLAG = 1;
	}

	# ●IPアドレスを正引きする A-2
	if($REMOTE_HOST && Mebius::HostFormat({ Host => $REMOTE_HOST })){

		# ホストタイプを判定
		my($host_type) = Mebius::HostType({ Host => $REMOTE_HOST });

		# "正引き" 取得したホスト名からIPアドレスを”正引き”して、正誤チェックをおこなう
		($addr_gethostbyname) = Mebius::GetHostByName({ Host => $REMOTE_HOST });

			# 無条件に許可するホスト名の場合 ( 携帯のフルブラウザなど )
			if($host_type->{'special_allow_gethostbyname_flag'}){
				$host = $REMOTE_HOST;
			}
			# 正引きに成功
			elsif($addr_gethostbyname && $addr_gethostbyname eq $REMOTE_ADDR){
				$host = $REMOTE_HOST; # ここで初めてホスト名を正式に定義
			}			# 正引きの結果がカラの場合 ( 以降の処理を続行 )
			elsif($addr_gethostbyname eq ""){

			}
			# 失敗
			else{
				Mebius::AccessLog(undef,"Gethostbyname-wrong","REMOTE_ADDR ： $REMOTE_ADDR => ホスト名 : $REMOTE_HOST => GetHostByName ： $addr_gethostbyname");
				$host = ""; # null の値でホスト名を定義してしまう、以降の処理でホスト名の定義処理をおこなわないように
				$GETHOSTBYNAME_STRANGE_FLAG = 1;	# 念のためフラグも立てておく
			}

	}

	# ●前回の gethostbyaddr から一定時間以上が経過している場合はIPアドレスファイルを更新 A-3
	if($ADDR_FILE_RENEW_FLAG && time > $addr->{'last_gethostbyaddr_time'} + (1*24*60*60)){
			my(%renew);
			$renew{'addr'} = $REMOTE_ADDR;
			$renew{'host'} = $host;
			$renew{'gethostbyname'} = $addr_gethostbyname;
			$renew{'last_gethostbyaddr_time'} = time;

			#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
			Mebius::Host::update_or_insert_main_table(\%renew);

	}


	# ●特殊な接続元において、ホスト名が取得できなかった場合、ファイル情報を見て投稿を許可する
	# => Who is 検索 や 管理者の手動許可がなくても、以前にホスト名の記録があるだけで投稿許可
	if(!defined $host && $flag->{'trusted_host'} && !$GETHOSTBYNAME_STRANGE_FLAG){

		# ホストタイプを判定
		my($host_type) = Mebius::HostType({ Host => $addr->{'host'} });

			# ホスト名が取得できなくても、以前にホストが記録されていた場合は、投稿できるように
			if($use->{'TypeWithFile'}){

					# ファイルに記録されているのが携帯端末の場合
					if($host_type->{'type'} eq "Mobile"){
						$host = "$REMOTE_ADDR.mobile.mb2.jp";
					}
					# そうでない場合
					else{
						$host = "$REMOTE_ADDR.mb2.jp";
					}

			}

	}

	# ●逆引きできない場合も、管理者が許可していたり、Who is から許可している場合は、IPアドレスをホスト名に見せかけて投稿許可
	if(!defined $host && $flag->{'special_allow'} && !$GETHOSTBYNAME_STRANGE_FLAG){ $host = "$REMOTE_ADDR.mb2.jp"; }

	# ●それでもホスト名が取得できない場合、Who is から検索
	# => 既に許可されている場合は実行しない
	# => 管理者がIPアドレスを禁止している場合は実行しない
	# => 前回のWho is 検索から時間が経っていない場合は実行しない
	# => IPアドレスの正引きで偽装判定された場合は実行しない
	if(!defined $host && $flag->{'allow_get_whois'} && !$GETHOSTBYNAME_STRANGE_FLAG){

		# Who is から検索
		my($whois) = Mebius::whois_nic({ Addr => $REMOTE_ADDR });

		# マスターにメールする内容
		my $mail_body .= qq($basic_init->{'admin_url'}index.cgi?mode=cda&file=$REMOTE_ADDR \n\n);
		$mail_body .= qq($whois->{'source'});
		$mail_body .= qq(処理タイプ： \$use->{'TypeWithFile'} : $use->{'TypeWithFile'} / \$use->{'TypeByFile'} : $use->{'TypeByFile'} \n\n);

			# Whois サイトがメンテ中だった場合
			if($whois->{'mente_flag'}){

				# IPファイルを更新
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_get_whois_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = time;
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# 記録用
				Mebius::AccessLog(undef,"Whois-get-but-now-mente",$mail_body);

				# マスターにメールする
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"Who is サイトがメンテナンス中でした。 - $REMOTE_ADDR",$mail_body);

			}

			# Whoisで許可された場合
			elsif($whois->{'allow_flag'}){

				# IPファイルを更新
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_deny_allow_time'} = time;
				$renew{'last_get_whois_time'} = time;
				$renew{'whois_allowed_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = "";
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# 記録用
				Mebius::AccessLog(undef,"Whois-get-allow",$mail_body);

				# マスターにメールする
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"IPアドレスが自動許可されました。 - $REMOTE_ADDR",$mail_body);

				# ホストを代入
				$host = "$REMOTE_ADDR.mb2.jp";

			}
			# Whoisで許可されなかった場合
			else{

				# IPファイルを更新
				my(%renew);
				$renew{'addr'} = $REMOTE_ADDR;
				$renew{'last_get_whois_time'} = time;
				$renew{'last_get_whois_but_mente_time'} = "";
				#Mebius::AddrFile({ TypeRenew => 1 },$REMOTE_ADDR,\%renew);
				Mebius::Host::update_or_insert_main_table(\%renew);

				# 記録用
				Mebius::AccessLog(undef,"Who-is-get-not-allow",$mail_body);
				# マスターにメールする
				Mebius::Email::send_email("To-master BlockRoopingGetHost",undef,"IPアドレスが自動許可されませんでした。 - $REMOTE_ADDR ",$mail_body);

			}

	}

	# ローカルでのホスト名書き換え
	if(Mebius::alocal_judge()){ # && $host =~ /^(localhost)$/
		$host = "local.localhost.jp";
	}

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName){ Mebius::Roop::relese(__PACKAGE__,$HereName,$HereKey); }

# 最終リターン
return($host);

}

#-----------------------------------------------------------
# ホストの種類を
#-----------------------------------------------------------
sub HostType{

my($use) = @_;
my(%self);

	# 必須値の確認
	if(!exists $use->{'Host'}){	die("Perl Die!  Host value is empty."); }
	if(!defined $use->{'Host'}){ return(); }

# Near State （呼び出し） 2.20
my $StateName1 = "HostType";
my $StateKey1 = $use->{'Host'};
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

	# 携帯のホスト
	if($use->{'Host'} =~ /\.(docomo\.ne\.jp)/){ $self{'mobile_id'} = "DOCOMO"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(ezweb\.ne\.jp)$/){ $self{'mobile_id'} = "AU"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(softbank\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(vodafone\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(jp-([dnrtcknsq]+)\.ne\.jp)$/){ $self{'mobile_id'} = "SOFTBANK"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(e-mobile\.ad\.jp)$/){ $self{'mobile_id'} = "EMOBILE"; $self{'type'} = "Mobile"; }
	elsif($use->{'Host'} =~ /\.(ppp\.prin\.ne\.jp)$/){ $self{'mobile_id'} = "WILLCOM"; $self{'type'} = "Mobile"; }

	# 検索携帯ツール
	elsif($use->{'Host'} =~ /(\.search\.tnz\.yahoo\.co\.jp$|\.mobile\.ogk\.yahoo\.co\.jp$|-out-f136\.google\.com$)/){
		$self{'mobile_id'} ="MOBILE";
	}

	# 携帯のフルブラウザ
	#elsif($use->{'Host'} =~ /\.au-net\.ne\.jp$/){ $self{'special_allow_gethostbyname_flag'} = 1; }
	elsif($use->{'Host'} =~ /\.pcsitebrowser\.ne\.jp|\.ppp\.prin\.ne\.jp$/){ $self{'special_allow_gethostbyname_flag'} = 1; $self{'type'} = "MobileFullBrowser"; }

	# Bot のホスト
	elsif($use->{'Host'} =~ /\.(crawl\.yahoo\.net|googlebot\.com|msn\.com|super-goo\.com)$/){ $self{'type'} = "Bot"; }
	elsif($use->{'Host'} =~ /^(rate-limited-proxy-(\d+)-(\d+)-(\d+)-(\d+)\.google.com$)/){ $self{'type'} = "Bot"; }
	elsif($use->{'Host'} =~ /\.(baidu\.com|baidu\.jp|hinet\.net|naver\.com)$/){ $self{'type'} = "Bot"; }

	# 共通の全員のプロクシ
	elsif($use->{'Host'} =~ /\.au-net\.ne\.jp$/){ $self{'type'} = "SmartPhone"; }

	# Near State （保存） 2.10
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%self); }

return(\%self);

}

#-----------------------------------------------------------
# Who is でアドレスを検索
#-----------------------------------------------------------
sub whois_nic{

# 宣言
my($use) = @_;
my(%self);

	# 必須値のチェック
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr is empty."); }
	if(!defined $use->{'Addr'}){ return(); }

	# IPアドレスが変な場合
	if(!Mebius::AddrFormat({ Addr => $use->{'Addr'} })){ return(); }

# Who is のページを取得		
my($source) = Mebius::getpage("Source","http://whois.nic.ad.jp/cgi-bin/whois_gw?type=&key=$use->{'Addr'}&lang=");
$self{'source'} = $source;

	# Who is サイトがメンテナンス中の場合
	# SSS => 本当はステータスコードを取得したい
	if($source =~ /メンテナンス中/){
		$self{'mente_flag'} = 1;
	}

	# 最終更新日時をゲット
	# who is の該当情報があった場合、IPアドレスを自動的に許可、ファイルを更新する、管理者にメールを送信
	if($source =~ /\Qネームサーバ\E|組織名/ && $source !~ /baidu|Asia|SAKURA\-NET/i){
		$self{'allow_flag'} = 1;
	}

	# 最終更新日時を判定
	if($self{'source'} =~ m! \[最終更新]\ ([\s\t]+)? (\d{4})/(\d{2})/(\d{2})!x){
		my $year = $2;
		my $month = $3;
		my $day = $4;
		my($time) = Mebius::TimeLocal(undef,$year,$month,$day);

			# あまり昔に更新されているIPは許可しない
			if($time < time - (5*365*24*60*60)){
				$self{'allow_flag'} = 0;
			}
	}
	# 最終更新日時が取得できない場合は許可しない
	else{
		$self{'allow_flag'} = 0;
	}

return(\%self);


}

#-----------------------------------------------------------
# sub Isp の別名
#-----------------------------------------------------------
sub get_isp_by_host{
Isp(undef,$_[0]);
}

#-----------------------------------------------------------
# ホスト名からISPを取得
#-----------------------------------------------------------
sub Isp{

# 宣言
my($type,$host) = @_;
my($isp,@isp,$isp_fook,$i,$hit_flag,$second_domain,$top_level_domain);

	# ローカル
	if(Mebius::alocal_judge() && $host eq "YUMA-PC"){ return($host); }

# ホスト名が短い場合はリターン
if(length($host) < 5){ return(); }

	@isp = (split/\./,$host);

	# xxx.jp など、短い形式の場合は、ホスト名をそのまま返す
	if(@isp <= 2){ return($host,$host,$isp[-1]); }

	# ホスト名を展開
	foreach(@isp){
		$i++;
			if(!$hit_flag){
					if($i == 1){ next; }
					if($_ =~ /^(\d+)$/){ next; }
					if($_ =~ /([0-9]{3,})/){ next; }
			}
		$hit_flag = 1;
		if(defined($isp_fook)){ $isp_fook = join "." , ($isp_fook,$_); }
		else{ $isp_fook = $_; }
	}

	# ISP を定義
	if($isp_fook){
		$isp = $isp_fook;
	}
	else{
		if(@isp >= 2){ $isp = "$isp[-2].$isp[-1]"; }
	}

	# セカンドドメインを定義
	if($isp[-2] && $isp[-1]){ $second_domain = "$isp[-2].$isp[-1]"; }

	# 主ドメインを定義
	if($isp[-1]){ $top_level_domain = "$isp[-1]"; }

	if($type =~ /Print-view/){
		print qq($host<br$main::xclose> > $isp<br$main::xclose><br$main::xclose>);
	}

	if(wantarray){
		return($isp,$second_domain,$top_level_domain);
	} else {
		return $isp;
	}
}

#-----------------------------------------------------------
# ホスト名 / IPアドレスの適正チェック
#-----------------------------------------------------------
sub HostCheck{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$host,$addr,$isp,$second_domain) = @_;
my($alert_domain_flag,%isp_data,%second_domain_data);

#if($main::alocal_mode){ $addr = "198.54.202.70"; $host = "cc.dd.pl"; $isp = "dd.pl"; $second_domain = "dd.pl"; }

	# 警告ドメインかどうかを判定
	if($host && $host !~ /(\.jp)$/){
		(%isp_data) = Mebius::penalty_file("Isp Get-hash",$isp);
		(%second_domain_data) = Mebius::penalty_file("Second-domain Get-hash",$second_domain);
			if(!$isp_data{'allow_host_flag'} && !$second_domain_data{'allow_host_flag'}){
				$alert_domain_flag = 1;
			}
	}

	# IPアドレスが変な場合
	if($addr !~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
		$main::e_access .= qq(▼IPアドレスが取得できません。（ $basic_init->{'mailform_link'} ）<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","IPアドレス制限 : $addr");
		Mebius::AccessLog(undef,"Deny-ip-address","IPアドレス制限： $addr");
	}

	# ホスト名が取得できない場合
	elsif(length($host) < 5 && $type !~ /Not-empty-check/){

		$main::e_access .= qq(▼ホスト名が取得できません。（ $basic_init->{'mailform_link'} ）<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","ホスト名取得できず： IP - $addr / Host - $host");
		Mebius::AccessLog(undef,"Deny-hostname","ホスト名取得できず： IP - $addr / Host - $host");
	}

	# ホスト名がドメインの形式でない場合
	elsif($host !~ /\.([a-zA-Z]{2,4})$/ && $host){
		$main::e_access .= qq(▼ホスト名がうまく取得できません。（ $basic_init->{'mailform_link'} ）<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","ホスト名の形式が変： $host");
		Mebius::AccessLog(undef,"Deny-hostname","ホスト名の形式が変： $host");
	}

	# ホスト名がツール/プロクシっぽい場合
	elsif($alert_domain_flag){
			#	&& !$main::k_access && $host =~ /(proxy|^tor|\.tor([0-9+])?|^anony|\.anony|^unknown|\.telenet|\.(arpa|local)$)/
		$main::e_access .= qq(▼この接続元は使えません。（ $basic_init->{'mailform_link'} ）<br>);
		Mebius::AccessLog(undef,"Deny-axscheck","ホスト名制限： $host");
		Mebius::AccessLog(undef,"Deny-hostname","ホスト名制限： $host");
		Mebius::AccessLog(undef,"Foreign-post","海外ドメイン制限： $isp \n 管理： $basic_init->{'admin_url'}main.cgi?mode=cdl&file=$isp&filetype=isp");
	}

	# 海外のホスト名の場合
	elsif($host =~ /\.(br|cn|de|it|il|in|lu|lv|ru|tw|ua)$/){
		$main::a_com .= qq(▼海外からの書き込みですか？<br$main::xclose>);
	}

return($alert_domain_flag);

}

#-----------------------------------------------------------
# 自分のIPアドレス
#-----------------------------------------------------------
sub my_addr{

	if(addr_format_error_check($ENV{'REMOTE_ADDR'})){
		;
	} else{
		$ENV{'REMOTE_ADDR'};
	}

}

#-----------------------------------------------------------
# IPアドレスの書式チェック
#-----------------------------------------------------------
sub addr_format_error_check{

my($error) = AddrFormat({ Addr => $_[0] , TypeReturnErrorFlag => 1 });

$error;

}

#-----------------------------------------------------------
# ホスト名のフォーマット
#-----------------------------------------------------------
sub AddrFormat{

# 宣言
my($use) = @_;
my($justy_flag,$error_flag);

	# 必須の値
	if(!exists $use->{'Addr'}){ die("Perl Die!  Addr value is empty."); }

	# 正誤チェック
	if(defined $use->{'Addr'}){
			if($use->{'Addr'} =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/){

				$justy_flag = 1;
			}	elsif($use->{'Addr'} =~ /^([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4}):([0-9a-z]{1,4})$/){
#2401:fa00:4:fd00:9905:4853:bbbd:a3a3

				$justy_flag = 1;
			}


			else{
				$error_flag = 1;
			}
	}
	else{
			$error_flag = 1;
	}

	# リターン
	if($use->{'TypeReturnErrorFlag'}){

		return($error_flag);
	}
	else{
		return($justy_flag);
	}

}



#-----------------------------------------------------------
# IPアドレスのフォーマット
#-----------------------------------------------------------
sub HostFormat{

# 宣言
my($use) = @_;
my($error_flag,$justy_flag);

	# 必須の値
	if(!exists $use->{'Host'}){ die("Perl Die!  Host value is empty."); }

	# 正誤チェック
	if(defined $use->{'Host'}){
			# Second Level Domain は 「英数字」と「ハイフン」で構成される
			if($use->{'Host'} =~ /^([a-zA-Z0-9\.\-]+\.)?([a-zA-Z0-9\-]+?)\.([a-zA-Z]{2,4})$/){
				$justy_flag = 1;
			}
			elsif(Mebius::alocal_judge() && $use->{'Host'} =~ /^([a-zA-Z0-9\-]+)$/){
				$justy_flag = 1;
			}
			else{
				$error_flag = 1;
			}
	}
	else{
			$error_flag = 1;
	}

	# リターン
	if($use->{'TypeReturnErrorFlag'}){
		return($error_flag);
	}
	else{
		return($justy_flag);
	}

}



#-----------------------------------------------------------
# IP アドレス用ファイル ( フラグを立てる処理のため、とりあえずサブルーチン内の途中では return しない )
#-----------------------------------------------------------
sub AddrFile{

# 宣言
my($use,$addr,$select_renew) = @_;
my($i,@renew_line,%data,$FILE1,%renew);

	# IPアドレスが変な場合
	if(!Mebius::AddrFormat({ Addr => $addr })){ return(); }

# エンコード
my($encaddr) = Mebius::Encode(undef,$addr);

# ファイル定義
my($init_directory) = Mebius::BaseInitDirectory();
my $directory1 = "${init_directory}_hostname/";
my $file1 = "${directory1}${encaddr}_hostname.log";

	# ディレクトリ作成
	if($use->{'TypeRenew'} && (rand(100) < 1 || Mebius::alocal_judge())){
		Mebius::Mkdir(undef,$directory1);
	}

	# ファイルを開く
	if($use->{'FileCheckError'}){
		$data{'f'} = open($FILE1,"+<",$file1) || main::error("ファイルが存在しません。");
	}
	else{

		$data{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合は新規作成
			if(!$data{'f'} && $use->{'TypeRenew'}){
				Mebius::Fileout("Allow-empty",$file1);
				$data{'f'} = open($FILE1,"+<$file1");
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'Flock'}){ flock($FILE1,2); }

# トップデータを取得
	# トップデータを展開
	for(1..2){
		chomp($data{"top$_"} = <$FILE1>);
	}

# トップデータを分解	( ※ empty_key = 使っていないキー )
($data{'host'},$data{'allow_key'},undef,$data{'last_deny_allow_time'},$data{'last_get_whois_time'},$data{'last_gethostbyaddr_time'}) = split(/<>/,$data{'top1'});
($data{'gethostbyname'},$data{'first_time'},$data{'last_time'},$data{'whois_allowed_time'},$data{'last_get_whois_but_mente_time'}) = split(/<>/,$data{'top2'});

	# 更新用に内容を記憶しておく
	if($use->{'TypeRenew'}){ %renew = %data; }

	# ファイル更新
	if($use->{'TypeRenew'}){

		# 情報を自動更新
			if(!$data{'first_time'}){ $renew{'first_time'} = time; }
		$renew{'last_time'} = time;

			# 指定のデータを更新
			my($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# トップデータを追加
		push(@renew_line,"$renew->{'host'}<>$renew->{'allow_key'}<><>$renew->{'last_deny_allow_time'}<>$renew->{'last_get_whois_time'}<>$renew->{'last_gethostbyaddr_time'}<>\n");
		push(@renew_line,"$renew->{'gethostbyname'}<>$renew->{'first_time'}<>$renew->{'last_time'}<>$renew->{'whois_allowed_time'}<>$renew->{'last_get_whois_but_mente_time'}<>\n");

		# ファイル更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;

	}

close($FILE1);

	# パーミッション変更
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$file1);
	}

	# ●フラグを立てる ( これ以前の処理で return してしまうと必要なフラグが立てられなくなるので注意 )
	if($use->{'TypeGetFlag'}){

		# フラグ
		my(%flag);

		# Who is 許可のキープ期間
		my $whois_keep_allow_term = 30*24*60*60;

			# ▼ホスト名が逆引きできない場合も、投稿を許可するフラグ (A-1)
			# => 管理者が手動で許可している場合
			if($data{'allow_key'} eq "1"){ $flag{'special_allow'} = 1; }
			# => 前回 Who is で逆引きして、成功判定がされている場合
			elsif($data{'whois_allowed_time'} && time < $data{'whois_allowed_time'} + $whois_keep_allow_term){ $flag{'special_allow'} = 1; }

			# ▼今回のWho is 検索を許可するフラグ (A-2)
			# => 管理者によって禁止されていない、なおかつ現在は許可期限内ではないことが最低条件 ( 負荷軽減のため )
			if($data{'allow_key'} ne "0" && !$flag{'special_allow'}){
					# 前回がメンテナンス中などで先送りした場合、比較的短い時間で再検索する
					if($data{'last_get_whois_but_mente_time'} && time >= $data{'last_get_whois_but_mente_time'} + (6*24*24)){ $flag{'allow_get_whois'} = 1; }
					# 前回のWhois検索から一定時間が経過している場合
					elsif(!$data{'last_get_whois_time'} || time > $data{'last_get_whois_time'} + $whois_keep_allow_term){
						$flag{'allow_get_whois'} = 1;
					}
			}

			# IPアドレス照合
			if($data{'gethostbyname'} && $data{'host'} && $addr eq $data{'gethostbyname'} && Mebius::HostFormat({ Host => $data{'host'} }) ){ $flag{'trusted_host'} = 1; }

			# ハッシュを結合
			$data{'Flag'} = \%flag;

	}

return(\%data);

}



1;
