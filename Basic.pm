
use strict;

# 宣言
#use Apache::DBI;
use Compress::Zlib; 
#use Mebius::Report;
use Mebius::Status;
use Mebius::Utility;
use Mebius::Template;
use Mebius::Auth;
use Mebius::Admin;
use Mebius::CerEmail;
use Mebius::Parts;
use Mebius::Gaget;
use Mebius::Reason;
use Mebius::Report;
use Mebius::Encoding;
use Mebius::RegistCheck;
use Mebius::Regist;
use Mebius::IventDay;
use Mebius::UsersTag;
use Mebius::Linux;
use Mebius::Base::DBI;
use Mebius::Mobile;
#use Mebius::Flag;
use Mebius::Operate;
use Mebius::Hostbyaddr;
use Mebius::DosDBI;
use Mebius::Switch;
use Mebius::Base::DBI;
use Mebius::BBS::Status;
use Mebius::Follow;
use Mebius::Javascript;
use Mebius::Question;
use Mebius::Server;
use Mebius::Roop;
use Encode::Guess;

use Encode qw();
use Mebius::SNS;
package main;
use Mebius::Export;
use DBI;


#-----------------------------------------------------------
# デコード処理・基本調整処理 
#-----------------------------------------------------------
sub decode{


# 全ての変数を初期化 ( 重要 )
reset 'a-z';

# umaskを設定
umask(0070);

# モジュールの全変数を初期化 ( 重要 )
Mebius::State::AllReset();
Mebius::Roop::all_reset();

	# デバッグ用に %ENV を変更 ( ローカル )
	if(Mebius::alocal_judge()){
			Mebius::Debug::OverWriteENV();
	}

	# ローカルで全テーブルを作成
	#if(Mebius::alocal_judge()){
	#	Mebius::DBI->create_all_tables();
	#}

# 宣言
my($type,undef,$init,$init2,undef,$base_server_domain2) = @_;
my($init_start,$start);

our($secret_mode,$mobile_test_mode,$getaccess_mode);
our($moto,$category,$kflag,$thisyear,%in);
our($mode,$submode1,$submode2,$submode3,$submode4,$submode5) = undef;
our($age,$agent,$realagent,$cookie,$addr,$referer,$requri,$scriptname,$device_type) = undef;
our($k_access,$kaccess_one,$bot_access,$bot_access2) = undef;
our($chandle,$cmtrip,$base_server_domain) = undef;
our($topics_line_reshistory,$one_line_reshistory,$follow_line) = undef;
if($init){ $init_start = "init_start_${init}"; $start = "start_$init"; }
if($init2){ $init_start = "${init2}::init_start_${init}"; $start = "${init}::start_$init"; }

	# ドメイン定義
	our($server_domain) = Mebius::server_domain();
	$base_server_domain = $base_server_domain2;

# メンテなど
$mobile_test_mode = 0;

	# 大設定ディレクトリを定義
	our($int_dir) = Mebius::BaseInitDirectory("$type");

	# 処理タイプを定義
	if(Mebius::alocal_judge()){ our $alocal_mode = 1; }

# 全ての共通設定を取り込み ( グローバル変数 )
init_defult($type);

# ● EVN チェク
Mebius::ENV::WrongCheck();

# 時刻を取得
my($date_multi) = Mebius::now_date_multi();
our $time = time;
our $thismonth = $date_multi->{'month'};
our $today = $date_multi->{'day'};
our $thishour = $date_multi->{'hour'};
our $thismin = $date_multi->{'minute'};
our $thissec = $date_multi->{'second'};
#our $thiswday = $date_multi->{'weekday'};
our $thismonthf = $date_multi->{'monthf'};
our $todayf = $date_multi->{'dayf'};
our $thishourf = $date_multi->{'hourf'};
our $thisminf = $date_multi->{'minutef'};
our $thissecf = $date_multi->{'secondf'};
our $date = $date_multi->{'date_till_minute'};
our $thisyear = $date_multi->{'year'};
our $thisyearf = $date_multi->{'yearf'};

# 環境変数などを取得
our($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc,%env) = get_env_decode(undef,$type);
$realagent = $age = $agent;

# クッキーゲット（全体）
my($main_cookie) = Mebius::my_cookie_main_logined();
our($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account,undef,undef,undef) = Mebius::Cookie::hash_to_array_main(%$main_cookie);

# アクセスタイプ判定
my($access) = Mebius::my_access();
our $agent = $access->{'multi_user_agent'};
our $k_access = $access->{'mobile_id'};
our $kaccess_one = $access->{'mobile_uid'};

# デバイスタイプを取得
my($use_device) = Mebius::my_use_device();
our %device = %$use_device;
our $device_type = $use_device->{'browse_type'};

# リアルデバイス情報を取得
my($real_device) = Mebius::my_real_device();
our %real_device = %$real_device;
our $bot_access = $real_device->{'bot_flag'};
our $sikibetu = $real_device->{'utn'};

# HTMLパーツを取得
our($parts) = Mebius::Parts::HTML(undef);
our(%parts) = %$parts;
our($checked,$selected,$disabled) = undef;
our $checked = $parts{'checked'};
our $selected = $parts{'selected'};
our $disabled = $parts{'disabled'};

	# 携帯版のパーツを取得
	if($use_device->{'type'} eq "Mobile"){
		&kget_items();
	}

# XIPを取得 ( 環境変数取得のあと )
our($xip,$xip_enc,$no_xip_action) = &get_xip($addr,$agent,$k_access);

	# デコード処理
	if($type !~ /Not-indecode/){ &indecode(undef,$type); }

# 各種データを取得
my($myaccount) = Mebius::my_account();
	if($myaccount->{'login_flag'}){ our %myaccount  = %$myaccount; }

	# クッキーの調整 ( アカウントデータ取得のあと )
	($chandle,$cmtrip) = split(/#/,$cnam);
	if($csecret eq "1" || $csecret eq "2"){ $csecret = undef; }
	$cnumber =~ s/\W//g;
	if(length($crireki) >= 5){ $crireki = undef; }
	if($crireki eq "2"){ $crireki = "off"; }
	if($k_access && !$cookie){ our $chowold = 18; }
	elsif($cage){ our $chowold = $thisyear - $cage; }

	# 戻り先URLを取得
	if($referer || $in{'backurl'}){
		require "${int_dir}part_backurl.pl";
		get_backurl("",$in{'backurl'});
	}

	if($device_type eq "mobile"){ $main::kflag = 1; }

	# プログラムタイプごとの基本設定を取り込み
	if($type !~ /Not-init-start/){
		#	if($init){ &$init_start(); } elsif(defined(&init_start)) { &init_start(); } # no strict な書き方
			if($init){
				eval "\&$init_start()";
			} elsif(defined(&init_start)) {
				&init_start();
			}
	}

# モード定義
$mode = $in{'mode'};
($submode1,$submode2,$submode3,$submode4,$submode5) = split(/-/,$mode);

	# モードを展開
	foreach(split(/-/,$mode,-1)){
		$main::submode_num++;
	}

	# DOS攻撃をチェック ( 何故この位置で実行？ より前の処理のほうが、確実に実行されるはず )
	{
		Mebius::Dos::access();
	}

	# 拒否IP
	if($ENV{'REMOTE_ADDR'} =~ /^(50\.63\.138\.34)$/){
		Mebius::AccessLog(undef,"Bad-IP-and-Access-Block");
		die("Perl Die! $ENV{'REMOTE_ADDR'} is Bad IP.");
	}

	# スラッシュ２個以上のURLは正規化
	#redirect_double_slash_url();
	if($ENV{'REQUEST_URI'} =~ /\/\// && $ENV{'REQUEST_METHOD'} ne "POST"){
		# ドメインを取得
		my($server_domain) = Mebius::server_domain();
		(my $redirect_url = $ENV{'REQUEST_URI'}) =~ s!/{2,}!/!g;
			if($main::bot_access){ Mebius::AccessLog(undef,"Slash-url-bot"); }
			else{ Mebius::AccessLog(undef,"Slash-url"); }
		Mebius::Redirect("301","http://$server_domain$redirect_url");
	}

	# https は正規化
	if($ENV{'REQUEST_URI'} !~ m!/jak/! && Mebius::procotol_type() eq "https"){

		my($request_url) = Mebius::request_url();
		$request_url =~ s/^https/http/g;

		Mebius::redirect($request_url,301);
		exit;
	}


	# 特定外部サイトからの訪問
	if($ENV{'HTTP_REFERER'} =~ /^http:\/\/(www\.)?(ime\.nu|ime\.st)\//){
		require "${int_dir}part_enemysite.pl";
		from_enemysite(undef,$referer);
	}

	# 変な環境変数
	if($ENV{'REQUEST_METHOD'} ne "POST" && $ENV{'REQUEST_METHOD'} ne "GET" && $ENV{'REQUEST_METHOD'} ne "HEAD"){
		Mebius::AccessLog(undef,"Strange-request-method","\$ENV{'REQUEST_METHOD'} ： $ENV{'REQUEST_METHOD'}");
	}

	# スタート前の処理 
	if(defined(&before_start)){ &before_start(); }

	if($ENV{'REQUEST_METHOD'} eq "GET" && rand(100) < 1){
			my($my_account) = Mebius::my_account();
				if($my_account->{'login_flag'}){
					Mebius::HistoryAll("RENEW My-file");
				}
	}

	# 処理スタート
	if($init){
		eval "\&$start()";
	} elsif(defined(&start)) {
		&start();
	}

}

#-----------------------------------------------------------
# 共通の初期設定
#-----------------------------------------------------------
sub init_defult{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type) = @_;
my(%basic);
my($init_directory) = Mebius::BaseInitDirectory();
our($backurl,$no_headerset,$error_done,$headflag,$moto,$lock_dir,$k_access,$kaccess_one,$mente_mode,$script,%backup_directory);

# サーバードメインを取得
my($server_domain) = Mebius::server_domain();

# バックアップ
our @backup_directory_number = ("1","15");
	foreach(@backup_directory_number){
			$backup_directory{$_} = "/var/www-backup$_/web_data/";
	}

# メンテ / テストモード
$mente_mode = 0;
if($mente_mode){ require "${init_directory}part_mente.pl"; &all_mente(); } 
our $getaccess_mode = 0;

# 投稿ストップモード
	if(Mebius::Switch::stop_bbs()){
		our $stop_mode = "BBS";
	}

# 外せない初期設定
our $dirpms = 0707;
our $logpms = 0606;

our $jak_dir = $basic_init->{'jak_directory'};
our $pct_dir = "/pct/";

if($script eq ""){ $script = "./"; }
our $lockkey = 1;


our $home = "http://aurasoul.mb2.jp/";
#our $mailform = $basic_init->{'mailform_link'};
our $auth_url = $basic_init->{'auth_url'};
our $paint_url = "/paint/";
our $paint_dir = $basic_init->{'paint_dir'};

our $gold_url = "/_gold/";

our @domains = ("aurasoul.mb2.jp","mb2.jp");
my($all_domains) = Mebius::Init::AllDomains();
our(@all_domains) = (@$all_domains);
our $goraku_url = 'http://mb2.jp/';

	# 大ドメイン再定義
	if($main::base_server_domain eq ""){
		$main::base_server_domain = $server_domain;
	}

	# メインURLの補足
	if($server_domain eq $main::base_server_domain){
		$main::main_url = "http://$main::base_server_domain/_main/";
	}
	else{
		$main::main_url = "http://$main::base_server_domain/_main/";
	}

our $jak_url = $basic_init->{'admin_url'};
our $jak_paint_url = "${jak_url}paint/";

our $door_url = "http://mb2.jp/_main/";
our $base_url = 'http://aurasoul.mb2.jp/';
our $home = $base_url;
our $guide_url = $basic_init->{'guide_url'};
our $hometitle = "メビウスリング掲示板";

our $qst_url = "http://aurasoul.mb2.jp/_qst/";
our $delete_url = $basic_init->{'report_bbs_url'};

# 管理者(マスター)のIP/ホスト名
#our $master_addr = "119.239.40.136";
our $master_addr = $basic_init->{'master_addr'};
	#if($master_addr eq $ENV{'REMOTE_ADDR'}){ $basic{'master_addr_flag'} = 1; }
our(@master_hosts);
push(@master_hosts,".osk.mesh.ad.jp");
push(@master_hosts,".tky.mesh.ad.jp");
push(@master_hosts,".rev.home.ne.jp");
push(@master_hosts,".au-net.ne.jp");

	# ローカル設定
	if(Mebius::alocal_judge()){
		$lock_dir = "${init_directory}_lock/";
		#$jak_url = "/cgi-bin/patio/admin/";
		$jak_paint_url = "/paint/";

		$jak_url = "$basic_init->{'admin_http'}://$server_domain/jak/";
		push(@domains,"localhost");
		$master_addr = "127.0.0.1";
		push(@master_hosts,"localhost",".localhost.jp","YUMA-PC");
			foreach(@backup_directory_number){
				$backup_directory{$_} = "${init_directory}bkup$_/";
			}

	}

}

