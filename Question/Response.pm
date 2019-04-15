
use strict;
package Mebius::Question::Response;
use Mebius::Regist;
use base qw(Mebius::Base::DBI Mebius::Question Mebius::Base::Data);
use Mebius::Export;

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
"question_response";
}

#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {

type => { } , 

number => { PRIMARY => 1 } , 
response_time => { int => 1 } ,
target_post_number => { INDEX => 1 , Relation => 1 } , 

account => { INDEX => 1 } , 
handle => { } , 
addr => { }  ,
host => { text => 1 } , 
user_agent => { text => 1 } , 
mobile_uid => { text => 1 } , 
text => { text => 1 } , 

good_num => { int => 1  } ,
bad_num => { int => 1 } ,  
good_accounts => { text => 1 } ,
good_addrs => { text => 1 } ,
good_cnumbers => { text => 1 } ,
bad_accounts => { text => 1 } ,
bad_addrs => { text => 1 } ,
bad_cnumbers => { text => 1 } ,

reported_flag => { int => 1 } , 
deleted_flag => { int => 1 } , 
penalty_flag => { int => 1 } , 

font_color => {} ,
control_account => { } , 
control_time => { int => 1 } , 
control_reason => { } ,
 
};

#number_per_question => { int => 1 } , 
# target_post_number ｑを


$column;

}

#-----------------------------------------------------------
# 回答データを HTMLに ( １行 )
#-----------------------------------------------------------
sub data_to_line{

my $self = shift;
my $data = shift;
my $post_data = shift;
my $init = $self->init();
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my $basic = new Mebius::Question;
my $fillter = new Mebius::Fillter;
my $relation_object = new Mebius::Question::Post;
my($line,$push_good_line,$other_data_line,$tag_class,$comment);

	if($self->use_push_bad()){
		$push_good_line = $self->good_and_bad_button($data);
	} else {
		$push_good_line = $self->good_button($data);
	}

# ●時刻表示、ハンドルネームなど
$other_data_line .= qq(<div class="right margin-top">);
$other_data_line .= Mebius::SNS::URL->account_link($data->{'account'},"$data->{'handle'}","QUESTION"); # 
$other_data_line .= qq( - );
$other_data_line .= Mebius::Time->how_before($data->{'response_time'});
	if(!$self->report_mode_judge() && !$use->{'ViewReport'}){
		$other_data_line .= " " . $html->input("submit","report_question_response_preview_$data->{'number'}","報告",{ class => "report" });
	}
$other_data_line .= qq(</div>);


$other_data_line .= qq(<div class="clear"></div>);

	# 削除等の操作ボタン
	if(Mebius->common_admin_judge() && !$self->report_mode_judge()){
		$other_data_line .= qq(<div class="right">);
		$other_data_line .= Mebius::Control->radio_parts("question_control_response_$data->{'number'}",{ deleted_flag => $data->{'deleted_flag'} } );
		$other_data_line .= qq(</div>);
	}

# データ
my $id = "qr_$data->{'number'}";

	if(!$use->{'hit'} || $use->{'hit'} >= 2){
		$tag_class .= " border-top-gray";
	}

	if($data->{'deleted_flag'}){
		$line .= $html->start_tag("div",{ class => "deleted_answer $tag_class" , id => $id });
	} elsif($use->{'best_answer_flag'}){
		$line .= $html->start_tag("div",{ class => "best_answer $tag_class" , id => $id });
			$line .= qq(<div class="red margin-bottom">★べすとあんさー</div>);
	} elsif($use->{'good_answer_flag'}){
		$line .= $html->start_tag("div",{ class => "limited_best_answer $tag_class" , id => $id });
		$line .= qq(<div class="red margin-bottom">★べすとあんさー\(暫定\)</div>);
	} elsif($data->{'good_num'} >= 1){
		$line .= $html->start_tag("div",{ class => "good_answer $tag_class" , id => $id });
	} else {
		$line .= $html->start_tag("div",{ class => "answer $tag_class" , id => $id });
	}

	if($data->{'deleted_flag'}){
		$line .= $html->span("削除済み ( by \@$data->{'control_account'} )",{ class => "alert" });

	}


$comment .= e($data->{'text'});
	if( my $message = $fillter->each_comment_fillter($comment)){
		$comment = $message;
	} 


my $style = "color:$data->{'font_color'};" if($data->{'font_color'});

	if( my $relation_data = $data->{'relation_data'}){
		my $url = $relation_object->data_to_url($relation_data);
		$line .= $html->start_tag("div",{ class => "margin-top margin-bottom" });
		$line .= $html->href($url,"Q. $relation_data->{'text'}");
		$line .= $html->close_tag("div");
	}

$line .= $html->tag("div",$comment,{ NotEscape => 1 , style => $style , class => "comment" });

$line .= $html->start_tag("div",{ class => "control_answer" });
$line .= $push_good_line;
$line .= $other_data_line;

$line .= $html->close_tag("div");

# 全体を閉じる
$line .= $html->close_tag("div");

$line;

}
#-----------------------------------------------------------
# 回答を投稿する
#-----------------------------------------------------------
sub new_response{

my $self = shift;
my $post = new Mebius::Question::Post;
my $response = new Mebius::Question::Response;
my $regist = new Mebius::Regist;
my $param_utf8 = my $param = Mebius::Query->single_param_utf8();
my($my_account) = Mebius::my_account();
my $init = $self->init();
my(%update);
my $basic = new Mebius::Question;

# アクセス制限
Mebius->axs_check("ACCOUNT");

# 共通のエラー
Mebius::Question::regist_common_error(__PACKAGE__);

	if(Mebius->character_num($param->{'text'}) > $init->{'word_length_limit'}){
		$self->error("文字数オーバーです。");
	} elsif(Mebius::Text->character_num($param->{'text'}) < $init->{'word_length_small_limit_response'}){
		$self->error("文字数が少なすぎます。");
	}

my $post_data = $post->fetchrow_main_table({ number => $param->{'q'} })->[0];

	if($self->deny_response($post_data)){
		$self->error($self->deny_response($post_data));
	}

	if($self->still_responsed($param->{'q'})){
		$self->error($self->still_responsed($param->{'q'}));
	}

# 24時間以内に何個投稿したか
my $too_many_response_error = $self->too_many_response();
	if($too_many_response_error && !$basic->escape_error()){ $self->error($too_many_response_error); }


$update{'text'} = $param->{'text'};
$update{'number'} = $self->create_new_char(30) || $self->error("もういちどお試し下さい。");
$update{'target_post_number'} = $param->{'q'};
$update{'response_time'} = time;
%update = (%update,%{Mebius::Device->my_connection()});
$update{'account'} = $my_account->{'id'} || die;
$update{'handle'} = utf8_return($my_account->{'handle'});
$update{'font_color'} = $regist->param_to_font_color();

# レス用のデータを更新
$self->insert_main_table(\%update);

# 質問本体を更新
my $post_data = $self->post_number_to_data($param->{'q'});
my %update_post;
$update_post{'number'} = $param->{'q'};
$update_post{'first_response_time'} = time if(!$post_data->{'first_response_time'});
$update_post{'last_modified'} = time;
$update_post{'last_response_time'} = time;
$update_post{'last_response_account'} = $my_account->{'id'};
$update_post{'response_num'} = ["+",1];

$post->update_main_table(\%update_post);

# アカウントを更新
Mebius::Auth::File("Renew" , $my_account->{'id'} , { question_last_response_time => time } );

$post->create_common_history_on_comment({ content_targetA => $post_data->{'number'} , last_response_target => $update{'number'} , last_response_num =>  $post_data->{'response_num'}+1 , subject => $post_data->{'text'} , last_account => $my_account->{'id'} });

Mebius::redirect(Mebius::Question::URL->question($param->{'q'}));

exit;

}

