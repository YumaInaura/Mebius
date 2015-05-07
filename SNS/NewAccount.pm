
use strict;
use Mebius::Email;
use Mebius::CerEmail;
use Mebius::SNS::Account;
package Mebius::SNS::NewAccount;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 共通の設定
#-----------------------------------------------------------
sub init{

my(%init);
my $self = shift;

push @{$init{'BCL'}} , "新規アカウント登録";
$init{'cer_email_action_type'} = "new_account";

\%init;

}


#-----------------------------------------------------------
# モード分岐
#-----------------------------------------------------------
sub mode_junction{

my $self = shift;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();

	if(!Mebius::alocal_judge() && $my_account->{'login_flag'}){ Mebius->error("既にあなたはアカウントをお持ちです。"); }

	if($param->{'type'} eq "send_email"){
		$self->sendmail_do();
	} elsif($param->{'type'} eq "submit_view"){
		$self->submit_view();
	} elsif($param->{'type'} eq "submit"){
		$self->submit();
	} else {
			if($self->must_email_switch()){
				$self->sendmail_form_view();
			} else {
				$self->submit_view();
			}
	}


}


#-----------------------------------------------------------
# メール送信フォーム
#-----------------------------------------------------------
sub sendmail_form_view{

my $self = shift;
my $html = new Mebius::HTML;
my $init = $self->init();
my($param) = Mebius::query_single_param();
my $print;

my $rand = int(rand 99999);
my $default_inputed_email = "yuma\@$rand.biglobe.ne.jp" if(Mebius::alocal_judge());

$print .= qq(<h1>新規アカウント登録</h1>);

$print .= qq(<form action="" method="post">);
$print .= qq(メールアドレス );
$print .= $html->input("hidden","mode","new_account");
$print .= $html->input("hidden","type","send_email");
$print .= $html->input("hidden","backurl",$param->{'backurl'});
$print .= $html->input("text","email",$default_inputed_email,{ placeholder => "example\@ne.jp" });
$print .= $html->input("submit","","認証メールを送信する");
$print .= qq(</form>);

Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => $init->{'BCL'} },$print);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub must_email_switch{
0;
}


#-----------------------------------------------------------
# メール送信
#-----------------------------------------------------------
sub sendmail_do{

my $self = shift;
my($param) = Mebius::query_single_param();
my $email = new Mebius::Email;
my $init = $self->init();
my($basic_init) = Mebius::basic_init();
my $time = time;

# アクセス制限
Mebius->axs_check("ACCOUNT Make-account");

# POSTメソッドでなければエラーに
Mebius::Query->post_method_or_error();

	if(!$email->confidence_address($param->{'email'})){
		Mebius->error("このメールアドレスは使えません。");
	}

# 既にメールアドレスが使われているかどうかをアカウント一覧からチェック
$self->still_used_email_address_on_all_account_and_error($param->{'email'});

# 新しいCHAR をデータベースに登録する
my $char = Mebius::CerEmail->create_new_char_or_error($param->{'email'},$init->{'cer_email_action_type'});
my $back_url_param = Mebius::back_url_param() if($param->{'backurl'});

my $mail_body = "アカウント登録を続けるには、こちらのURLにアクセスして下さい。\n有効時間内に認証を済ませない場合は、URLが無効になります。\n$basic_init->{'auth_url'}?mode=new_account&type=submit_view&char=$char$back_url_param";
my $mail_subject = "アカウント登録のためのメール認証 - メビウスリング";

# メール送信
my($send_email_error) = Mebius::Email->send({ source => "utf8" },$param->{'email'},$mail_subject,$mail_body);
	if($send_email_error){
		Mebius->error($send_email_error);
	}

my $print = qq(<p>認証用メールを送信しました。あなたのメールアドレス \( <strong class="red">).e($param->{'email'}).qq(</strong> \) の受信トレイをご確認下さい。</p>);
$print .= qq(<p>届かない場合は別のメールアドレスで試したり、迷惑メールフォルダを確認したり、<strong class="red">mb2.jp</strong> のドメインを許可設定して下さい。</p>);

	if(Mebius::alocal_judge()){
		$print .= Mebius::auto_link($mail_body);
	}

Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => $init->{'BCL'} },$print);

}


#-----------------------------------------------------------
# 既にメールアドレスが使われているかどうかを確認してエラーを出す
#-----------------------------------------------------------
sub still_used_email_address_on_all_account_and_error{

my $self = shift;
my $email = shift;
my($error);

	if($email eq ""){ $error = "メールアドレスが指定されていません。"; }

my $all_account_dbi = Mebius::SNS::Account->fetchrow_on_hash_main_table({ remain_email => $email });

my $num = keys %$all_account_dbi;
	if($num >= 1){
		$error = "このメールアドレスは既に使われています。";
	}

	if($error){
		Mebius->error($error);
	}

}


