
# 宣言
use strict;

use Mebius::BBS;
use Mebius::Paint;
use Mebius::Question;
use Mebius::Video::Basic;
use Mebius::Saying::Basic;
use Mebius::Move;

package Mebius::Report;
use Mebius::Export;
use base qw(Mebius::Base::DBI);

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
sub around_form{

my $self = shift;
my $parts = shift;
my $type = shift;
my $use = shift;
my $operate = new Mebius::Operate;
my $overwrite_use = $operate->overwrite_hash($use,{ source => "utf8" , OnlyTarget => 1 });

report_mode_around_form($parts,$type,$overwrite_use);

}


#-----------------------------------------------------------
# メインのテーブル名
#-----------------------------------------------------------
sub main_table_name{
my $self = shift;
"report";
}



#-----------------------------------------------------------
# メインテーブルのカラム名
#-----------------------------------------------------------
sub main_table_column{

my $self = shift;

my $column = {
status_key => {} , 
content_type => { INDEX => 1 } , 
server_domain => {} , 
unique_number => {} , 
unique_char => {} , 
report_category => {} , 
target_unique_number => {} , 
targetA => {} , 
targetB => {} , 
targetC => {} , 
targetD => {} , 
report_res_number => {} , 
report_type_res_or_thread => {} , 
report_reason_for_thread => {} , 
main_reason => {} , 
sub_reason => {} , 
report_time => { int => 1 } , 
report_detail => { text => 1 } , 
report_referer_url => {} , 
report_handle_check => {} , 
handle => {} , 
trip => {} , 
id => {} , 
cnumber => {} , 
account => {} , 
addr => {} , 
host => {} , 
user_agent => {} , 
mobile_uid => {} , 
email => {} , 
answer_type => {} , 
answer_penaly_type => {} , 
answer_handle => {} , 
answer_id => {} , 
answer_time => { int => 1 , INDEX => 1 } , 
answer_improper_check => {} , 
last_update_time => { int => 1 } , 
};

$column;


}

#-----------------------------------------------------------
# カラムに合わせて INSERT 内容のハッシュを調整
#-----------------------------------------------------------
sub adjust_set_main_table{

my($set) = @_;

my($column) = main_table_column();
my($adjusted_set) = Mebius::DBI->adjust_set($set,$column);

$adjusted_set;

}

#-----------------------------------------------------------
# (ユーザーによる)報告モードの分岐判定
#-----------------------------------------------------------
sub report_mode_junction{

my $self = shift;
my $use = shift;

	# ここでエラーも一緒にチェック、エラーがなければ処理続行
	if(send_report_justy_judge()){

			my($report) = foreach_query();

		Mebius::Report->send_report($report,$use);

	}

}

#-----------------------------------------------------------
# 報告モードに移行するボタン
#-----------------------------------------------------------
sub move_to_report_mode_button{

my $use = shift if(ref $_[0] eq "HASH");
my($self,$submit_type,$disabled,$button_class);
my($parts) = Mebius::Parts::HTML();

	# 送信させない場合
	if(Mebius::Switch::stop_user_report()){
		$disabled = $parts->{'disabled'};
		$submit_type = "button";
	} else {
		$button_class = "report";
		$submit_type = "submit";
	}


	# 報告モードの場合
	my($request_url) = Mebius::request_url();

	if(!$use->{'NotThread'}){
			if(report_mode_judge()){
				$self .= qq( <input type="button" value="スレッドを報告" class="report disabled" disabled>\n);
			} else {
				$self .= qq(<form action="./?report=).e(time).qq(#REPORT_THREAD" method="post" class="inline" >\n);
					my($foreach_hidden_tags) = Mebius::foreach_query_and_get_input_hidden_tag({ exclusion => ["report_mode_for_res","report_mode_for_thread"] });
				gq_utf8($foreach_hidden_tags);
				$self .= qq($foreach_hidden_tags);
				$self .= qq(<input type="$submit_type" name="report_mode_for_thread" value="スレッドを報告" class="$button_class"$disabled>\n);
				$self .= qq(</form>\n);
			}
	}

	if(report_mode_judge()){
		$self .= qq(<input type="button" value="レスをまとめて報告" class="report disabled" disabled>\n);
	}	elsif($use->{'ViewResReportButton'}){
			$self .= qq(<form action="./?report=).e(time).qq(#REPORT_RES" method="post" class="inline" >\n);
			my($foreach_hidden_tags) = Mebius::foreach_query_and_get_input_hidden_tag({ exclusion => ["report_mode_for_res","report_mode_for_thread"] });
			gq_utf8($foreach_hidden_tags);
			$self .= qq($foreach_hidden_tags);
			$self .= qq(<input type="$submit_type" name="report_mode_for_res" value="レスをまとめて報告" class="$button_class"$disabled>\n);
			$self .= qq(</form>\n);
	}

	if($disabled){
		$self .= qq(<span class="alert">※レポート機能は一時停止中です。いましばらくお待ちください。</span>);
	}


$self;

}


