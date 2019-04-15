
# 基本機能
use strict;
use Mebius::Fixurl;
use Mebius::Handle;
use Mebius::Domains;
package Mebius::Admin;

#-----------------------------------------------------------
# オートリンク
#-----------------------------------------------------------
sub auto_link{

my($text) = @_;
my($self);

		# 一般用→管理用への修正
		my($self) = Mebius::Fixurl("Normal-to-admin",$text);

		# 自動リンク
		($self) = Mebius::auto_link($self);

$self;

}


#-----------------------------------------------------------
# http または https を返す
#-----------------------------------------------------------
sub http_kind{

my($self);

	if(Mebius::alocal_judge()){
		$self = "http";
	} else {
		$self = "https";
	}

}

#-----------------------------------------------------------
# 管理用の基本URL （サーバーごと）
#-----------------------------------------------------------
sub basic_url{

my($server_addr) = @_;

my($main_server_domain) = Mebius::main_server_domain($server_addr);

http_kind() . qq(://) . $main_server_domain . qq(/jak/);

}



#-----------------------------------------------------------
# 管理用フラグの扱い
#-----------------------------------------------------------
sub ridge_admin_flag{
my$flag;

$flag = 1 ;

		sub admin_mode_judge{
				if($ENV{'MOD_PERL'}){
					0;
				} else {
					$flag;
				}
			$flag;
		}
}

#-----------------------------------------------------------
# SNSでの管理者レベル
#-----------------------------------------------------------
sub sns_account_admin_level{

my($my_account) = Mebius::my_account();

$my_account->{'admin_flag'};

}

#-----------------------------------------------------------
# 管理者レベルの設定
#-----------------------------------------------------------
sub basic_init{

my(%self);

# 管理者ランク設定
$self{'master_rank'} = 100;
$self{'leader_rank'} = 50;
$self{'sesdir'} = "./ses/";


\%self;

}


#-----------------------------------------------------------
# HTMLヘッダに追加する部分
#-----------------------------------------------------------
sub html_header_navigation{


my($self);
my($basic_init) = Mebius::basic_init();
my($my_admin) = Mebius::my_admin();

$self .= qq(
\n<!-- ▼ヘッダリンク -->
<div class="admark">
<a href="$main::home" class="red">管理モード</a>
<a href="$basic_init->{'admin_http'}://mb2.jp/jak/index.cgi">娯楽</a>
);

	# 記録ファイルへのリンク
	if(Mebius::alocal_judge()){
		$self .= qq(<a href="index.cgi?mode=vadhistory&amp;file=$main::admy_file" class="red">記録</a>);
	} else {
		$self .= qq(<a href="$basic_init->{'admin_url'}index.cgi?mode=vadhistory&amp;file=$main::admy_file" class="red">記録</a>);
	}

	# 会員制の掲示板
	if($my_admin->{'leader_flag'}){ $self .= qq( <a href="$basic_init->{'admin_http'}://aurasoul.mb2.jp/jak/sc$main::admy_file.cgi" class="red">会員制</a>); }

# 管理者一覧など
$self .= qq( -);
$self .= qq( $main::adroom_link_utf8);
$self .= qq( <a href="$basic_init->{'admin_report_bbs_url'}">削除依頼</a>);
$self .= qq( <a href="$basic_init->{'guide_url'}%B4%C9%CD%FD%A3%D1%A1%F5%A3%C1">Ｑ＆Ａ</a>);
$self .= qq( <a href="$basic_init->{'admin_url'}index.cgi?mode=echeck-p-1" class="green">注意</a> );
$self .= qq( <a href="http://mb2.jp/_main/admins.html">管理者一覧</a>);
#$self .= qq( <a href="https://aurasoul.mb2.jp/jak/chat/comchat.cgi">チャット</a>);
$self .= qq( <a href="$basic_init->{'admin_main_url'}?mode=mydata">マイ設定</a>);

$self .= qq( <a href="$basic_init->{'admin_main_url'}?mode=allregistcheck">投稿判定</a>(<a href="$basic_init->{'admin_main_url'}?mode=allregistcheck&amp;select=$main::todayf">★</a>) );

	if($my_admin->{'master_flag'}){
		$self .= qq(<a href="$basic_init->{'guide_url'}?action=LOGIN">ガイド管理</a>);
		$self .= qq( <a href=").e($basic_init->{'admin_main_url'}).qq(?mode=make_password">パスワード</a>);
		$self .= qq( <a href=").e($basic_init->{'admin_main_url'}).qq(?mode=bbs_status&type=create_bbs_form">掲示板の作成</a>);

	}

# HTML
$self .= qq(</div>\n<!-- ▲ヘッダリンク -->\n\n);

$self;

}

#-----------------------------------------------------------
# 自分のデータ
#-----------------------------------------------------------
sub my_account{

# 宣言
my($use,$account) = @_;
my(%admin);

# Near State （呼び出し） 2.30
my $StateName1 = "my_account";
my $StateKey1 = "$account";
my($state) = Mebius::State::Call(__PACKAGE__,$StateName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$StateName1,$StateKey1); }

	# Near State （保存） 2.30
	if($StateName1){ Mebius::State::Save(__PACKAGE__,$StateName1,$StateKey1,\%admin); }

return(\%admin);

}


