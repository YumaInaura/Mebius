
use strict;
package Mebius::SNS;
use Mebius::Export;
use base qw(Mebius::Base::Basic);

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
sub main_limited_package_name{
"sns";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_all_objects{

my $self = shift;
my(%object);

$object{'diary'} = new Mebius::SNS::Diary;

\%object;

}

#-----------------------------------------------------------
# すべての設定
#-----------------------------------------------------------
sub init{
my $self = shift;
my(%init);

$init{'title'} = "メビリンＳＮＳ";

\%init;

}

#-----------------------------------------------------------
# ログインを促すリンク
#-----------------------------------------------------------
sub please_login_link{

my $self = shift;
my($basic_init) = Mebius::basic_init();
my $html = new Mebius::HTML;
my($my_account) = Mebius::my_account();
my($text);

	# ログイン状態の場合 ( ログイン状態でも、非ログインユーザーにどのような文面が表示されているかを確認するために、テキストを設定する )
	if($my_account->{'login_flag'}){
		$text .= qq(ログイン \(または新規登録\)が必要です。);
	# 非ログイン状態の場合
	} else {
		my($request_url_encoded) = Mebius::request_url_encoded();
		#my $login_url = $html->href("$basic_init->{'auth_url'}?backurl=$request_url_encoded","ログイン");
		my $login_link = $self->login_link();
		my $new_submit_url = $html->href("$basic_init->{'auth_url'}?&amp;mode=aview-newform&amp;backurl=$request_url_encoded","新規登録");
		$text .= qq( $login_link \( または $new_submit_url \) してください。);
	}

$text;

}


#-----------------------------------------------------------
# ログイン用の共通リンク
#-----------------------------------------------------------
sub login_link{

my $self = shift;
my $html = new Mebius::HTML;

my($request_url_encoded) = Mebius::request_url_encoded();
my $login_link = $html->href("/_main/?mode=login_form&amp;backurl=$request_url_encoded","ログイン");

$login_link;

}

#-----------------------------------------------------------
# SNS関係の色々なログを入れてるディレクトリのパス
#-----------------------------------------------------------
sub all_log_directory_path{

my $self = shift;
my($share_directory) = Mebius::share_directory_path();	
my $directory = "${share_directory}_authlog/";

$directory;

}
#-----------------------------------------------------------
# 管理者かどうかを判定
#-----------------------------------------------------------
sub admin_judge{

my $self = shift;
my($my_account) = Mebius::my_account();
my($flag);

	if($my_account->{'admin_flag'}){
		$flag = 1;
	}	elsif(Mebius::Admin::admin_mode_judge()){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_navigation_links{ }

#-----------------------------------------------------------
# 自分の日記などのナビゲーションリンク
#-----------------------------------------------------------
sub my_navigation_links_for_header{

# 宣言
my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my $mode = $param->{'mode'};
my $guide_url = $basic_init->{'guide_url'};
my($footer_link,$footer_link2,@links,@hidden_links,$print);

	# ＳＮＳトップへのリンク
	#if("http://$server_domain$requri" eq $basic_init->{'auth_url'}){ push @links , qq(<span class="linked">SNSトップ</span>); }
	#else{ push @links , qq(<a href="$basic_init->{'auth_url'}">SNSトップ</a>); }

	# フィードへのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "feed"){ push @links , qq(<span class="linked">フィード</span>); }
			#else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/feed">フィード</a>); }
			else{ push @links , qq(<a href="$basic_init->{'auth_url'}">フィード</a>); }
	}


	# マイプロフへのリンク
	if($my_account->{'login_flag'}){
		if($mode eq "" && $param->{'account'} eq $my_account->{'id'}){ push @links , qq(<span class="linked">プロフ</span> ); }
		else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/">プロフ</a>); }
	}

	# ログインしていない場合
	else{
		if($mode eq "" && $param->{'account'} eq ""){ push @links , qq(ログイン); }
		else{push @links , qq(<a href="$basic_init->{'auth_url'}">ログイン</a>);}
	}

	#if(!$my_use_device->{'smart_flag'}){
	#		if($mode eq "aview-alldiary"){ push @links , qq(<span class="linked">新日記</span> ); }
	#		else{ push @links , qq(<a href="$basic_init->{'auth_url'}aview-alldiary.html">新日記</a>); }
	#}


	# 自分の友人一覧へのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "aview-friend"){ push @links , qq(<span class="linked">マイメビ</span> ); }
			else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/aview-friend">マイメビ</a>); }
	}

	# 自分の日記へのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "diax-all-new"){ push @links , qq(<span class="linked">日記</span> ); }
			else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/diax-all-new">日記</a>); }
			if($mode eq "fdiary"){ push @links , qq( (<span class="linked">新</span>) ); }
			else{ push @links , qq( (<a href="$basic_init->{'auth_url'}$my_account->{'file'}/?mode=fdiary">新</a>) ); }
	}

	# 自分の伝言板へのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "viewcomment"){ push @links , qq(<span class="linked">伝言板</span> ); }
			else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/viewcomment">伝言板</a>); }
	}


	# メッセージへのリンク
	if($my_account->{'login_flag'}){
			if($my_account->{'allow_message_flag'}){
					if($mode eq "message"){ push @links , qq(<span class="linked">メッセージ</span> ); }
					else{ push @links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/message">メッセージ</a>); }
			}
	}	

	# メンバーリストへのリンク
	if($mode eq "aview-newac-1"){ push @hidden_links , qq(<span class="linked">メンバー</span> ); }
	else{ push @hidden_links , qq(<a href="$basic_init->{'auth_url'}aview-newac-1.html">メンバー</a>); }


	# 設定ページヘのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "edit"){ push @hidden_links , qq(<span class="linked">設定</span> ); }
			else{ push @hidden_links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/edit">設定</a>); }
	}

	#if(!$my_use_device->{'smart_flag'}){
	#		if($mode eq "aview-allresdiary"){ push @links , qq(<span class="linked">新着レス</span> ); }
	#		else{ push @links , qq(<a href="$basic_init->{'auth_url'}aview-allresdiary.html">新着レス</a>); }
	#}

	#if(!$my_use_device->{'smart_flag'}){
	#		if($mode eq "aview-allcomment"){ push @links , qq(<span class="linked">新着伝言</span> ); }
	#		else{ push @links , qq(<a href="$basic_init->{'auth_url'}aview-allcomment.html">新着伝言</a>); }
	#}

	#if(!$my_use_device->{'smart_flag'}){
	#		if($mode eq "tag-new"){ push @links , qq(<span class="linked">新着タグ</span> ); }
	#		else{ push @links , qq(<a href="$basic_init->{'auth_url'}tag-new.html">新着タグ</a>); }
	#}

	#if(!$my_use_device->{'smart_flag'}){
	#	push @hidden_links , qq(<a href="${guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">よくある質問</a>);
	#}

	#if(!$my_use_device->{'smart_flag'}){
		#push @hidden_links , qq(<a href="${guide_url}%BA%EF%BD%FC%B0%CD%CD%EA%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">削除依頼</a>);
	#}

	# 自分のタグへのリンク
	if($my_account->{'login_flag'}){
			if($mode eq "tag-view"){ push @hidden_links , qq(<span class="linked">タグ</span> ); }
			else{ push @hidden_links , qq(<a href="$basic_init->{'auth_url'}$my_account->{'file'}/tag-view">タグ</a>); }
	}


	# ログイン中の場合
	if($my_account->{'login_flag'} && $mode ne "logout"){
		push @hidden_links , qq(<a href="$basic_init->{'auth_url'}logout.html">ログアウト</a>);
	}

my $hidden_links = join " " , @hidden_links;

	# 整形
	if($my_use_device->{'mobile_flag'}){
		$print = qq(<hr /><div style="font-size:x-small;">$footer_link$hidden_links</div>\n);

	}	elsif($my_use_device->{'touch_display_flag'}){

		$print .= qq(<div class="logined_navigation word-spacing clear scroll-element">);
		#$print .= qq(<div class="scroll-element">);
		$print .= join " " , (@links,@hidden_links); 
		#$print .= qq(</div>);
		$print .= qq(</div>);

	} else {

		$footer_link = join " " , @links; 
		$hidden_links = qq( <span class="none" id="account_navigation_hidden">$hidden_links</span>);

		$print .= qq(<div class="logined_navigation word-spacing clear">);
		$print .= $footer_link;
		$print .= $hidden_links;
		$print .= " " . $html->href("#","他",{ onclick => "vswitch('account_navigation_hidden','inline');return false;" , class => "fold" });
			if($my_use_device->{'touch_display_flag'}){
				$print .= qq(</div>);
			}
		$print .= qq(</div>\n);
	}

	#if($use->{'Bottom'}){
	#	$footer_link2;
	#} else {
	#	$footer_link;
	#}

$print;

}


#-----------------------------------------------------------
# BODY を出力
#-----------------------------------------------------------
sub print_html{

my $self = shift;
my $print = shift;
my $use = shift;

my $sns_multi_link = $self->my_navigation_links({ Top => 1 });
my $sns_multi_link2 = $self->my_navigation_links({ Bottom => 1 });


$print = qq(
$sns_multi_link
$print
$sns_multi_link2
);

my $relay_use = Mebius::Operate->overwrite_hash($use,{ source => "utf8" , css_files => ["auth"] });
Mebius::Template::gzip_and_print_all($relay_use,$print);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_friend_accounts{

my $self = shift;
my($my_account) = Mebius::my_account();

$self->friend_accounts($my_account);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub friend_accounts{

my $self = shift;
my $account_data = shift;
my(@fetch);

	foreach my $target_account (split(/\s/,$account_data->{'friend_accounts'})){
		push @fetch , $target_account;
	}

\@fetch;

}



1;