#-----------------------------------------------------------
# 環境変数のチェック
#-----------------------------------------------------------
sub get_env_decode{

# 宣言
my($type,$basic_type) = @_;
my($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc);
our($k_access,$mobile_test_mode,$host,$server_domain);

# 環境変数を取得
$agent = $ENV{'HTTP_USER_AGENT'};
$cookie = $realcookie = $ENV{'HTTP_COOKIE'};
$addr = $ENV{'REMOTE_ADDR'};
$requri = $ENV{'REQUEST_URI'};
$referer = $ENV{'HTTP_REFERER'};
$scriptname = $scriptdir = $ENV{'SCRIPT_NAME'};

# 環境変数を整形
$scriptname =~ s/(.+?)([a-zA-Z0-9_]+)\.([a-zA-Z]{2,3})$/$2\.$3/g;
$scriptname =~ s/(\.\.|\/)//g;
#if($moto eq ""){ $moto = $scriptname; $moto =~ s/(_|\.)([a-zA-Z0-9]+)//g; $realmoto = $moto; $moto =~ s/^sub//; }

if($referer){ ($referer) = ($referer); }
if($agent){ ($agent) = Mebius::escape("",$agent); }
($addr) = Mebius::escape("",$addr);
if($requri){ ($requri) = Mebius::escape("NOTAND",$requri); }

my(%env) = Mebius::Env("Get-proxy-only");

	# 不正なＵＲＬを禁止
	if($requri =~ m!(/actbbs/|/cgi-bin/)! && $basic_type !~ /Allow-natural-url/ && !Mebius::alocal_judge()){ Mebius::AccessLog(undef,"Actbbs-access"); &error("このページは存在しません。"); }

	# 自サーバーからのアクセスを記録
	foreach(@main::server_addrs){
		if($addr eq $_){ Mebius::AccessLog(undef,"Server-self"); }
	}


	# 現在のＵＲＬを定義
	if($server_domain && $requri){
		$selfurl = "http://$server_domain$requri";
		$selfurl_enc = Mebius::Encode("",$selfurl);
	}

# リターン
return($moto,$realmoto,$addr,$agent,$cookie,$realcookie,$referer,$requri,$scriptname,$scriptdir,$selfurl,$selfurl_enc,%env);

}


#-----------------------------------------------------------
# デコード処理
#-----------------------------------------------------------
sub indecode{

# 宣言
my($type,$relay_type) = @_;
my($buf,@query_key,@query_value,%query,$multi_part_flag);
my($convert_from);
my($q) = Mebius::query_state();
my($init_directory) = Mebius::BaseInitDirectory();
my $query = new Mebius::Query;
our($postbuf,$postbuf_query,$no_headerset);
our($postflag,$postbuf_query_esc,$upload_flag,$query_string,$content_length) = undef;

# 変数を初期化
undef(our %in);
undef(our %ch);
undef(our %query_not_escaped);

# CGI.pm を積極的に使うかどうか
my $UseEncoding = 1;

	# アップロード軽視の場合
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/){
		$multi_part_flag = 1;
	}


	# データ受け取り
	{
		require "${init_directory}part_upload.pl";
		$query_string = $q->query_string();
	}

	# データ受け取り
	if($ENV{'REQUEST_METHOD'} eq "POST") {
		$postflag = 1;
	}

	# CGI.pm を使う場合
	foreach($q->param()){
		$query{$_} = $q->param($_);
			if($UseEncoding){ push(@query_value,$query{$_}); }
		push(@query_key,$_);
	}

	# 文字コード判定
	if($UseEncoding){
		($convert_from) = Mebius::Encoding::all_queries_guess();
	}

my $encode_is_utf8 = $query->selected_encode_is_utf8();

	# クエリ展開
	foreach(@query_key){

		# 局所化
		my $key = $_;
		my $val = $query{$_};

			# アップロードファイルがある場合
			if($multi_part_flag){
				if($key eq "upfile" && $val){ $upload_flag = 1; next; }
			}

			# コード変換 ( 型グロブで変換する変数を指定している )
			if($UseEncoding){
					if($encode_is_utf8){
						shift_jis($val);
					} elsif($val && $convert_from){
						Mebius::Encoding::from_to($convert_from,"shift_jis",$val);
					}
			}


		# エスケープ前のクエリを記憶する
		$query_not_escaped{$key} = $val;

		# エスケープ
		my($value_escaped) = Mebius::escape("",$val);

		# 値を定義
		$in{$key} = $value_escaped;
		$ch{$key} = 1;

			if($postbuf){ $postbuf .= "&$key=" . (Mebius::Encode("",$value_escaped)); }
			else{ $postbuf = "$key=" . (Mebius::Encode("",$value_escaped)); }

	}

	# クエリ全体のエスケープ値を定義 
	($postbuf_query_esc) = Mebius::escape("",$postbuf);


}

