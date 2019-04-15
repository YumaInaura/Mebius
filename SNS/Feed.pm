
use strict;

package Mebius::SNS::Feed;
use Mebius::Text;
use Mebius::History;
use Mebius::Question::URL;

use Mebius::Query;

use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"feed";
}

#-----------------------------------------------------------
# テーブル設定
#-----------------------------------------------------------
sub main_table_column{

my $column = {
content_type => { } , 
data1 => {} , 
data2 => {} , 
data3 => {} , 
subject => { } ,
account => { } ,
handle => { } ,  
post_time => { int => 1 } ,
last_modified => { int => 1 } ,
hidden_flag => { int => 1 } ,
deleted_flag => { int => 1 } ,
last_update_time => { int => 1 } ,
};

$column;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_group_to_line{

my $self = shift;
my $data_group = shift;

my $use = shift;
my $sns_url = new Mebius::SNS::URL;
my $times = new Mebius::Time;
my $html = new Mebius::HTML;
my $question_url = new Mebius::Question::URL;
my $device = new Mebius::Device;
my $text = new Mebius::Text;
my $history = new Mebius::History;
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
#my $account_handle = Mebius::SNS::Account->all_account_handle();
my($hit,$line);

	foreach my $hash (@{$data_group}){

		my($url,$mark,$status,$how_before_time,$handle,$account_name);

		my $history_data = $hash->{'history_hash_data'};

			# フィルタで非表示にする場合
			if(Mebius::Fillter::heavy_fillter($hash->{'subject'})){
				next;
			} elsif(($use->{'AllMember'} && $hash->{'hidden_from_feed_flag'}) || $history_data->{'hidden_from_friends_flag'}){
					if($my_account->{'admin_flag'}){
						$status .= $html->span("[隠]",{ class => "green" });
					} else {
						next;
					}
			} elsif($hash->{'content_typeA'} eq "bbs" && $hash->{'content_targetA'} =~ /^sc|^fjs$/){
				next;
			}

			if($hash->{'deleted_flag'}){
					if($my_account->{'admin_flag'}){
						$status .= $html->span("[削除]",{ class => "red" });
					} else {
						next;
					}
			}

		$hit++;
			if($hit > $use->{'max_view'} && $use->{'max_view'}){ next; }

			# マークを定義
			if($hash->{'content_typeA'} eq "question"){
				$mark = $html->strong("?",{ class => "green" });
			} elsif($hash->{'content_typeA'} eq "tags"){
				$mark = $html->strong("#",{ class => "green" });
			} elsif($hash->{'content_typeA'} eq "vine"){
				$mark = $html->strong("V",{ class => "green" });
			} elsif($hash->{'content_typeA'} eq "bbs"){
				$mark = $html->strong("!",{ class => "red" });

			} else{
				$mark = qq(&nbsp;);
			}

			# リンク先のURLを定義
			if($use->{'Comment'}){
				$how_before_time = $history_data->{'regist_time'};
				$url = $history->multi_content_url_with_move($history_data);
				$account_name = $history_data->{'access_target'};
				$handle = $history_data->{'last_handle'} || "\@$history_data->{'access_target'}";
			} else {
				$how_before_time = $hash->{'content_create_time'};
				$url = $history->multi_content_url($hash);
				$account_name = $hash->{'first_account'};
				$handle = $hash->{'first_handle'} || "\@$hash->{'first_account'}";
			}

		my $response_num = $hash->{'last_response_num'} || 0;
		my $subject = $text->omit_character("$hash->{'subject'}",20) . "($response_num)";
		my $subject_link = $html->href($url,$subject);
		my $account_link = $sns_url->account_link_free_text($account_name,$handle);
		my $how_before =  $times->how_before($how_before_time);

			if($device->use_device_is_smart_phone()){

					if($hit >= 2){
						$line .= qq(<div class="smart-line border-top-gray">);
					} else {
						$line .= qq(<div class="smart-line">);
					}

				$line .= qq(<div class="ell">);
				$line .= qq($mark$subject_link $status);
				$line .= qq(</div>);

				$line .= qq(<div class="right">$account_link $how_before</div>);

				$line .= qq(</div>);

			} else {
				$line .= qq(<div>$mark $subject_link $status - $account_link $how_before</div>);
			}
	}

$line;

}


#-----------------------------------------------------------
# 全メンバーの更新 ( フィード一覧 )
#-----------------------------------------------------------
sub all_members_feed_line{

my $self = shift;
my $max_view_per_news = shift;
my $use = shift || {};
my $history = new Mebius::History;
my $status = new Mebius::Status;
my(@data,$history_hash_data_group);
my($status_data_group);

my $border_time = time - 1*24*60*60;

	if(Mebius::alocal_judge()){ $border_time = time - 365*24*60*60; }

	if($use->{'search_keyword'}){

		$status_data_group = $status->fetchrow_main_table({ subject => ["LIKE","%$use->{'search_keyword'}%"] , first_account => ["LIKE","%$use->{'search_keyword'}%"] , first_handle => ["LIKE","%$use->{'search_keyword'}%"] },{ OR => 1 });
	} else {

		$status_data_group = $status->fetchrow_main_table_desc({ content_create_time => [">=",$border_time] },"content_create_time",{ LIMIT => $max_view_per_news*2 , Debug => 0 });
	}

#, first_account  => ["IS NOT NULL"]  

my $adjusted_data_group = $status->adjust_data_group_for_feed_topics($status_data_group,$use);

my $line = $self->data_group_to_line($adjusted_data_group,{ max_view => $max_view_per_news , AllMember => 1 } );

$line;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_friends_post{

my $self = shift;
my $account = shift;
my $max_view_per_news = shift || 100;
my $sns = new Mebius::SNS;
my $html = new Mebius::HTML;
my $status = new Mebius::Status;
my $query = new Mebius::Query;
my $param  = $query->param();
my($basic_init) = Mebius::basic_init();
my($print);

my $limit = $param->{'limit'} || $max_view_per_news;
$print .= qq(<div class="line-height-large margin-bottom">);

my $friend_accounts = $sns->friend_accounts($account);

	if(@{$friend_accounts}){
		my $border_time = time - 30*24*60*60;
		my $status_data_group = $status->fetchrow_main_table_desc({ first_account => ["IN",$friend_accounts]  },"content_create_time",{ LIMIT => $limit });
		my $adjusted_data_group = $status->adjust_data_group_for_feed_topics($status_data_group,{ Index => 1 });
		$print .= $self->data_group_to_line($adjusted_data_group,{ max_view => $max_view_per_news }) || "まだデータがありません。";
	} else {
		$print .= qq(まだマイメビがいません。);
	}

my $link = $html->href("$basic_init->{'auth_url'}$account->{'id'}/friend-diary","以前のデータ");
$print .= qq(<div class="right">$link</div>);
$print .= qq(</div>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_friends_comment{

my $self = shift;
my $account = shift;
my $max_view_per_news = shift || 100;
my $history = new Mebius::History;
my $sns = new Mebius::SNS;
my $html = new Mebius::HTML;
my $query = new Mebius::Query;
my $param  = $query->param();
my($print,$status_data_group);

my $limit = $param->{'limit'} || $max_view_per_news;

my $friend_accounts = $sns->friend_accounts($account);

	if(@{$friend_accounts} >= 1){
		$status_data_group = $history->fetchrow_main_table_with_status_data_group({ access_target_type => "account" , access_target => ["IN",$friend_accounts] , last_response_num => [">=",1] },{ Debug => 0 , priority_key => "regist_time" , ORDER_BY => ["regist_time DESC"] , LIMIT => $limit } );
	} else {
		return();
	}

my $debug_num = @{$status_data_group};

my @last_sorted_data_group = sort { $b->{'history_hash_data'}->{'regist_time'} <=> $a->{'history_hash_data'}->{'regist_time'} } @{$status_data_group};

$print .= qq(<div class="line-height-large margin-bottom">);
$print .= $self->data_group_to_line(\@last_sorted_data_group ,{ max_view => $max_view_per_news , Comment => 1 } ) || "まだデータがありません。";
$print .= qq(</div>);

$print;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_friend_news_view{

my $self = shift;
my $sns = new Mebius::SNS;
my $html = new Mebius::HTML;
my($print);

my $account_data = $self->account_data_kind();
my $title = "マイメビの更新";


$print .= $html->tag("h2","新着",{ id => "post" });
$print .= $self->my_friends_post($account_data,100);

$print .= $html->tag("h2","更新",{ id => "renew" });
$print .= $self->my_friends_comment($account_data,100);

$sns->print_html($print,{ Title => $title , h1 => $title , BCL => [$title] });


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub account_data_kind{

my $self = shift;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($account_data);

	if($param->{'account'} eq ""){
		$account_data = $my_account;
	} elsif($my_account->{'admin_flag'} && $param->{'account'}){
		($account_data) = Mebius::Auth::File("ReturnRef",$param->{'account'});
	} else {
			if($param->{'account'} ne $my_account->{'id'}){
				#Mebius::redirect($basic_init->{'auth_url'});
				Mebius->error("自分のアカウントではありません。");
				exit;
			} else {
				$account_data = $my_account;
			}
	}

$account_data;

}



package Mebius::Auth;
use Mebius::Text;
use Mebius::History;
use Mebius::Export;

#-----------------------------------------------------------
# フィードページの表示 (ニュースフィード)
#-----------------------------------------------------------
sub feed_view{

# 宣言
my $sns = new Mebius::SNS;
my $html = new Mebius::HTML;
my $self = new Mebius::SNS::Feed;
my($my_account) = Mebius::my_account();
my $sns_multi_link = $sns->my_navigation_links({ Top => 1 });
my $sns_multi_link2 = $sns->my_navigation_links({ Bottom => 1 });
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($navigation_links,$line,$account,$feed_line,$news_link);
my($q) = Mebius::query_state();
my $question_init = Mebius::Question->init();

$account = $self->account_data_kind();

# 新着情報を取得
($feed_line) = all_feed({ account_hash => $account });

	# チャット城へのリンク
	if(time > $my_account->{'firsttime'} + 60*24*60*60){
		$navigation_links .= qq(<li><a href="http://aurasoul.mb2.jp/chat/tmb3/mebichat.cgi">登録60日以上の方は”新チャット城”を利用できます。</a></li>);
	}

# タイトルを定義
my $page_title = qq(フィード);

	# ユーザー色指定
	if($my_account->{'color1'}){ $main::css_text .= qq(h2{background-color:#$account->{'color1'};border-color:#$account->{'color1'};}); }


my($new_message_line) = special_feed_message($account);

# 最終表示内容を定義
$line .= qq($sns_multi_link);


$line .= qq(<h1>$page_title <span class="ac">\@).e($account->{'id'}).qq(</span></h1>
<div class="word-spacing scroll">
<div class="scroll-element">
あなた： 
<a href="$basic_init->{'auth_url'}$account->{'file'}/aview-befriend">マイメビ申\請</a>
<a href="$basic_init->{'auth_url'}$account->{'file'}/?mode=fdiary">新しい日記を書く</a>
);
$line .= $html->href($question_init->{'base_url'},"質問する");

$line .=qq( | 
全メンバー： 
<a href="$basic_init->{'auth_url'}aview-allresdiary.html">新着レス</a>
<a href="$basic_init->{'auth_url'}aview-allcomment.html">新着伝言</a>
<a href="$basic_init->{'auth_url'}tag-new.html">新着タグ</a>
);

	# CCC 2012/8/21 (火) - 1week
	if(time < 1345553915 + 7*24*60*60){
		$line .= qq(<a href="$basic_init->{'guide_url'}2012.08.21+SNS%A5%D5%A5%A3%A1%BC%A5%C9%A5%DA%A1%BC%A5%B8%BA%EE%C0%AE" target="_blank" class="blank red">※表\示変更のお知らせ</a>);
	}

	# 伝言板の内容を取得
	require "${init_directory}auth_comment.pl";
	my($comments,$form) = main::view_auth_comment("PROF Get-index Low-load Back-url UTF-8",$my_account->{'file'},"",5,%$my_account);

utf8($comments,$form);

$line .= qq(
</div>
</div>

<h2 id="NEWS"$main::kfontsize_h2>新着一覧</h2>
$new_message_line

$feed_line
$comments
$form
<h2 id="NAVI">リンク</h2>
<ul>
$navigation_links
</ul>
$sns_multi_link2
);

# ヘッダ
Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => qq($page_title \@).e($account->{'file'}) },$line);

exit;

}

#-----------------------------------------------------------
# 特殊新着メッセージ
#-----------------------------------------------------------
sub special_feed_message{

my($account) = @_;
my($news_link);
my($basic_init) = Mebius::basic_init();
my $times = new Mebius::Time;

	# ●マイメビ申請の新着状況
	{

			# ▼CCC アカウント本体に記録された数がゼロ以下の場合は、古い方式で未処理のマイメビ申請数を取得する (負荷の高い方式)
			# ▼2012/8/22 (水) => 3ヶ月ほど
			if($account->{'new_applied_num'} eq "" || $account->{'new_applied_num'} < 0 && time < 1345567007 + 3*30*24*60*60){

				# ファイルから申請状況を取得
				my(undef,$new_apply_num,$new_apply_time) = main::defined_befriend_list(undef,$account->{'file'});

					# アカウント本体を更新
					if($new_apply_num){
						Mebius::Auth::File("Renew",$account->{'file'},{ new_applied_num => $new_apply_num , last_applied_time => $new_apply_time });
					} else{
						Mebius::Auth::File("Renew",$account->{'file'},{ new_applied_num => 0 , last_applied_time => $new_apply_time });
					}

			}

			# ▼新着マイメビ申請がある場合
			if($account->{'new_applied_num'} >= 1){
				my($how_before_applied) = $times->how_before($account->{'last_applied_time'});
				$news_link .= qq(　 <a href="$account->{'profile_url'}aview-befriend" style="color:#f00;">★$account->{'new_applied_num'}件のマイメビ申請が届いています</a>　 $how_before_applied);
			}

	}


	# ●新着メッセージ
	if($account->{'allow_message_flag'}){

			# ▼CCC アカウント本体に記録されたメッセージ件数がゼロ以下の場合は、古い方式で新着メッセージ件数を取得する (負荷の高い方式)
			# ▼2012/8/22 (水) => 3ヶ月ほど
			if($account->{'unread_message_num'} eq "" || $account->{'unread_message_num'} < 0 && time < 1345567007 + 3*30*24*60*60){
				my(%box) = Mebius::Auth::MessageBox("Get-new-status",$account->{'file'},"catch");
					if($box{'new_message'}){
						$news_link .= qq( <a href="$account->{'profile_url'}?mode=message" style="color:#f00;">☆$box{'new_message'}件の新着メッセージがあります</a>);
					}
					# アカウント本体を更新
					if($box{'new_message'}){
						Mebius::Auth::File("Renew",$account->{'file'},{ unread_message_num => $box{'new_message'} });
					} else{
						Mebius::Auth::File("Renew",$account->{'file'},{ unread_message_num => 0 });
					}
			}

			# ▼新方式でメッセージ件数を表示
			if($account->{'unread_message_num'}){
				$news_link .= qq( <a href="$account->{'profile_url'}?mode=message" style="color:#f00;">☆$account->{'unread_message_num'}件の新着メッセージがあります</a>);
			}

	}

	# リメイン用のアドレスを設定していない場合
	if(!$account->{'remain_email'}){
		$news_link .= qq( <a href="$account->{'profile_url'}?mode=aview-remain&type=reset_remain_email_view&input_type=password" style="color:#f00;">☆パスワードを忘れた時のために、メールアドレスを設定して下さい。</a>);
	}

	# 新着リンクの整形
	if($news_link){ $news_link = qq(<div class="news_link">$news_link</div>); }

$news_link;

}

#-----------------------------------------------------------
# 全てのフィード
#-----------------------------------------------------------
sub all_feed{

# 宣言
my $self = __PACKAGE__;
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my $feed = new Mebius::SNS::Feed;
my $history = new Mebius::History;
my $status = new Mebius::Status;
my $feed = new Mebius::SNS::Feed;
my $sns = new Mebius::SNS;
my $account = $use->{'account_hash'};
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($friend_diary,$newcomment,%res_news,$news,$max_view_per_news,$bbs_new_res_line,$my_friend_all_line,$my_friend_comment_line,$my_friend_all_line);

require "${init_directory}auth_prof.pl";

	# ★ニュース１カテゴリあたりの、表示最大行数
	if($my_use_device->{'wide_flag'}){
		$max_view_per_news = 6;
	} else {
		$max_view_per_news = 4;
	}

$my_friend_all_line .= $html->tag("h3","マイメビの新着",{},{ href => "./friend_feed.html#post" });
$my_friend_all_line .= $feed->my_friends_post($account,$max_view_per_news);

$my_friend_comment_line .= $html->start_tag("div",{ class => "line-height-large padding-top border-top" , style => "background:#eef;" });
$my_friend_comment_line .= $html->tag("h3","マイメビの更新",{ },{ href => "./friend_feed.html#renew"  });
$my_friend_comment_line .= $feed->my_friends_comment($account,$max_view_per_news);
$my_friend_comment_line .= $html->close_tag("div");

# ▼マイメビの新着日記
#($friend_diary) = Mebius::Auth::FriendDiaryIndex("Get-topics",$account->{'file'},$max_view_per_news);

	# ▼あなたのコメント履歴
	#{
		#my($plustype_resdiary);
			# 更新を許可
			#if($my_account->{'file'} eq $q->param('account')){
			#	$plustype_resdiary .= qq( Allow-renew-news);
			#}
		#(%res_news) = Mebius::SNS::Diary::comment_history("Get-topics",$account->{'file'},$max_view_per_news);
		#shift_jis($res_news{'topics_line'});
	#}

	# ▼ニュース
	{
		($newcomment) = Mebius::Auth::News("Prof Get-topics",$account->{'file'},$max_view_per_news);
	}

#my($bbs_new_res_line) = Mebius::BBS::ThreadStatus->new_res_list({ max_view => 5 });
#shift_jis($bbs_new_res_line);
#				<h3>掲示板の新しいレス</h3>
#				$bbs_new_res_line

my $all_members_feed .= qq(<h3><a href="$basic_init->{'auth_url'}aview-alldiary.html">全メンバーの新着</a></h3>);
$all_members_feed .= qq(<div class="line-height-large margin-bottom">);
$all_members_feed .= $feed->all_members_feed_line($max_view_per_news+5);
$all_members_feed .= qq(</div>);
$all_members_feed .= qq(<div class="right"><a href="$basic_init->{'auth_url'}aview-alldiary.html#LIST">→続きを見る</a></div>);

utf8($friend_diary,$newcomment);



	# ▼新着一覧の定義
	{

			if($my_use_device->{'smart_flag'}){
				$news .= qq(
				$friend_diary
				$my_friend_all_line
				$my_friend_comment_line
				<div class="border-top">$all_members_feed</div>
				$res_news{'topics_line'}
				<div class="border-top">$newcomment</div>
				$news
				);

			} else {
				$news .= qq(

				<div class="float-left float-width" style="margin-right:2%;">
				$friend_diary
				$my_friend_all_line
				$my_friend_comment_line
				$res_news{'topics_line'}
				</div>

				<div class="float-left float-width">
				$all_members_feed
				$newcomment
				$news
				</div>

				<div class="clear"></div>
				);
			}
	}




}


1;