#-----------------------------------------------------------
# ログインを実行
#-----------------------------------------------------------
sub MemberFile{

# 局所化
my($type,$id,$password,$session_id,$host) = @_;
my(undef,undef,undef,%renew) = @_ if($type =~ /Use-renew-hash/);
my($login_flag,$member_handler,%admy,@renew_line,@allow_hosts);
my $cookie_key = $ENV{'SERVER_ADDR'};
my($admin_basic_init) = Mebius::Admin::basic_init();
my($share_directory) = Mebius::share_directory_path();
my($host) = Mebius::get_host_state();

	# 汚染チェック
	if($id eq ""){ main::error("管理者IDを入力してください。"); }
	if($id =~ /\W/){ main::error("管理者IDが不正です。"); }
	#if($password eq ""){ main::error("パスワードを入力してください。"); }

	# セッションIDを新規作成
	if($type =~ /Enter-login/ && !$session_id){ $session_id = Mebius::Crypt::char(undef,30); }

# ファイル定義
my $directory1 = "${share_directory}_admin_member/";
my $file = "${directory1}${id}_member.dat";

# メンバーファイルを展開
open($member_handler,"<",$file) && ($admy{'f'} = 1);

	# ファイルロック
	if($type =~ /Renew/){ flock($member_handler,1); }

# トップデータを分解
chomp($admy{'top1'} = <$member_handler>);
chomp($admy{'top2'} = <$member_handler>);
chomp($admy{'top3'} = <$member_handler>);
chomp($admy{'top4'} = <$member_handler>);
chomp($admy{'top5'} = <$member_handler>);
chomp($admy{'top6'} = <$member_handler>);
close($member_handler);

	if($type =~ /File-check-error/ && !$admy{'f'}){ main::error("ファイルが存在しません。"); }

# ハッシュを定義
($admy{'id'},$admy{'password'},$admy{'rank'},$admy{'name'},$admy{'account'},$admy{'email'},$admy{'file'}) = split(/<>/,$admy{'top1'});
($admy{'deleted_text'},$admy{'mobile_email'},$admy{'use_mailform'}) = split(/<>/,$admy{'top2'});
($admy{'allow_isp_group'}) = split(/<>/,$admy{'top3'});
($admy{'last_renew_time'}) = split(/<>/,$admy{'top4'});
($admy{'concept'}) = split(/<>/,$admy{'top5'});
($admy{'res_template'}) = split(/<>/,$admy{'top6'});

# ハッシュ調整 / 統合
$admy{'second_id'} = $admy{'file'};

	# ●自分のアクセスの場合
	if($type =~ /My-access/){

			# アカウントが廃止されている場合
			if($admy{'concept'} =~ /Close-account/){
				main::error("凍結中のアカウントです。");
			}

			# IDファイルが存在しない場合
			if(!$admy{'f'}){

					# メール送信
					Mebius::Admin::AlertMail(undef,"存在しないID ( $id ) へのログイン挑戦");

					# エラー
					main::error("管理者ID、またはパスワードが一致しません。");

			}

			# パスワードが設定されていない場合
			if($admy{'password'} eq ""){ main::error("このメンバーにはパスワードが設定されていません。マスターに連絡してください。"); }

		# 局所化
		my($allow_isp_flag,$allow_isp);

		# ホスト名から自分のISPを抽出
		my($isp) = Mebius::Isp(undef,$host);

			if(!$admy{'allow_isp_group'}){ main::error("管理メンバーの設定が正常に出来ていません。マスターに連絡してください。"); }


			foreach my $allow_isp (split(/->/,$admy{'allow_isp_group'})){
					if($allow_isp && $host =~ /\.$allow_isp$/){ $allow_isp_flag = 1; }
			}


			# # ISPが不正な場合
			# if(!$allow_isp_flag){

			# 	# 警告メール送信
			# 	Mebius::Admin::AlertMail(undef,"不正なISP ( $isp ) ",undef,%admy);

			# 	# ログを記録
			# 	Mebius::AccessLog("Not-unlink-file","Admin-bad-host","管理者 $admy{'id'} のアクセスで、ISPが合致しませんでした。 攻撃者のホスト： $host");

			# 	# エラー表示
			# 		if(!Mebius::alocal_judge()){
			# 			main::error("ログイン出来ません。");
			# 		}
			# }
	}

		# ●自分のアクセスで、パスワードが合致した場合
		if($type =~ /My-access/) {

				# パスワード照合
				my($password_successed_flag) = Mebius::Admin::DeCrypt($password,$admy{'password'});

				# メルアドが設定されていないと、ランクを下げる
				if(!$admy{'email'} && !$admy{'mobile_email'}){
					$admy{'rank'} = 0;
					$admy{'not_start_flag'} = 1;
				}

				# パスワードが一致した場合
				if($password_successed_flag || $type =~ /Session-login/){
					$login_flag = 2;
					$main::admy_name = $main::my_name = $admy{'name'};
					($main::admy_nickname) = split(/☆/,$admy{'name'});
					$main::admy_rank = $main::my_rank = $admy{'rank'};
					$main::admy_file = $main::admy_second_id = $admy{'file'};
					$main::admy_account = $admy{'account'};
					$main::admy_email = $admy{'email'};
					$main::admy_session = $session_id;
					$main::admy_id = $admy{'id2'};
				}
				# 一致しなかった場合
				else{
					Mebius::Admin::AlertMail(undef,"パスワードの不一致",undef,%admy);
					main::error("管理者ID、またはパスワードが一致しません。");
				}
		}


	# ●ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

			# ハッシュ展開
			foreach(keys %renew){
				$admy{$_} = $renew{$_};
			}

		push(@renew_line,"$admy{'id'}<>$admy{'password'}<>$admy{'rank'}<>$admy{'name'}<>$admy{'account'}<>$admy{'email'}<>$admy{'file'}<>\n");
		push(@renew_line,"$admy{'deleted_text'}<>$admy{'mobile_email'}<>$admy{'use_mailform'}<>\n");
		push(@renew_line,"$admy{'allow_isp_group'}<>\n");
		push(@renew_line,"$admy{'last_renew_time'}<>\n");
		push(@renew_line,"$admy{'concept'}<>\n");
		push(@renew_line,"$admy{'res_template'}<>\n");

		Mebius::Fileout(undef,$file,@renew_line);

		Mebius::Admin::MemberFookFile("Renew New-edit",$admy{'file'},$admy{'id'});

	}

	# ●入力フォームからログインした場合
	if($type =~ /Enter-login/ && $login_flag >= 2){

		# ファイル更新
			if($admin_basic_init->{'sesdir'}){
				Mebius::Fileout(undef,"$admin_basic_init->{'sesdir'}/$session_id.dat","$id<>$main::time<>\n");
			} else {
				main::error("セッション用のディレクトリが存在しません。");
			}

		# Cookieをセット
		my @t = gmtime(time + 24*60*60);
		my @m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
		my @w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
		my $gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);
		print "Set-Cookie: $cookie_key=$session_id; expires=$gmt; path=/; \n";

		# ログイン履歴を更新
		main::renew_logined();

		# メール送信
		Mebius::Admin::AlertMail(undef,"ログインしました",undef,%admy);

	}


