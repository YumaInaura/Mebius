
use strict;
use Mebius::Question::URL;
use Mebius::SNS::Feed;
use Mebius::Operate;
package Mebius::Question::Post;
use Mebius::Export;
use base qw(Mebius::Base::DBI Mebius::Question Mebius::Base::Data);

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
"question";
}

#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {

number => { PRIMARY => 1  } ,
text => { text => 1 } ,

handle => { } ,
account => { INDEX => 1 } ,
addr => { } ,
host => { text => 1 } , 
user_agent => { text => 1 } , 
mobile_uid => { text => 1 } , 

tags => { } , 

best_answer_time => { int => 1 }  ,
best_answer_response_number => { } ,
decide_best_answer_account => { }  ,

post_time => { int => 1 , INDEX => 1 } ,
response_limit_time => { int => 1 } ,
response_num => { int => 1 } ,

first_response_time => { int => 1 } , 
last_response_time => { int => 1 , INDEX => 1 } ,
last_modified => { int => 1 } ,

access_count => { int => 1 , INDEX => 1  } , 
access_addrs => { text => 1 } ,

all_good_num => { int => 1 } , 

reported_flag => { int => 1 } , 
deleted_flag => { int => 1 , INDEX => 1 } , 
penalty_flag => { int => 1 } , 

control_account => { } , 
control_time => { int => 1 } , 
control_reason => { } ,

last_response_account => { } ,

last_update_time => { int => 1 } ,

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deleted_flag_to_deny_post_error_message{

my $self = shift;
my $init = $self->init();
my($my_account) = Mebius::my_account();
my($data_group,$error);

	if( my $target = $my_account->{'id'}){
		$data_group = $self->fetchrow_main_table({ account => $target });
	} else {
		return();
	}

	foreach my $data (@{$data_group}){
			if($data->{'deleted_flag'} > time - 7*24*60*60){
				$error = e("過去の投稿が削除されたため、$init->{'title'}ではしばらく新規投稿できません。");
			}
	}

$error;

}

