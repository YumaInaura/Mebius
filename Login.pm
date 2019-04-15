
use strict;
#use Mebius::AuthServerMove;
package Mebius::Login;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# ログインフォーム
#-----------------------------------------------------------
sub login_form_view{

my $self = shift;
my $use = shift;
my $error_message = shift;
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($maxlengthac,$form,$error_line,%use_header);
my $sns_init = Mebius::SNS->init();

	if(!$ENV{'HTTP_COOKIE'} && !Mebius::Device::bot_judge() && !$param->{'redirected'}){
		Mebius::Cookie::set_main();
			if($use->{'SNS_TOP'}){
				Mebius::Redirect(undef,"$basic_init->{'auth_url'}?redirected=1");
			} else {
				Mebius::Redirect(undef,"/_main/?mode=login_form&redirected=1");
			}
	}

# Canonical属性
$main::canonical = "${main::auth_url}";

# CSS定義
$use_header{'inline_css'} .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
span.alert{font-size:90%;color:#f00;}
.forgot{font-size:90%;color:#f00;}
);

	if(!$use->{'SNS_TOP'}){
		$use_header{'inline_css'} .= qq(
		h2{background:#aaf;padding:0em 0.5em;}
		);
	}


# ログインフォームを取得 ( 処理タイプをそのまま引渡し )
($form) = Mebius::Login->login_form_parts($use,$error_message);

$main::meta_tag_free .= qq(\n<meta name="google-site-verification" content="maWaXY_1fhtNFnNdUn7WH2Jg36BcB1YP3TxvF8pQ3WY">);

	# ヘッダ
	#if($ENV{'REQUEST_METHOD'} eq "GET"){
		$use_header{'BodyTagJavascript'} = qq( onload="document.login_form.authid.focus()");
	#}


$use_header{'source'} = "utf8";
$use_header{'GoogleWebMasterToolTag'} = 1;

	if($use->{'SNS_TOP'}){
		push @{$use_header{'BCL'}} , "ログイン";
		$use_header{'Title'} = "$sns_init->{'title'}";
	} else {
		push @{$use_header{'BCL'}} , "ログイン";
		$use_header{'Title'} = "ログイン - メビウスリングアカウント";
	}

my $print = <<"EOM";
<h1>メビウスリング アカウント</h1>
$error_line
$form
EOM

	if($use->{'SNS_TOP'}){
		Mebius::SNS->print_html($print,\%use_header);
	} else {
		Mebius::Template::gzip_and_print_all(\%use_header,$print);
	}

exit;


}


#-----------------------------------------------------------
# ログインフォームを取得
#-----------------------------------------------------------
sub login_form_parts{

# 宣言
my $self = shift;
my $use = shift;
my $error_message = shift;
my($form,$error_line,$inputed_account,$inputed_password);
my($checked_check1,$checked_check2,$password_input_type);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($parts) = Mebius::Parts::HTML();
my $device = new Mebius::Device;
require "${init_directory}auth_prof.pl";

		# 整形
	if($my_account->{'login_flag'}){
		Mebius::Auth::feed_view(); 
		#Mebius::Redirect(undef,"$my_account->{'profile_url'}feed");
	} else {
		$form .= qq(
		アカウントに登録すると、以下のサービスがご利用いただけます。
		<ul class="margin">
		<li>メビリンSNS （<a href="${main::guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">→よくある質問</a>）</li>
		<li>メビリン・アドベンチャー</li>
		</ul>
		<h2>ログイン</h2>
		);
	}

	# クッキーなしの場合
	if(!$main::cookie && !Mebius::Device::bot_judge()){
			if($main::in{'redirected'}){
					$form .= qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong>);
			}
		return($form);
	}

	# ログイン中の場合
	if($main::pmfile){
		$form .= qq(既にログイン中です。);
		$form .= qq(<ul class="margin">);
		$form .= qq(<li><a href="${main::auth_url}$main::pmfile/">→あなたのプロフィールへ</a></li>);
		$form .= qq(<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">→メビリンアドベンチャーへ</a></li>);
		$form .= qq(</ul>);
		return($form);
	}

	# パスワード入力欄のタイプ
	$password_input_type = "password";

	# 初期チェック
	if($device->use_device_is_mobile() || $ENV{'USER_AGENT'} =~ /3DS/){
		$checked_check1 = $main::parts{'checked'};
		$checked_check2 = $main::parts{'checked'};
	}

	if(Mebius::Query::post_method_judge()){
		$inputed_account = $main::in{'authid'};
		$inputed_password = $main::in{'passwd1'};
			if($main::in{'checkpass'}){
				$checked_check1 = $parts->{'checked'};
				$password_input_type = "text";
			}
			if($main::in{'other'}){
				$checked_check2 = $parts->{'checked'};
			}
	}


	# エラーメッセージ
	if($error_message){
		g_utf8($error_message);
		$error_line = qq(<div class="line-height padding" style="background:#fee;color:#f00;">エラー： $error_message</div>);
		$form .= qq($error_line);
	}

my $action = $basic_init->{'this_server_main_script_url'};

# フォーム部分
$form .= qq(
<form action="$action" method="post" name="login_form" $main::sikibetu>
<div><table>
<tr>
<td class="nowrap">アカウント名
</td><td>
<input type="text" name="authid" value="$inputed_account" pattern="^[0-9a-zA-Z]+\$" class="putid">
( 例： mickjagger )

</td>
</tr>
<tr>
<td class="nowrap">パスワード</td>
<td><input type="$password_input_type" name="passwd1" value="$inputed_password" maxlength="20">
(例： Adfk432d ) 
　 <a href="$basic_init->{'auth_url'}?mode=aview-remain" class="size80" tabindex="-1">※パスワードを忘れてしまった場合は…</a>
</td>
</tr>
<tr><td></td><td>
<input type="submit" value="ログインする">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="$main::in{'back'}">
<input type="hidden" name="backurl" value="$main::in{'backurl'}">
<input type="hidden" name="login_doned" value="1">
<br><br>

<input type="checkbox" name="checkpass" value="1" id="login_check1"$checked_check1>
<span class="alert"><label for="login_check1">スペルチェック　…　ログインに失敗した場合、入力した「パスワード」を、画面にそのまま表\示させます（後ろに人がいないかご確認ください）。</label></span><br>
<input type="checkbox" name="other" value="1" id="login_check2"$checked_check2>
<span class="alert"><label for="login_check2">強力ログイン　…　「一部の掲示板で筆名がリンクにならない」「新チャット城、マイログが使えない」などの不具合が起こる場合は、チェックを入れてください。</label></span><br>
</td></tr>
</table><br>);

$form .= qq(
<ul>
<li><a href="$basic_init->{'auth_url'}?mode=aview-newform$main::backurl_query_enc">→アカウントをお持ちでない方は、こちらから新規登録してください。</a></li>
<li><a href="$basic_init->{'auth_url'}?mode=aview-remain">→パスワードを忘れてしまった場合の再発行。</a></li>
</ul>
);


$form .= qq(
</div>
</form>
);

$form .= qq(<h2>ログイン時のご注意</h2>);

$form .= qq(<ul>\n);
$form .= qq(<li>アカウントにメールアドレスが登録されている場合、ログインした時点で自分にメールが送信されます。\n);

$form .= qq(</ul>\n);

return($form);

}


#-----------------------------------------------------------
# ログアウト前の画面
#-----------------------------------------------------------
sub logout_form_view{

my $self = shift;
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my $sns = new Mebius::SNS;
my($server_domain) = Mebius::server_domain();
my($basic_init) = Mebius::basic_init();

my $title = "ログアウト ( $server_domain )";
my $action = $basic_init->{'this_server_main_script_url'};

my $print = qq(
<h1>$title</h1>
本当にログアウトしますか？<br><br>
<form action="$action" method="post" utn>
<div>
<input type="hidden" name="mode" value="logout">);

$print .= $html->input("hidden","account",$my_account->{'id'});
$print .= $html->input("submit","action","ログアウトする");
$print .= $self->server_move_input_tag();
$print .= qq(<input type="hidden" name="logout_doned" value="1">
</div>
</form>
);

$sns->print_html($print,{ BCL => [$title] , Title => $title });

exit;

}


#-------------------------------------------------
# ログアウト
#-------------------------------------------------
sub logout{

# 宣言
my $self = shift;
my($basic_init) = Mebius::basic_init();
my($none,$next,$logout_doned);
my $query = new Mebius::Query;
my $sns = new Mebius::SNS;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($server_domain) = Mebius::server_domain();

	# Get送信を禁止
	if(!$query->post_method()){ main::error("GET送信はできません。"); }

# 二重クッキーセットを防止
$main::no_headerset = 1;

# タイトルなど定義
my $head_link3 = qq(ログアウト);

# ジャンプ
my $jump_url = $basic_init->{'auth_url'};
my $jump_sec = 5;

$next = $self->relay_login_or_logout_form({ Logout => 1 });

my $print = qq(ログアウトしました。（<a href="$basic_init->{'auth_url'}">→進む</a>）<br><br>$next);

# クッキーをセット
	if($param->{'account'} eq $my_account->{'id'}){
		Mebius::Cookie::set_main({ account => "" , hashed_password => "" , } );
	}

$sns->print_html($print,{ BCL => [$head_link3] , Title => "ログアウト" });

exit;

}

#-----------------------------------------------------------
# 各サーバーでの連続したログイン/ログアウトフォーム
#-----------------------------------------------------------
sub relay_login_or_logout_form{

my $html = new Mebius::HTML;
my $self = shift;
my $use = shift;
my($server_domain) = Mebius::server_domain();
my($my_account) = Mebius::my_account();
my($next);

	if(!$self->server_move_input_tag()){ return(); }
	if(!$self->relay_next_domain()){ return(); }

my $next_domain = $self->relay_next_domain();
my $action = "http://$next_domain/_main/";

$next .= qq(<form action="$action" method="post" utn><div>);
$next .= $self->server_move_input_tag();
$next .= $html->input("hidden","account",$my_account->{'id'}); # $my_account->{'id'} は念のため。実際には param で渡された値が入る
$next .= $html->input("hidden","backurl");

		if($use->{'Logout'}){
			$next .= qq(うまくログアウトできない場合は、サーバーごとにログアウトしてください。);
			$next .= $html->input("hidden","mode","logout");
			$next .= $html->input("submit","action","$next_domain からログアウト");
		} elsif($use->{'Login'}) {
			$next .= qq(サーバーごとのログインモードです。);
			$next .= $html->input("hidden","other");
			$next .= $html->input("hidden","authid");
			$next .= $html->input("hidden","passwd1");
			$next .= $html->input("hidden","mode","login");
			$next .= $html->input("submit","action","$next_domain でログイン");
		}


$next .= qq(</div></form>);

$next; 

}


#-----------------------------------------------------------
# 次のURL
#-----------------------------------------------------------
sub relay_next_domain{

my $self = shift;
my($param) = Mebius::query_single_param();
my(@domain);

my @next_use_domain = $self->next_use_domains();


$next_use_domain[0];

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub next_use_domains{

my $self = shift;
my($param) = Mebius::query_single_param();
my(@domain,@use_domain);
my($server_domain) = Mebius::server_domain();

	if($param->{'relay_domains'}){
		@domain = $self->param_justy_domains($param->{'relay_domains'});
	} else {
		(@domain) = Mebius::all_domains();
	}

	# 現在のサーバーは使用するドメインに追加しない
	foreach my $domain (@domain){
			if($server_domain eq $domain){
				0;
			} else {
				push @use_domain , $domain;
			}
	}

@use_domain;

}


#-----------------------------------------------------------
# ドメイン毎ログインのための input タグを生成
#-----------------------------------------------------------
sub server_move_input_tag{

my $self = shift;
my($param) = Mebius::query_single_param();
my($server_domain) = Mebius::server_domain();
my $html = new Mebius::HTML;
my(@use_domain,@domain,$input_tag);

my @use_domain = $self->next_use_domains();
my $value = join "," , @use_domain;

	if($value){
		$input_tag = $html->input("hidden","relay_domains",$value,{ NotOverWrite => 1 });
	}

$input_tag;

}


#-----------------------------------------------------------
# クエリから
#-----------------------------------------------------------
sub param_justy_domains{

my $self = shift;
my $select_param = shift;
my(@all_domain) = Mebius::all_domains();
my @justy_domain;

	if(!$select_param){ return(); }

my @all_param_domain = split(/,/,$select_param);


	foreach my $domain (@all_domain){
			foreach my $param_domain (@all_param_domain){
					if($domain eq $param_domain){
						push @justy_domain , $domain;
					}
			}
	}

@justy_domain;

}


#-------------------------------------------------
# ログイン記録ファイル
#-------------------------------------------------
sub TryFile{

# 宣言
my($type,$xip) = @_;
my(undef,undef,$max_missed_count) = @_ if($type =~ /Get-hash/);
my(undef,undef,$input_id,$input_password,%renew) = @_ if($type =~ /Renew/);
my($line,$file_handle1,%data,@renew_line);
my($directory1,$directory2,$input_password_hashed,$i);
my($share_directory) = Mebius::share_directory_path();

	# ログイン失敗できる上限
	if(!$max_missed_count){
		$max_missed_count = 10;
	}

# 最大行数
my $max_line = 100;

# エンコード
my($xip_enc) = Mebius::Encode(undef,$xip);
	if($xip_enc eq ""){ return(); }

# ディレクトリ定義
$directory1 = "${share_directory}_login_try/";

	# アカウント名、パスワードが入力されていない場合は、ログイン失敗としてカウントしない
	if($type =~ /Login-missed/ && ($input_id eq "" || $input_password eq "")){
		return();
	}

	# ファイル定義
	if($type =~ /Auth-file/){
			if($type =~ /By-cookie/){
				$directory2 = "${directory1}_auth_cookie_login_try/";
			}
			elsif($type =~ /By-form/){
				$directory2 = "${directory1}_auth_form_login_try/";
			}
			else{
				return();
			}
	}

	# ファイル定義
	elsif($type =~ /Adventure-file/){
			if($type =~ /By-cookie/){
				$directory2 = "${directory1}_adventure_cookie_login_try/";
			}
			elsif($type =~ /By-form/){
				$directory2 = "${directory1}_adventure_form_login_try/";
			}
			else{
				return();
			}
	}

	# ファイル定義
	elsif($type =~ /FsWiki-file/){
			if($type =~ /By-cookie/){
				$directory2 = "${directory1}_fswiki_cookie_login_try/";
			}
			elsif($type =~ /By-form/){
				$directory2 = "${directory1}_fswiki_form_login_try/";
			}
			else{
				return();
			}
	}
	# ファイルタイプの定義がない場合
	else{
		return();
	}

# ファイル定義
$data{'file1'} = "${directory2}${xip_enc}_login_try.dat";

	# ファイルを開く
	if($type =~ /File-check-error/){
		$data{'f'} = open($file_handle1,"+<$data{'file1'}") || main::error("ファイルが存在しません。");
	}
	else{

		$data{'f'} = open($file_handle1,"+<$data{'file1'}");

			# ファイルが存在しない場合
			if(!$data{'f'}){
					# 新規作成
					if($type =~ /Renew/){
						# ディレクトリ作成
						Mebius::Mkdir(undef,$directory1);
						Mebius::Mkdir(undef,$directory2);
						Mebius::Fileout("Allow-empty",$data{'file1'});
						$data{'f'} = open($file_handle1,"+<$data{'file1'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# ファイルロック
	if($type =~ /Renew|Flock/){ flock($file_handle1,2); }

	# トップデータを展開
	for(1..10){
		chomp($data{"top$_"} = <$file_handle1>);
	}

# トップデータを分解 ( 空行も削除しないように )
($data{'key'},$data{'missed_count'},$data{'all_missed_count'}) = split(/<>/,$data{'top1'});
($data{'last_missed_yearmonthday'},$data{'last_missed_time'}) = split(/<>/,$data{'top2'});
($data{'last_input_id'},$data{'last_input_password_hashed'}) = split(/<>/,$data{'top3'});
(undef) = split(/<>/,$data{'top4'});
(undef) = split(/<>/,$data{'top5'});
(undef) = split(/<>/,$data{'top6'});
(undef) = split(/<>/,$data{'top7'});
(undef) = split(/<>/,$data{'top8'});
(undef) = split(/<>/,$data{'top9'});
(undef) = split(/<>/,$data{'top10'});

	# ファイルを展開
	while(<$file_handle1>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$login_try_time2,$encid2,$host2,$agent2,$cnumber2,$account2) = split(/<>/);

			# 更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$key2<>$login_try_time2<>$encid2<>$host2<>$agent2<>$cnumber2<>$account2<>\n");

			}

	}

	# ● ハッシュ調整

	# 日が変わったらログイン回数をキャンセルする
	if($data{'last_missed_yearmonthday'} ne "$main::thisyearf-$main::thismonthf-$main::todayf"){
		$data{'missed_count'} = 0;
		$data{'missed_count'} = 0;
	}

	# 失敗回数オーバー
	if($data{'missed_count'} >= $max_missed_count){
		$data{'error_flag'} = qq(今日のログインの失敗回数が多すぎるため、実行出来ません。明日また試してください。);
	}

	# ● ファイル更新
	if($type =~ /Renew/){

			# ハッシュを一斉更新
			foreach(keys %renew){
					$data{$_} = $renew{$_};
			}

			# 失敗回数を増やす場合
			if($type =~ /Login-missed/){

					# 入力されたパスワードをハッシュ化
					($input_password_hashed) = Mebius::Crypt::crypt_text("Digest-base64",$input_password,"$input_id,$input_id,$input_id,$input_id,$input_id,$input_id,$input_id,$input_id,$input_id,$input_id");

					# アカウント名、パスワード共に前回の全く同じ場合は、失敗回数を増やさずリターン
					if($data{'last_input_id'} eq $input_id && $data{'last_input_password_hashed'} eq $input_password_hashed){
						close($file_handle1);
						return();
					}

				# 失敗カウントを増やす
				$data{'missed_count'}++;
				$data{'all_missed_count'}++;
				$data{'last_missed_time'} = time;
				$data{'last_missed_yearmonthday'} = "$main::thisyearf-$main::thismonthf-$main::todayf";
				$data{'last_input_id'} = $input_id;
				$data{'last_input_password_hashed'} = $input_password_hashed;
				#$data{'agent'} = $main::agent;
				#$data{'addr'} = $main::addr;
			}

		# 更新データを定義 ( 空行も削除しないように )
		push(@renew_line,"$data{'key'}<>$data{'missed_count'}<>$data{'all_missed_count'}<>\n");
		push(@renew_line,"$data{'last_missed_yearmonthday'}<>$data{'last_missed_time'}<>\n");
		push(@renew_line,"$data{'last_input_id'}<>$data{'last_input_password_hashed'}<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");
		push(@renew_line,"<>\n");


		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}

# ファイルを閉じる
close($file_handle1);

	# パーミッション変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$data{'file'}); }

# リターン
return(\%data);

}

#-----------------------------------------------------------
# ログイン履歴( アカウント別 ）
#-----------------------------------------------------------
sub login_history{

# 局所化
my $self = shift;
my($type,$file) = @_;
my $account = $file;
my(undef,undef,$myaccount) = @_ if($type =~ /(Index|Onedata)/);
my(undef,undef,$make_account_blocktime) = @_ if($type =~ /(Deny-make-account)/);
my($basic_init) = Mebius::basic_init();
my($share_directory) = Mebius::share_directory_path();

my($line,$line_plus,$i,$encid,$my,@renew_line,$filehandle1,$gethost,$top,$index_line,$interbel_second);
my($host_view_on,$cnumber_view_on,$encid_view_on,$agent_view_on,%self,$FILE1,%onedata,$my_account);
my($time) = (time);

# 各種情報を取得
my($my_cookie) = Mebius::my_cookie_main(); # logined にすると無限ループが起こるので注意
my($access) = Mebius::my_access();
my $addr  = $ENV{'REMOTE_ADDR'};

# CSS定義
$main::css_text .= qq(
td.agent2{font-size:50%;}
th{text-align:left;}
);

# 最大記録行数
my $max_line = 50;

# 取り込み処理
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# 汚染チェック
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }
$self{'file1'} = "${share_directory}_login_history/${file}_login_history.log";

	# 閲覧時の権限チェック ( Mebius::Auth::File からのループに注意！ 限定された処理でだけおこなうこと )
	if($type =~ /(Index|Onedata)/){
		($my_account) = Mebius::my_account();
			if($file ne $myaccount && !$my_account->{'admin_flag'} && $type !~ /Admin/){ return(); }
	}

# ファイル更新のインターバル秒数を設定
$interbel_second = 1*60*60;

# ログイン履歴を開く
open($FILE1,"+<",$self{'file1'});

	# ファイルを開く
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$self{'file1'}) || main::error("ファイルが存在しません。");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$self{'file1'});

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($type =~ /Renew/){
						Mebius::Mkdir(undef,$self{'directory1'});
						Mebius::Fileout("Allow-empty",$self{'file1'});
						$self{'f'} = open($FILE1,"+<",$self{'file1'});
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($type =~ /Renew/){ flock($FILE1,2); }

# トップデータを開く
chomp( my $top1 = <$FILE1>);

# トップデータを分解
($self{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$FILE1>){

		# ループカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$lasttime2,$addr2,$host2,$cnumber2,$agent2,$encid2) = split(/<>/);

			# ○1行をゲットする処理
			if($type =~ /Onedata/){
				close($FILE1);
					%onedata = ("key" => $key2 , "lasttime" => $lasttime2 , "addr" => $addr2 , 
						"host" => $host2, "cnumber" => $cnumber2, "agent" => $agent2, "encid" => $encid2);
					return(%onedata);
			}

			# ●ファイル更新のための処理
			if($type =~ /Renew/){

				# 初回ループのみの処理
				if($i == 1){

					# ファイルを更新せずにリターンする場合
					# IPアドレスかUAが同一、なおかつ前回の更新から一定時間が経過していない場合
					if(($addr2 eq $addr || $agent2 eq $access->{'multi_user_agent_escaped'}) && $time <= $lasttime2 + $interbel_second){
						close($FILE1);
						return();
					}

				}

				# 接続データが重複する場合は、次へ
				if($agent2 eq $access->{'multi_user_agent_escaped'} && $addr2 eq $addr && $cnumber2 eq $my_cookie->{'char_escaped'}){ next; }
				if($main::k_access && $agent2 eq $access->{'multi_user_agent_escaped'}){ next; }

				# 更新行を追加する
				if($i <= $max_line){
					push(@renew_line,"$key2<>$lasttime2<>$addr2<>$host2<>$cnumber2<>$agent2<>$encid2<>\n");
				}

			}

			# ●インデックス取得のための処理
			if($type =~ /Index/){
				
				# 整形
				$index_line .= qq(<tr>);

				# 日付を整形
				my($date2) = Mebius::Getdate("",$lasttime2);

					# 管理番号を表示
					if($type =~ /Admin/ || $my_account->{'admin_flag'} >= 1){
						my(%history_cnumber) = main::get_reshistory("CNUMBER Get-hash",$cnumber2);
						my($enccnumber2) = Mebius::Encode("",$cnumber2);
						$cnumber2 = qq(<a href="${main::jak_url}index.cgi?mode=cdl&amp;file=$enccnumber2&amp;filetype=number" class="manage">$cnumber2</a>);
							foreach(split(/\s/,$history_cnumber{'accounts'})){
									if($_ eq $account){ next; }
								$cnumber2 .= qq(<br$main::xclose> );
								#$cnumber2 .= qq( <a href="${main::auth_url}$_/">$_</a> \n);
									if($my_account->{'admin_flag'} >= 1){
										$cnumber2 .= qq( <a href="$basic_init->{'auth_url'}aview-login-$_.html" style="color:#080;">$_</a> \n);
									}
									else{
										$cnumber2 .= qq( <a href="$basic_init->{'auth_url'}$_/">$_</a> \n);
									}
								$cnumber2 .= qq( <a href="${main::jak_url}index.cgi?mode=cdl&amp;file=$_&amp;filetype=account" style="color:#f00;">$_</a> \n);
							}
						$cnumber_view_on = 1;
					}
					else{ $cnumber2 = ""; }

					# ホスト名を表示(マスター用)
					if(($type =~ /Admin/ && $main::admy_rank >= $main::master_rank) || ($type !~ /Admin/ && $my_account->{'master_flag'})){
						my(%history_host) = main::get_reshistory("HOST Get-hash",$host2);
						my($enchost2) = Mebius::Encode("",$host2);
						$host2 = qq(<a href="${main::jak_url}index.cgi?mode=cdl&amp;file=$enchost2&amp;filetype=host" class="manage">$host2</a>);
							foreach(split(/\s/,$history_host{'accounts'})){
									if($_ eq $account){ next; }
								$host2 .= qq(<br$main::xclose> );
								#$host2 .= qq( <a href="${main::auth_url}$_/">$_</a> \n);
								$host2 .= qq( <a href="$basic_init->{'auth_url'}aview-login-$_.html" style="color:#080;">$_</a> \n);
								$host2 .= qq( <a href="${main::jak_url}index.cgi?mode=cdl&amp;file=$_&amp;filetype=account" style="color:#f00;">$_</a> \n);
							}
						$host_view_on = 1;
					}
					#elsif($file eq $myaccount){ $host_view_on = 1; }
					else{ $host2 = ""; }

					# UAを表示（管理者用）
					if($type =~ /Admin/ || $my_account->{'admin_flag'} >= 1){
						my(%history_agent) = main::get_reshistory("KACCESS_ONE Get-hash",$agent2);
						my($encagent2) = Mebius::Encode("",$agent2);
						$agent2 = qq(<a href="${main::jak_url}index.cgi?mode=cdl&amp;file=$encagent2&amp;filetype=agent" class="manage">$agent2</a>);
							foreach(split(/\s/,$history_agent{'accounts'})){
									if($_ eq $account){ next; }
								$agent2 .= qq( <a href="$basic_init->{'auth_url'}$_/" style="color:#f00;">$_</a> \n);
							}
						$agent_view_on = 1
					}
					elsif($file eq $myaccount){ $agent_view_on = 1; }

					# IDを表示
					if($type =~ /Admin/ || $my_account->{'admin_flag'} >= 1 || $file eq $myaccount){
						$encid2 = qq(<i>★$encid2</i>);
						$encid_view_on = 1;
					}

				# 表示行を定義
				$index_line .= qq(<td>$date2</td>);
				if($cnumber_view_on){ $index_line .= qq(<td class="red">$cnumber2</td>); }
				if($host_view_on){ $index_line .= qq(<td class="red">$host2</td>); }
				if($encid_view_on){ $index_line .= qq(<td>$encid2</td>); }
				if($agent_view_on){ $index_line .= qq(<td class="green agent2">$agent2</td>); }
				$index_line .= qq(</tr>);

			}

			# ●アカウントロック時の、新規作成停止処理
			if($type =~ /Deny-make-account/){

				my(%renew_history);
				$renew_history{'make_account_blocktime'} = $make_account_blocktime;
				# 新 アカウント発行制限
				Mebius::HistoryAll("RENEW Use-renew-hash Not-isp",undef,$host2,$agent2,$cnumber2,undef,%renew_history);
			}

	}

	# ●ファイル更新
	if($type =~ /Renew/){

		# ＩＤを取得
		($encid) = main::id();

		# ホスト名を取得
		($gethost) = Mebius::GetHostWithFile();
		
		# 追加
		unshift(@renew_line,"1<>$time<>$addr<>$gethost<>$my_cookie->{'char_escaped'}<>$access->{'multi_user_agent_escaped'}<>$encid<>\n");

			# トップデータの調整
			if($self{'key'} eq ""){ $self{'key'} = 1; }

		# トップデータを追加
		unshift(@renew_line,"$self{'key'}<>\n");

		# ファイル更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;

	}

# ファイルを閉じる
close($FILE1);

	# パーミッション変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$self{'file1'}); }

	# インデックスを整形してリターン
	if($type =~ /Index/){
		my($th);
		$th .= qq(<th>記録日時</th>);
			if($cnumber_view_on){ $th .= qq(<th>管理番号</th>); }
			if($host_view_on){ $th .= qq(<th>ホスト名</th>); }
			if($encid_view_on){ $th .= qq(<th>ＩＤ</th>); }
			if($agent_view_on){ $th .= qq(<th>ユーザーエージェント</th>); }
		$th = qq(<tr>$th</tr>\n);

			if($index_line){ $index_line = qq(<table summary="アカウントのアクセス履歴" class="login_history">$th$index_line</table>); }	
		return($index_line);
	}

}


#-------------------------------------------------
# ログイン
#-------------------------------------------------
sub login{

# 基本設定を取得
my $self = shift;
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my($account,$line,$xiptop1,$line_ses,$encpass,$ises);
my($encpass1,$encpass2,$text,$login_success_flag,$crypted_password,$collation_type,$jump_sec,$jump_url);
require "${init_directory}auth_makeid.pl";

my @all_domains = Mebius::all_domains();

	if($ENV{'REQUEST_METHOD'} ne "POST"){ main::error("GET送信は出来ません。"); }

# ホスト名を取得
my($gethost) = Mebius::GetHostWithFile();
my($host) = Mebius::get_host();

# 大文字も小文字に
my $account = lc $param->{'authid'};

# 基本エラー
my($account_name_error) = Mebius::Auth::AccountName("",$account);
	if($account_name_error){ Mebius::Auth::Index("Error-browse",$account_name_error); }


	# ログイン後のページへ
	if($param->{'logined'}){ main::logined(); }

	# ＧＥＴ送信を禁止

# ログインのトライ回数をチェック
my($login_missed) = TryFile("Get-hash Auth-file By-form",$main::xip);

	# 今日のログイン失敗数が上限を超えている場合、無条件にエラーに
	if($login_missed->{'error_flag'}){
		my $message = shift_jis_return($login_missed->{'error_flag'});
		Mebius::Auth::Index("Error-browse",$message);
	}


# タイトルなど定義
my $head_link3 = qq(&gt; ログイン);

	# 各種エラー
	if($param->{'passwd1'} eq ""){
		Mebius::Auth::Index("Error-browse","パスワードを入力してください。");
	}

# アカウントファイルを開く
# 何故 Not-file-check に？ => アカウントの存在チェックを簡易実行されないように、必ず「アカウント名かパスワードが間違っています」のエラーを出すために
my(%account) = Mebius::Auth::File("Not-file-check",$account);

# ●パスワード照合
($login_success_flag,$crypted_password,$collation_type) = Mebius::Auth::Password("Collation-password",$param->{'passwd1'},$account{'salt'},$account{'pass'});

	# ログを記録
	if($login_success_flag){
		Mebius::AccessLog(undef,"Account-collation-password-succesed",qq(アカウント: $account / 照合タイプ : $collation_type ));
	}	else {
		Mebius::AccessLog(undef,"Account-collation-password-missed",qq(アカウント: $account / 照合タイプ : $collation_type ));
	}

	# パスワード照合に成功した場合
	if($login_success_flag){

		my $email_text = "アカウント \@$account にログインしました。";
			shift_jis($email_text);

		# メール送信
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "$email_text" , comment => "$email_text $basic_init->{'auth_url'}" });

		# クッキーをセット
		Mebius::Cookie::set_main({ account => $account , hashed_password => $crypted_password });

	}
	# ログインに失敗した場合
	else{

		my $email_text = "アカウントへのログインに失敗しました。";
			shift_jis($email_text);

		# メール送信
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "$email_text" , comment => "$email_text $basic_init->{'auth_url'}" });

		# 今日のログイン失敗回数を増やす
		TryFile("Renew Login-missed  Auth-file By-form",$main::xip,$account,$main::in{'passwd1'});

		# エラーを表示する
		Mebius::Auth::Index("Error-browse",qq(パスワード、またはアカウント名 ( <a href=\"$basic_init->{'auth_url'}$account/\">$account</a> ) が間違っています。（<a href=\"$basic_init->{'guide_url'}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB\">→よくある質問</a>）
		<br>大文字/小文字の違いなどに注意して、正しいパスワード・アカウント名を入力してください。
		<br><br>※アカウント名が分からない場合は<a href=\"$basic_init->{'auth_url'}aview-newac-1.html\">アカウント一覧</a>から検索できます。
		));
	}


	# 第二ログインをおこなう場合
	if($param->{'other'} && $self->server_move_input_tag()){
		$text = $self->relay_login_or_logout_form({ Login => 1 });

	# ログイン後、ページジャンプ $jump_sec = $auth_jump;
	} else {

		# ジャンプ先
		$jump_sec = 1;
		$jump_url = qq($basic_init->{'auth_url'}$account/feed);
			foreach(@all_domains){
					if($param->{'backurl'} =~ /http:\/\/($_)\/(.+)/){
						$jump_url = $&;
					}
			}

		# ログイン後の文章
		$text = qq(ログインしました。（<a href="$jump_url">→進む</a>）);

	}

Mebius::HistoryAll("RENEW My-file");

Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => "ログイン - メビウスリング" , css_files => ["auth"] , RefreshURL => $jump_url , RefreshSecond => $jump_sec , BCL => [$head_link3] },$text);