#-----------------------------------------------------------
# レスできるかどうかの判定
#-----------------------------------------------------------
sub deny_response{

my $self = shift;
my $post_data = shift;
my $response_dbi = shift;
my $basic = new Mebius::Question;
my $post = new Mebius::Question::Post;
my $response = new Mebius::Question::Response;
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my $init = $self->init();
my($error);

	if(!$post_data){ die "$post_data ?" ; }
	if(!$response_dbi){
		$response_dbi = $response->fetchrow_main_table({ target_post_number => $param->{'q'} } );
	}
	if($basic->escape_error()){ return(); }


	if(!$post_data){
		$error = "質問が存在しません。";	
	} elsif($post_data->{'first_response_time'} && time > $post_data->{'first_response_time'} + $init->{'allow_response_time_since_post'} + 30*60){
		$error = "もう回答は締め切られています。";
	} elsif($post_data->{'account'} eq $my_account->{'id'}){
		$error = "自分の質問には答えられません。";
	} elsif($post_data->{'deleted_flag'}){
		$error = "削除済みの質問です。";
	} elsif($post->best_answered_judge($post_data)){
		$error = "既にベストアンサーがつけられているので回答出来ません。";
	}

$error;

}


#-----------------------------------------------------------
# 既に回答済みかどうかを判定
#-----------------------------------------------------------
sub still_responsed{

my $self = shift;
my $question_number = shift;
my $basic = new Mebius::Question;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($still_flag);

	# 負荷軽減
	if(!$question_number){ warn("question number is empty,"); return();  }
	if($basic->escape_error()){ return(); }

# 回答済みの場合
my $response_dbi = $self->fetchrow_main_table({ target_post_number => $question_number , account => $my_account->{'id'} });

	foreach my $response_data ( @{$response_dbi} ){
			if($response_data->{'account'} eq $my_account->{'id'} && $my_account->{'id'}){
				$still_flag = "あなたはもうこたえてます。";
			}
	}


$still_flag;

}

#-----------------------------------------------------------
# レス投稿回数が多すぎる場合
#-----------------------------------------------------------
sub too_many_response{

my $self = shift;
my($my_account) = Mebius::my_account();
my $init = $self->init();
my($error);

my $border_hour = $init->{'max_response_border_hour'} || die;
my $max_response_num = $init->{'max_response_num'} || die;

my $border_time = time - $border_hour*60*60;

	# DBIのクエリを減らすための処理
	if($my_account->{'question_last_response_time'} < $border_time){ return(); }

my($post_dbi,$result) = $self->fetchrow_main_table({ account => $my_account->{'id'} , response_time => [">",$border_time] });
	if($result >= $max_response_num){	
		$error = "${border_hour}時間以内に答えられる質問は${max_response_num}ケまでです。";
	}

$error;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_push_bad{
1;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"response";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub relation_object{
my $object = new Mebius::Question::Post;
$object;
}



#-----------------------------------------------------------
# エラーの場合
#-----------------------------------------------------------
sub error{
my $self = shift;

Mebius::Question::View->question_view({ error => $_[0] });
}


1;

