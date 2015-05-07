
use strict;
use CGI;
package Mebius::BBS;

#-----------------------------------------------------------
# ID履歴の強制度を判定
#-----------------------------------------------------------
sub id_history_level_judge{

my $use = shift if(ref $_[0] eq "HASH");
my(%self,$account_link_flag);
my($my_cookie) = Mebius::my_cookie_main_logined();
my($my_account) = Mebius::my_account();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($parts) = Mebius::Parts::HTML();
my($query) = Mebius::query_state();

	if($ENV{'REQUEST_METHOD'} eq "POST"){
			if($query->param('account_link')){
				$account_link_flag = 1;
			}
	}
	else{
			$account_link_flag = 1;
	}

	# ▼必ず”使わない”場合
	if(Mebius::BBS::secret_judge() || $init_bbs->{'another_idsalt'} || $init_bbs->{'concept'} =~ /Not-idory/){
		$self{'level'} = "not";
		#$self{'input'} .= qq( <input type="checkbox" name="none" value="Off" id="history_open"$parts->{'disabled'}>\n);
		#$self{'input'} .= qq( <strike>ID履歴</strike>\n);
	}

	# ▼履歴を任意でオフにする場合
	elsif($my_account->{'login_flag'} && $query->param('account_link') && $query->param('name') =~ /#(.*)#history-off/i){
		$self{'record_flag'} = 0;
	}

	# ▼任意の場合 ( 非使用 )
	elsif($my_account->{'login_flag'} && 0){
		my $checked;

		$self{'level'} = "free";

			# プレビュー/送信時
			if($ENV{'REQUEST_METHOD'} eq "POST"){

					# 使う
					if($query->param('history_open')){
						$checked = $parts->{'checked'};
						$self{'record_flag'} = 1;
						$self{'set_cookie_value'} = "On";
					}

					# ID履歴がオフで、アカウント表示もオフの場合、ID履歴を強制的に有効に
					elsif(!$query->param('account_link')){
						$self{'alert_flag'} = qq(「ID履歴」と「アカウント表\示」の両方をオフにすることは出来ません。このまま書きこむと「ID履歴」のみが公開されます。);
						$self{'record_flag'} = 1;
						$self{'set_cookie_value'} = "On";
					}
					else{
						$self{'set_cookie_value'} = "Off";
					}


			}

			# フォーム表示時
			else{
					if($my_cookie->{'use_id_history'} ne "Off"){ $checked = $parts->{'checked'}; }
			}

		#$self{'input'} .= qq( <input type="checkbox" name="history_open" value="On" id="history_open"$checked>\n);
		#$self{'input'} .= qq(<label for="history_open">ID履歴</label>\n);

	# ▼必ず ”使う”場合
	}	else {
		$self{'level'} = "must";
		$self{'record_flag'} = 1;
		#$self{'input'} .= qq( <input type="checkbox" name="none" value="On" id="history_open"$parts->{'disabled'}$parts->{'checked'}>\n);
		#$self{'input'} .= qq(<label for="history_open">ID履歴</label> <span class="alert">※アカウントにログインするとID履歴をオフにできます。</span>\n);
		#$self{'input'} .= qq(<input type="hidden" name="history_open" value="On">\n);
	}

	# Sjis にエンコード
	if($use->{'from_encoding'}){
		Mebius::Encoding::from_to("utf8",$use->{'from_encoding'},$self{'alert_flag'});
	}

\%self;

}

#-----------------------------------------------------------
# 掲示板のスレッドで、アカウント毎の投稿履歴リンクを表示するかどうかの判定
#-----------------------------------------------------------
sub view_account_history_judge{

my $concept = shift;

	if($concept =~ /Accountory/){ return 1; }

}

#-----------------------------------------------------------
# スレッド内のレスの削除状況を判定
#-----------------------------------------------------------
sub comment_deleted_judge{

my($res_data);

$res_data = $_[0] if(ref $_[0] eq "HASH");
$res_data = { concept => $_[0] , deleted => $_[1] } if(ref $_[0] eq "");

	#if(@_){ die("Too many value is relayed."); }

	if($res_data->{'concept'} =~ /Deleted-comment/){
			return 1;
	}

	if($res_data->{'deleted'} && $res_data->{'deleted'} ne "<Re>"){
		return 1;
	}

}

#-----------------------------------------------------------
# スレッド内のレスの筆名の削除状況を判定
#-----------------------------------------------------------
sub handle_deleted_judge{

my $res_data = shift;
my($self);

	if(@_){ die("Perl Die! Too many value is relayed."); }

	if($res_data->{'concept'} =~ /Deleted-handle/){
		$self = 1;
	}

$self;

}



#-----------------------------------------------------------
# 記事主によるレス削除の可否
#-----------------------------------------------------------
sub allow_thread_master_delete_judge{

my $use_thread = shift;
my $res_data = shift;
my $init_bbs = shift;
my($my_account) = Mebius::my_account();
my($edit);

	if($init_bbs->{'allow_thread_master_delete'} != 1){ return("この掲示板では記事主によるレス削除は出来ません。"); }

	# 削除済みの場合は削除できない
	if(! defined $res_data){ return("レスが存在しません。"); }

	# 削除済みの場合は削除できない
	if(Mebius::BBS::comment_deleted_judge($res_data) == 1){ return("既に削除済みのレスです。"); }

	# ０番のレスは削除できない
	if($res_data->{'res_number'} eq "0"){ return("最初のレスは削除できません。"); }

	if(!$res_data->{'regist_time'} || time > $res_data->{'regist_time'} + 1*24*60*60){ return("削除するには時間が経ちすぎています。"); }

	if(!$use_thread->{'zero_account'}){ return("この記事はアカウントが設定されていません。"); }

	if($use_thread->{'zero_account'} ne $my_account->{'id'}){ return("記事を新規投稿した時と同じアカウントにログインしてください。"); }




return 1;

}

#-----------------------------------------------------------
# 記事番号の不正チェック
#-----------------------------------------------------------
sub thread_number_judge{

my($thread_number) = @_;
my($self);

	if($thread_number eq "" || $thread_number =~ /\D/){
		0;
	} else {
		$self = 1;
	}

$self;

}

#-----------------------------------------------------------
# 掲示板種類の不正チェック
#-----------------------------------------------------------
sub bbs_kind_judge{

my($bbs_kind) = @_;
my($self);

	if($bbs_kind eq "" || $bbs_kind =~ /[^0-9a-zA-Z]/){
		0;
	} else {
		$self = 1;
	}

$self;
}

1;