#-----------------------------------------------------------
# 既に登録済みの場合
#-----------------------------------------------------------
sub redun_email_address_error{

my($param) = Mebius::query_single_param();
my $all_account = Mebius::SNS::Account->fetchrow_main_table_on_hash();

}

#-----------------------------------------------------------
# 認証メール発行後のアカウント本登録フォーム
#-----------------------------------------------------------
sub submit_view{

my $self = shift;
my $error_message = shift;
my $query = new Mebius::Query;
my $init = $self->init();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($print,$form,@BCL,$gold_text);
my $html = new Mebius::HTML;
my $sns_init = Mebius::SNS->init();
my $init = $self->init();
my($dbi_data,$new_email);

	# 認証がない場合はエラーに
	if($self->must_email_switch()){
		$dbi_data = Mebius::CerEmail->char_to_dbi_data_or_error($param->{'char'},$init->{'cer_email_action_type'});
		$new_email = $dbi_data->{'email'};
	}

	if($main::stop_mode =~ /SNS|Make-new-account/){ Mebius->error("現在、新規登録は停止中です。","503 Service Temporarily Unavailable"); }

# CSS定義
my $css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
input{margin:0.3em 0em;}
.forgot{font-size:90%;color:#f00;}
ul{color:#f00;}
);


# タイトル定義
my $sub_title = "新規アカウント登録 - $sns_init->{'title'}";

# 金貨引継ぎなどの説明

$gold_text = qq(
<li>「金貨」「投稿回数」「総文字数」はリセットされ、アカウント毎に記録されるようになります。ログアウトすると元の記録から始められる場合があります。</li>
);

# ローカルでの初期入力
my $first_input_password = "qaswqasw" if Mebius::alocal_judge();
my $first_checked_agree1 = my $first_checked_agree2 = my $first_checked_agree3 = " checked" if Mebius::alocal_judge();
my $input_password_type;
if(Mebius::alocal_judge()){ $input_password_type = "text"; } else { $input_password_type = "password"; }

# フォーム部分
$form .= qq(
<h2 id="ALERT">ご注意 ( 必ずお読みください )</h2>

<ul>
<li>クレジットカードの暗証番号など、大事なパスワードを入力しないでください。</li>
<li>アカウントの乱立はご遠慮ください。既にアカウントをお持ちの方は<a href="$basic_init->{'auth_url'}">ログイン</a>してください。</li>
<li>いちどアカウントを作ると、完全閉鎖は出来ません。日記やコメントをひとつずつ削除して、何もない状態にする必要があります。</li>
$gold_text
</ul>


<h2 id="NEW">登録フォーム</h2>);

	if($error_message){
		$form .= $html->strong("※エラー ： $error_message",{ class => "red" });
	}


$form .= qq(<form action="./" method="post" utn>);
$form .= qq(<div>希望アカウント名 <span class="alert">※</span><br>);

my $default_inputed_authid = int(rand 9999999999) if(Mebius::alocal_judge());
$form .= $html->input("text","authid",$default_inputed_authid,{ pattern => "^[0-9a-z]+\$" , autofocus => 1 , placeholder => "例) mickjagger" });
$form .= qq(<span class="guide_text">　( 半角英数字 3-10文字 )　</span><br>);

$form .= qq(ハンドルネーム <br>);
$form .= $html->input("text","name","",{ placeholder => "例) メビウス浩太郎" });
$form .= qq(<span class="guide_text">　※あとから変更できます。</span><br>);

$form .= qq(パスワード <span class="alert">※</span><br>);
$form .= $html->input($input_password_type,"passwd1",$first_input_password);

$form .= qq(<span class="guide_text">　例： Adfk432d </span><br>パスワード\(確認\) <span class="alert">※</span><br>);
$form .= $html->input($input_password_type,"passwd2",$first_input_password);

$form .= $html->input("hidden","backurl",$param->{'backurl'});
$form .= $query->input_hidden_encode();

$form .= qq(
<span class="guide_text">　例： Adfk432d</span><br>
<input type="hidden" name="mode" value="new_account">
<input type="hidden" name="type" value="submit">
メールアドレス<br>);

$form .= e($new_email);

$form .= qq(

<h3>利用規約</h3>

<ul>
<li><input type="checkbox" name="check1" value="1"$first_checked_agree1> 私は<a href="$basic_init->{'guide_url'}%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A4%CE%A5%EB%A1%BC%A5%EB" target="_blank">$sns_init->{'title'}のルール</a>と、必要なリンク先のガイドを熟読しました。
<li><input type="checkbox" name="check2" value="1"$first_checked_agree2> 私は<strong class="red">「個人情報の掲載、交換」「悪口、陰口、罵倒」「晒し行為」「マナーを欠いたグチ」「チェーン投稿」</strong>などの不正利用は、決しておこないません。
<li><input type="checkbox" name="check3" value="1"$first_checked_agree3> 不適切な利用があった場合、私は予\告なしに「コメント削除」「アカウントロック（削除）」「投稿制限」「プロバイダ連絡」などの処置を取られても構\いません。
</ul>
<br>

<input type="submit" value="利用上の注意に同意して、アカウントを作成する"><br>
<br>

</div>);

$form .= $html->input("hidden","char",$param->{'char'});
$form .= qq(</form>);

	# クッキーなしの場合
	if(!$ENV{'HTTP_COOKIE'}){
		$form = qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong><br><br>);
	}

my $print = <<"EOM";
<h1>新規アカウント登録 - メビウスリング</h1>
$form
EOM

Mebius::Template::gzip_and_print_all({ Title => $sub_title , inline_css => $css_text , source => "utf8" , BCL => $init->{'BCL'} },$print);


}