#-------------------------------------------------
#  HTMLヘッダ
#-------------------------------------------------
sub header{

# 宣言
my $self = new Mebius;
my($type,$use) = @_;
if(ref $type eq "HASH"){ $use = $type; }
my $history = new Mebius::History;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($cssfile,$css_fontsize,$now_url_box,$length,$help_area,$google_header_form,$linkprof,);
my($google_selected1,$bbs_google_find,$head_message1,$head_message2,$bcl_top_link);
my($google_search_submit_title,$sorcial_line,$topics_area,%use_history,$ivent_html,$print,$header,$google_ie,$topics_line_reshistory,$topics_line_reshistory,$account_navigation);

# グローバル変数
our($backurl,$thisis_bbstop,$headflag,$server_domain,$postflag,$google_oe,$thisis_toppage,%in);
our($title,$cfollow,$ccount,$csecret,$follow_line,$nosearch_mode,$no_headerset);
our($k_access,$postbuf);
our($thismonth,$thishour,$today,$moto,$concept,$bot_aceess,$door_url,$home,$one_line_reshistory,$bot_access);

my $mebius = new Mebius;
my($param) = Mebius::query_single_param();
my($init_directory) = Mebius::BaseInitDirectory();
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my $html = Mebius::HTML->new();

# 各種データを取得
my($myaccount) = Mebius::my_account();

	# スマフォ振り分け
	if($my_real_device->{'smart_flag'}){
		$google_search_submit_title = qq(検索);
	}
	else{
		$google_search_submit_title = qq(Google 検索);
	}


	# ヘッダの重複処理を禁止
	if($headflag){ return; }
$headflag = 1;

$topics_line_reshistory = $history->new_system_topics();

	# フォローを取得
	if(!Mebius::Admin::admin_mode_judge() && !Mebius::Switch::light()){

			if($ENV{'HTTP_COOKIE'} && !$my_use_device->{'smart_flag'}){
				require "${init_directory}part_follow.pl";
			}

	}

	# クッキーが無い場合や、ある場合も一定確率で、閲覧だけでクッキーをセット
	if((!$ENV{'HTTP_COOKIE'} || rand(5) < 1 || Mebius::alocal_judge()) && !$no_headerset && $ENV{'REQUEST_METHOD'} eq "GET" && !$my_account->{'login_flag'}) {
		Mebius::Cookie::set_main();
	}

# ドキュタイプ／XHTML宣言
	if($my_use_device->{'mobile_flag'}){
		$print .= qq(<?xml version="1.0" encoding="shift_jis"?>\n);
		$print .= qq(<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.0//EN" "http://www.wapforum.org/DTD/xhtml-mobile10.dtd">\n);
		$print .= qq(<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">\n);
	} else {
		$print .= qq(<!DOCTYPE html>\n);
		$print .= qq(<html lang="ja">\n);
	}

# ヘッダ部分を定義
$print .= $mebius->between_head_tag($use);

	# Body タグの Javascript
	my $body_javascript;
	if($use->{'BodyTagJavascript'}){ $body_javascript = $use->{'BodyTagJavascript'} ; }
	elsif($main::body_javascript){
		$body_javascript = $main::body_javascript;
		utf8($body_javascript);
	}

	if($my_real_device->{'id'} eq "iPhone" || $my_real_device->{'id'} eq "iPod"){ $body_javascript = ""; }

$print .= qq(<body$body_javascript id="body_top">);

#$print .= qq(<div style="position:fixed; top:0px; left:0px; width:100%; height:16px; padding:4pt;background-color:gold; text-align:center;">↑上辺に固定</div>);
#$print .= qq(<div style="height:32px;"> </div>);


	if($my_use_device->{'mobile_flag'}){
		$print .= mobile_header_navigation();
	}

	# 掲示板毎の検索セレクト部分、初期チェックを決定
	if($thisis_toppage || $nosearch_mode || $type =~ /Not-search-me/){ $google_selected1 = " selected"; }
	else{
		my($domain,$search_title,$search_domain);
			if($my_real_device->{'smart_flag'}){ $search_title = "コンテンツ"; }
			elsif( my $site_title = $use->{'site_title'}){ $search_title = $site_title; }
			else{ $search_title = $main::title; utf8($search_title); }

			if( $search_domain = $use->{'search_domain'}){
				$domain = $search_domain;
			} else{
				$domain = "mb2.jp";
			}

			if($moto eq "auth"){ $bbs_google_find = qq(<option value="sns.mb2.jp" selected>$search_title</option>); }
			elsif($search_domain){ $bbs_google_find = qq(<option value="$search_domain" selected>$search_title</option>); }
			elsif($server_domain =~ /^([a-z0-9+]\.mb2\.jp)$/){ $bbs_google_find = qq(<option value="$1" selected>$1</option>); }
			else{	$bbs_google_find = qq(<option value="$domain/_$moto" selected>$search_title</option>); }
	}

my $help_area = $self->all_page_navigation_links();

# Google検索窓


	if($use->{'source'} ne "utf8"){
		$google_ie = qq(<input type="hidden" name="ie" value="Shift_JIS">);
			if($ENV{'HTTP_USER_AGENT'} =~ /Firefox/){ $google_oe = undef; }
			else{ $google_oe = qq(<input type="hidden" name="oe" value="Shift_JIS">); }
	}

$google_header_form .= qq(
<form method="get" action="https://www.google.co.jp/search" class="nomargin">
<div class="google_bar">
<a href="https://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img" alt="Google"></a>
<span class="vmiddle">
<select name="sitesearch" class="site_select">);

	# スマフォ振り分け
	if($my_real_device->{'smart_flag'}){
		$google_header_form .= qq(<option value="mb2.jp"${google_selected1}>サイト全体</option>\n);
	}
	else{
		$google_header_form .= qq(<option value="mb2.jp"${google_selected1}>メビウスリング</option>\n);
	}

$google_header_form .= qq(
$bbs_google_find
<option value="">ウェブ全体</option>
</select>
<input type="$main::parts{'input_type_search'}" name="q" size="31" maxlength="255" value="" class="ginp">
<input type="submit" name="btnG" value="$google_search_submit_title">
$google_ie
$google_oe
<input type="hidden" name="hl" value="ja">
<input type="hidden" name="domains" value="mb2.jp">
</span></div>
<div class="help_block word-spacing">$help_area</div>
</form>
);

	# ヘッダリンクを定義
	# 投稿履歴からトピックスを表示
	if($my_use_device->{'mobile_flag'}){
		$print .= qq(<div style="font-size:x-small;background:#ffb;border-bottom:1px #000 solid;">$topics_line_reshistory</div>);
	}

	elsif(!Mebius::Admin::admin_mode_judge()){

			# ＵＲＬ表示を定義
			if($ENV{'REQUEST_URI'} && $ENV{'REQUEST_METHOD'} eq "GET"){

				my($url);
					if(length($ENV{'REQUEST_URI'}) <= 40){

						$url = "http://${server_domain}$ENV{'REQUEST_URI'}";
					}
				$length = int(length($url)/2);
					if($length > 50){ $length = 50; }

				# 整形
				$now_url_box .= qq(<input size="50" style="width:).e(${length}).qq(em;" type="text" value=").e($url).qq(" onclick="javascript:select();" class="nowurl" id="now_url_box">　);

			}
			else{ $now_url_box = qq(&nbsp;); }


			if($topics_line_reshistory && !$use->{'SimpleSource'}){
				$topics_area .= qq(<div class="topics_line">$topics_line_reshistory</div>);
			}
			else{
				$topics_area .= qq(<div class="topics_line_empty"></div>);
			}

			# 今日の早起きさん
			if($ENV{'HTTP_COOKIE'} || $k_access){
					if($thishour >= 5 && $thishour  <= 8){
				$head_message2 .= qq(<div style="text-align:center;width:85%;margin:0.5em auto 1.0em auto;font-size:90%;"><a href="http://aurasoul.mb2.jp/_early/">～$thismonth月$today日、早起きですか？～</a></div>);
					}
			}

			if($ENV{'HTTP_COOKIE'} && time < 1333217960 + (15)*60*60){
				$head_message2 .= qq(<div style="text-align:center;width:85%;margin:0.5em auto 1.0em auto;clear:both;"><a href="http://aurasoul.mb2.jp/wiki/guid/%A5%E1%A5%D3%A5%DE%A5%CD%A1%BC" class="blank" target="_blank">～懸賞に応募する～</a> <span class="red">New!</span></div>);
			}

			# ソーシャルボタン
			if($ENV{'REQUEST_METHOD'} eq "GET" && !$main::secret_mode && $type !~ /Not-sorcial-button/){
				$sorcial_line = $self->sorcial_navigation_line();
			}

			# パンくずリストの追加
		my $bcl_line .= $mebius->bcl_line($use);

			if($my_account->{'login_flag'}){
				my $sns = new Mebius::SNS;
				$account_navigation .= $sns->my_navigation_links_for_header();
			}

			# ●イベント
			my $tell_area;
			{
				($ivent_html) =Mebius::ivent_html();
				#$tell_area .= qq(<div class="red center">※メンテナンスにつき、掲示板への投稿を停止中です。再開\予\定…12/6 <strike>12:00</strike> 16:00 (延長の場合もあります)</div>);
					#if($ENV{'SERVER_ADDR'} eq "112.78.200.216" && time < 1368113906 + 24*60*60){
					#	$tell_area .= qq(<div class="guide green center">※お知らせの訂正…書き込み可\能\なまま、サーバー移転をおこないます。 <a href="http://aurasoul.mb2.jp/wiki/guid/2013.05+%A5%B5%A1%BC%A5%D0%A1%BC%B0%DC%C5%BE%A4%CE%A4%AA%C3%CE%A4%E9%A4%BB">→詳細</a></div>);
					#}
			}

		# ウェブページヘッダ領域の出力
		$print .= qq(<div class="bar">);

			# スマフォ板
			if($my_use_device->{'smart_flag'}){
				#$bcl_line =~ s/(\s+)?(&gt;)(\s+)?/$2/g;
				$print .= qq(<div class="scroll">);
				$print .= qq(<div class="help_block word-spacing">$help_area</div>);
				$print .= $ivent_html;
				$print .= $account_navigation;
				$print .= qq(</div>);

				$print .= qq(<div class="head_bar">);

				$print .= qq(<div class="link_box scroll"><nav class="inline scroll-element">$bcl_line</nav></div>);

				#$print .= qq(<div class="url_box"></div>);
				$print .= qq(</div>);

			}
			# デスクトップ版
			else{
				$print .= qq($google_header_form);
				$print .= qq(<div class="">$account_navigation</div>);
				$print .= $ivent_html;

				$print .= qq(<div class="head_bar">);
				$print .= qq(<div class="link_box"><nav>$bcl_line</nav></div>);
				$print .= qq(<div class="url_box">$now_url_box $sorcial_line</div>);
				$print .= qq(</div>);
			}


		$print .= qq($head_message1);
		$print .= qq(</div>);
		$print .= $tell_area;
		$print .= $topics_area;
		$print .= qq($head_message2);

	}



	# 管理モードのナビゲーションリンク
	if(Mebius::Admin::admin_mode_judge() && !$use->{'NotAdminNavigation'}){
		($print) .= Mebius::Admin::html_header_navigation();
	}

	# 整形用のDIVタグを自動出力
	$print .= qq(<div class="body1">);


	# アカウントを新規作成したばかり
	if($my_account->{'firsttime'} && time < $my_account->{'firsttime'} + 60*60){
		$print .= qq(<div class="message-yellow center">);
		$print .= qq(アカウントを新規登録しました。 ページ右上のリンク \( );
		$print .= $html->href($basic_init->{'auth_url'},"@".$my_account->{'id'});
		$print .= qq( \) からいつでもプロフィールにアクセスできます。);
		$print .= qq(</div>);
	}


$print;

}





#-----------------------------------------------------------
# 携帯版ヘッダ
#-----------------------------------------------------------
sub mobile_header_navigation{

our($kboad_link_select,$kboad_link,$kindex_link,$kauth_link,$plus_navilinks,$kmypage_link,$kback_link);
my $sns = new Mebius::SNS;

	# 引継ぎ値から戻りリンクを定義
	#if($over_backlink){
	#	$over_backlink =~ s/&/&amp;/g;
	#	$kback_link2 = qq( <a href="$over_backlink"$main::utn2>元</a>);
	#	$kback_link = qq( $emoji{'number7'}<a href="$over_backlink" accesskey="7"$main::utn2>元</a>);
	#}

	# ３番リンクを再定義
	if($kboad_link_select){ $kboad_link = $kboad_link_select; }

my $account_navigation .= $sns->my_navigation_links_for_header();

# ナビゲーションリンクを設定
# $kdw_link 
my $navilinks_header = qq(
<div style="padding-bottom:0.4em;font-size:x-small;border-bottom:solid #000 1px;">
$plus_navilinks $kindex_link $kboad_link
$kauth_link $kback_link $kmypage_link
$account_navigation
</div>
);


$navilinks_header;

}

no strict;


#-----------------------------------------------------------
# 携帯版のフッタ- no strict -
#-----------------------------------------------------------
sub mobile_footer_navigation{

# 宣言
my($use,$over_links) = @_;
my($over_backlink,$plus_navilinks,$middle_link) = split(/<>/,$over_links);
my($navilinks_footer,$nowurl_input,$nowurl_box,$print);
our($follow_line,$requri,$kboad_link_select2);

# ３番リンクを再定義
if($kboad_link_select2){ $kboad_link2 = $kboad_link_select2; }

	# オートフォロー
	if($follow_line){
		$print .= qq(<div style="background:#6dd;$ktextalign_center_in$kborder_top_in"><a id="AFOLLOW"></a>フォロー</div>);
		$print .= qq(<div style="$kmargin_normal_in">$follow_line$kuplink_right</div>\n);
	}

# ナビゲーションリンク
$print .= qq(<div style="background:#9d9;$ktextalign_center_in$kborder_top_in">$emoji{'number8'}<a href="#C" id="C" accesskey="8">ナビリンク</a></div>);
$print .= qq(<div style="$kmargin_normal_in">);

	if($nowfile){ $print .= qq(□<a href="./">メニュページ</a> [3]<br$main::xclose>); }

$print .= qq(□<a href="${home}">トップページ</a> [1]<br$main::xclose>);

	if($one_line_reshistory){ $print .= qq(□<a href="#RESHISTORY2">投稿履歴を確認</a><br$main::xclose>); }
	if($follow_line){ $print .= qq(□<a href="#AFOLLOW">フォローを確認</a>);}

$print .= qq($kuplink_right</div>);

	# 現在のURL
	if(!$postflag && length($requri) <= 50 && $requri !~ /&/ && $requri){
		my($subject_enc,$body_enc,$now_url2_esc,$now_url2_enc);
		($now_url2_esc) = Mebius::escape("Not-amp","http://$server_domain$requri");
		($now_url2_enc) = Mebius::Encode("","http://$server_domain$requri");

		$body_enc = qq(「$sub_title」);
			#if($chandle){ $subject_enc = qq($chandleより); }
			#else{ $subject_enc = qq(メビウスリングの紹介); }

		if($k_access eq "SOFTBANK"){ }
		else{
			($body_enc) = Mebius::Encode("",$body_enc);
			($subject_enc) = Mebius::Encode("",$subject_enc);
		}
		$body_enc .= qq(%0D%0A);

		$nowurl_box .= qq(<div style="background:#9d9;$ktextalign_center_in$kborder_top_in">現在のURL</div>);
		$nowurl_box .= qq(<form action="./" method="get"><div  style="$kpadding_normal_in$ktextalign_center_in">);
		$nowurl_box .= qq(<input type="text" name="nowurl" value="$now_url2_esc" size="24"$xclose>);
		$nowurl_box .= qq(<br$main::xclose>$emoji{'mobile'}<a href="mailto:?subject=$subject_enc&amp;body=$now_url2_enc">このURLをﾒｰﾙで送る</a>);
		$nowurl_box .= qq(</div></form>);
		$print .= qq($nowurl_box);
	}

# 降ったリンク
$print .= our $khrtag;
$print .= qq(<div style="text-align:center;margin-bottom:1em;">);
$print .= qq( <a href="$basic_init->{'guide_url'}%A5%D7%A5%E9%A5%A4%A5%D0%A5%B7%A1%BC%A5%DD%A5%EA%A5%B7%A1%BC">ﾌﾟﾗｲﾊﾞｼﾎﾟﾘｼ-</a>);
$print .= qq( <a href="http://mb2.jp/etc/amail.html">お問い合わせ</a>);
$print .= qq(</div>);

# ロゴ
$print .= qq($khrtag<div style="$ktextalign_center_in$kline_height_in">);
$print .= qq(- メビウスリング -);
$print .= qq(<br$main::xclose>);


$print .= qq(</div>);

$print;

}

use strict;

#-------------------------------------------------
#  HTMLフッタ
#-------------------------------------------------
sub footer{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$use) = @_;
if(ref $type eq "HASH"){ $use = $type; }
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($init_directory) = Mebius::BaseInitDirectory();
my($mobile_item) = kget_items();
my($line,$allsearch_form,$google_search_box,$follow_line);
my $mebius = new Mebius;
our($original_maker,$footer_plus,$secret_mode,$kflag,$cgold,$csilver,$one_line_reshistory,$postbuf,$kuplink_righ);

	# 携帯版の場合
	#if($my_use_device->{'mobile_flag'}){ my($k_footer) = &kfooter(@_); return($k_footer); }

	# 整形用のDIVタグを自動出力
$line .= qq(</div>);

	# フォローを取得
	#if(!Mebius::Admin::admin_mode_judge() && !Mebius::Switch::light()){
	#		if($ENV{'HTTP_COOKIE'} && $my_use_device->{'smart_flag'}){
	#			require "${init_directory}part_follow.pl";
	#			($follow_line) = get_follow("HEADER");
	#			($line) .= $follow_line;
	#		}
	#}

$line .= qq(<footer>);
$line .= qq(<div class="footerlink clear">);

	if(Mebius::Admin::admin_mode_judge()){

		$line .= qq(<a href="https://mb2.jp/jak/fjs.cgi?mode=url">ＵＲＬ変換</a>┃<a href="$basic_init->{'guide_url'}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">禁則</a>┃<a href="$basic_init->{'guide_url'}wiki/guid/?action=LIST">ガイド一覧</a>┃<a href="$basic_init->{'admin_report_bbs_url'}">削除依頼板</a>┃<a href="index.cgi?mode=vlogined">ログイン履歴</a>┃<a href="$basic_init->{'admin_main_url'}?mode=cdl">管理番号</a>┃$main::adroom_link_utf8);

	# 通常モード
	} elsif(!$my_use_device->{'mobile_flag'}) {
			# スマフォ板
			if($my_use_device->{'smart_flag'}){
				$line .= qq(<a href="http://aurasoul.mb2.jp/wiki/guid/%A5%D7%A5%E9%A5%A4%A5%D0%A5%B7%A1%BC%A5%DD%A5%EA%A5%B7%A1%BC">プライバシー</a>┃);
			}
			# デスクトップ版
			else{
					# スクリプトの配布元
					if($original_maker){ $line .= qq($original_maker┃); }
				# スクリプトの改造者
				$line .= qq(<a href="http://aurasoul.mb2.jp/wiki/guid/%A5%D7%A5%E9%A5%A4%A5%D0%A5%B7%A1%BC%A5%DD%A5%EA%A5%B7%A1%BC">プライバシーポリシー</a>┃);
					#if(!$main::sns{'flag'}){ $line .= qq(<a href="${main::main_url}past.html">過去ログ</a>┃); }
			}

			#if(!$secret_mode){ $line .= qq(<a href="http://aurasoul.mb2.jp/_delete/">削除依頼</a>┃); }
		$line .= qq(<a href="http://mb2.jp/etc/amail.html">お問い合わせ</a>);

			# 金貨の表示
			if($cgold ne ""){
				my($main_domain_url) = Mebius::URL::main_domain_url();
				$line .= qq(┃<img src=").e($main_domain_url).q(pct/icon/gold1.gif" alt="金貨" title="金貨" class="noborder">);
					if($cgold >= 0){ $line .= qq( $cgold); }
					else{ $line .= qq( <span class="blue">$cgold</span>); }
				#$line .= qq( \( $main::server_domain \) );
			}

	}	

$line .= qq(\n</div>);

	# 追加するライン
	if($footer_plus){ $line .= qq(<div class="footerlink clear">$footer_plus</div>); }


	if(!$use->{'no_ads_flag'} && !$my_use_device->{'mobile_flag'}){
		my($google_search_box) = Mebius::Gaget->google_search_box($use);

			if($google_search_box){
				$line .= qq(<div class="right margin">$google_search_box</div>);
			}
	}

	# パンくずリストの追加
$line .= qq(<div class="bcl scroll"><nav class="scroll-element">);
$line .= $mebius->bcl_line($use);
$line .= qq(</nav></div>);

	# 投稿履歴を表示
	if($one_line_reshistory){
			if($my_use_device->{'mobile_flag'}){
				$line .= qq(<div style="background:#fcc;$mobile_item->{'border_top_in'}$mobile_item->{'text_align_center_in'}"><a id="RESHISTORY2"></a>投稿履歴</div>);
				$line .= qq(<div style="$mobile_item->{'margin_normal_in'}">$one_line_reshistory$mobile_item->{'up_link_right'}</div>\n);
			} else {
				$line .= qq(<div class="footer_res_history">$one_line_reshistory</div>);
			}
	}

		# 端末切り替えフォーム
	if($ENV{'REQUEST_METHOD'} eq "GET"){
		($line) .= Mebius::Mypage::select_my_device_form();
	} else {
		$line .= qq(<div></div>);
	}

	# スマフォ用
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<div class="right padding"><a href="#body_top" class="move">▲ページ最上部へ</a></div>);
	}