return(%admy);

}


#-----------------------------------------------------------
# ひもづけファイル
#-----------------------------------------------------------
sub MemberFookFile{

# 宣言
my($type,$second_id,$id) = @_;
my(undef,undef,undef,%renew) = @_ if($type =~ /Renew/);
my($i,@renew_line,%data,$file_handler);
my($share_directory) = Mebius::share_directory_path();

	# 汚染チェック
	if($id =~ /\W/){ return(); }
	if($second_id =~ /\W/ || $second_id eq ""){ return(); }

# ファイル定義
my $file = "${share_directory}_admin_member/${second_id}_second_id.dat";

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file") || main::error("この管理者は存在しません。");
	}
	else{
		open($file_handler,"<$file");
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'id'}) = split(/<>/,$top1);


close($file_handler);

	# 新規更新
	if($type =~ /New-edit/){
		$data{'id'} = $id;
	}

	# ファイル更新
	if($type =~ /Renew/){
			foreach(keys %renew){
				$data{$_} = $renew{$_};
			}
		unshift(@renew_line,"$data{'key'}<>$data{'id'}<>\n");
		Mebius::Fileout(undef,$file,@renew_line);
	}

return(%data);

}

#-------------------------------------------------
#  crypt暗号
#-------------------------------------------------
sub encrypt_admin_password {

my($inpw) = @_;

# 文字列定義
my @char = ('a'..'z', 'A'..'Z', '0'..'9', '.', '/');

# 乱数で種を生成
my $salt = $char[int(rand(@char))] . $char[int(rand(@char))];

# 暗号化
my $encrypt = crypt($inpw, $salt) || crypt ($inpw, '$1$' . $salt);

$encrypt;

}


