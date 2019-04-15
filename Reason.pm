
use strict;
use CGI;
package Mebius::Reason;
use Mebius::Export;

#-----------------------------------------------------------
# 全ての選択ボックス ( レス削除 )
#-----------------------------------------------------------
sub res_control_box_full_set{

# 宣言
my($use,$selected,$res_number) = @_;
my($line);
my($param) = Mebius::query_single_param();
my %relay_use  = %$use;

	# レスが削除されている場合を自動判定
	if(ref $use->{'res_data'} eq "HASH"){
		($relay_use{'comment_deleted_flag'}) = Mebius::BBS::comment_deleted_judge($use->{'res_data'});
		($relay_use{'handle_deleted_flag'}) = Mebius::BBS::handle_deleted_judge($use->{'res_data'});
	}

# 各パーツを取得
my($line_normal) = Mebius::Reason::comment_control_box_with_reason(\%relay_use,"delete",$selected,$res_number);
my($line_penalty) = Mebius::Reason::comment_control_box_with_reason(\%relay_use,"penalty",$selected,$res_number);

# 筆名削除ボックス
my($handle_delete) = Mebius::Reason::handle_control_input_form(\%relay_use,{ ActionType => "delete" , SelectActionType => $param->{'handle'} });

# 筆名復活ボックス
my($handle_revive) = Mebius::Reason::handle_control_input_form(\%relay_use,{ ActionType => "revive" , SelectActionType => $param->{'handle'} });

# 筆名復活ボックス
my($handle_revive) = Mebius::Reason::all_history_control_input(\%relay_use);

# 本文復活ボックス
my($comment_revive_box) = comment_revive_box(\%relay_use);

$line .= qq(<div>$line_normal</div>);
$line .= qq(<div>$line_penalty</div>);
($line) .= qq(<div>) . res_control_no_reaction_box($use) . qq(</div>);
$line .= qq(<div>$comment_revive_box $handle_revive $handle_delete</div>);

($line) .= qq(このスレッドの全てのレスに同じチェックを入れる： );
($line) .= all_check_reason_button(\%relay_use,"over");
($line) .= all_check_reason_button(\%relay_use,"all");
($line) .= all_check_reason_button(\%relay_use,"under");

return($line);

}

#-----------------------------------------------------------
# 全ての理由にチェックを入れるボタン
#-----------------------------------------------------------
sub all_check_reason_button{

my($relay_use,$javascript_mode) = @_;
my($line,$text);

	# モード判定
	if($javascript_mode eq "over"){
		$text = qq(↑これより上のレス);
	} elsif($javascript_mode eq "all"){
		$text = qq(全てのレス);
	} elsif($javascript_mode eq "under"){
		$text = qq(これより下のレス↓);
	} else {
		die("Please select mode.");
	}

my($bbs_kind,$thread_number,$res_number) = split(/-/,$relay_use->{'unique_number'});
my $bbs_kind_and_thread_number = qq($bbs_kind-$thread_number);

# 全てのチェック
$line .= qq( );
$line .= qq(<span id="reason_all_check_).e($javascript_mode).qq(_).e($relay_use->{'unique_number'}).qq(">$text</span>);
$line .= qq(<a href="javascript:reason_all_check\(').e($bbs_kind_and_thread_number).qq(',').e($res_number).qq(',').e($javascript_mode).qq('\);" class="none" id="reason_all_check_hidden_).e($javascript_mode).qq(_).e($relay_use->{'unique_number'}).qq(">).e($text).qq(</a>);

}