#-----------------------------------------------------------
# 報告用のチェックボックス (レス単位)
#-----------------------------------------------------------
sub report_check_box_per_res{

my $use = shift if(ref $_[0] eq "HASH");
my $report_target = shift;
my($parts) = Mebius::Parts::HTML();
my($q) = Mebius::query_state();
my($use_device) = Mebius::my_use_device();
my($self,$checked,$i,$line);
my $question = new Mebius::Question;

	# フォーマットチェック
	if($report_target eq "" || $report_target =~ /[^a-zA-Z0-9\-\_]/){
		warn("Invalid value in report target ' $report_target '");
		return();
	}

	if(!$use->{'NaturalParts'}){
		$self .= qq(<div class="right padding-height">);
	}

	# ●コメントの報告欄
	if(!$use->{'comment_deleted_flag'}){

			if(!$use->{'NaturalParts'}){
				$self .= qq(違反タイプ： );
			}
		$self .= select_box_for_report_res({ select_name => $report_target });

	} else {
		$self .= qq(<span class="alert">※コメントは削除済みです。</span>);
	}

	if(!$use->{'NaturalParts'}){
		$self .= qq(</div>);
	}

$self;

}
#-----------------------------------------------------------
# 報告フォーム全体
#-----------------------------------------------------------
sub report_mode_around_form{

my $parts = shift;
my $select_name = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $html = new Mebius::HTML;
my($self,$display_none_class);
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
my $time = time;

# 整形
$select_name =~ s/^report_//g;

	# 報告モードでなければリターン
	#if(!report_mode_judge()){ return($parts); }


	# パーツ定義
	{

			# 帯
			if($use->{'Res'}){
				$self .= qq(<div style="background:#090;" class="padding-height center margin-bottom" id="REPORT_RES"><strong class="white">レスの報告</strong></div>);
			} elsif ($use->{'Thread'}){
				$self .= qq(<div style="background:#090;" class="padding-height center margin-bottom" id="REPORT_RES"><strong class="white">ページの報告</strong></div>);
				$display_none_class = " none"; # スレッドのレス部分だけを隠すための none
			}

		my $action = "#REPORT_FORM";
			if(Mebius::alocal_judge()){ $action = "./?time=$time#REPORT_FORM"; }

		$self .= $html->start_tag("form",{ method => "post" , class => "inline" , action => $action , utn => 1 });
		$self .= qq(<input type="hidden" name="send_report" value="1">);
		$self .= $html->input("hidden","backurl");

		#$self .= Mebius::Query->input_hidden_encode();

			if($param->{'char'} =~ /^(\w+)$/){
				$self .= q(<input type="hidden" name="char" value=").e($param->{'char'}).q(">);
			} else {
				my($input_char) = Mebius::Crypt::char(undef,20);
				$self .= qq(<input type="hidden" name="char" value=").e($input_char).q(">);
			}

			#if($use->{'RelayInputHidden'}){
				my($foreach_hidden_tags) = Mebius::foreach_query_and_get_input_hidden_tag({ limited => ["account","mode","moto","no","No","r","word","(.*?)report_(.+?_)?preview_(.+?)","report_mode_for_res","report_mode_for_thread","single_reason_report_mode"] });
				gq_utf8($foreach_hidden_tags);
				$self .= qq($foreach_hidden_tags);
			#}


		# 元パーツを追加
		$self .= qq(<div class="$display_none_class">);
		$self .= qq($parts\n);
		$self .= qq(</div>);

		# フォームを追加
		($self) .= report_form($select_name,$use);


		$self .= qq(</form>\n);

	}

$self;

}