# 終了
exit;

}

package Mebius;

#-----------------------------------------------------------
# アカウント / 個体識別番号別のセーブデータ
#-----------------------------------------------------------
sub save_data{

# 宣言
my($use,$target) = @_;
#my($use,$target,$k_access) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($line,$savefile,$backfile,%self,$file1,@renew_line,$renew);

	# 汚染チェック
		if($target eq ""){ return; }

	# ファイル定義など （ アカウント ）
	if($use->{'FileType'} eq "Account"){

		# アカウント名判定
		if(Mebius::Auth::AccountName(undef,$target)){ return(); }

		#$savefile = "${init_directory}_save_account/${file}_save_account.cgi";
		$file1 = "${init_directory}_save_account/${target}_save_account.cgi";
	}

	# ファイル定義など （ モバイル ）
	elsif($use->{'FileType'} eq "Mobile"){

		my($device) = Mebius::device($target);
			if($device->{'mobile_uid'}){
				$file1 = "${init_directory}_save_mobile/$device->{'mobile_uid'}_save_$device->{'mobile_id'}.cgi";
				#$backfile = "${init_directory}_backup/_save_mobile/${file}_save_${k_access}.cgi";
				if($main::cookie eq ""){ $main::cookie = 1; }
			}
	}

	# タイプ定義がない場合
	else{ return; }

	# ファイルを開く
	my($FILE1,$read_write) = Mebius::File::read_write($use,$file1);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

	# トップデータを展開
	for(1..2){ chomp($self{"top$_"} = <$FILE1>); }

# トップデータを分解
($self{'cookie_name'},$self{'cookie_gold'},$self{'cookie_regist_count'},$self{'cookie_regist_all_length'},$self{'cookie_email'},$self{'cookie_follow'},$self{'cookie_thread_up'},undef,$self{'cookie_font_color'},$self{'cookie_age'},$self{'cookie_refresh_second'},$self{'cookie_bbs_news'},$self{'cookie_fontsize'},$self{'cookie_omit_text'},$self{'cookie_secret'},$self{'cookie_account'},$self{'cookie_hashed_password'},undef,$self{'cookie_id_fillter'},$self{'cookie_account_fillter'}) = split(/<>/,$self{'top1'});
($self{'set_count'},undef,$self{'cookie_silver'}) = split(/<>/,$self{'top2'});

	# ファイル更新
	if(exists $use->{'Renew'}){

			# 任意の更新とリファレンス化
			($renew) = Mebius::Hash::control(\%self,$use->{'select_renew'});
			($renew) = Mebius::format_data_for_file($renew);

		# トップデータを追加
	push(@renew_line,"$renew->{'cookie_name'}<>$renew->{'cookie_gold'}<>$renew->{'cookie_regist_count'}<>$renew->{'cookie_regist_all_length'}<>$renew->{'cookie_email'}<>$renew->{'cookie_follow'}<>$renew->{'cookie_thread_up'}<><>$renew->{'cookie_font_color'}<>$renew->{'cookie_age'}<>$renew->{'cookie_refresh_second'}<>$renew->{'cookie_bbs_news'}<>$renew->{'cookie_fontsize'}<>$renew->{'cookie_omit_text'}<>$renew->{'cookie_secret'}<>$renew->{'cookie_account'}<>$renew->{'cookie_hashed_password'}<><>$renew->{'cookie_id_fillter'}<>$renew->{'cookie_account_fillter'}<>\n");
	push(@renew_line,"$renew->{'set_count'}<><>$renew->{'cookie_silver'}<>\n");

		# ファイル更新
		Mebius::File::truncate_print($FILE1,@renew_line);

	}

close($FILE1);

	# パーミッション変更
	if(exists $use->{'Renew'}){ Mebius::Chmod(undef,$file1); }

	# リターン
	if(exists $use->{'Renew'}){
		return($renew);
	}
	else{
		return(\%self);
	}

}



1;