#-----------------------------------------------------------
# 本文操作ボックス
#-----------------------------------------------------------
sub comment_control_box_with_reason{

# 宣言
my($use,$action_type,$selected,$unique_number) = @_;
my($selected_action_type,$selected_reason) = split(/_/,$selected);
my($line,$input_name,$reason_style);
my($parts) = Mebius::Parts::HTML();
my($use_device) = Mebius::my_use_device();

	# 代入
	if($use->{'unique_number'}){ $unique_number = $use->{'unique_number'}; }

	# 汚染チェック
	if($action_type =~ /\W/){ return(); }
	if($unique_number =~ /[^0-9a-zA-Z\-]/){ return(); }

# 削除理由のリストを定義
my($kind_list) = kind_list_for_res();

$input_name = "comment_control";

# 局所化
my($checked_flag,$action_title,$class);

	# 配列を展開
	foreach( sort { $kind_list->{$b}->{'order'} <=> $kind_list->{$a}->{'order'} } keys %$kind_list ){

		# 局所化
		my($checked1,$id,$javascript,$label_style);

		my $hash = $kind_list->{$_};

		# 行を分解
		my $reason_text = Mebius::order($hash->{'admin_title'},$hash->{'title'});
		my $reason_type = $_;

		#my($reason_text,$reason_type) = split(/=/,$_);

			# IDを定義
			if($use_device->{'type'} ne "Mobile"){ $id = qq(${reason_type}_${action_type}_$unique_number); }

			# 初期チェック状態を定義
			if("${selected_action_type}:${selected_reason}" eq "${action_type}:${reason_type}"){ # !$type{'Not-checked'} && 

				$checked1 = $parts->{'checked'};
				$checked_flag = 1;
				$label_style .= qq(background:yellow;);
			}

			# ユーザーから報告のある種類の場合
			if($use->{'user_report_kind'}->{$reason_type}){
				$label_style .= qq(border:solid 2px #f00;);
			}

			# Javascript
			if($use_device->{'type'} ne "Mobile"){
				$javascript = qq( onclick="reason_checked('$unique_number');");
			}


		# チェックボタン
		$line .= qq(<input type="radio" name="${input_name}_$unique_number" value="${action_type}_${reason_type}"$javascript id="$id"$checked1> );

			# ラベル
			if($use_device->{'type'} ne "Mobile"){

				my($label_style_tag) = Mebius::to_style_element($label_style);
				$line .= qq(<label for="$id" id="${id}_label"$label_style_tag>$reason_text</label>\n);
			}
			else{
				$line .= qq($reason_text\n);
			}
	}

	# 未選択ボックス ( 1個 )
	if($action_type ne "penalty"){
		my($checked_first,$normal_line);
			if(!$checked_flag){ $checked_first = $parts->{'checked'}; } # $type{'First-checked'} && 
		$normal_line .= qq(<input type="radio" name="${input_name}_$unique_number" value="" id="none_${action_type}_$unique_number" onclick="reason_checked('$unique_number');"$checked_first>\n);
			if($use_device->{'type'} ne "Mobile"){ $normal_line .= qq(<label for="none_${action_type}_$unique_number" id="none_${action_type}_${unique_number}_label">); }
		$normal_line .= qq(未選択);
			if($use_device->{'type'} ne "Mobile"){ $normal_line .= qq(</label>\n); }
		$line = qq($normal_line$line);
	}

	# 表示タイトル	
	if($action_type eq "delete"){
		$action_title = "削除";
		$class .= " control_delete";
	}
	elsif($action_type eq "penalty"){ 
		$action_title = "罰削除";
		$class .= " control_penalty";
	}

# 整形
$line = qq(<span class="$class"$reason_style>$action_title ： $line</span>);

$line;

}

#-----------------------------------------------------------
# 本文復活ボックス
#-----------------------------------------------------------
sub comment_revive_box{

my($use) = @_;
my($parts) = Mebius::Parts::HTML();
my($my_use_device) = Mebius::my_use_device();
my($self);

	# 削除済みの場合、復活ボタンを表示
		my($checked_revive,$id);

	# ボックスを表示する場合
	if($use->{'comment_deleted_flag'} || $use->{'GetAllBox'}){
		$self .= qq(<span class="control_revive">);
		if(!$my_use_device->{'mobile_flag'}){ $id = qq( id="comment_revive_).e($use->{'unique_number'}).qq("); }
		$self .= qq(<input type="radio" name="comment_control_).e($use->{'unique_number'}).qq(" value="revive"$id$checked_revive).qq( onclick="reason_checked\(').e($use->{'unique_number'}).qq('\)">);
		if(!$my_use_device->{'mobile_flag'}){ $self .= qq(<label for="comment_revive_).e($use->{'unique_number'}).qq(" id="comment_revive_).e($use->{'unique_number'}).qq(_label" class="blue">); }
		$self .= qq(本文復活);
		if(!$my_use_device->{'mobile_flag'}){$self .= qq(</label>\n); }
		$self .= qq(</span> );
	# 表示しない場合
	} else {
		$self .= qq(<strike><span class="control_revive blue"><input type="radio" name="").e($parts->{'disabled'}).qq(>本文復活</span></strike>);
	}

$self;

}


#-----------------------------------------------------------
# 筆名操作ボックス
#-----------------------------------------------------------
sub handle_control_input_form{

# 宣言
my($use,$use2) = @_;
my($self,$omit_flag);
my($parts) = Mebius::Parts::HTML();
my($use_device) = Mebius::my_use_device();
my($checked_handle,$id,$id_tag,$label_style);

	# タグを省略
	if($use_device->{'type'} eq "Mobile"){ $omit_flag = 1; }

		# ●筆名削除ボックスの場合
		if($use2->{'ActionType'} eq "delete"){

				if($use->{'handle_deleted_flag'}){
					return();
				} elsif($use2->{'SelectActionType'} eq "delete"){
					$checked_handle = $parts->{'checked'};
				}

		# ●筆名復活ボックスの場合
		} elsif($use2->{'ActionType'} eq "revive"){

				if(!$use->{'handle_deleted_flag'}){
					return();
				} elsif($use2->{'SelectActionType'} eq "revive"){
					$checked_handle = $parts->{'checked'};
				}
		}

		if(!$omit_flag){
			$id = qq(handle_control_).e($use2->{'ActionType'}).qq(_).e($use->{'unique_number'});
			$id_tag = qq( id="$id");
		}

			# ユーザーから報告のある種類の場合
			if($use->{'user_report_handle_flag'}){
				$label_style .= qq(border:solid 2px #f00;);
			}
			my($label_style_tag) = Mebius::to_style_element($label_style);

		if($use2->{'ActionType'} eq "revive"){
			#$self .= qq(<input type="checkbox" name="handle_control_).e($use->{'unique_number'}).qq(" value="revive"$id_tag$checked_handle>);
		}
		else{
			#$self .= qq(<input type="checkbox" name="handle_control_).e($use->{'unique_number'}).qq(" value="delete" onclick="handle_control_check\(').e($use->{'unique_number'}).qq('\)"$id_tag$checked_handle>);
		}
	
		#if(!$omit_flag){ $self .= qq(<label for="handle_control_$use2->{'ActionType'}_$use->{'unique_number'}"$label_style_tag>); }

		if($use2->{'ActionType'} eq "revive"){
			#$self .= qq(<span style="color:#00f;">);
			$self .= qq(<label class="handle_control" for=").e($id).qq(">);
			$self .= qq(<input type="checkbox" name="handle_control_).e($use->{'unique_number'}).qq(" value="revive"$id_tag$checked_handle>);
			$self .= qq(<span>);
			$self .= qq(筆名復活);
			$self .= qq(</span>);
			$self .= qq(</label>);

			#$self .= qq(</span>);
		}
		else{
				if($use->{'EmphasisHandleDelete'}){ $self .= qq(<strong class="red">); }

			#$self .= qq(<span class="handle_control">);
			my $style .= qq(border:solid 2px #f00;) if($use->{'user_report_invalid_handle_flag'});

			$self .= qq(<span class="handle_control">);
			$self .= qq(<label for=").e($id).qq(">);
			$self .= qq(<input type="checkbox" name="handle_control_).e($use->{'unique_number'}).qq(" value="delete" onclick="handle_control_check\(').e($use->{'unique_number'}).qq('\)"$id_tag$checked_handle>);
			$self .= qq(<span style=").e($style).q(">);
			$self .= qq(筆名削除);
			$self .= qq(</span>);
			$self .= qq(</label>);
			$self .= qq(</span>);

			#$self .= qq(</span>);

				if($use->{'EmphasisHandleDelete'}){ $self .= qq(</strong>); }
		}

		#if(!$omit_flag){ $self .= qq(</label>\n); }



$self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_history_control_input{

my $self = shift;
my $use = shift;
my($print);
my $html = new Mebius::HTML;

$print .= $html->input("checkbox","super_block_",1,{ text => "ブロック削除" , style => "color:red;" });

$print;

}


#-----------------------------------------------------------
# 「対応しない」ボックス
#-----------------------------------------------------------
sub res_control_no_reaction_box{

my($use) = @_;
my($parts) = Mebius::Parts::HTML();
my($my_use_device) = Mebius::my_use_device();
my($self);

		my($checked_no_reaction,$id);

	# ボックスを表示する場合
	#if($use->{'comment_deleted_flag'}){
		$self .= qq(<span class="control_no-reaction">);
		$self .= qq(非対応： );
			if(!$my_use_device->{'mobile_flag'}){ $id = qq(etc_no-reaction_).e($use->{'unique_number'}); }
		$self .= qq(<input type="radio" name="comment_control_).e($use->{'unique_number'}).qq(" value="no-reaction" id="$id"$checked_no_reaction).qq( onclick="reason_checked\(').e($use->{'unique_number'}).qq('\)">);
			if(!$my_use_device->{'mobile_flag'}){ $self .= qq(<label for=").e($id).qq(" id=").e($id).qq(_label" class="">); }
		$self .= qq(対応しない);
			if(!$my_use_device->{'mobile_flag'}){ $self .= qq(</label>\n); }
		$self .= qq(</span> );
	# 表示しない場合
	#} else {
	#	$self .= qq(<strike><span class=""><input type="radio" name="").e($parts->{'disabled'}).qq(>対応しない</span></strike>);
	#}

$self;

}


#-----------------------------------------------------------
# 制限日時のセレクトボックスを取得（一部）
#-----------------------------------------------------------
sub get_select_denyperiod{

# 宣言
my($type,$selected_time) = @_;
my($line,$i_day,$i_week,$i_month,$max_month);
my($parts) = Mebius::Parts::HTML();
our($thishour,$thismin,$thissec);

# 解除日のセレクトボックス (日）

	# エラーチェック
	if($selected_time =~ /\D/){ return(); }

	# 選択済み
	if($selected_time){
		my($how) = Mebius::second_to_howlong({ } , $selected_time - time);
		$line .= qq(<option value="$selected_time"$parts->{'selected'}>$how後\n);
	}

my $unblock_time_day = time - $thishour*60*60 - $thismin*60 - $thissec;
	for(1...6){
		$i_day++;
		$unblock_time_day += (24*60*60);
		$line .= qq(<option value="$unblock_time_day">$i_day日後);
	}

# 解除日のセレクトボックス (週間）
my $unblock_time_week = time - $thishour*60*60 - $thismin*60 - $thissec;
	for(1...4){
		$i_week++;
		$unblock_time_week += (7*24*60*60);
		$line .= qq(<option value="$unblock_time_week">$i_week週間後);
	}


	# 解除日のセレクトボックス (月）
	if($type =~ /Limited/){ $max_month = 2; }
	else{ $max_month = 12; }
my $unblock_time_month = time - $thishour*60*60 - $thismin*60 - $thissec;
	for(1...$max_month){
		$i_month++;
		$unblock_time_month += (30*24*60*60);
		$line .= qq(<option value="$unblock_time_month">約$i_monthヶ月後);
	}

	# 解除日のセレクトボックス
	my $unblock_time = time - $thishour*60*60 - $thismin*60 - $thissec;
	for(1...30){
		$unblock_time += (24*60*60);
		my(%date) = Mebius::Getdate("Get-hash",$unblock_time);
		$line .= qq(<option value="$unblock_time">$date{'yearf'}/$date{'monthf'}/$date{'dayf'}</option>\n);
	}

return($line);

}

#-----------------------------------------------------------
# 削除理由の選択ボックスを取得 ( 旧 … まだ使っている部分あり ) 
#-----------------------------------------------------------
sub get_select_reason{

# 宣言
my($select,$type) = @_;
my($line);
my($parts) = Mebius::Parts::HTML();

# 基本設定を取得
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();

	if($type =~ /RADIO/){ }
	else{ $line .= qq(<option value="">削除/制限理由</option>\n); }

	foreach( sort keys %{$kind_list_for_thread}){

		my $hash = $kind_list_for_thread->{$_};
		my($number,$key,$reason,$guide) = ($_,$hash->{'type'},$hash->{'title'},$hash->{'guide'});


			# 過去に設定していたが、現在は非使用の対応理由
			if($hash->{'NotNewUse'}){ next; }

			# アカウントには表示しない対応理由
			if($type =~ /ACCOUNT/ && $hash->{'NotForAccount'}){ next; }

			# アカウント専用の対応理由 ( なので他の処理ではエスケープする )
			if($type !~ /ACCOUNT/ && $hash->{'ForAccount'}){ next; }

			# ラジオボックス
			if($type =~ /RADIO/){
				my($checked1);
				if($number eq $select){ $checked1 = $parts->{'checked'}; }
					$line .= qq(<input type="radio" name="reason" value="$number" id="reason_$select"$checked1>);
					$line .= qq(<label for="reason_$select">$reason</label>\n);
			}

			# セレクトボックス
			else{
					if($number eq $select){ $line .= qq(<option value="$number" selected style="background:#faa;"> $reason</option>\n); }
					else{ $line .= qq(<option value="$number"> $reason</option>\n); }
			}

	}


return ($line);


}

#-----------------------------------------------------------
# セレクトボックス
#-----------------------------------------------------------

sub select_box_for_thread{

my $use = shift if(ref $_[0] eq "HASH");
my %use = %$use;

$use{'SelectBox'} = 1;

box_for_thread_core(\%use);

}

#-----------------------------------------------------------
# ラジオボックス
#-----------------------------------------------------------
sub radio_box_for_thread{

my $use = shift if(ref $_[0] eq "HASH");
my %use = %$use;

$use{'RadioBox'} = 1;

box_for_thread_core(\%use);

}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub box_for_thread_core{

my $use = shift if(ref $_[0] eq "HASH");
my($self,$i,$hit);
my($parts) = Mebius::Parts::HTML();
my($param) = Mebius::query_single_param();


	# モード判定
	if($use->{'RadioBox'}){

	} elsif($use->{'SelectBox'}){

	}	 else {
		die("Plese Select Mode.");
	}

my $selected_number = Mebius::order($use->{'selected'},$param->{$use->{'input_name'}});
my $input_name = Mebius::order($use->{'input_name'},"reason");

# 基本設定を取得
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();


	# 展開
	foreach my $reason_number ( sort { $a <=> $b } keys %$kind_list_for_thread ){

		my $reason = $kind_list_for_thread->{$reason_number};
		my($checked,$selected,$text_title);
		$i++;

			# 既に使っていない理由
			if($reason->{'NotNewUse'} || $reason->{'ForAccount'}){
				next;
			}

			# 処理タイプと理由のタイプによっては表示しない
			if($reason->{'ForAccount'} && !$use->{'ForAccount'}){
				next;
			}


			# 初期チェック
			if($param->{$use->{'input_name'}}){
					if($selected_number eq $reason_number){
						$checked = $parts->{'checked'};
						$selected = $parts->{'selected'};
					}
			}
			# 初期チェック
			elsif($reason->{'DefaultChecked'}){
				$checked = $parts->{'checked'};
				$selected = $parts->{'selected'};
			}

			# 表示するテキスト
			if($reason->{'easy_title'}){
				$text_title .= e($reason->{'easy_title'});
			} else {
				$text_title .= e($reason_number);
			}

		$hit++;

			# RADIO
			if($use->{'RadioBox'}){

					if($hit % 7 == 0){ $self .= qq(<br>); }

				my $id = qq($input_name-$reason_number);
				my $checked = $parts->{'checked'} if ($use->{'reason'} eq $reason_number);
				my $style = qq(border:3px solid #f00;) if($use->{'reported_reasons'}->{$reason_number});

				$self .= qq(<input type="radio" name=").e($input_name).qq(" value=").e($reason_number).qq(").e($checked).qq( id=").e($id).qq(").e($checked).qq(>);
				$self .= qq(<label title=").e($reason->{'title'}).qq(" for=").e($id).qq(" style=").e($style).qq(">);
				$self .= qq($text_title);
				$self .= qq(</label>);
				$self .= qq(\n);

			# SELECT
			} elsif ($use->{'SelectBox'}){
				$self .= qq(<option value=").e($reason_number).qq(").e($selected).qq(>);
				$self .= e($reason->{'title'});
			}

	}

	# 整形
	if($use->{'SelectBox'}){
		$self = qq(<select name=").e($input_name).qq(">$self</select>\n);
	}


$self;

}

#-----------------------------------------------------------
# タイプ番号からテキストへ ( スレッド )
#-----------------------------------------------------------
sub type_to_detail_for_thread{

my($reason_number) = @_;

# 基本設定を取得
my($kind_list_for_thread) = Mebius::Reason::kind_list_for_thread();

$kind_list_for_thread->{$reason_number}->{'title'};

}

#-----------------------------------------------------------
# タイプ番号から詳細へ ( レス )
#-----------------------------------------------------------
sub type_to_detail_for_res{

my($main_reason_type,$sub_reason_type) = @_;

# 基本設定を取得
my($kind_list_for_res) = Mebius::Reason::kind_list_for_res();

$kind_list_for_res->{$main_reason_type}->{'detail'};

}


#-----------------------------------------------------------
# 削除理由のリスト ( レス )
#-----------------------------------------------------------
sub kind_list_for_res{

my %self = (

local => 
{
	type => "local" ,
	title => "ローカルルール" ,
	admin_title => "ﾛｰｶﾙ" , 
	detail => "ローカルルール違反" , 
	delete_message => "" , 
	group => [
		{ type => "local_rule" , detail => "ローカルルール違反" } ,
	] , 
} ,

paint => 
{
	title => "絵" , 
	admin_title => "絵" , 
} ,

self => ,
{
	type => "self" ,
	title => "本人/ﾐｽ" , 
	admin_title => "本人/ﾐｽ" , 
	detail => "投稿ミス/本人からの削除依頼" , 
} ,

pink => 
{
	type => "pink" ,
	title => "出会い系" ,
	admin_title => "出会い" , 
	detail => "出会い系利用（メールアドレス掲載など）" , 
	delete_message => "" , 
	group => [
		{ type => "email_address" , detail => "メールアドレス掲載・要求" } ,
		{ type => "meeting" ,  detail => "会う約束・オフ会の開催" } ,
	]
 
} ,

sexvio => 
{
	type => "sexvio" , 
	title => "性的/暴力的" ,
	admin_title => "性/暴" , 
	detail => "性的、暴力的な内容" , 
	delete_message => "" , 
	group => [
		{ type => "sex" , detail => "性的な内容" } , 
		{ type => "shock" , detail => "ショッキングな内容" } ,
	] , 
} ,

private => 
{
	type => "private" , 
	title => "個人情報" ,
	admin_title => "個人情報" , 
	detail => "個人情報の掲載・要求" , 
	delete_message => "" , 
	ReportForAdminOnly => 1 , 
	group => [
		{ type => "real_name" , detail => "本名の掲載・要求(姓名両方)" } ,
		{ type => "private_address" , detail => "住所の掲載・要求", } , 
		{ type => "telephone_number" , detail => "電話番号の掲載・要求" } , 
		{ type => "private_imfomation" , detail => "プライベートな情報" } , 
	] , 
} ,

category => 
{
	type => "category" ,
	title => "進行" ,
	admin_title => "ｶﾃ違い/雑談" , 
	detail => "カテゴリ違い・雑談化" , 
	delete_message => "" , 
	group => [
		{ type => "theme" , detail => "カテゴリ違い・テーマ違い" } , 
		{ type => "conversation" , detail => "雑談化" } , 
	] ,
} ,

trouble => 
{
	type => "trouble" ,
	title => "迷惑行為" ,
	admin_title => "" , 
	detail => "迷惑行為（文字羅列・無断転載・AA・チェーン・宣伝など）" , 
	delete_message => "" , 
	group => [
		{	type => "enumeration" , detail => "文字羅列" } ,
		{ type => "reprinting" , detail => "無断転載・転用" } , 
		{ type => "AA" , detail => "AA(アスキーアート)" } , 
		{ type => "chain" , detail => "チェーン投稿" } , 
		{ type => "advertise" , detail => "宣伝行為" } , 
		{ type => "multi_posting" , detail => "マルチポスト" } , 
		{ type => "etc" , detail => "上記に当てはまらない迷惑行為" } , 
	] , 
} ,

manner => 
{
	type => "manner" ,
	title => "マナー" ,
	admin_title => "ﾏﾅ-/過剰" , 
	detail => "マナー違反・リアクション違反" , 
	order => -1 , 
	delete_message => "" , 
	group => [
		{ type => "mannert" , detail => "マナー違反" } , 
		{ type => "reaction" , detail => "リアクション違反" } , 
		{ type => "call" , detail => "不適切な注意・呼びかけ" } , 
	] , 
} ,

vanish => 
{
	title => "消去" , 
	order => -98 , 
	detail => ""
} ,


etc => 
{
	type => "etc" ,
	title => "その他" ,
	admin_title => "その他" , 
	detail => "その他の違反" , 
	delete_message => "その他" , 
	order => -99 , 
	group => [
		{ type => "crime" , detail => "犯罪行為の報告・予告・奨励" } , 
		{ type => "copyright", detail => "著作権・肖像権の侵害" } ,
		{ type => "etc" , detail => "どの項目にも当てはまらない違反" } , 
	] , 
} ,


);

\%self;

}

#-----------------------------------------------------------
# 削除理由のリスト ( スレッド )
#-----------------------------------------------------------
sub kind_list_for_thread{
my($basic_init) = Mebius::basic_init();

# 削除理由のリスト
my %self = (
"" => 
	{ 
		easy_title => "未選択" , 
		title => "未選択" , 
		DefaultChecked => 1 , 
 } , 
1 => 
	{ 
		easy_title => "重複/乱立" , 
		title => "重複記事/記事の乱立" , 
		guide => "原則として、ひとつの掲示板に、同テーマの記事は１個までです。記事はうまくジャンル分けしてください。" , 
		NotForAccount => 1 , 
		MustRefererURL => 1 , 
 } , 

2 => 
	{ 
		easy_title => "カテ違い" , 
		title => "カテゴリ違い" , 
		guide => "ふさわしいカテゴリ、掲示板を選んでください。" , 
		NotForAccount => 1 , 
 } , 

3 => 
	{ 
		easy_title => "注意書不足" , 
		title => "注意書き、チェック不足" , 
		guide => "性的、暴\力的な内容を含む記事など、新規投稿画面のルールや、ローカルルールに従ってください。年齢設定に偽りがある場合も、削除対象です。" , 
		NotForAccount => 1 , 
 } , 

4 => 
	{ 
		easy_title => "限定/個人" , 
		title => "参加者の限定、個人的な記事" , 
		guide => "年齢/学年/居住地/性別 で参加者を決めたり、個人的な記事を作ることは出来ません。" , 
		NotForAccount => 1 , 
 } , 

5 => 
	{ 
		easy_title => "" , 
		title => "個人的な記事" , 
		guide => "「俺と話そう」「ハンドルネームが入った記事」など、個人的な記事は禁止です。" , 
		NotNewUse => 1 , 
 } , 

6 => 
	{ 
		easy_title => "テーマ" , 
		title => "テーマの問題" , 
		guide => "テーマを適切に設定してください。「（関連性のない）複数のテーマがある記事」「単発記事」などは原則として禁止です。" , 
		NotForAccount => 1 , 
 } , 

7 => 
	{ 
		easy_title => "迷惑" , 
		title => "迷惑投稿（荒らし、ＡＡ、チェーン投稿、宣伝など）" , 
		guide => "他の方に迷惑のかからないよう、サイトをご利用ください。" , 
 } , 

8 => 
	{ 
		easy_title => "出会い" , 
		title => "出会い系利用 （メルアド交換、文通、会う約束など）" , 
		guide => "「メルアド掲載/交換」「文通相手/電話相手の募集」「バーチャルデート」「会う約束」などの出会い系利用はご遠慮ください。" , 
 } , 

9 => 
	{ 
		easy_title => "マナー" , 
		title => "マナー違反" , 
		guide => "マナー、言葉遣いなどには充分ご注意ください。" , 
 } , 

10 => 
	{ 
		easy_title => "個人情報" , 
		title => "個人情報の掲載" , 
		guide => "「住所」「本名」「電話番号」などの個人情報や、プライベートな情報は絶対に書き込まないでください。" , 
		ReportForAdminOnly => 1 , 
 } , 

11 => 
	{ 
		easy_title => "性的/暴力" , 
		title => "性的、または暴\力的で思慮のない書き込み" , 
		guide => "議論・相談以外で、思慮のない性的・暴\力的な書き込みをしないでください。" , 
 } , 

12 => 
	{ 
		easy_title => "ローカル" , 
		title => "ローカルルール違反" , 
		guide => "ローカルルールを確認してください。" , 
		NotForAccount => 1 , 
 } , 

13 => 
	{ 
		easy_title => "" , 
		title => "テーマ、題名が不明確" , 
		guide => "分かりやすい題名、テーマを使ってください。" , 
		NotNewUse => 1 , 
 } , 

14 => 
	{ 
		easy_title => "著作/肖像" , 
		title => "著作権/肖像権の問題" , 
		guide => "二次創作、無断転載などは禁止です。" , 
 } , 

15 => 
	{ 
		easy_title => "本人/ミス" , 
		title => "本人からのご連絡/投稿ミス" , 
		guide => "" , 
 } , 

16 => 
	{ 
		easy_title => "雑談化/スレ違い" , 
		title => "雑談化/チャット化/カテゴリ違いのレス" , 
		guide => "雑談化/チャット化/カテゴリ違いの投稿は控え、この記事のテーマに合った投稿をしてください。" , 
 } , 


17 => 
	{ 
		easy_title => "犯罪" , 
		title => "犯罪の報告・示唆・奨励など" , 
		guide => "犯罪にあたる行為（もしくはそれにつながる行為）を報告・示唆・奨励しないでください。" , 
 } , 

18 => 
	{ 
		easy_title => "問題" , 
		title => "問題が起きやすいテーマ" , 
		guide => "非常に問題が起きやすいテーマは、管理者側で対応させていただく場合があります。（例：「不良集まれ！」」「グチ言い放題」など）" , 
		NotForAccount => 1 , 
 } , 


20 => 
	{ 
		easy_title => "運営" , 
		title => "サイト運営上の問題" , 
		guide => "サイト運営上の問題で管理者が対応させていただく場合があります。（荒らし防止など）" , 
		NotForAccount => 1 , 
 } , 

21 => 
	{ 
		easy_title => "デリケート" , 
		title => "デリケートなコンテンツ" , 
		guide => "自殺・自傷・自然災害・不幸な事故・わいせつ事件などのデリケートな話題は、運営上の理由により非表示になる場合があります。" , 
		guide_url => e($basic_init->{'guide_url'}).q(/%A5%C7%A5%EA%A5%B1%A1%BC%A5%C8%A4%CA%C6%E2%CD%C6) , 
 } , 

50 => 
	{ 
		easy_title => "アカ乱立" , 
		title => "アカウントの乱立・作りすぎ" , 
		guide => "アカウントの乱立はご遠慮ください。" , 
		ForAccount => 1 , 
 } , 

51 => 
	{ 
		easy_title => "虚偽情報" , 
		title => "誕生日など、虚偽情報の設定" , 
		guide => "誕生日は正確に入力するか、空欄のままにしてください。" , 
		NotNewUse => 1 , 
 } , 

52 => 
	{ 
		easy_title => "別アカウント" , 
		title => "別アカウントの影響" , 
		guide => "同一ユーザーの他アカウントでの違反ある場合、関連アカウントにも影響する場合があります。たとえばひとつのアカウントがロック中に、別のアカウントを使って活動しないでください。" , 
		ForAccount => 1 , 
 } , 

53 => 
	{ 
		easy_title => "アカウント管理不足" , 
		title => "アカウントの管理不足" , 
		guide => "ご自身のアカウントを適切に管理してください。あなたのアカウント内で他のユーザー様がルール違反をおこなっている場合、放置せずに、削除などの対応をお願いします。" , 
		ForAccount => 1 , 
 } , 

54 => 
	{ 
		easy_title => "アカウント不正" , 
		title => "アカウントの不正利用" , 
		guide => "他人のアカウントを不正に利用するなどの利用はご遠慮ください。" , 
		ForAccount => 1 , 
 } , 


71 => 
	{ 
		easy_title => "なりきりクオリティ" , 
		title => "なりきりのクオリティ不足" , 
		guide => "「短文」「ロルを使わない投稿」「キャラになりきれていない投稿」などが多い状態です。" , 
 } , 


98 => 
	{ 
		easy_title => "使えない接続元" , 
		title => "使えない接続元" , 
		guide => "接続元が不正です。" , 
		NotForReport => 1 , 
 } , 

101 => 
	{ 
		easy_title => "ゲーム不正" , 
		title => "ゲームでの不正行為" , 
		guide => "ゲームにおける不正利用（システムバグの利用、サーバーに負担を欠ける行為など）。" , 
 } , 

201 => 
	{ 
		easy_title => "不正なレポート" , 
		title => "不適切な違反報告" , 
		guide => "違反報告において不適切な利用はご遠慮ください。" , 
 } , 

99 => 
	{ 
		easy_title => "その他" , 
		title => "その他" , 
		guide => "総合ガイド、ローカルルールを確認してください。" , 
 } , 

);

\%self;

}


1;