#-------------------------------------------------
# 新規作成 - 会員ファイル
#-------------------------------------------------
sub submit{

# ファイル名など決定
my $self = shift;
my($file,$line,$line_ses,$encpass_md5,%renew_history,$test_account_flag);
my(%renew_account,@new_salt,$main_server_flag,$relay_salt,$redirect_finished_url,%debug,$special_allow_flag,@BCL);
my $email = new Mebius::Email;
my $init = $self->init();
my($basic_init) = Mebius::basic_init();
my $new_account = new Mebius::SNS::NewAccount;
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();
my $query = new Mebius::Query;
my($cer_email,$new_email);

# IPなどでアカウント連続作成制限をするかどうか
my $deny_history_mode = 1;

# アクセス制限
Mebius->axs_check("ACCOUNT Make-account");

# POSTメソッドでなければエラーに
$query->post_method_or_error();

# DBI からメールアドレスをゲット
	if($self->must_email_switch()){
		$cer_email = Mebius::CerEmail->char_to_dbi_data_or_error($param->{'char'},$init->{'cer_email_action_type'});
		$new_email = $cer_email->{'email'} || Mebius->error("メールアドレスが認識できません。");

		# 既にメールアドレスが使われているかどうかをアカウント一覧からチェック
		$self->still_used_email_address_on_all_account_and_error($new_email);

	}

	if($new_email && !$email->confidence_address($new_email)){
		Mebius->error("このメールアドレスは使えません。");
	}

# 何日の間、同一ＩＰからの連続アカウント発行を禁止するか
my $wait_makeid = 30;

# アカウント名の最大文字数
my $max_acname = 10;

	# ストップモード
	if($main::stop_mode =~ /SNS|Make-new-account/){
		Mebius->error("現在、新規登録は停止中です。","503");
	}

# ファイル名を定義
$file = $param->{'authid'};

	# 汚染チェック
	#if($main::cnumber){ $cfile = $main::cnumber; }
#$cfile =~ s/\W//g;

# 二重クッキーセットを防止
$main::no_headerset = 1;

# ID取得
#my($encid) = &id();
my($encid);

	# チェックモード
	if($param->{'authid'} eq "vvvv"){ $test_account_flag = 1 ;}

	if($deny_history_mode){ Mebius::HistoryAll("Check-make-account-error My-file"); }

# トリップ取得
#my($enctrip) = &trip($main::cnam);
my($enctrip);

# タイトルなど定義
push @BCL , "アカウント作成";

	# クッキー判別
	if(!$ENV{'HTTP_COOKIE'}){ $new_account->submit_view("この環境ではアカウントを作成できません。"); }

	# アカウント名判定
	my($account_name_flag) = Mebius::Auth::AccountName(undef,$file);
		if($account_name_flag){ $new_account->submit_view(utf8($account_name_flag)); }
		if($file eq "test"){ Mebius->error("このアカウント名は新規作成できません。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# 重複ＩＤチェック
	if(!$test_account_flag && -d $account_directory){
		my($other_text) = $self->get_other_account($file,$max_acname);
		$new_account->submit_view("このアカウント名は既に使われています。$other_text");
	}

	# 新制限 2010/12/09 に開始
	if(!$test_account_flag && !$special_allow_flag && $deny_history_mode){
		Mebius::HistoryAll("Check-make-account-error My-file");
	}

	# 規約への同意をチェック
	#if($main_server_flag){
			if($param->{'preview'} ne "ok" && ($param->{'check1'} eq "" || $param->{'check2'} eq "" || $param->{'check3'} eq "")){
					$new_account->submit_view("アカウントを作成するには、利用上の注意に同意する必要があります。");
			}
	#}

	# パスワードと一緒にアカウント名をチェック
	#if($main_server_flag){
		Mebius::Regist::PasswordCheck(undef,$param->{'authid'},$param->{'passwd1'},$param->{'passwd2'});
	#}

	# エラー表示
	if($main::e_com){
		$new_account->submit_view(utf8_return($main::e_com));
	}

	# サンプルと同じものを禁止
	if($param->{'authid'} eq "mickjagger"){ $new_account->submit_view("サンプルと同じアカウント名は使えません。"); }
	if($param->{'passwd1'} eq "Adfk432d"){ $new_account->submit_view("サンプルと同じパスワードは使えません。"); }

	# 変なカウント名，パスワード
	if($param->{'authid'} =~ /sex/){ $new_account->submit_view("アカウント名エラー"); }

	# メールアドレスの書式チェック
	#if($param->{'email'}){
	#	my($error_flag) = Mebius::Email->format_error($param->{'email'});
	#		if($error_flag){ 
	#			$new_account->submit_view($error_flag);
	#		}
	#}

my($new_name,$name_error) = Mebius::Regist::name_check($param->{'name'});
	if(@$name_error >= 1){
		$new_account->submit_view("@{$name_error}");
	}
shift_jis($new_name);

	# プレビュー画面へ
	if($param->{'preview'} ne "ok"){
		$self->preview_view("この内容でよろしいですか？");
	}

# ロック開始
main::lock("auth$file");

# パスワードを暗号化 ( POST )
($encpass_md5,@new_salt) = Mebius::Auth::Password("New-password Digest-base64",$param->{'passwd1'});


	# ソルトを展開してデータとして扱う
	($renew_account{'salt'},$relay_salt) = Mebius::Auth::NewSaltForeach(undef,@new_salt);

	# アカウント基本ファイル作成
	if($test_account_flag){
		# テスト用にアカウント基本情報を削除
		File::Path::rmtree($account_directory);
	}

# 基本ディレクトリ作成
my($success_mkpath) = Mebius::mkpath($account_directory);

	# 基本ディレクトリ作成に失敗した場合
	if($success_mkpath <= 0){
		my $error_text = qq(アカウント: $file / ディレクトリ作成 $success_mkpath / $account_directory / $encpass_md5 / @new_salt);
		Mebius::AccessLog(undef,"Account-new-make",$error_text);
		Mebius::Email->send("To-master","アカウント作成失敗",$error_text);
		Mebius->error("アカウントの作成に失敗しました。");
	}

	# 主要サーバーのみ、各種ディレクトリを作成
	#if($main_server_flag){
		Mebius::Mkdir("","${account_directory}diary");
		Mebius::Mkdir("","${account_directory}comments");
		Mebius::Mkdir("","${account_directory}friend");
		Mebius::Mkdir("","${account_directory}bbs");
	#}

# アカウント基本ファイル定義
$renew_account{'key'} = 1;
$renew_account{'account'} = $file;
$renew_account{'pass'} = $encpass_md5;
$renew_account{'name'} = e($new_name);

#$renew_account{'salt'} = $new_salt[0];
#$renew_account{'pass_crypt'} = $encpass_crypt;
#$renew_account{'salt_crypt'} = $salt_crypt;
$renew_account{'firsttime'} = time;
#$renew_account{'name'} = $main::i_handle;
#$renew_account{'mtrip'} = $main::i_trip;
#$renew_account{'encid'} = $encid;
#$renew_account{'enctrip'} = $enctrip;
$renew_account{'email'} = "";
$renew_account{'remain_email'} = $new_email;
$renew_account{'ocomment'} = 1;
$renew_account{'odiary'} = 1;
$renew_account{'obbs'} = 1;
$renew_account{'osdiary'} = 1;
$renew_account{'first_email'} = $new_email;
$renew_account{'first_host'} = $main::host;
$renew_account{'first_agent'} = $main::agent;
$renew_account{'concept'} .= qq( Password-format-type4);

# ファイルを新規作成
Mebius::Auth::File("Allow-not-file Renew New-account",$file,\%renew_account);

# ロック解除
main::unlock("auth$file");

	# 履歴ファイルを更新
	$renew_history{'plus_make_accounts'} = $file;
	$renew_history{'make_account_blocktime'} = time + 30*24*60*60;
	Mebius::HistoryAll("RENEW Make-account My-file Not-isp",undef,undef,undef,undef,undef,%renew_history);

	# 主要サーバーで「新アカウント一覧」作成
	#if(!$test_account_flag){
	#	Mebius::Auth::AccountListFile("Renew New-account Normal-file",$file,$main::i_handle);
	#	Mebius::Auth::AccountListFile("Renew New-account Search-file",$file,$main::i_handle);
	#}

	# メール発行
	#if($main::in{'email'} && $main_server_flag){
	#}

# リダイレクト用のエンコード
my($encpass_md5_encoded,$relay_salt_encoded) = Mebius::Encode(undef,$encpass_md5,$relay_salt);

# 最終リダイレクト先URL
#my $redirect_finished_url = "${auth_url}?mode=idmaked&authid=$main::in{'authid'}&back=$main::in{'back'}";

# クッキーをセット
Mebius::Cookie::set_main({ account => $file , hashed_password => $encpass_md5 });

# 全体のテーブル作成
#Mebius::Auth::AllAccount::create_main_table();

#my $print ="登録しました。";
#Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => \@BCL },$print);

# 認証用のDBIを更新
Mebius::CerEmail->done($param->{'char'});

# 戻り先がある場合はリダイレクト
Mebius::redirect_to_back_url();

# フィードにリダイレクト
Mebius::redirect("$basic_init->{'auth_url'}$file/feed");

# 本人にメール送信
	if($new_email){
		Mebius::Auth::PasswordMemoEmail("New-account",$new_email,$file,$new_email);
	}

#Mebius::redirect($redirect_finished_url);

exit;


}

#-----------------------------------------------------------
# 別のアカウント名候補を取得
#-----------------------------------------------------------
sub get_other_account{

my $self = shift;
my($file,$max_acname) = @_;

	if(length($file) > $max_acname-2){ return; }

	# 最大100個のファイルをチェック
	for(10..99){

		# ディレクトリ定義
		my($account_directory) = Mebius::Auth::account_directory("$file$_");
			if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

			if(!-d ${account_directory}){
				return(" $file$_ であれば使えます。");
			}
	}

}

#-------------------------------------------------
# 発行前のプレビュー
#-------------------------------------------------
sub preview_view{

# 局所化
my $self = shift;
my($hidden,$check_password);
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $init = $self->init();


# CSS定義
my $css_text .= qq(
.forgot{font-size:90%;color:#f00;}
.big{font-size:200%;color:#080;}
);

	# パスワードの一部を表示
	if(length($param->{'passwd1'}) >= 4){
		#$alocal_check_password .= qq( 確認： );
		$check_password .= substr($param->{'passwd1'},0,2);
			for(3 .. length($param->{'passwd1'})){
				$check_password .= qq(*);
			}
	}


my $inputs .= $html->input("hidden","mode","new_account");
$inputs .= $html->input("hidden","preview","ok",{ NotOverwrite => 1 });
$inputs .= $html->input("hidden","type","submit");
$inputs .= $html->input("hidden","authid");
$inputs .= $html->input("hidden","name");
$inputs .= $html->input("hidden","passwd1");
$inputs .= $html->input("hidden","passwd2");
$inputs .= $html->input("hidden","char");
$inputs .= $html->input("hidden","check1");
$inputs .= $html->input("hidden","check2");
$inputs .= $html->input("hidden","check3");
$inputs .= $html->input("hidden","backurl");
$inputs .= $query->input_hidden_encode();

# ＨＴＭＬ
my $print = qq(
アカウントを発行します。この内容でよろしいですか？<br><br>
<form action="" method="post" utn>
<div>
$inputs
<ul>
<li>アカウント名： <strong class="big">).e($param->{'authid'}).qq(</strong>
<li>パスワード： <strong class="big">).e($check_password).qq(</strong> 
</ul>

<br>

<input type="submit" value="この内容でアカウントを発行する"><br><br>
</div>
</form>
);


#( <a href="mailto:?body=ACCOUNT:%81%40$in{'authid'}%0D%0APASS:%81%40$in{'passwd1'}">クリックするとすべて表\示されます</a> )
#<li>メールアドレス： ).e($param->{'email'}).qq(  <span class="guide_text">＊アカウント名の控えが送信されます。</span>

Mebius::Template::gzip_and_print_all({ inline_css => $css_text , source => "utf8" , BCL => $init->{'BCL'} },$print);

exit;

}

1;