$line .= qq(</footer>\n);


$line .= $mebius->footer_javascript($use) if(!$my_use_device->{'mobile_flag'});

$line .= mobile_footer_navigation() if($my_use_device->{'mobile_flag'});

	# ●管理者のみにアクセスデータを表示
	if($my_account->{'master_flag'} || Mebius::alocal_judge()){
		$line .= access_data_on_html();
	}

#$line .= qq(<div style="height:16px;"> </div>);
#$line .= qq(<div style="position:fixed; bottom:0px; left:0px; width:100%; height:16px; padding:4pt;background-color:lime; text-align:center;">↓下辺に固定</div>);

	# フォローを取得
	if(!Mebius::Admin::admin_mode_judge() && !Mebius::Switch::light()){
			if($ENV{'HTTP_COOKIE'}){
				require "${init_directory}part_follow.pl";
				$line .= get_follow("HEADER");
			}
	}

$line .= qq(</body></html>);

# 整形
$line =~ s/\t//g;

	if($type !~ /GET/ && !$use->{'NotPrint'}){ print $line; }

# リターン
return($line);

}


#-----------------------------------------------------------
# アクセスデータをHTMLとして表示 ( 管理者向け )
#-----------------------------------------------------------
sub access_data_on_html{

my($line);
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;

$line .= qq(<div class="line-height-large">);
$line .= qq(<div>Time: ).e(time).qq(</div>);

$line .= qq(Postbuf: ) . e($main::postbuf);
$line .= qq(<br><br>);

	# Cookieを表示
	if(Mebius::alocal_judge() || $my_account->{'master_flag'}){
		$line .= qq(<div class="line-height">Cookie:<br$main::xclose>);
			foreach(split(/;/,$ENV{'HTTP_COOKIE'})){
				my($escaped_line) = e($_);
				my($cookie_name,$cookie_body) = split(/=/,$escaped_line);
				$line .= qq(<span class="red">$cookie_name</span>=<span class="green">$cookie_body</span>;<br$main::xclose>);
			}
		$line .= qq(</div>);
	}

	# リファラを表示
	if($ENV{'HTTP_REFERER'}){
		$line .= qq(<div style="margin-top:1em;color:purple;">Referer: );
		$line .= $html->href($ENV{'HTTP_REFERER'});
		$line .= qq(</div>);
	}

	# mod_perl
	if($ENV{'MOD_PERL'}){
		$line .= qq(<div> MOD_PERL : ).e($ENV{'MOD_PERL'}).q(</div>)
	}

	foreach my $key ( keys %ENV ){
		$line .= qq(<div>);
		#$line .= e($key).qq(:);
		#$line .= e($ENV{$key});
		$line .= qq(</div>);

	}

$line .= qq(</div>);

$line;

}