#-----------------------------------------------------------
# 報告フォーム
#-----------------------------------------------------------
sub report_form{

my($select_name) = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($q) = Mebius::query_state();
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();
my($my_use_device) = Mebius::my_use_device();
my($parts) = Mebius::Parts::HTML();
my($my_cookie) = Mebius::my_cookie_main_logined();
$my_cookie = hash_to_utf8($my_cookie) if($use->{'source'} eq "utf8");
my($line,$error_message);
my $query = new Mebius::Query;

	# 報告モードでなければリターン
	#if(!report_mode_judge()){ return(); }


# ●タグ始まり
$line .= qq(<input type="hidden" name="report_mode" value="1">);
$line .= qq(<div class="padding" style="border:solid 1px #080;margin-bottom:1em;background:#efe;" id="REPORT_FORM">);

	# ●プレビュー表示
	if($q->param('preview')){
		$line .= qq(<div class="message-blue margin">);
		$line .= qq(<h3>プレビュー：</h3>);
		my($report_detail) = e($param_utf8->{'report_detail'});
		$report_detail = Mebius::auto_link_blank($report_detail);
		$report_detail =~ s/[\r\n]/<br>/g;
		$line .= $report_detail;
		$line .= qq(</div>);
	}

	# ●エラー表示
	if(send_report_judge()){

		my($error) = send_report_basic_error_check({});

			foreach(@$error){

				$error_message .= qq(<li>$_</li>);
			}

			if($error_message){
				$line .= qq(<div class="message-red red margin"><h3>エラー：</h3><ul>$error_message</ul></div>);
			}
	}

	# ●警告を表示
	if(send_report_judge()){

		my($alert_message);
		my $checked = $parts->{'checked'} if($param->{'break_alert'});
		my(undef,$alert) = send_report_basic_error_check({});

			foreach(@$alert){
				$alert_message .= qq(<li>$_</li>);
			}

			if($alert_message){
				$line .= qq(<div class="message-red red margin"><h3>確認：</h3><ul>$alert_message</ul><label><input type="checkbox" name="break_alert").e($checked).qq(><span>同意する</span></label></div>);
			}

	}

	# ●テーブル始まり
	{
		$line .= qq(<table class="width100">);
	}

	# ●筆名エリア
	{
		my($inputed_name);

			if($q->param('send_report') && $ENV{'REQUEST_METHOD'} eq "POST"){
				$inputed_name = $q->param('name');
			} else {
				$inputed_name = $my_cookie->{'name'};
			}

		g_utf8($inputed_name);

		$line .= qq(<tr>);
		$line .= qq(<td style="width:8.0em;">筆名 <span class="alert">※</span></td>);
		$line .= qq(<td>);
		$line .= qq(<input type="text" name="name" value=").e($inputed_name).qq(">);
		$line .= qq(</td>);
		$line .= qq(</tr>);

	}

	# ●メールアドレスエリア
	{
		my($inputed);
			if($q->param('send_report') && $ENV{'REQUEST_METHOD'} eq "POST"){
				$inputed = $q->param('email');
			} else {
				$inputed = $my_cookie->{'email'};
			}
			gq_utf8($inputed);
		$line .= qq(<tr>);
		$line .= qq(<td>メールアドレス</td>);
		$line .= qq(<td>);
		$line .= qq(<input type="email" name="email" value=").e($inputed).qq(" placeholder="例\) example\@ne.jp">);
		$line .= qq(</td>);
		$line .= qq(</tr>);

	}

	# ● 依頼理由エリア	(レス一括)
	{

		# ▼依頼理由のリストを定義
		$line .= qq(<tr>);
		$line .= qq(<td class="valign-top">違反タイプ <span class="alert">※</span></td>);

		$line .= qq(<td>);

		# ▼スレッドへの報告
		if(report_mode_judge_for_thread() || $use->{'Thread'}){

			($line) .= Mebius::Reason::select_box_for_thread({ input_name => "report_$select_name" });

		# ▼レスへの報告
		} else {

				if($use->{'OnlyTarget'}){
					$line .= Mebius::Report::report_check_box_per_res({ NaturalParts => 1 },"${select_name}");
				} else {
					# 複数選択モード ( レスへの報告 )
					$line .= qq(<span class="alert">報告対象ごと、ひとつずつ選んで下さい。</span>);
				}
		}
		$line .= qq(</td>);

		$line .= qq(</tr>);

	}

	# ●参照URL
	if(report_mode_judge_for_thread() || $use->{'Thread'}){

		my($inputed);
			if($q->param('send_report') && $ENV{'REQUEST_METHOD'} eq "POST"){
				$inputed = $q->param("referer_url_${select_name}");
			}
			gq_utf8($inputed);

		$line .= q(<tr>);
		$line .= q(<td><span class="">参照スレッド</span></td>);
		$line .= q(<td>);
		$line .= q(<span class=""><input type="url" name="referer_url_).e($select_name).q(" value=").e($inputed).q(" placeholder="例： http://mb2.jp/_test/123.html"></span>);
		$line .= q(<span class="guide">※ 重複記事を報告する場合などに、スレッドのURLを入力してください。</span>);
		$line .= q(</td>);
		$line .= q(</tr>).qq(\n);

	}

	# ●詳細エリア
	{

		$line .= qq(<tr>);
		$line .= qq(<td class="valign-top">詳細 <span class="alert">※</span></td>);

		$line .= qq(<td>);

			# ▼詳細入力エリア
			{
				$line .= qq(<textarea name="report_detail" class="wide" style="background:#fee;" placeholder="違反行為を報告します。スレッドへの書き込みではないためご注意ください。">);	# background:#efe;
					my $inputed_textarea = e($q->param('report_detail'));
					gq_utf8($inputed_textarea);
				$line .= qq($inputed_textarea);
				$line .= qq(</textarea>);

			}

			# ▼注意書きエリア (詳細下)
			{
				$line .= qq(<ul class="no-point red size90">);
				$line .= qq(<li>※報告は非公開です。(管理者だけに届きます)</li>);
				$line .= qq(</ul>);
			}

		$line .= qq(</td>);

		$line .= qq(</tr>);

	}

	# ●送信ボタン
	{
		$line .= qq(<tr>);
		$line .= qq(<td></td>);
		$line .= qq(<td>);
		#$line .= qq(<input type="submit" name="preview" value="プレビュー" class="ipreview report">);
		$line .= qq(　<input type="submit" name="" value="違反報告する" class="isubmit report red" style="color:#f00;">);
		$line .= qq(</td>);
		$line .= qq(</tr>);

	}

	# ●タグ/テーブル終わり
	{
		$line .= qq(</table>);
		$line .= qq(</div>);

	}

	if($use->{'source'} eq "utf8"){
		$line .= $query->input_hidden_encode();
	}


	# ● Javascriopt
	if(!$my_use_device->{'mobile_flag'}){
		$line .= qq[
		<script>
		window.onload = function(){
		var i;
				for(i = 0; i <= 10000 ; i++){
					bgswitch('report_res_label_'+i,'report_res_'+i,'#ff0','#9f9');
				}
		}
		</script>
		];
	}




$line;

}