#-------------------------------------------------
#  crypt照合
#-------------------------------------------------
sub DeCrypt {
	my($inpw,$enpw) = @_;

	if ($enpw eq "") { main::error("認証できません"); }

	# 種抜き出し
	my($salt) = $enpw =~ /^\$1\$(.*)\$/ && $1 || substr($enpw, 0, 2);

	# 照合処理
	if (crypt($inpw, $salt) eq $enpw || crypt($inpw, '$1$' . $salt) eq $enpw) {
		return (1);
	} else {
		return (0);
	}
}

use Mebius::Directory;

#-----------------------------------------------------------
# 管理者一覧をディレクトリから取得
#-----------------------------------------------------------
sub MemberList{

# 宣言
my($type) = @_;
my($line);
my($share_directory) = Mebius::share_directory_path();

# ディレクトリを開く
my(@list) = Mebius::GetDirectory(undef,"${share_directory}_admin_member/");

	# ディレクトリを展開
	foreach(@list){

		# 局所化
		my($admin_id);

		# ファイル選別
		if($_ =~ /^(\w+)_member\.dat$/){ $admin_id = $1; } else { next; }

		# 色々な分解
		my($filename,$tail) = split(/\./,$_);
		my(%member) = Mebius::Admin::MemberFile("Get-hash Allow-empty-password",$admin_id);

			# 一般モード用のインデックスを取得
			if($type =~ /Get-index-normal/){
				$line .= qq(<div class="line-height-large">\n);
				$line .= qq($member{'name'});
					if($member{'account'}){ $line .= qq( / <a href="${main::auth_url}$member{'account'}/">\@$member{'account'}</a>\n); }
					if($member{'use_mailform'} eq "1" && $member{'email'}){ $line .= qq( / <a href="./admins-form-$member{'second_id'}.html">メールフォーム</a>); }
				$line .= qq(\n);
				$line .= qq(</div>\n);
			}

			# 管理用
			if($type =~ /Get-line-admin-record/){
				$line .= qq(<a href="index.cgi?mode=vadhistory&amp;file=$member{'file'}">$member{'name'}</a> );
			}

	}

return($line);

}

#-----------------------------------------------------------
# ログイン失敗履歴ファイル
#-----------------------------------------------------------
sub LoginMissedHistory{

# 宣言
my($type) = @_;
my(undef,$user_name,$missed_type,$handle) = @_ if($type =~ /New-login-missed/);
my($i,@renew_line,%data,$file_handler,$file1);

	# ファイル定義
	if($main::alocal_mode){ $file1 = "login_missed_history_admin_alocal.log"; }
	else{ $file1 = "login_missed_history_admin.log"; }

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1");
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2) = split(/<>/);

			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>\n");
			}

	}

close($file_handler);

	# 新規追加
	if($type =~ /New-login-missed/){
		unshift(@renew_line,"<>$missed_type<>$handle<>$user_name<>$main::time<>$main::date<>$main::host<>$main::agent<>");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);




}


#-----------------------------------------------------------
# 権限チェック
#-----------------------------------------------------------
sub LevelCheck{

# 宣言
my($type,$must_level) = @_;

	# 権限が足りない場合はエラーに
	if($main::admy{'rank'} < $must_level){
		main::error("この管理をするのに、必要な権限がありません。 <br$main::xclose> あなたの権限 : $main::admy{'rank'} / 必要な権限 $must_level");
	}

return();

}


#-----------------------------------------------------------
# 管理者とマスターに警告メールを送る
#-----------------------------------------------------------
sub AlertMail{

# 宣言
my($type,$mail_subject,$mail_body,%member) = @_;
my($member_address);

	# 携帯に送るか、PCに送るか
	if($member{'email'}){ $member_address = $member{'email'}; }
	elsif($member{'email_mobile'}){ $member_address = $member{'email_mobile'}; }

# 題名に情報を付加する
my $mail_subject_send = qq(管理モード : $mail_subject - $member{'id'} ( $main::host ));

# マスターにメールを送信
Mebius::Email::send_email("Allow-send-all To-master Important-message UTF8",undef,$mail_subject_send,$mail_body);

	# メンバーにメールを送信
	if($member_address){
		Mebius::Email::send_email("Allow-send-all View-access-data UTF8",$member_address,$mail_subject_send,$mail_body);
	}

return();

}