#-----------------------------------------------------------
# 携帯用の各要素を取得
#-----------------------------------------------------------
sub kget_items{

# 宣言
my($type) = @_;
my($now_url2);
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my(%item);
our($requri,$backurl,$kget_items_done,$kflag,$selected,$disabled,$checked,$xclose,$ktype);
our($mailurl_link,$mailurl_link2);
our($kfontsize_xsmall_in,$kfontsize_xsmall,$kfontsize_small,$kfontsize_midium);
our($kfontsize_h1,$kstyle_h1,$kfontsize_h2,$kstyle_h2,$kfontsize_medium_in,$kborder_top_in,$kborder_bottom_in,$ktextalign_right_in);
our($kbackground_blue2_in,$ktext_align_in,$khrtag,$kback_link2,$kfontsize_small_in,$sikibetu,$kboad_link,$kboad_link2,$kindex_link,$kindex_link2,$kauth_link,$kauth_link2);
our(%in,%done,$home,$backurl_href,$kmargin_normal_in,$kback_link,$selfurl_enc,$kstyle_h3,$mybackurl,$ktextalign_center_in,$kmypage_link,$kpadding_normal_in);

	if(!$my_use_device->{'mobile_flag'}){ return(); }

$kflag = 1;
$done{'kget_items'} = 1;

# 絵文字を取得
my(%emoji) = Mebius::Emoji("",$my_real_device->{'id'});

# パーツを取得
our($parts) = Mebius::Parts::HTML({ TypeMobile => 1});
our(%parts) = (%$parts);
$selected = $parts->{'selected'};
$disabled = $parts->{'disabled'};
$checked = $parts->{'checked'};

$xclose = " /";
$checked = qq( checked="checked");
$kflag = 1;
#$ktag = "k";
$ktype = " MOBILE";
$khrtag = qq(<hr />);
#$kboad = "km0.html";
#$kindex = "kindex.html";
#$kinputtag = qq(<input type="hidden" name="k" value="1"$xclose>);
#$kquery = "&k=1";
#$kquery_enc = "&amp;k=1";
$kfontsize_xsmall_in = qq(font-size:x-small;);
$kfontsize_xsmall = qq( style="$kfontsize_xsmall_in");
$kfontsize_small_in = qq(font-size:small;);
$kfontsize_small = qq( style="$kfontsize_small_in");
$kfontsize_midium = qq( style="font-size:medium;");
$main::kstyle_h1_in = qq(font-size:small;background:#ddf;text-align:center;);
$main::kstyle_h2_in = qq(font-size:small;background:#ddf;text-align:center;);
$main::kstyle_h3_in = qq(font-size:small;background:#ddd;);
$kfontsize_h1 = $kstyle_h1 = qq( style="$main::kstyle_h1_in");
$kfontsize_h2 = $kstyle_h2 = qq( style="$main::kstyle_h2_in");
$kstyle_h3 = qq( style="$main::kstyle_h3_in");
$kfontsize_medium_in = qq(font-size:medium;);
$item{'border_top_in'} = $kborder_top_in = qq(border-top:1px #000 solid;);
$kborder_bottom_in = qq(border-bottom:1px #000 solid;);
$main::kborder_bottom = qq( style="$kborder_bottom_in");
$kbackground_blue2_in = qq(background:#ddf;);
$main::kbackground_green1_in = qq(background:#9f9;);
$main::kbackground_yellow1_in = qq(background:#ffb;);
$item{'text_align_center_in'} = $ktextalign_center_in = qq(text-align:center;);
$ktextalign_right_in = qq(text-align:right;);
$item{'margin_normal_in'} = $kmargin_normal_in = qq(margin:0.5em 0em;);
$kpadding_normal_in = qq(padding:0.5em 0em;);
our $kline_height_in = qq(line-height:1.4;);
$item{'up_link_right'} = our $kuplink_right = qq(<div style="$ktextalign_right_in"><a href="#body_top">ページ先頭</a>$emoji{'number2'}</div>);

	# $in{'backurl'}から戻り先を判定（２）
	if($in{'backurl'} && $backurl){
		if($backurl){
			$kback_link = qq( $emoji{'number7'}<a href="$backurl" accesskey="7"$main::utn2>元</a>);
			$kback_link2 = qq( $emoji{'number7'}<a href="$backurl"$main::utn2>元</a>);
		}
	}

	# リファラから戻り先を定義（３）
	elsif($backurl_href){
		$kback_link = qq( $emoji{'number7'}<a href="$backurl_href" accesskey="7"$main::utn2>戻</a>);
		$kback_link2 = qq( $emoji{'number7'}<a href="$backurl_href"$main::utn2>戻</a>);
	}

	# リンク
	if($kboad_link eq "off"){ $kboad_link = $kboad_link2 = undef; }
	#elsif($kboad_link eq "now"){ $kboad_link = $kboad_link2 = qq( $emoji{'number3'}ﾒﾆｭ); }
	else{
		if(our $nowfile){
			$kboad_link = qq( $emoji{'number3'}<a href="./" accesskey="3"$main::utn2>ﾒﾆｭ</a>);
			$kboad_link2 = qq( $emoji{'number3'}<a href="./"$main::utn2>ﾒﾆｭ</a>);
		}
	}


	# トップページへのリンク
	if($kindex_link eq "off"){ $kindex_link = ""; }
	#elsif($kindex_link eq "now"){ $kindex_link = qq( $emoji{'number1'}\Top); }
	else{
		$kindex_link = qq( $emoji{'number1'}<a href="${home}" accesskey="1">$emoji{'home'}</a>);
		$kindex_link2 = qq( $emoji{'number1'}<a href="${home}">$emoji{'home'}</a>);
	}

	# マイページへのリンク
	if($ENV{'HTTP_COOKIE'}){
		my($backurl_query_enc);
			if($ENV{'REQUEST_METHOD'} eq "POST"){ $backurl_query_enc = qq(&amp;backurl=off); }
			elsif($selfurl_enc){ $backurl_query_enc = qq(&amp;backurl=$selfurl_enc); }
			elsif($mybackurl){ $backurl_query_enc = qq(&amp;backurl=$mybackurl); }

		$kmypage_link = qq( <a href="${main::main_url}?mode=my$backurl_query_enc"$sikibetu>$emoji{'wrench'}</a>);
	}

	# SNS へのリンク
	if($ENV{'HTTP_COOKIE'}){
			if($my_account->{'login_flag'}){
				$kauth_link = qq( $emoji{'number9'}<a href="$basic_init->{'auth_url'}$my_account->{'id'}/" accesskey="9"$sikibetu>SNS</a>);
				$kauth_link2 = qq( $emoji{'number9'}<a href="$basic_init->{'auth_url'}$my_account->{'id'}/"$sikibetu>SNS</a>);
			}
			else{
				$kauth_link = qq( <a href="$basic_init->{'auth_url'}">SNS</a>);
				$kauth_link2 = qq( <a href="$basic_init->{'auth_url'}">SNS</a>);
			}
	}


\%item;


}

#-----------------------------------------------------------
# フォロー内容を取得してヘッダに表示
#-----------------------------------------------------------
sub get_follow{

# 宣言
my($type,$maxview,$maxpertype) = @_;
my($line,$pmfollow,$follow_link,$auto_follow_flag,$auto_follow_text,$edit_link,$put_type,@tops,@cfollow_buf);
my($selects_cfollow,$selects_reshistory,$hit_core,$mypage_line,%count,%follow);
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
our($followed_flag) = undef;
our($cfollow,$script);

# 基本設定を取得
if($my_use_device->{'mobile_flag'}){ $put_type = "MOBILE"; }
my($max_follow,$max_follow_pertype) = Mebius::BBS::init_follow("$put_type");

	# リターン
	if($cfollow eq "off"){ return(); }
	if(!$ENV{'HTTP_COOKIE'}){ return(); }

	# CSS設定
	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE (7|6|5)\.0/){ $main::css_text .= qq(div.follow{padding-top:0.3em;}); }

	# ●Cookieのフォローを展開、追加 
	foreach(split(/\s/,$cfollow)){
		my($type2,$moto2) = split(/=/,$_);
			if($type2 eq "bbs"){ $follow{$moto2} = 1; }
	}

	# ●投稿履歴から代入する
	{
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}part_history.pl";
		my(@cfollow_reshistory) = &get_reshistory("FOLLOW My-file");

			foreach(@cfollow_reshistory){
				my $bbs_kind = $_;
					if($bbs_kind =~ /^sub([0-9a-z]+)/){ $bbs_kind = $1; }
				$follow{$bbs_kind} = 1;
			}
	}

	if(%follow){
		my($get_line) =  Mebius::Follow::get_all_follow("Get-index",%follow);
		#shift_jis($get_line);
		($line) .= $get_line;
	}

	# 最終的にフォロー内容がない場合
	if($line eq "" && $cfollow ne ""){
		$line = qq(今は表\示できる内容がありません。);
	}

	# 最終的にフォロー内容がない場合
	elsif($line eq "" && $type =~ /HEADER/){
		if($my_use_device->{'mobile_flag'}){ return(); }
		else{
			$line .= qq(<div class="follow">フォロー： );

		if($my_use_device->{'mobile_flag'}){
				if(our $nowfile){ $line .= qq(<a href="$script?type=form_follow">この掲示板をフォロー？</a> ); }
				else{ $line .= qq(今はありません。 ); }
		}
		else{
				#if(our $nowfile){ $line .= qq(<a href="$script?type=form_follow">”$head_title” をフォローしませんか？</a> ); }
				if(our $nowfile){ $line .= qq(今はありません。 ); }
				else{ $line .= qq(今はありません。 ); }
		}
			$line .= qq( <a href="$basic_init->{'guide_url'}%A5%D5%A5%A9%A5%ED%A1%BC%B5%A1%C7%BD">?</a>);
			$line .= qq(</div>);
			return($line);
		}
		}

	# フォロー内容がない場合 ( マイページ )
	elsif($line eq "" && $type =~ /MYPAGE/){
		$line .= qq(いまは表\示できる内容がありません。);
	}

	# マイページでの整形
	if($type =~ /MYPAGE/){
		$line = qq(<table summary="フォロー一覧"><tr><th>記事</th><th>投稿者</th><th>掲示板</th><th>時刻</th></tr>\n$line</table>);
	}

	# 整形
	#if($param->{'mode'} eq "my"){ $edit_link = qq(編集); } else { $edit_link = qq(<a href="${main::main_url}?mode=my$backurl_mypage_enc#FOLLOW">続き</a>); }

	if($auto_follow_flag){ $follow_link .= qq(); }

	# デザイン整形
	if($line){
		if($type =~ /MYPAGE/){}
		else{
			if($my_use_device->{'mobile_flag'}){ $line = qq($line<br$main::xclose>$edit_link); }
			else{ $line = qq(<div class="follow">$auto_follow_textフォロー： $line　 $follow_link $edit_link </div>); }
		}
	}

# リターン
return($line);

}

#-----------------------------------------------------------
# 端末タイプ切り替えフォーム
#-----------------------------------------------------------
sub get_device_type_form_mypage{

# 宣言
my($use) = @_;
my($line);
my($my_cookie) = Mebius::my_cookie_main();
my($parts) = Mebius::Parts::HTML();
my($real_device) = Mebius::my_real_device();

# 端末の種類
my @device = (
"Auto->自動判定->初期設定です。",
"Desktop->PC->パソ\コン版のページを表\示します。",
"Smart-phone->スマートフォン->ページの余白は狭く、他のパーツも小さく表\示します。",
"Mobile->携帯電話->旧携帯電話(ガラゲー)用のシンプルな画面を表\示します。",
"Tablet-pc->タブレット (iPadなど)->ページの余白を狭く表\示します。",
"Portable-game-player->小型ゲーム(PSPなど)->小型ゲーム機用の小さな画面を表\示します。",
);


	# 端末タイプを展開
	foreach(@device){

		# 局所化
		my($selected,$title_tag);

		# 分割
		my($device_type2,$device_type_text2,$device_guide2) = split(/->/,$_);
		
		# タイトルタグ
		$title_tag = qq( title="$device_guide2") if(!$real_device->{'type'} eq "Desktop");

		# フォームを定義
			if($my_cookie->{'device_type'} eq $device_type2){ $selected = $parts->{'selected'}; }
		$line .= qq(<option value="$device_type2"$title_tag$selected>$device_type_text2</option>\n);

	}

	# 整形
	if($use->{'TypeFooterForm'}){
		$line = qq(<strong>画面</strong> ：  <select name="cdevice_type">$line</select>\n);
	}
	else{
		$line = qq(<tr><td><strong>画面タイプ</strong></td><td><select name="cdevice_type">$line</select></td></tr>\n);
	}

return($line);

}

package Mebius::Mypage;
use Mebius::Export;

#-----------------------------------------------------------
# 端末タイプ切り替えフォーム
#-----------------------------------------------------------
sub select_my_device_form{

# 宣言
my($use) = @_;
my($line);
my($basic_init) = Mebius::basic_init();
my($real_device) = Mebius::my_real_device();

		# GET の場合のみフォームを取得
	if($ENV{'HTTP_COOKIE'} && $ENV{'REQUEST_METHOD'} eq "GET" && $real_device->{'type'} ne "Mobile"){
		$line .= qq(<form action="http://).e($basic_init->{'top_level_domain'}).qq(/_main/" method="post">);
		$line .= qq(<div class="right margin" style="text-align:right;">);
		$line .= qq(<input type="hidden" name="mode" value="my"$main::xclose>);
		$line .= qq(<input type="hidden" name="redirect" value="1"$main::xclose>);
		($line) .= main::get_device_type_form_mypage({ TypeFooterForm => 1 });
		my($backurl) = Mebius::back_url( { TypeRequestURL => 1 } );
		$line .= qq($backurl->{'input_hidden'});
		$line .= qq(<input type="submit" name="csubmit" value="切替"$main::xclose>);
		$line .= qq(</div>);
		$line .= qq(</form>);
	}

return($line);

}


package main;

#-----------------------------------------------------------
# XIP を取得
#-----------------------------------------------------------
sub get_xip{

# 宣言
my($addr,$agent,$k_access) = @_;
my($xip,$xip_enc,$no_xip_action);

# 振り分け
if($k_access eq "DOCOMO" || $k_access eq "AU"){ $xip = $agent; }
elsif($k_access){ $no_xip_action = 1; $xip = $agent; }
else{ $xip = $addr; }

# エンコード
($xip_enc) = Mebius::Encode("",$xip);

# リターン
return($xip,$xip_enc,$no_xip_action);

}

#-----------------------------------------------------------
# クッキー取得 
#-----------------------------------------------------------
sub get_cookie{

Mebius::get_cookie(@_);

}



#-----------------------------------------------------------
# 取り込み処理 ( このサブルーチン内の処理が行われる時は、既に $int_dir の値は設定されている )
#-----------------------------------------------------------
our($int_dir) = Mebius::BaseInitDirectory();
sub repairform{ require "${int_dir}main_repairurl.pl"; &get_repairform(@_); }
sub error{ require "${int_dir}part_error.pl"; &do_error(@_); }
sub set_cookie_old{ my($init_directory) = Mebius::BaseInitDirectory(); require "${init_directory}part_setcookie_old.pl"; &do_set_cookie_old(@_); }
sub redun{ require "${int_dir}part_redun.pl"; &do_redun(@_); }
sub divide{ require "${int_dir}part_divide.pl"; &do_divide(@_); }
sub get_status{ require "${int_dir}part_getstatus.pl"; &do_get_status(@_); }
sub access_log{ require "${int_dir}part_accesslog.pl"; &do_access_log(@_); }
sub access_log2{ require "${int_dir}part_accesslog2.cgi"; &do_access_log2(@_); }
sub kerror { require "${int_dir}k_error.pl"; &do_kerror(@_); }
sub http404{ require "${int_dir}part_404.pl"; &do_404(@_); }
sub axscheck{ require "${int_dir}part_axscheck.pl"; &do_axscheck(@_); }
sub id{ Mebius::my_id(@_); }
sub trip{ require "${int_dir}part_axscheck.pl"; &get_trip(@_); }
sub lock{ Mebius::lock(@_); }
sub unlock{ Mebius::unlock(@_); }
sub backurl{ require "${int_dir}part_backurl.pl"; &get_backurl(@_); }
sub mail{ require "${int_dir}part_email.cgi"; &email(@_); }
sub oldremove{ require "${int_dir}part_files.pl"; &do_oldremove(@_); }
sub minsec{ require "${int_dir}part_timer.pl"; &do_minsec(@_); }

package Mebius;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# <head> ～ </head> 部分を定義
#-----------------------------------------------------------
sub between_head_tag{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($print);
my($my_real_device) = Mebius::my_real_device();
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my $mebius = new Mebius;
my($head_javascript_line,$css_fontsize,%js_count,$head_page_title,$javascript_files,$meta_jump,$meta_robots,$meta_tag_free);
my $css_text = $main::css_text;
my $canonical = $main::canonical || $use->{'canonical'};

	# Canonical属性
	if($canonical){
		$canonical = qq(<link rel="canonical" href=").e($canonical).qq(">\n);
	}
	# Https ページで Http への canonical を設定
	else{
		($canonical) = Mebius::AutoCanonical({ TypeHttpsToHttp => 1 });
	}

	# META ロボットタグ
	unless( $meta_robots = $main::meta_robots){
			if($main::noindex_flag || $use->{'RobotsNoIndex'} || Mebius::Report::report_mode_judge()){ $meta_robots = qq(<meta name="robots" content="noindex,nofollow,noarchive">\n); }
			elsif($use->{'RobotsNoIndexFollow'}){ $meta_robots = qq(<meta name="robots" content="noindex,follow,noarchive">\n); }
			else{ $meta_robots = qq(<meta name="robots" content="noarchive">\n); }
	}

	# 任意のメタタグ
	#if($main::meta_tag_free){
	#	$meta_tag_free = $main::meta_tag_free;
	#}

$meta_tag_free .= qq(<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=0">\n);

	# スマフォ用
	if($my_use_device->{'smart_phone_flag'}){
		$meta_tag_free .= qq(<meta name="format-detection" content="telephone=no">\n);
	}
	elsif($my_use_device->{'id'} eq "DSi"){
		$meta_tag_free .= qq(<meta name="viewport" content="width=device-width">\n);
	}
	# タブレットPC向け
	elsif($my_real_device->{'type'} eq "Tablet-pc"){
		$meta_tag_free .= qq(<meta name="viewport" content="width=device-width">\n);
	}

	if($use->{'GoogleWebMasterToolTag'} || $use->{'ContentsTopPage'}){
		$meta_tag_free .= qq(<meta name="google-site-verification" content="maWaXY_1fhtNFnNdUn7WH2Jg36BcB1YP3TxvF8pQ3WY">);
	}


	# ●ジャンプ ( meta refresh ) の設定
	{
		my($jump_url);
		if(defined $use->{'RefreshURL'}){ $jump_url = $use->{'RefreshURL'}; }
		elsif(defined $main::jump_url){ $jump_url = $main::jump_url; }
			if($jump_url){
				my($jump_second);
					if(defined $use->{'RefreshSecond'}){ $jump_second = $use->{'RefreshSecond'}; }
					elsif(defined $main::jump_sec) { $jump_second = $main::jump_sec; }
				$meta_jump = qq(<meta http-equiv="refresh" content="${jump_second};url=${jump_url}">\n);
			}
	}

my @css_files = @main::css_files;
my $css_files = $mebius->css_files({ Simple => $use->{'Simple'} , style => $main::style , css_files => \@css_files });

	# 重複する外部Javascriptファイルを削除
	my @javascript_files = grep( !$js_count{$_}++, @main::javascript_files ) ;
	# 外部Javascriptファイルを展開
	foreach my $file_name (@javascript_files){
		$javascript_files .= qq(<script type="text/javascript" src="/skin/$file_name.js"></script>\n);
	}

	# Head タグ内の Javascript
	if($use->{'head_javascript'}){ $head_javascript_line = $use->{'head_javascript'}; }
	elsif($main::head_javascript){ $head_javascript_line = $main::head_javascript.""; utf8($head_javascript_line); }

$print .= qq(<head>);

	if($my_use_device->{'mobile_flag'}){
		$print .= qq(<meta http-equiv="content-type" content="application/xhtml+xml; charset=shift_jis" />\n);
	} else {
			if($use->{'source'} eq "utf8" && !$my_real_device->{'mobile_flag'}){
				$print .= qq(<meta http-equiv="content-type" content="text/html; charset=utf-8">\n);
			} else {
				$print .= qq(<meta http-equiv="content-type" content="text/html; charset=shift_jis">\n);
			}

	}
$print .= qq(<meta name="referrer" content="origin">\n);

	# タイトル定義
	if(defined $use->{'Title'}){
		$head_page_title = $use->{'Title'};
			if($use->{'source'} ne "utf8"){ utf8($head_page_title); }
	}
	else{ ($head_page_title) = utf8($main::sub_title); }

$print .= qq(<title>).e($head_page_title).qq(</title>
$meta_robots$canonical$meta_jump$main::meta_nocache$meta_tag_free
$css_files
);

	# COOKIE からマイ設定を取得
	if($main::cfontsize){ $css_fontsize = qq(body{font-size:$main::cfontsize%;}\n); }

	# IE8 対応
	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE 8/){
		$css_text .= qq(textarea.wide{width:750px;}\n);
		$css_text .= qq(.table1{margin-left:auto;margin-right:auto;}\n);
	}

	# Firefox CSS対応
	if($ENV{'HTTP_USER_AGENT'} =~ /Firefox/){
		$css_text .= qq(.body1{overflow:visible;});
	}

	# 任意のＣＳＳ
	if($css_text || $use->{'css_text'} || $use->{'inline_css'}){
		$css_text =~ s/\t//g;
		$print .= qq(<style type="text/css">\n);
		$print .= qq(<!--\n);
		$print .= e("$css_fontsize$css_text$use->{'css_text'}$use->{'inline_css'}",{ NotValue => 1 });
		$print .= qq(-->\n);
		$print .= qq(</style>\n);
	}

	# 任意のJavascript
	if($main::javascript_text && !$my_use_device->{'mobile_flag'}){
		my $javascript_text = $main::javascript_text;
		utf8($javascript_text);
		$print .= qq(<script type="text/javascript">\n);
		$print .= qq(<!--\n);
		$print .= qq($javascript_text\n);
		$print .= qq(-->\n);
		$print .= qq(</script>\n);
	}

$print .= "$head_javascript_line";

#my($google_analytics) = Mebius::Gaget::google_analytics();
#$print .= "$google_analytics\n";

	# Javascript外部ファイル
	if(($use->{'Jquery'}) && !$my_use_device->{'mobile_flag'}){ # && $use->{'BeforeUnload'}

		$print .= qq(<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>\n);
	}

# BODY 部分開始
$print .= qq(</head>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub css_files{

my $self = shift;
my $use = shift;
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($css_files,%css_count);
my @css_files = @{$use->{'css_files'}};
my $style = $use->{'style'};


	# ●CSSの定義
	if($my_use_device->{'mobile_flag'}){ return(); }

	# 基本スタイル
	if(!$use->{'Simple'}){
		unshift(@css_files,"bas");
	}

	# 個別CSSを定義
	if($style){
		$style =~ s!(\.\.)?/style/!!g;
		my($file,$tail) = split(/\./,$style);
		push(@css_files,$file);
	}

	# 管理用
	if(Mebius::Admin::admin_mode_judge()){
		push(@css_files,"admin");
	}
	push @css_files , @{$use->{'css_files'}} if(ref $use->{'css_files'} eq "ARRAY");

	# スマフォ向けスタイル
	if(!$use->{'Simple'}){
			if($my_use_device->{'smart_css_flag'}){ push(@css_files,"smart_phone"); }
			elsif($my_use_device->{'type'} =~ /^(Tablet-pc|Portable-game-player)$/){ push(@css_files,"tablet"); }
	}

# 外部CSSファイルを展開
my($css_count);
@css_files = grep( !$css_count{$_}++, @css_files );

my($main_domain_url) = Mebius::URL::main_domain_url();
	foreach(@css_files){
		my $css_file_path;
			if(Mebius::Device::accept_gzip_type() && !Mebius::alocal_judge()){
				#$css_file_path = "$basic_init->{'css_and_js_file_url'}style_gzip/$_.css.gz";
				$css_file_path = "$basic_init->{'css_and_js_file_url'}style/$_.css";
			} else {
				$css_file_path = "$basic_init->{'css_and_js_file_url'}style/$_.css";
			}

		$css_files .= qq(<link rel="stylesheet" href=").e($css_file_path).q(" type="text/css">).qq(\n);
	}


$css_files;

}

#-----------------------------------------------------------
# フッタの Javascript を定義
#-----------------------------------------------------------
sub footer_javascript{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $gaget = new Mebius::Gaget;
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my($basic_init) = Mebius::basic_init();
my($line);

# Google +1 ボタン用 ( 今は非使用 )
#my($google_plusone_script) = Mebius::Gaget::google_plusone_script() if($my_real_device->{'wide_flag'} && $ENV{'REQUEST_METHOD'} eq "GET" && !$main::secret_mode && !$my_use_device->{'mobile_flag'});
#$line .= qq($google_plusone_script);

	# Javascript外部ファイル
	#if(($use->{'Jquery'}) && !$my_use_device->{'mobile_flag'}){ # && $use->{'BeforeUnload'}
	#	$line .= qq(<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>\n);
	#}



	if($my_use_device->{'smart_flag'} || $my_use_device->{'tablet_flag'}){
		$line .= $gaget->line_javascript();
	}

	# 任意のJavascriptファイル
	if(!$my_use_device->{'mobile_flag'}){

		my(@all_javascript_files);
		my($main_domain_url) = Mebius::URL::main_domain_url();

		my $year_month_day = "2013-09-06";

			# 基本 JS ファイル
			if($my_real_device->{'id'} eq "DSi"){
				push( @all_javascript_files,"basic_not_analyze-$year_month_day");
			}	else {
				push( @all_javascript_files,"basic-$year_month_day");
			}

			# 管理用 JS ファイル
			if(Mebius::Admin::admin_mode_judge()){
				push( @all_javascript_files,"admin");
			}

		push @all_javascript_files , our @javascript_files;
			if(ref $use->{'javascript_files'} eq "ARRAY"){ push @all_javascript_files , @{$use->{'javascript_files'}}; }

		# 重複する外部Javascriptファイルを削除
		my %js_count;
		@all_javascript_files = grep( !$js_count{$_}++, @all_javascript_files ) ;

			foreach(@all_javascript_files){

				my $js_file;
				my $base_url = $use->{'css_base_url'} || $basic_init->{'css_and_js_file_url'};

					if(Mebius::Device::accept_gzip_type() && !Mebius::alocal_judge()){
						#$js_file = qq(${base_url}skin_gzip/$_.js.gz);
						$js_file = qq(${base_url}skin/$_.js);
					} else {
						$js_file = qq(${base_url}skin/$_.js);
					}

				$line .= q(<script type="text/javascript" src=").e($js_file).q("></script>).qq(\n);
			}

	}

	# Twitter用
	if(!Mebius::Admin::admin_mode_judge() && !$my_use_device->{'mobile_flag'}){

		$line .= $gaget->twitter_javascript();

	}

	# Javascript のパーツ
	if($use->{'BeforeUnload'} && !$my_use_device->{'mobile_flag'}){

		my($before_unload_javascript) = Mebius::Javascript::before_unload_use_form();
		($line) .= $before_unload_javascript;
	}

$line;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_page_navigation_links{

my $self = shift;
my($print);
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my(@links);

my $csecret = $main::csecret;
my $moto = $main::moto;
my $postbuf = $main::postbuf;

	# 会員制へのリンク
	if($csecret =~ /[a-z0-9]/ && !$my_account->{'master_flag'}){
		my($i);
			foreach(split(/ /,$csecret)){
					if($_ !~ /^([a-z0-9]{2,})$/){ next }
				$i++;
				my $title = qq($_);
					if($i < 2){ $title = qq(会員制 ( $_ )); } 
				push @links , qq(<a href="http://aurasoul.mb2.jp/_sc$_/">$title</a>);
			}
	}

	# 記録
	if($csecret){
		Mebius::AccessLog(undef,"CSECRET","秘密板Cookie ： $main::csecret");
	}

	# マイページへのリンク
	if($ENV{'HTTP_COOKIE'}){
		my $my_page_main_url;
		if(Mebius::alocal_judge()){ $my_page_main_url = "http://localhost/_main/" }
			else{ $my_page_main_url = "http://mb2.jp/_main/"; }

			if($param->{'mode'} eq "my"){ push @links , qq(マイページ); }
			else{
				push @links , qq(<a href="${my_page_main_url}?mode=my">マイページ</a>); }
			if($my_use_device->{'wide_flag'}){
					if($param->{'mode'} eq "my"){ push @links , qq(設定); }
					else{ push @links , qq(<a href="${my_page_main_url}?mode=settings#EDIT">設定</a>); }
			}
	}

	# マイアカウントへのリンク
	if($ENV{'HTTP_COOKIE'}){
			if($my_account->{'login_flag'}){
				#push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/feed">\@).e($my_account->{'id'}).qq(</a>);
				push @links , qq(<a href="$basic_init->{'auth_url'}">\@).e($my_account->{'id'}).qq(</a>);
			} else {
				my $sns = new Mebius::SNS;
				push @links , $sns->login_link();
			}
	}

	# 新チャット城へのリンク
	#if($myaccount->{'login_flag'} && time > $my_account->{'firsttime'} + 60*24*60*60 && $my_use_device->{'wide_flag'}){
	#	push @links , qq(<a href="http://aurasoul.mb2.jp/chat/tmb3/mebichat.cgi">チャット</a>); 
	#}

	# 管理モードへのリンク
	if($my_account->{'admin_flag'} >= 1){
		my($buf);
			if($postbuf && $ENV{'REQUEST_METHOD'} ne "POST"){ $buf = "?$postbuf"; $buf =~ s/(&)?moto=([a-z0-9]+)//g; $buf =~ s/\?(&)/?/g; $buf =~ s/\?$//g; $buf =~ s/&/&amp;/g;  }
		push @links , qq(<a href="$main::jak_url$moto.cgi$buf" class="red">管理</a>);
	}

# 最終リンク
push @links , qq(<a href="$basic_init->{'guide_url'}">ガイド</a>);

my $print = join " " , @links;

		if($my_use_device->{'touch_display_flag'}){
			$print .= " " . $self->sorcial_navigation_line();
			$print = qq(<div class="scroll-element">$print</div>);
		}

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sorcial_navigation_line{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();
my($my_real_device) = Mebius::my_real_device();
my($param) = Mebius::query_single_param();
my $gaget = new Mebius::Gaget;
my($sorcial_line);

# メールメモ
	# LINE で送る
	if($my_use_device->{'type'} eq "Desktop" || $my_use_device->{'tablet_flag'}){
		my($request_url_encoded) = Mebius::request_url_encoded();
		my($main_domain_url) = Mebius::URL::main_domain_url();
		$sorcial_line .= qq(<a href="mailto:?body=).e($request_url_encoded).q("><image src=").e($main_domain_url).q(pct/mail1.gif" style="height:16px;vertical-align:top;"></a>　);
	}

	# Twitter
	if(!$param->{'not_twitter'}){
		($sorcial_line) .= $gaget->tweet_button({ twitter_account => "mb2.jp" });
	}

	# LINE で送る
	if($my_use_device->{'smart_flag'} || $my_use_device->{'tablet_flag'}){
		#$sorcial_line .= qq( - );
		($sorcial_line) .= $gaget->line_button();
	}

	# Google +1 ボタン
	if($my_real_device->{'wide_flag'}){	$sorcial_line .= "　" . Mebius::Gaget::google_plusone_button(); }

$sorcial_line;

}



#-----------------------------------------------------------
# パンくずリストを定義
#-----------------------------------------------------------
sub bcl_line{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($bcl_line,@bcl);
my($server_domain) = Mebius::server_domain();
my($bcl_top_link,@bcl_adjusted,$bcl_line);

	if($use->{'BBS_TOP_PAGE'}){
		push @bcl_adjusted , qq(TOP);
	} else {
		push @bcl_adjusted , qq(<a href="http://mb2.jp/">TOP</a>);
	}

	# リンク２
	if(!$use->{'NotDefaultBCL'}){
		my $bcl_line;
			if($main::head_link2 eq "0"){ $main::head_link2 = ""; }

				elsif($main::head_link2 eq ""){

						if( my $bcl = $main::head_title || $main::title){
								if($main::thisis_bbstop){ push @bcl , $bcl; }
								else{ $bcl_line .= $html->href("http://$server_domain/_$main::moto/" ,$bcl); }
							push @bcl_adjusted , utf8($bcl_line);

						}

			}

	}


# BCL
my @old_bcl = ($main::head_link1,$main::head_link1_25,$main::head_link1_5,$main::head_link2,$main::head_link2_5,$main::head_link3,$main::head_link4,$main::head_link5);
	foreach my $link (@old_bcl){
		$link =~ s/^\s+//g;
		$link =~ s/^&gt;//g;
			if($link){
				push @bcl_adjusted  , utf8($link);
			}
	}

	if($use->{'BCL'} && !$my_use_device->{'mobile_flag'}){

			foreach my $bcl (@{$use->{'BCL'}}){

				my($title,$url);

				if(ref $bcl eq "HASH"){
					$title = $bcl->{'title'};
					$url = $bcl->{'url'};
				} else {
					$title = $bcl;
				}

				if($use->{'source'} ne "utf8"){ utf8($title); }

				if($my_use_device->{'narrow_flag'}){ 
					$title = Mebius::Text->omit_character($title,8);
				} else {
					$title = Mebius::Text->omit_character($title,15);
				}

				if($url){
					push @bcl_adjusted , $html->href($url,$title);
				} else {
					push @bcl_adjusted , e($title);
				}
			}

	}

	#if($my_use_device->{'narrow_flag'}){ 
	#	$bcl_line .= join "&gt;" , @bcl_adjusted;
	#} else {
		$bcl_line .= join " &gt; " , @bcl_adjusted;
	#}

$bcl_line;

}

#-----------------------------------------------------------
# 管理者かどうかを二つの条件で OR 判定する
#-----------------------------------------------------------
sub common_admin_judge{

my $self = shift;
my($my_account) = Mebius::my_account();
my($admin_flag);

	if(Mebius::Admin::admin_mode_judge() || $my_account->{'admin_flag'}){
		$admin_flag = 1;
	} else {
		0;
	}

$admin_flag;

}

#-----------------------------------------------------------
# 別名ども
#-----------------------------------------------------------
sub axs_check{ my $self = shift; main::axscheck(@_); } 
sub error{ my $self = shift; main::error(@_); } 
sub access_log{ main::access_log(@_); }
sub my_admin{ my $result = Mebius::Admin::my_admin(@_); }
sub send_email{ my $result = Mebius::Email::send_email(@_); }
sub my_address{ Mebius::Email::my_address(@_); }
sub mail_format{ Mebius::Email::mail_format(@_); }
sub char{ Mebius::Crypt->char(@_); }
sub character_num{ Mebius::Text::character_num(@_); }
sub substr_character{ Mebius::Text::substr_character(@_); }


1;
