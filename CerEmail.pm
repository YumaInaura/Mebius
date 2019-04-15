
use strict;
package Mebius::CerEmail;
use base qw(Mebius::Base::DBI);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# メインテーブルの設定
#-----------------------------------------------------------
#sub main_table_init{
#my $init = {
#MEMORY => 1 ,
#};

#}

#-----------------------------------------------------------
# メインてブルの名前
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
"cer_email";
}


#-----------------------------------------------------------
# カラム名
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
email_char => { PRIMARY => 1 , other_names => { char => } } , 
email => { text => 1 } , 
done => { int => 1 } , 
action_type => { } , 
create_time => { int => 1 } , 
relay_data1 => { text => 1 } , 
relay_data2 => { text => 1 } , 
relay_data3 => { text => 1 } , 
relay_data4 => { text => 1 } , 
relay_data5 => { text => 1 } , 
last_update_time => { int => 1 } ,
};

$column;

}

#-----------------------------------------------------------
# 新しい char を作ってデータベースに登録する
#-----------------------------------------------------------
sub create_new_char{

my $self = shift;
my $email = shift;
my $action_type = shift;
my $use = shift;

my $char = Mebius::Crypt->char(30);;

my %update = ( email_char => $char , email => $email , action_type => $action_type , create_time => time );
%update = (%update,%{$use->{'update'}}) if(ref $use->{'update'} eq "HASH");

# 認証メール用のテーブルを作成
#$self->create_main_table();
$self->update_or_insert_main_table(\%update);

$char;

}


#-----------------------------------------------------------
# 新しい char を作ってデータベースに登録する、もしくはエラーを表示
#-----------------------------------------------------------
sub create_new_char_or_error{

my $self = shift;
my $email = shift;
my $email_obj = new Mebius::Email;

# 連続して同じアドレスに認証メールを送れないように
my $error_flag = $self->redun_send_email($email);
	if($error_flag && !Mebius::alocal_judge()){
		Mebius->error("いちどに認証メールを送ることは出来ません。日が替わるなど、時間が経ってからもういちど試して下さい。");
	}

# メールアドレスのフォーマットをチェック
my($format_error) = $email_obj->format_error($email);
	if($format_error){
		Mebius->error($format_error);
	}

my $char = $self->create_new_char($email,@_);

$char;

}


#-----------------------------------------------------------
# 何度も同じメールアドレスに対して、重複して送信しているかどうかをチェック
#-----------------------------------------------------------
sub redun_send_email{

my $self = shift;
my $email = shift;
my($error_flag);

my $border_time = time - 24*60*60;
my $cer_email_dbi = $self->fetchrow_on_hash_main_table({ email => $email , done => 0 , create_time => [">",$border_time] });
my $border = 3;

	if(ref $cer_email_dbi eq "HASH"){
		my $num = keys %$cer_email_dbi;
			if($num > $border){
				$error_flag = 1;
			}
	} else {
		0;
	}

$error_flag;

}

#-----------------------------------------------------------
# 指定された char が使えるものかどうかをチェック
#-----------------------------------------------------------
sub char_to_dbi_data_or_error{

my $self = shift;
my $char = shift;
my $action_type = shift;
my $use = shift if(ref $_[0] eq "HASH");
my(@error,$email,$cer_email_dbi);

	if($char eq ""){ push @error , "認証用の文字列を入力して下さい。"; }
	if($action_type eq ""){ push @error , "認証タイプが不明です。"; }

	# 指定にエラーがなければ DBI から情報を取得する
 if(!@error){

		$cer_email_dbi = Mebius::CerEmail->fetchrow_on_hash_main_table({ email_char => $char , done => 0 , action_type => $action_type });

		my $data = $cer_email_dbi->{$char};

			if(!$data){
				push @error , "この動作はもう完了しているか、もしくは認証用の情報が存在しません。 ";
			} else {
				$email = $cer_email_dbi->{$char}->{'email'} || push @error , "メールアドレスが登録されていません。";
			}
	}

	# エラーがある場合は即時エラーを表示
	if(@error >= 1){
		$self->error(\@error);
	}

$cer_email_dbi->{$char};

}

#-----------------------------------------------------------
# char を使用済みに
#-----------------------------------------------------------
sub done{

my $self = shift;
my $char = shift;

	if($char eq ""){
		warn("char is empty.");
		return;
	}

# 認証用のDBIを更新
$self->update_or_insert_main_table({ char => $char , done => 1 });

}

#-----------------------------------------------------------
# エラー
#-----------------------------------------------------------
sub error{

my $self = shift;
Mebius->error(@_);

}

1;