#-----------------------------------------------------------
# 自分の管理者情報を取得
#-----------------------------------------------------------
sub my_admin{

# 局所化
my($time) = time;
my(%session,%admy);
my $cookie_key = $ENV{'SERVER_ADDR'};
my($param) = Mebius::query_single_param();
my($admin_basic_init) = Mebius::Admin::basic_init();

	# 管理モードであることを確認
	if(!Mebius::Admin::admin_mode_judge()){ return(); }

# Near State （呼び出し） 2.30
my $HereName1 = "my_admin";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

# 連続ログイン可能時間
my $authtime = 24*60*60;

	# ●ログインを実行（ＰＯＳＴ）
	if($param->{'mode'} eq "login" && $ENV{'REQUEST_METHOD'} eq "POST") {

		(%admy) = Mebius::Admin::MemberFile("Enter-login Get-hash My-access",$param->{'id'},$param->{'pw'},undef,$main::host);

			# 古いセッションファイルを一掃
			Mebius::GetDirectory("Delete-all-file",$admin_basic_init->{'sesdir'},$authtime*7);

	}

	# ●ログイン中の処理
	else{

		my($key,$val,%cook);

		# クッキー取得
		my $cook = $ENV{'HTTP_COOKIE'};

			# Cookieから該当ID(セッションファイル名)を取り出す
			foreach ( split(/;/, $cook) ) {
				my($key,$val) = split(/=/);
				$key =~ s/\s//g;
				$cook{$key} = $val;
			}

			# 汚染チェック
			$cook{$cookie_key} =~ s/[^\w\.]//g;

			# Cookieが存在しない場合
			if(!$cook){ main::enter_disp(undef,"Cookieが無効ですか？"); }

			# セッションファイル、またはセッションＩＤがない場合、ＰＡＳＳ入力画面に移動
			if(!$cook{$cookie_key}){ main::enter_disp(); }

		# セッションファイルを開く
		open(IN,"<","$admin_basic_init->{'sesdir'}/$cook{$cookie_key}.dat") && ($session{'f'} = 1);
		chomp(my $sesdata = <IN>);
		close(IN);

			# このセッション名のファイルが存在しない場合は、ログイン画面を出す
			if(!$session{'f'}) {

					# クッキーにセッション名はあるが、サーバー側にセッションファイルがない場合（不正アタックの可能性アリ）
					if($cook{$cookie_key}){

						# メール送信
						my $email_alert_subject = qq(管理モード ： 存在しないセッション名でのアクセス ( $cook{$cookie_key} ));
						Mebius::Email::send_email("To-master Important-message",undef,$email_alert_subject);

						# セッションクッキー埋め込み
						our $gmt; #SSS → 何？
						print "Set-Cookie: ${cookie_key}=; expires=$gmt; path=/; \n";

						main::enter_disp(undef,"アタック？");
					}

					# クッキーに何もなく、セッションファイルもない、初期状態の場合
					else{ main::enter_disp(); }
			}


		# セッションファイルから管理者情報をＧＥＴ
		my($id,$lasttime) = split(/<>/,$sesdata);

			# 時間チェック、セッションファイルの削除
			if (time - $lasttime > $authtime) {
				unlink("$$admin_basic_init->{'sesdir'}/$cook{$cookie_key}.dat");
				print "Set-Cookie: ${cookie_key}=; path=/;\n";
				main::error("ログイン有効時間を経過しました。再度ログインしてください。<br><a href=\"/jak/index.cgi\">【再ログイン】</a>");
			}

		# 名前＆クッキーID＆ログインID定義（ログイン直後をのぞく？）
		(%admy) = Mebius::Admin::MemberFile("Session-login Get-hash My-access",$id,undef,$cook{$cookie_key},$main::host);

			# マスターの場合
			if($admy{'rank'} >= $admin_basic_init->{'master_rank'}){
				$admy{'master_flag'} = 1;
				$admy{'leader_flag'} = 1;
			}
			# リーダーの場合
			elsif($admy{'rank'} >= $admin_basic_init->{'leader_rank'}){
				$admy{'leader_flag'} = 1;
			}


			# マスターは、管理ランクを自由に変更して確認できるように
			if($admy{'master_flag'} && $param->{'admin_rank'} =~ /^(\d+)$/){
				$main::admy_rank = $main::my_rank = $admy{'rank'} = $param->{'admin_rank'};
			}


	}


	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,\%admy); }

\%admy;

}


1;