#-----------------------------------------------------------
# fertchrow して、データを補足して返す
#-----------------------------------------------------------
sub fetchrow_main_table_and_complete_data{

my $self = shift;
my $post_data = $self->fetchrow_main_table(@_);
my $question_url = new Mebius::Question::URL;
my $text = new Mebius::Text;
my(@return);

	foreach my $post_data ( @{$post_data} ){

		my %complete_data  = %{$post_data};
		$complete_data{'url'} = $question_url->question($post_data->{'number'});
		#$complete_data{'subject'} = $text->omit_character($post_data->{'text'},20);
		$complete_data{'subject'} = $post_data->{'text'};
		$complete_data{'content_type'} = "question";
		push @return , \%complete_data;
	}

\@return;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub content_target_setting{

my $self = shift;
my $setting = ["number"];
$setting;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_setting_for_multi_data{

my $self = shift;

my $adjust_data = {
content_targetA => ["number"],
};

$adjust_data;

}

#-----------------------------------------------------------
# 最後に新規質問した時間を確かめる
#-----------------------------------------------------------
sub my_last_post_time{

my $self = shift;

# アカウントファイルで判定する場合
my($my_account) = Mebius::my_account();
$my_account->{'question_last_post_time'};

# DBI で判定する場合
#my $account = shift;
#	if(Mebius::Auth::account_name_error($account)){ return(); }
#my $dbi_data = $self->fetchrow_main_table({ account => $account }, { LIMIT => 1 , ORDER_BY => ["post_time DESC"] });
#$dbi_data->[0]->{'post_time'};
#my $last_post_time = 

}

#-----------------------------------------------------------
# 新規投稿
#-----------------------------------------------------------
sub new_post{

my $self = shift;
my($print,%update);
my $all_members_news = new Mebius::SNS::Feed;
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();
my($my_account) = Mebius::my_account();
my $init = $self->init();
my $question_url = new Mebius::Question::URL;

# アクセス制限
Mebius->axs_check("ACCOUNT");

	if( my $error = $self->deleted_flag_to_deny_post_error_message()){
		$self->error($error);
	}

	if(Mebius->character_num($param->{'text'}) > $init->{'word_length_limit'}){
		$self->error("文字数オーバーです。");
	} elsif(Mebius::Text->character_num($param->{'text'}) < $init->{'word_length_small_limit'}){
		$self->error("文字数が少なすぎます。");
	}

# 本文の重複投稿チェック
my $post_data_redun = $self->fetchrow_main_table({ text => $param_utf8->{'text'} })->[0];
	if($post_data_redun){
		$self->error("これと同じ内容の質問が投稿済みです。");
	}

$update{'number'} = $self->create_new_char(20) || $self->error("もういちどお試し下さい。");

# 共通のエラー
$self->regist_common_error();

# 24時間以内に何個投稿したか
my $too_many_post_error = $self->too_many_post();
	if($too_many_post_error && !Mebius::alocal_judge()){ $self->error($too_many_post_error); }

# 投稿内容の定義

$update{'text'} = $param_utf8->{'text'};
$update{'post_time'} = time;
$update{'last_modified'} = time;
%update = (%update,%{Mebius::Device->my_connection()});
$update{'account'} = $my_account->{'id'} || die;
$update{'handle'} = utf8_return($my_account->{'handle'});

# テーブルを更新
$self->insert_main_table(\%update);

# アカウントを更新
Mebius::Auth::File("Renew" , $my_account->{'id'} , { question_last_post_time => time } );

# フィード用のメモリテーブルを更新
$all_members_news->insert_main_table({ content_type => "question" , data1 => $update{'number'} ,  post_time => time , subject => $param_utf8->{'text'} , account => $my_account->{'id'} , handle => $update{'handle'} , last_account => $my_account->{'id'} });

$self->create_common_history_on_post({ content_targetA => $update{'number'} , subject => $update{'text'} , last_account => $my_account->{'id'} , content_create_time => time });

Mebius::redirect($question_url->question($update{'number'}));

exit;

}

#-----------------------------------------------------------
# 新規投稿回数が多すぎる場合
#-----------------------------------------------------------
sub too_many_post{

my $self = shift;
my($my_account) = Mebius::my_account();
my $init = $self->init();
my($error);

my $border_hour = $init->{'max_post_border_hour'} || die("setting is strange");
my $max_post_num = $init->{'max_post_num_per_limit'} || die("setting is strange");
my $border_time = time - $border_hour*60*60;

	# DBIのクエリを減らすための処理
	if($my_account->{'question_last_post_time'} < $border_time){ return(); }

my($post_dbi,$result) = $self->fetchrow_main_table({ account => $my_account->{'id'} , post_time => [">",$border_time] });

	if($result >= $max_post_num){	
		$error = "${border_hour}時間以内に作れる質問は${max_post_num}ケまでです。";
	}

$error;

}


#-----------------------------------------------------------
# 質問にベストアンサーがつけられているかどうかを判定する
#-----------------------------------------------------------
sub best_answered_judge{

my $self = shift;
my $data_post = shift;
my($best_answered_flag);
my $init = $self->init();

	# 質問者がベストアンサーを決めている場合
	if($data_post->{'best_answer_response_number'}){
		$best_answered_flag = 1;
	# 質問から一定時間が経過し、なおかつレスもついている場合
	} elsif(time > $data_post->{'first_response_time'} + $init->{'push_good_limit_since_post_time'} && $data_post->{'response_num'} >= 1){
		$best_answered_flag = 1;
	} else {
		0;
	}

$best_answered_flag;

}

#-----------------------------------------------------------
# アクセスカウンタを回す
#-----------------------------------------------------------
sub new_access{

my $self = shift;
my $post_data = shift || die;
my $operate = new Mebius::Operate;
my($still_flag);
my($my_account) = Mebius::my_account();

	if(length($ENV{'REMOTE_ADDR'}) <= 5){ return(); }
	if(Mebius::Device::bot_judge()){ return(); }

my @addrs = split(/\s+/,$post_data->{'access_addrs'});
	foreach my $addr (@addrs){
		if($ENV{'REMOTE_ADDR'} eq $addr){ $still_flag = 1; }
	}

my @update_addrs = $operate->push_limited_num(\@addrs,$ENV{'REMOTE_ADDR'},50);

	if(!$still_flag || Mebius::alocal_judge()){
		push @addrs , $ENV{'REMOTE_ADDR'};
		$self->update_main_table({ access_addrs => "@update_addrs" , number => $post_data->{'number'} , access_count => ['+',1] },{ Debug => 0 });
	}


}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_link_text{

my $self = shift;
my $data = shift;

my $text = $data->{'text'} || $data->{'subject'};

$text;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_link{

my $self = shift;
my $data = shift;
my $use = shift;
my $html = new Mebius::HTML;
my $text = new Mebius::Text;
my($link);

my $url = $self->data_to_url($data);
my $link_text = $self->data_to_link_text($data);

	if($use->{'omit_character_num'} >= 1){
		$link_text = $text->omit_character($link_text,$use->{'omit_character_num'});
	}

$link = $html->href($url,$link_text);

$link;

}



#-----------------------------------------------------------
# 質問本体
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $init = Mebius::Question->init();
my($url);

my $number = $data->{'number'} || $data->{'content_targetA'};

$url = "$init->{'base_url'}?q=$number";

$url;

}

#-----------------------------------------------------------
# 質問本体
#-----------------------------------------------------------
sub data_to_url_with_move{

my $self = shift;
my $data = shift;
my $use = shift;
my($url_with_move);

my $url = $self->data_to_url($data);

my $response_target = $data->{'response_target'} || $data->{'last_response_target'};

	if( $response_target ){
		$url_with_move = "${url}#qr_$response_target";
	} else {
		$url_with_move = $url;
	}

$url_with_move;

}

#-----------------------------------------------------------
# エラー
#-----------------------------------------------------------
sub error{

my $self = shift;
my $error = shift;


Mebius::Question::View->top_page_view($error);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"question";
}


1;