#-----------------------------------------------------------
# レポートのためのセレクトボックス
#-----------------------------------------------------------
sub select_box_for_report_res{

my($line);
my $use = shift if(ref $_[0] eq "HASH");
my($param) = Mebius::query_single_param();
my($parts) = Mebius::Parts::HTML();
my($kind_list);

	# 名前が指定されていない場合
	if(!$use->{'select_name'}){
		die("Perl Die! Please decide '\$use->{'select_name'}' ");
	}


	# 削除理由を展開
		($kind_list) = Mebius::Reason::kind_list_for_res();
		$line .= qq(<select name="report_).e($use->{'select_name'}).qq(">);

$line .= qq(<option value="">未選択\n);

	# ●理由を展開
	foreach my $type ( sort keys %$kind_list ){

		my $hash = $kind_list->{$type};

			if($use->{'ResMode'} && !$hash->{'detail'}){ next; }

			# ▼グループが設定されている場合
			if($hash->{'group'}){
				my $i;
				$line .= qq(<optgroup label="$hash->{'title'}">\n);

					foreach my $group (@{$hash->{'group'}}){

						my($class,$selected);
								if($param->{"report_$use->{'select_name'}"} =~ /^$type-$group->{'type'}$/){

									$selected = $parts->{'selected'};
								}

						$line .= qq(<option value=").e($type).qq(-).e($hash->{'group'}->[$i]->{'type'}).qq(").e($selected).qq(>).e($hash->{'group'}->[$i]->{'detail'}).qq(\n);
						$i++;
					}
				$line .= qq(</optgroup>\n);

			}

	}

$line .= qq(</select>);

$line;

}







#-----------------------------------------------------------
# モード切り替えリンク
#-----------------------------------------------------------
sub report_view_switch_link{

my($line);
my($q) = Mebius::query_state();

my @link = (
{ type => "" , title => "未確認" } , 
{ type => "still_admin_check" , title => "確認済み" } , 
);

	# 展開
	foreach(@link){

			# 選択状態の場合 ( クエリを判定 )
			if($_->{'type'} eq $q->param('view_type')){
				$line .= e($_->{'title'}).qq(\n);

			# 非選択状態の場合 ( クエリを判定 )
			} else {
				# リンクを定義
				$line .= qq(<a href="?mode=report_view);
					if($_->{'type'}){
						$line .= qq(&amp;view_type=).e($_->{'type'});
					}
				$line .= qq(">).e($_->{'title'}).qq(</a>\n);
			}
	}

$line;


}

#-----------------------------------------------------------
# レポートを処理する
#-----------------------------------------------------------
sub report_control{

my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
my($my_admin) = Mebius::my_admin();
my $question = new Mebius::Question;
my $video = new Mebius::Video;
my $saying = new Mebius::Saying;
my $tags = new Mebius::Tags;
my $move = new Mebius::Move;

	# 管理モードでないと実行できない
	if(!Mebius::Admin::admin_mode_judge()){
		main::error("You're not admin!");
	}

	# 全てのレポートを対応済みにする
	if($param->{'type'} eq "no_reaction_to_all_report" && $my_admin->{'master_flag'}){

		no_reaction_to_all_report();


	# 最近対応したレポートをもとに戻す
	} elsif($param->{'type'} eq "undo_recently_answer" && $my_admin->{'master_flag'}){

		undo_recently_answer();

	# レポートに対応する
	} else {

		# 掲示板のスレッドを操作
		Mebius::Admin::bbs_thread_control_multi_from_query();

		# SNSの日記を操作
		my($controled_sns_diary) = Mebius::SNS::Diary::query_to_control();

		# SNSの伝言板を操作
		Mebius::SNS::CommentBoad::query_to_control();

		$saying->query_to_control({ NotRedirect => 1});

		$question->control({ FROM_REPORT => 1 });

		$video->control({ FROM_REPORT => 1 });

		$tags->query_to_control();

	}

# SSS 後ほど修正 => 何を修正するんだっけ？
$move->redirect_to_self_url();
#Mebius::Redirect("","$basic_init->{'admin_main_url'}?mode=report_view");

exit;

}

#-----------------------------------------------------------
# 全てのレポートを対応済みにする
#-----------------------------------------------------------
sub no_reaction_to_all_report{

my($table_name) = main_table_name() || die;
my($dbh) = Mebius::DBI->connect();

my $set = { answer_time => time };

Mebius::DBI->update(undef,$table_name,$set,"WHERE (answer_time is NULL OR answer_time = '0');");

}

#-----------------------------------------------------------
# 最近対応したレポートを元に戻す
#-----------------------------------------------------------
sub undo_recently_answer{

my($table_name) = main_table_name() || die;
my($dbh) = Mebius::DBI->connect();
my $border_time = time - 1*60*60; # 何時間前のものまでもとに戻すか
my $set = { answer_time =>  };

Mebius::DBI->update(undef,$table_name,$set,"WHERE answer_time >= $border_time;");

}


#-----------------------------------------------------------
# １レス毎に依頼理由を選ぶかどうか
#-----------------------------------------------------------
sub select_reason_per_res_judge{

return 1; # このモードで固定 ( 単一選択モードはもう使わない )

my($q) = Mebius::query_state();
	if($q->param('single_reason_report_mode')){ return 0; } else { return 1; }

}

#-----------------------------------------------------------
# 不適切な理由の選択ボックス
#-----------------------------------------------------------
sub improper_report_select_box{

my($kind) = improper_report_kind();
my($line);

	foreach(@$kind){

		foreach (@{$_->{'group'}}){
				$line .= qq(<label>);
				$line .= qq(<input type="radio" name="improter_report" value=").e($_->{'type'}).qq(">);
				$line .= qq(<span>);
				$line .= e($_->{'title'});
				$line .= qq(</span>);
				$line .= qq(</label>);

		}

	}

$line;

}
#-----------------------------------------------------------
# 不適切な報告の種類
#-----------------------------------------------------------
sub improper_report_kind{

my @line = (

{
	type => "" , 
	group => [
		{ type => "" , title => "未選択" } 
	]

},

{
	type => "detail" , 
	title => "詳細/依頼理由" , 
	group => [
		{ type => "" , title => "詳細不明" , guide => "詳細や依頼理由は、具体的に、明確に書いてください。" } , 
		{ type => "not_report" , title => "報告でない" , guide => "" } , 
		{ type => "" , title => "存在しないルール" , guide => "" } , 
		{ type => "small_or_big" , title => "程度問題" , guide => "" } , 
		{ type => "invalid_report" , title => "レポート中の違反" , guide => "" } 
	] , 
},

{
	type => "etc" , 
	title => "その他" , 
	group => [
		{ type => "cant_line_check" , title => "本人確認不可" , guide => "本人確認が出来ませんでした。" } , 
		{ type => "too_many_select_target" , title => "大量指定" , guide => "あまりに大量の報告をいちどに送ったり、違反が含まれていないものまで一度に報告しないでください。よく確認の上、違反度の高いものからご報告ください。" } , 
		{ type => "rooping" , title => "繰り返しの報告" , guide => "同じ報告を何度も繰り返さないでください。" } , 
	] , 
},

);

\@line;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub original_text_highlight{

my $self = shift;
my $original_text = shift;
my $report_text = shift;
my(@for_highlight);
my $query = new Mebius::Query;
my $param  = $query->param();

my $highlighted_text = $original_text;

	foreach my $text (split /\[br\]+/ ,$report_text){
			if($text =~ /^(>|&gt;|＞)+(.+)/){
				push @for_highlight , $2;
			}
	}

	if(@for_highlight){

			my $search = "(" . (join "|" , @for_highlight) . ")";

			if(!$param->{'not_highlight'} && $highlighted_text =~ s!$search!<strong class="hit">$1</strong>!mg){
				1;
			}

	}

$highlighted_text;

}



1;
