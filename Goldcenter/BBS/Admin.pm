
use strict;
package Mebius::Admin;
use Mebius::BBS::Admin::Parts;
use Mebius::Export;
use Mebius::Fillter;

#-----------------------------------------------------------
# 複数の掲示板スレッドを操作するためのハッシュを、クエリを元に作成
#-----------------------------------------------------------
sub bbs_thread_control_multi_from_query{

my($q) = Mebius::query_state();
my(%control);
my($now_date) = Mebius::now_date();
my($admy) = Mebius::my_admin();
my $time = time;
my($table_name) = Mebius::Report::main_table_name();
my $bbs_thread = new Mebius::BBS::Thread;

	# 管理者以外は操作できないように
	if(!Mebius::Admin::admin_mode_judge()){
		main::error("Yor're not Administrator!");
	}

	# クエリを全て展開
	foreach ($q->param()){

		my($bbs_kind,$thread_number,$res_number);

			# ●スレッドの操作
			if($_ =~ /^thread_control_([0-9a-zA-Z]+)-(\d+)$/ && $q->param($_) ne ""){

				$bbs_kind = $1;
				$thread_number = $2;

				my %usefull = ( bbs_kind => $bbs_kind , thread_number => $thread_number );
				my($change_status_type);

					# 予約削除
					if($q->param($_) eq "delete"){
						$change_status_type = "Delete";
						$bbs_thread->delete_on_status(\%usefull);

					# すぐ削除
					} elsif($q->param($_) eq "delete_soon") {
						$change_status_type = "DeleteSoon";
						$bbs_thread->delete_on_status(\%usefull);
					# ロック実行
					}	elsif($q->param($_) eq "lock"){
						$change_status_type = "Lock";
					}

					# ロック解除
					elsif($q->param($_) eq "unlock"){
						$change_status_type = "Unlock";
					}

					# ピン止め
					elsif($q->param($_) eq "pin"){
						$change_status_type = "Pin";
					}

					# 記事復活
					elsif($q->param($_) eq "revive"){
						$change_status_type = "Revive";
						$bbs_thread->revive_on_status(\%usefull);
					}

					# 警告
					elsif($q->param($_) eq "alert"){
						$change_status_type = "Alert";
					}

					# 対応しない
					elsif($q->param($_) eq "no-reaction"){
						$change_status_type = "";
					}

					# 必要な代入
					if(defined $change_status_type){
						$control{$bbs_kind}{$thread_number}{'change_status_type'} = $change_status_type;
						$control{$bbs_kind}{$thread_number}{'report_control_flag'} = 1;
					}


					# 削除 / ロック理由
					if($q->param("thread_control_reason_$bbs_kind-$thread_number") =~ /^(\d+)$/){

						my $new_reason = $control{$bbs_kind}{$thread_number}{'reason'} = $q->param("thread_control_reason_$bbs_kind-$thread_number");

						# 削除データの書き換え用
						$control{$bbs_kind}{$thread_number}{'select_renew'}{'delete_data'} = "$admy->{'name'}=$now_date=$time=$new_reason";

					}

					# ロック期間
					if($q->param("thread_control_lock_end_time_$bbs_kind-$thread_number") =~ /^(\d+)$/){
						$control{$bbs_kind}{$thread_number}{'select_renew'}{'lock_end_time'} =  $q->param("thread_control_lock_end_time_$bbs_kind-$thread_number");
					}

			# ●レス本文の操作
			}	elsif ($_ =~ /^comment_control_([0-9a-zA-Z]+)-(\d+)-(\d+)$/ && $q->param($_) ne ""){

				$bbs_kind = $1;
				$thread_number = $2;
				$res_number = $3;

				# クエリから各要素を分割
				my($control_type,$control_reason) = split(/_/,$q->param($_));

				# 各スレッドを更新するためのハッシュ設定 ( ループ処理終了後に実行する )
				$control{$bbs_kind}{$thread_number}{$res_number}{'comment'} = { type => $control_type , reason => $control_reason };

					# 削除の場合、違反報告ファイルを対応済みにするためのフラグを立てる
					if($control_type =~ /^(delete|penalty|no-reaction)$/){
						$control{$bbs_kind}{$thread_number}{$res_number}{'comment'}{'report_control_flag'} = 1;
					}

					# ペナルティを付ける場合
					if($control_type =~ /^(penalty)$/){
						$control{$bbs_kind}{$thread_number}{$res_number}{'penalty_flag'} = 1;
					}


			# ●レス筆名の操作
			} elsif ($_ =~ /^handle_control_(\w+)-(\d+)-(\d+)$/ && $q->param($_) ne ""){

				$bbs_kind = $1;
				$thread_number = $2;
				$res_number = $3;

					# クエリが正常な場合
					if($q->param($_) =~ /^(delete|revive)$/){

						# クエリから各要素を分割
						my($control_type) = $1;

						# 各スレッドを更新するためのハッシュ設定 ( ループ処理終了後に実行する )
						$control{$bbs_kind}{$thread_number}{$res_number}{'handle'} = { type => $control_type  };

							# 削除の場合、違反報告ファイルを対応済みにするためのフラグを立てる
							if($control_type eq "delete"){
								$control{$bbs_kind}{$thread_number}{$res_number}{'comment'}{'report_control_flag'} = 1;
							}

					} else {
						0;
					}
			}

			# レポートの更新
			if($bbs_kind && $thread_number && $res_number){
				Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$bbs_kind' AND targetB='$thread_number' AND report_res_number='$res_number' AND content_type='bbs_thread';");
			} elsif($bbs_kind && $thread_number){
				Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$bbs_kind' AND targetB='$thread_number' AND report_type_res_or_thread='Thread' AND content_type='bbs_thread';");
			}

	}


# 各スレッド・インデックスなどを更新
my($multi_control) = bbs_thread_control_multi(\%control);

$multi_control;

}

#-----------------------------------------------------------
# 複数の掲示板スレッドを一斉に操作
#-----------------------------------------------------------
sub bbs_thread_control_multi{

my($control) = @_;
my($i_thread,%self);
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_newlist.pl";

	# 何も操作対象がない場合はリターン
	if(!defined $control){ return(); }

	# ●すべての掲示板を展開
	foreach my $bbs_kind (keys %$control ){
		
		my(%index_line_control);
		my $bbs_hash = $control->{$bbs_kind};

			# ●すべてのスレッドを展開
			foreach my $thread_number (keys %{$bbs_hash}){

				my $thread_control = $bbs_hash->{$thread_number};
				$i_thread++;

					# あまりに大量のスレッドはいちどに処理しない（予防処理）
					if($i_thread >= 100){
						next;
					}

				# スレッドを更新
				my($controled_thread) = Mebius::Admin::thread_control_core({ select_renew => $thread_control->{'select_renew'} , control => $thread_control , MyDeletedMessage => "削除済み" , MyHandle => "テスト管理者" , UTF8 => 1 },$bbs_kind,$thread_number);

				# 最終レスを削除した場合
				if($controled_thread->{'last_res_handle_delete_flag'}){
					my($main_thread) = Mebius::BBS::thread_state($thread_number,$bbs_kind);
						#if($main_thread->{'key'} eq "3"){ $file = $pastfile; } else { $file = $nowfile; }
						$index_line_control{$thread_number}{'last_handle'} = "削除";
						shift_jis($index_line_control{$thread_number}{'last_handle'});
				}

					# エラーの場合
					if($controled_thread->{'error'}){
						next;
					}

					# インデックス更新用にハッシュを調整する
					if($controled_thread->{'renew_index_flag'}){
						$index_line_control{$thread_number}{'key'} = $controled_thread->{'new_key_index'};
						$index_line_control{$thread_number}{'type'} = $thread_control->{'change_status_type'};
					}


					# 元が過去ログだった場合は、新過去ログメニューから復活する
					if($controled_thread->{'bepast_time'} && $thread_control->{'change_status_type'} =~ /^(Revive)$/){
						my($thread) = Mebius::BBS::thread_state($thread_number,$bbs_kind);
						my($bepast_time) = Mebius::get_date($controled_thread->{'bepast_time'});
						Mebius::BBS::PastIndexMulti("Repair-thread Renew",$bbs_kind,$bepast_time->{'yearf'},$bepast_time->{'monthf'},$thread);
					}

					# ▼スレッドを削除した場合
					if($thread_control->{'change_status_type'} =~ /^(Delete|DeleteSoon)$/){

							# 過去ログインデックスからの削除
							if($controled_thread->{'bepast_time'}){ # $controled_thread->{'before_renew'}->{'key'} eq "3" ||
								my($bepast_time) = Mebius::get_date($controled_thread->{'bepast_time'});
								my($thread) = Mebius::BBS::thread_state($thread_number,$bbs_kind);
								Mebius::BBS::PastIndexMulti("Delete-thread Renew",$bbs_kind,$bepast_time->{'yearf'},$bepast_time->{'monthf'},$thread);
							}

						# サイト全体の新着スレッド一覧を更新
						Mebius::Newlist::threadres("UNLINK THREAD","$bbs_kind-$thread_number-0");
						Mebius::Newlist::threadres("UNLINK RES UNLINK-ALL","$bbs_kind-$thread_number");
						Mebius::Newlist::threadres("UNLINK RES UNLINK-ALL Buffer","$bbs_kind-$thread_number");
						Mebius::Newlist::threadres("UNLINK ECHECK UNLINK-ALL","$bbs_kind-$thread_number");

							# 複数の「タグ単体ファイル」から、この記事の登録を一斉削除する
							# $in{'place'} を書き換えなくても動作するように
							if(-f "${init_directory}_thread_tag/_${bbs_kind}_tag/${thread_number}_tag.cgi"){
								#$in{'place'} = "thread"; # SSS
								require "${init_directory}main_tag.pl";
								open_threadtag("vanish RENEW","","",$bbs_kind,$thread_number);
							}
					}

					# このサブルーチン全体のハッシュを設定
					$self{'last_control_thread'} = $controled_thread;

					# ▼レスを削除した場合、サイト全体の新着レス一覧を更新
					{
						my(@unlinks_allres);
							foreach(@{$controled_thread->{'controled_res_numbers'}}){ push(@unlinks_allres,"$bbs_kind-$thread_number-$_"); }

							# 新着リストからデータを削除
							if($controled_thread->{'successed_flag'} && @unlinks_allres >= 1){
								Mebius::Newlist::threadres("UNLINK RES",@unlinks_allres);
								Mebius::Newlist::threadres("UNLINK RES Buffer",@unlinks_allres);
								Mebius::Newlist::threadres("UNLINK ECHECK",@unlinks_allres);
							}
					}


			}# -----スレッド処理終わり

			# ▼現行インデックスを更新
			if(%index_line_control){
				main::lock($bbs_kind); # ロック開始
				Mebius::BBS::index_file({ Renew => 1 , line_control => \%index_line_control },$bbs_kind); # 更新
				main::unlock($bbs_kind); # ロック解除
			}

	}


	# 管理記録ファイルを更新
	#if($thread_controled->{'successed_flag'}){
	#	&renew_myhistory("1","");
	#}

\%self;

}


#-----------------------------------------------------------
# スレッド操作 ( コア )
#-----------------------------------------------------------
sub thread_control_core{

# 宣言
my($use,$moto,$thread_number) = @_;
my($now_date) = Mebius::now_date_multi();
my($server_domain) = Mebius::server_domain();
my($basic_init) = Mebius::basic_init();
my($date) = Mebius::now_date();
my($init_directory) = Mebius::BaseInitDirectory();
my($my_admin) = Mebius::my_admin();
require "${init_directory}part_history.pl";
my($FILE1,@new,%trip_history_delete,%trip_history_delete_handle,%trip_history_repair,%trip_history_repair_handle,%account_history_repair_handle,%history_delete);
my(%encid_history_delete,%encid_history_delete_handle,%encid_history_repair,%encid_history_repair_handle,%account_history_delete_handle,%account_history_delete);
my(%handle_ranking_delete,$echeck_file,$file,@resnumbers,$renew,%self,%self_renew,$my_deleted_message);

	# 汚染チェック
	if($thread_number =~ /(\D)/ || $thread_number eq ""){ warn("Perl Warn! Thread number value '$1' is very strange."); return(); }
	if($moto =~ /([^0-9a-zA-Z])/ || $moto eq ""){ warn("Perl Warn! BBS moto value '$2' is very strange."); return(); }

# 削除用のデータを定義する
my $my_handle_shift_jis = $my_admin->{'name'};
my($my_handle) = utf8_return( $my_admin->{'name'});

	if($my_admin->{'deleted_text'}){
		$my_deleted_message = $my_admin->{'deleted_text'};
		utf8($my_deleted_message);
	} else {
		$my_deleted_message = "この投稿は削除されました";
	}

$self{'number'} = $thread_number;
	#if($use->{'UTF8'}){ shift_jis($my_handle_shift_jis); }

# RealMoto を定義
my($realmoto) = Mebius::BBS::real_bbs_kind($moto);

# ファイル名を取得 ( 汚染チェックが終わったこの位置で処理すること )
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto,$thread_number);

	# ファイル定義
	if($bbs_file->{'thread_file'}){ $file = $bbs_file->{'thread_file'}; }
	else{ die("Perl Die! Log directory name is empty."); }

# スレッドを読み込み
my($FILE1,$read_write) = Mebius::File::read_write({ Renew => 1 },$file);
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { main::error("記事 $moto - $thread_number が開けません"); }

# トップデータを分解
# トップデータを読み込み
my %data_format = Mebius::BBS::thread_top_data_format();
my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
%self = (%self,%$split_data);

	# スレッドを展開
	while (<$FILE1>) {

		# 本ループ内での局所化
		my($comment_control_type,$reason_text,$handle_control_type,$target_type,$resdelete_flag,$vanish_comment_flag,$plustype_penalty,$plus_penalty,$penalty_flag);

		# この行を分解
		chomp;
		my($res_number2,$number,$handle2,$trip2,$com,$date2,$reshost,$encid2,$d_h,$resagent,$d_j,$deleted_comment,$account,$image_data,$res_concept2,$regist_time2) = split(/<>/);

			# ペナルティの増加
			if($res_concept2 =~ /Alert-break/){ $plus_penalty = 3; }

		# IDを分解
		my($devce_encid2,$pure_encid2,$option_encid2) = Mebius::SplitEncid(undef,$encid2);

		# 日付を分解
		my(%date) = Mebius::SplitMebiDate(undef,$date2) if($date2);

		# 旧式データの整形
		$deleted_comment =~ s/<Re>//g;
			if($deleted_comment && $res_concept2 !~ /Deleted-comment/){ $res_concept2 .= qq( Deleted-comment); }


			# 本文の操作 ( 実行タイプ )
			if($res_number2 eq "0"){ 0; } # >>0 の書き込みは通常、操作しない
			elsif($use->{'control'}->{$res_number2}->{'comment'}->{'type'} eq "delete"){ $comment_control_type = "delete"; }
			elsif($use->{'control'}->{$res_number2}->{'comment'}->{'type'} eq "penalty"){ $comment_control_type = "delete"; $penalty_flag = 1; }
			elsif($use->{'control'}->{$res_number2}->{'comment'}->{'type'} eq "revive"){ $comment_control_type = "revive"; }

			my($kind_list_for_res) = Mebius::Reason::kind_list_for_res();

			# 削除理由
			$reason_text = $kind_list_for_res->{$use->{'control'}->{$res_number2}->{'comment'}->{'reason'}}->{'detail'};

			if($use->{'control'}->{$res_number2}->{'comment'}->{'reason'} eq "vanish"){ $vanish_comment_flag = 1; }

			# 筆名の操作
			if($use->{'control'}->{$res_number2}->{'handle'}->{'type'} eq "delete"){ $handle_control_type = "delete"; }
			elsif($use->{'control'}->{$res_number2}->{'handle'}->{'type'} eq "revive"){ $handle_control_type = "revive"; }

		# 削除理由の文章を整形
		my $reason_text_pure = $reason_text;
			if($reason_text){ $reason_text = qq(　削除理由： $reason_text); }

			# 操作したナンバーを記憶する
			if($comment_control_type || $handle_control_type || $reason_text){ push(@{$self{'controled_res_numbers'}},$res_number2); }

			# ●筆名を削除する
			if($handle_control_type eq "delete" && $res_concept2 !~ /Deleted-handle/){
				$res_concept2 .= qq( Deleted-handle);
				$self{'successed_flag'} = 1;

					# 掲示板毎のランキングから削除
					if(!$handle_ranking_delete{"$handle2-$trip2"}){
						Mebius::BBS::Handle("Delete-handle Renew File-check-return",$handle2,$trip2,$date{'year'},$date{'month'},$moto);
						$handle_ranking_delete{"$handle2-$trip2"} = 1;
					}

					# トリップの投稿履歴から【筆名】を削除
					if($trip2 && $res_concept2 =~ /Tripory/ && !$trip_history_delete_handle{$trip2}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("TRIP Delete-handle RENEW File-check-return",$trip2,undef,$realmoto,$thread_number);
						$trip_history_delete_handle{$trip2} = "done";
					}

					# IDの投稿履歴から【筆名】を削除
					if($pure_encid2 && $res_concept2 =~ /Idory5/ && !$encid_history_delete_handle{$pure_encid2}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("ENCID Delete-handle RENEW File-check-return",$pure_encid2,undef,$realmoto,$thread_number);
						$encid_history_delete_handle{$pure_encid2} = "done";
					}

					# アカウントの”公開”投稿履歴から【筆名】を削除
					if($account && Mebius::BBS::view_account_history_judge($res_concept2) && !$account_history_delete_handle{$account}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("Open-account Delete-handle RENEW File-check-return",$account,undef,$realmoto,$thread_number);
						$account_history_delete_handle{$account} = "done";
					}

					# 最終レスを削除した場合
					if($res_number2 == $self{'res'}){ $self{'last_res_handle_delete_flag'} = 1; }

			}

			# ●筆名を復活する
			elsif($handle_control_type eq "revive" && $res_concept2 =~ /Deleted-handle/){
				$res_concept2 =~ s/ Deleted-handle(-<.+>)?//g;
				$self{'successed_flag'} = 1;

					# トリップの投稿履歴から【筆名】を復活
					if($trip2 && $res_concept2 =~ /Tripory/ && !$trip_history_repair_handle{$trip2}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("TRIP Repair-handle RENEW File-check-return",$trip2,undef,$realmoto,$thread_number);
						$trip_history_repair_handle{$trip2} = "done";
					}

					# IDの投稿履歴から【筆名】を復活
					if($pure_encid2 && $res_concept2 =~ /Idory5/ && !$encid_history_repair_handle{$pure_encid2}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("ENCID Repair-handle RENEW File-check-return",$pure_encid2,undef,$realmoto,$thread_number);
						$encid_history_repair_handle{$pure_encid2} = "done";
					}

					# IDの投稿履歴から【筆名】を復活
					if($account && Mebius::BBS::view_account_history_judge($res_concept2) && !$account_history_repair_handle{$account}){
						require "${init_directory}part_history.pl";
						main::get_reshistory("Open-account Repair-handle RENEW File-check-return",$account,undef,$realmoto,$thread_number);
						$encid_history_repair_handle{$account} = "done";
					}


			}

			# ● スレッドを削除した場合
			if($use->{'control'}->{'change_status_type'} =~ /^(Delete)(Soon)?$/){

					# トリップの投稿履歴を削除 ( このループの $_ が書き換えられるので注意)
					if($trip2 && $res_concept2 =~ /Tripory/ && !$history_delete{'trip'}{$trip2}){
						main::get_reshistory("TRIP Delete-thread RENEW File-check-return",$trip2,undef,$realmoto,$thread_number);
						$history_delete{'trip'}{$trip2} = "done";
					}

					# IDの投稿履歴を削除 ( このループの $_ が書き換えられるので注意)
					if($pure_encid2 && $res_concept2 =~ /Idory5/ && !$history_delete{'id'}{$pure_encid2}){
						main::get_reshistory("ENCID Delete-thread RENEW File-check-return",$pure_encid2,undef,$realmoto,$thread_number);
						$history_delete{'id'}{$pure_encid2} = "done";
					}

					# アカウントの投稿履歴を削除 ( このループの $_ が書き換えられるので注意)
					if($account && Mebius::BBS::view_account_history_judge($res_concept2) && !$history_delete{'account'}{$account}){
						main::get_reshistory("Open-account Delete-thread RENEW File-check-return",$account,undef,$realmoto,$thread_number);
						$history_delete{'account'}{$account} = "done";
					}
			}

			# ●削除済みの本文に、削除理由を追加する
			#if($reason_text && $res_concept2 =~ /Deleted-comment/){
			#	$com =~ s/削除理由：(.+)//g;
			#	$com .= qq($reason_text ( 追記 $my_handle ) );
			#	$self{'successed_flag'} = 1;
			#}

			# ●レスを完全消去する ( VANISH )
			if($vanish_comment_flag && $res_concept2 !~ /Vanished/){
				$res_concept2 .= qq( Vanished);
				$self{'successed_flag'} = 1;

					# 最終レスを削除した場合
					if($res_number2 == $self{'res'}){ $self{'last_res_handle_delete_flag'} = 1; }

			}

			# ●本文を削除する
			if($comment_control_type eq "delete"){

					# ペナルティを課す
					if($penalty_flag && $res_concept2 !~ / Deleted-comment/){

						$plustype_penalty .= qq( Penalty);

						# レスコンセプトを変更
						$res_concept2 .= qq( Penalty-done);

						# ペナルティを与える
						Mebius::add_penalty_all("Renew New-delete UTF8 $plustype_penalty",$reshost,$number,$resagent,$account,$self{'sub'},$com,"/_$moto/$thread_number.html#S$res_number2",$plus_penalty,$reason_text_pure);

					}


					# 削除した内容をEcheckファイルに記録する
					if($penalty_flag){ $echeck_file = "delete-penalty"; }
					else{ $echeck_file = "delete"; }

				Mebius::Echeck::Datafile("Renew FromBBS","",$echeck_file,$com,"$handle2","$basic_init->{'admin_url'}$moto.cgi?mode=view&no=$thread_number#S$res_number2");
				Mebius::Echeck::Datafile("Renew FromBBS",$now_date->{'todayf'},$echeck_file,$com,"$handle2","$basic_init->{'admin_url'}$moto.cgi?mode=view&no=$thread_number#S$res_number2");

					# 削除文を定義
					my $deleted_text = qq(【$my_deleted_message】 削除者： $my_handle ( $date ) $reason_text);
					shift_jis($deleted_text);

					# 削除文と本文を入れ替え(既に削除済みでなければ)
					if($res_concept2 !~ /Deleted-comment/){
						($com,$deleted_comment) = ($deleted_text,$com);
						$self{'successed_flag'} = 1;
					}


					# 画像を削除(移動)する
					if($image_data){
						Mebius::Paint::Image("Delete-image Justy Renew-logfile-justy",undef,undef,$server_domain,$realmoto,$thread_number,$res_number2);
					}

					# トリップの投稿履歴を削除する
					if($trip2 && $res_concept2 =~ /Tripory/){

						main::get_reshistory("TRIP Delete-res RENEW File-check-return",$trip2,undef,$realmoto,$thread_number,$res_number2);
						$trip_history_delete{$trip2} = "done";
					}

					# IDの投稿履歴を削除する
					if($pure_encid2 && $res_concept2 =~ /Idory5/){
						main::get_reshistory("ENCID Delete-res RENEW File-check-return",$pure_encid2,undef,$realmoto,$thread_number,$res_number2);
						$encid_history_delete{$pure_encid2} = "done";
					}

					# アカンントの”公開”投稿履歴を削除する
					if($account && Mebius::BBS::view_account_history_judge($res_concept2)){
						main::get_reshistory("Open-account Delete-res RENEW File-check-return",$account,undef,$realmoto,$thread_number,$res_number2);
						$account_history_delete{$account} = "done";
					}

				# レスコンセプトを変更する
				$res_concept2 =~ s/ Revived-comment-(<(.+)>)?//g;
				$res_concept2 =~ s/ Deleted-comment//g;
				$res_concept2 .= qq( Deleted-comment);

					# 最終レスを削除した場合
					if($res_number2 == $self{'res'}){ $self{'last_res_handle_delete_flag'} = 1; }

			}

			# ●レスを復活させる
			elsif($comment_control_type eq "revive" && $res_concept2 =~ /(Deleted-comment|Vanished)/) {

					# ペナルティを解消する（以前にペナルティをつけた削除のみ）
					if($res_concept2 =~ /Penalty-done/){
						my($kdel_access) = main::check_kaccess($reshost,$resagent,undef,undef,undef,$plus_penalty);
							if($number){ Mebius::penalty_file("Cnumber Repair Renew",$number,undef,undef,undef,$plus_penalty); }
							if($reshost){ Mebius::penalty_file("Host Repair Renew",$reshost,undef,undef,undef,$plus_penalty); }
							if($kdel_access || ($resagent && !$number) ){ Mebius::penalty_file("Agent Repair Renew",$resagent,undef,undef,undef,$plus_penalty); }
							if($account){ Mebius::penalty_file("Account Repair Renew",$account,undef,undef,undef,$plus_penalty); }
					}

					# 値の更新を定義（Ｂ）
					if($res_concept2 =~ /Deleted-comment/){
						($com,$deleted_comment) = ($deleted_comment,undef);
					}

				# 成功フラグを立てる
				$self{'successed_flag'} = 1;

					# 画像を復活(移動)する
					if($image_data){
						Mebius::Paint::Image("Revive-image Justy Renew-logfile-justy",undef,undef,$server_domain,$moto,$thread_number,$res_number2);
					}

				# レスコンセプトを変更する
				$res_concept2 =~ s/ Deleted-comment//g;
				$res_concept2 =~ s/ Penalty-done//g;
				$res_concept2 =~ s/ Vanished//g;
				$res_concept2 .= qq( Revived-comment-<$my_handle_shift_jis>);

					# トリップの投稿履歴を復活する
					if($trip2 && $res_concept2 =~ /Tripory/){
						main::get_reshistory("TRIP Repair-res RENEW File-check-return",$trip2,undef,$realmoto,$thread_number,$res_number2);
						$trip_history_repair{$trip2} = "done";
					}

					# IDの投稿履歴を復活する
					if($pure_encid2 && $res_concept2 =~ /Idory5/){
						main::get_reshistory("ENCID Repair-res RENEW File-check-return",$pure_encid2,undef,$realmoto,$thread_number,$res_number2);
						$encid_history_repair{$pure_encid2} = "done";
					}
			}

			# 最終筆名
			if($res_concept2 !~ /Deleted/){
				$self_renew{'lasthandle'} = $handle2;
					if($regist_time2){ $self_renew{'lastrestime'} = $regist_time2; }
			}

		# ●データ行を追加する
		push(@new,"$res_number2<>$number<>$handle2<>$trip2<>$com<>$date2<>$reshost<>$encid2<>$d_h<>$resagent<>$d_j<>$deleted_comment<>$account<>$image_data<>$res_concept2<>$regist_time2<>\n");

	# ファイル展開終了
	}

	# ▼トップデータを変更する場合 ( 変更可能かどうかも判定 )
	my($self_renew_status);
	if(exists $use->{'control'}->{'change_status_type'}){

			my($error,$self_plus,$self_renew) = change_thread_status_error({ control_reason => $use->{'control'}->{'reason'} , change_status_type => $use->{'control'}->{'change_status_type'} },$use->{'new_key'},\%self);
			$self_renew_status = $self_renew;

			if(@$error){
				push(@{$self{'error'}},@$error);
			} else {
				$self{'successed_flag'} = 1;
				%self = (%self,%$self_plus);
			}
	}

	# 変更する行がある場合、スレッドを更新
	if($self{'successed_flag'}){

		# 任意の更新とリファレンス化
		($renew) = Mebius::Hash::control(\%self,$use->{'select_renew'},\%self_renew,$self_renew_status);

		# データフォーマットからファイル更新
		Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew,\@new);

	}

# ファイルを閉じる
close($FILE1);

	# パーミッション変更
	if($self{'successed_flag'}){
		Mebius::Chmod(undef,$file);
	}
	# リターン
	if(ref $renew eq "HASH"){
		return $renew;
	} else {
		return \%self;
	}

}

#-----------------------------------------------------------
# スレッドの状態を変更するための判定
#-----------------------------------------------------------
sub change_thread_status_error{

my $use = shift if(ref $_[0] eq "HASH");
my $new_key = shift;
my $thread = shift;
my(@error,%self,%renew);
my($admy) = Mebius::my_admin();

	# ●予約削除
	if($use->{'change_status_type'} eq "Delete"){

			# キーチェック＆エラー処理
			if($thread->{'key'} == 7 || $thread->{'key'} == 6 || $thread->{'key'} == 4 || $thread->{'key'} eq ""){
				push(@error,"記事が存在しないか、既に削除済みです");
			} else{
				# キーを変更
				$renew{'key'} = 7;
				# 削除予定時刻を決定
				$renew{'delete_reserve_time'} = time + 7*24*60*60;
				$self{'renew_index_flag'} = 1;
			}
	}

	# ●すぐに削除
	elsif($use->{'change_status_type'} eq "DeleteSoon"){

			# キーチェック＆エラー処理
			if($thread->{'key'} == 6 || $thread->{'key'} == 4 || $thread->{'key'} eq ""){
				push(@error,"記事が存在しないか、既に削除済みです");
			}	else {
				$renew{'key'} = 4;
				$self{'renew_index_flag'} = 1;
			}
	}

	# ●ロック実行
	elsif($use->{'change_status_type'} eq "Lock"){

		my $new_delreason;

			# ピン止め記事もロックできるように
			if($thread->{'key'} eq "2"){
			}
			else{
				$self{'renew_index_flag'} = 1;
			}

			if($thread->{'key'} ne "0" && $thread->{'key'} ne "1" && $thread->{'key'} ne "5" && $thread->{'key'} ne "2") {
				push(@error,"この状態の記事は、ロック開閉できません");
			} else {
			
				$self{'new_key_index'} = 0;
				$renew{'key'} = 0;
				$self{'renew_index_flag'} = 1;

					# ロック理由
					{
						my($delman,$delday,$deltime,$delreason) = split(/=/,$thread->{'delete_data'});
							if($delreason ne "" && $use->{'control_reason'} eq ""){ $new_delreason = $delreason; }
							else{ $new_delreason = $use->{'control_reason'}; }
						$new_delreason =~ s/\D//g;
					}
					if($new_delreason eq ""){ push(@error,"ロック理由を選択してください。"); }

			}

	}

	# ●ロック解除
	elsif($use->{'change_status_type'} eq "Unlock"){
			if($thread->{'keylevel'} >= 1) {
				push(@error,"この状態の記事は、ロック解除できません");
			}	else {
				$renew{'key'} = 1;
				$self{'new_key_index'} = 1;
				$self{'renew_index_flag'} = 1;
			}
	}

	# ●ピン止め
	elsif($use->{'change_status_type'} eq "Pin"){
			# キーチェック、エラー処理
			if ($thread->{'key'} ne "1" && $thread->{'key'} ne "2") {
				push(@error,"設定変更できません");
			}	else {
					# キー変更処理
					if ($thread->{'key'} eq "1") {
						$renew{'key'} =  2;
						$self{'new_key_index'} = 2;
					} elsif($thread->{'key'} eq "2") {
						$renew{'key'} = 1;
						$self{'new_key_index'} = 1;
					}
				$self{'renew_index_flag'} = 1;
			}
	}

	# ●記事復活
	elsif($use->{'change_status_type'} eq "Revive"){
			if($thread->{'key'} ne "4" && $thread->{'key'} ne "6" && $thread->{'key'} ne "7"){ push(@error,"削除された記事ではありません"); }
			elsif($admy->{'rank'} < 20) { push(@error,"復活権限がありません"); }
			else{
				$renew{'key'} = 1;
				$self{'new_key_index'} = 1;
				$self{'renew_index_flag'} = 1;
			}
	}

	# ●優良設定
	elsif($use->{'change_status_type'} eq "Good"){
			if($thread->{'key'} ne "1" && $thread->{'key'} ne "5") { push(@error,"この状態の記事は、優良設定できません"); }
			elsif($admy->{'rank'} < 5) { push(@error,"設定権限がありません"); }
			else{
					if($thread->{'key'} != 5) { $renew{'key'} = 5; } else { $renew{'key'} = 1; }
				$self{'renew_index_flag'} = 1;
				$self{'new_key_index'} = $renew{'key'};
			}
	}

	# ●警告
	elsif($use->{'change_status_type'} eq "Alert"){
			if($thread->{'key'} ne "1" && $thread->{'key'} ne "5") {
				push(@error,"この状態の記事は、警告設定できません");
			} else {
				$renew{'s/g'}{'concept'} = $renew{'.'}{'concept'} = " Alert-violation";
			}
	}

\@error,\%self,\%renew;

}


#-----------------------------------------------------------
# スレッド操作フォーム
#-----------------------------------------------------------
sub bbs_thread_admin_console{

# 局所化
my($use,$bbs_kind,$thread_number,$use_thread) = @_;
my($param) = Mebius::query_single_param();
my($q) = Mebius::query_state();
my($thread) = Mebius::BBS::thread_state($thread_number,$bbs_kind);
my($server_domain) = Mebius::server_domain();
my($init_directory) = Mebius::BaseInitDirectory();
my($bbs) = Mebius::BBS::init_bbs_parmanent($bbs_kind);
my($basic_init) = Mebius::basic_init();
my($init) = init_bbs_thread_view_admin();
my($back_url_param) = Mebius::back_url_param();
my($back_url_hidden) = Mebius::back_url_hidden();
my($back_url) = Mebius::back_url_auto();
my($parts) = Mebius::Parts::HTML();
my($console_line,$console_line2,$print,$juufuku_alert,$res_alert,$script,$admemo_line);
my($heavy_checked,$light_checked,$back_link,$lock_checked,$unlock_checked,$none_checked,$viosex_text,$souce_link,$date_alert,$delete_guard,$action_name);
my $bbs_path = Mebius::BBS::Path->new($use_thread);
my($init_directory) = Mebius::BaseInitDirectory();

require "${init_directory}part_sexvio.pl";
my $sexvio_text = main::sexvio_check($thread->{'sexvio'}); 

	# エスケープ
	if($bbs_kind eq "" || $thread_number eq ""){ return(); }

	# キーチェック、記事の状態を表示
	{
	
		my($line,$blank_date);
		my($handle,$date,$lasttime,$reason) = split(/=/,$thread->{'delete_data'});
			if($lasttime){
				($blank_date) = Mebius::second_to_howlong({ TopUnit => 1 },time-$lasttime);
					if($blank_date){ $blank_date = qq(( $blank_date前 )); }
			}
		utf8($handle);
		my $data = qq(｜$handle｜$date $blank_date｜$reason);

			if($thread->{'lock_flag'}) { $line = qq(【ロック中$data】\n); }
			elsif($thread->{'key'} == 2) { $line = qq(<span style="color:#90f;">【ピン止め記事$data 】</span>\n); }
			elsif($thread->{'key'} == 3) { $line = qq(<span style="color:#090;">【過去ログ】</span>\n); }
			elsif($thread->{'key'} == 4) { $line = qq(【完全削除済み$data 】\n); }
			elsif($thread->{'key'} == 5) { $line = qq(<span style="color:#00f;">【優良記事$data】</span>\n); }
			elsif($thread->{'key'} == 6) { $line = qq(【スペシャル削除済み$data 】\n); }
			elsif($thread->{'key'} == 7) {
					if($lasttime >= $thread->{'delete_reserve_time'}){ $line = qq(【予約削除→自動で完全削除済み$data 】\n); }
					else{ $line = qq(【削除予約中（あとで自動削除されます）$data 】\n); }
			}
			elsif($thread->{'alert_flag'}){ $line = qq(<span style="color:#090;">【警告$data】</span>); }

			if($line){
				$print .= qq(<div class="margin center"><strong style="color:#f00;font-size:90%;">$line);
				$print .= qq(</strong></div>);
			}
	}


$print .= qq(<div class="right">);

	# 
	#if($use->{'ViewReportMode'}){
		$action_name = qq(thread_control_).e($bbs_kind).qq(-).e($thread_number);
		my $id_name = e($bbs_kind).qq(-).e($thread_number);
	#} else {
	#	$action_name = qq(action);
	#}

	# ３ヶ月（９０日）以上前の記事は、警告
	{

		my($gyap_date) = Mebius::second_to_howlong({ TopUnit => 1 } , time - $thread->{'posttime'});

			if(time - $thread->{'posttime'} >= 90*24*60*60){
				$date_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！<span style="font-size:160%;">$gyap_date</span>以上前に作られた記事です！　この記事は原則、削除しないで下さい。</strong>);
				$delete_guard = 1;
			}
			# １ヶ月（６０日）以上前の記事も、警告
			elsif(time - $thread->{'posttime'} >= 30*24*60*60){
				$date_alert = qq(<br><strong style="color:#00f;background-color:lightblue;">★注意！<span style="font-size:160%;">$gyap_date</span>以上前に作られた記事です！　”削除するには惜しい”と思う場合は、記事をロックしてください。</strong>);
			}
	}

	# 性的、暴力的内容
	if($thread->{'viosex'} eq "3"){ $viosex_text = qq( <em style="color:#099;">★性/暴\</em> - ); }
	if($thread->{'viosex'} eq "2"){ $viosex_text = qq( <em style="color:#099;">★性</em> - ); }
	if($thread->{'viosex'} eq "1"){ $viosex_text = qq( <em style="color:#099;">★暴\</em> - ); }

# リンク
my $data_page_url = $bbs_path->thread_usefull_url_adjusted({ r => "data" } );
my $support_link = qq( [ <a href=").e("$data_page_url$back_url_param").qq(">記事データ</a> ] );

	# 戻りリンク
	if(!$use->{'ViewReportMode'}){
			if($back_url->{'justy_flag'}){ $back_link =  qq(<a href=").e($q->param('backurl')).qq(" style="color:#090;">戻</a>　); }
	}

	# ソースリンク
	if(!$use->{'ViewReportMode'}){
			if($main::admy{'master_flag'}) {
				$souce_link = qq(	[
				<a href="$script?mode=view&amp;sview=1&amp;no=).e($thread_number).qq(">ソ\ース</a>
				<a href="$basic_init->{'main_admin_url'}?mode=allregistcheck&amp;type=thread&amp;file=).e($thread_number).qq(&amp;select=).e($bbs_kind).qq(">Echeck</a>
				]	);
			}
	}

my($No_form);
	#if(!$use->{'ViewReportMode'}){
	#	($No_form) = main::No_form();
	#}

# 文字コードの調整
my($subject,$bbs_title) = utf8_return($thread->{'sub'},$bbs->{'title'});
my($thread_admin_url) = Mebius::BBS::thread_url_admin($thread_number,$bbs_kind);
my $bbs_url = $bbs_path->bbs_url_adjusted({ MainThread => 1 });

# タイトル情報
my $sub_line = qq(\n
<!-- ▼記事タイトル -->
<div class="data2">
<span style="font-size:150%;">$back_link<a href=").e($thread_admin_url).qq($back_url_param" style="color:#F55;">$viosex_text$subject</a>（<a href="$bbs_url">$bbs_title</a> / <a href="/_$bbs_kind/rule.html">ルール</a>）</span><br>
元のＵＲＬ：<a href="http://$server_domain/_$bbs_kind/$thread_number.html">http://$server_domain/_$bbs_kind/$thread_number.html</a>
$souce_link
$support_link
</div>
<!-- ▲記事タイトル -->
);

#$No_form 

	# レス数、作成日時
	$sub_line .=  qq(<div class="data right"><strong style="color:#F00;font-size:150%;">【作成 $thread->{'date'} 】 【$thread->{'res'}レス】</strong></div>\n\n);


	# 初期チェック
	if($param->{'delete_checked'} eq "heavy"){ $heavy_checked = $parts->{'checked'}; }
	elsif($param->{'delete_checked'} eq "light"){ $light_checked = $parts->{'checked'}; }
	elsif($param->{'delete_checked'} eq "lock"){ $lock_checked = $parts->{'checked'}; }
	else{ $none_checked = $parts->{'checked'}; }

	# レス数アラート
	if($thread->{'res'} >= 200) {
		$res_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！　レスが<span style="font-size:160%;">$thread->{'res'}件</span>もあります。この記事は原則、削除しないで下さい。</strong>);
		$delete_guard = 1;
	}
	elsif($thread->{'res'} >= 50) { $res_alert = qq(<br><strong style="color:#00f;background-color:lightblue;">★注意！　レスが<span style="font-size:160%;">$thread->{'res'}件</span>あります。”削除するには惜しい”と思う場合は、記事をロックしてください。</strong>); }

# 制限理由を取得
my $select_reason = $thread->{'control_reason'};
	if($param->{'reason'} ne ""){ $select_reason = $param->{'reason'}; }
#require "${init_directory}part_delreason.pl";

#my $id = "thread_control_reason_$bbs_kind-$thread_number";
my($reason_selects) =	Mebius::Reason::radio_box_for_thread({ input_name => "thread_control_reason_$bbs_kind-$thread_number" , reason => $thread->{'control_reason'} , reported_reasons => $use->{'reported_reasons'} });

#my($reason_selects) .= qq(<select name="thread_control_reason_).e($bbs_kind).qq(-).e($thread_number).qq(">\n);
#my($reason_selects_core) = Mebius::Reason::get_select_reason("$select_reason");
#$reason_selects .= $reason_selects_core;
#$reason_selects .= qq(<option value="">なし(警告解除)</option>\n);
#($reason_selects) .= qq(\n</select>);


# ロック期間のセレクトボックス
my($lock_term_select) = Mebius::Reason::get_select_denyperiod(undef,$thread->{'lock_end_time'});
my $lock_term_select_box = qq(<span class="display-none" id="lock_term_select-$id_name">ロック期間：<select name="thread_control_lock_end_time_).e($bbs_kind).qq(-).e($thread_number).qq("><option value="">無期限$lock_term_select</select></span>);
	#if($thread->{'key'} eq "0"){ $lock_term_select_box = undef; }
my $reason_class;

	if($thread->{'key'} eq "1" && !$thread->{'alert_flag'}){ $reason_class .= qq(display-none); }


		$console_line .= qq(
		<label>
		<input type="radio" name="$action_name" value="" id="delete_thread_none" onclick="javascript:vnone('thread_control_reason-$id_name');vnone('lock_term_select-$id_name');"$none_checked>
		<strong>未選択</strong>
		</label>
		);

		$console_line .= qq(
		<label>
		<input type="radio" name="$action_name" value="no-reaction" id="delete_thread_no-reaction" onclick="javascript:vnone('thread_control_reason-$id_name');vnone('lock_term_select-$id_name');">
		<strong>対応しない</strong>
		</label>
		);


		$console_line .= qq(
		<label>
		<input type="radio" name="$action_name" value="delete" id="delete_thread_timer" onclick="javascript:vblock('thread_control_reason-$id_name');vnone('lock_term_select-$id_name');"$light_checked>
		<strong>予約削除</strong>
		</label>
		);

		$console_line .= qq(
		<label>
		<input type="radio" name="$action_name" value="delete_soon" id="delete_thread_soon" onclick="javascript:vblock('thread_control_reason-$id_name');vnone('lock_term_select-$id_name');"$heavy_checked><strong>
		すぐ削除</strong>
		</label>
	);

	#}

# ロック実行
$console_line .= qq(<label>);
$console_line .= qq(<input type="radio" name="$action_name" value="lock" id="lock_thread" onclick="javascript:vinline('lock_term_select-$id_name');vblock('thread_control_reason-$id_name');"$lock_checked>);
$console_line .= qq(<span>ロック実行</span>);
$console_line .= qq(</label>);

	# ロック解除
	if($thread->{'lock_flag'}){
		$console_line .= qq(<label for="unlock_thread" class="blue">);
		$console_line .= qq(<input type="radio" name="$action_name" value="unlock" id="unlock_thread" onclick="javascript:vnone('lock_term_select-$id_name','thread_control_reason-$id_name');"$unlock_checked>);
		$console_line .= qq(<span>ロック解除</span>);
		$console_line .= qq(</label>);
	}

# 警告
$console_line .= qq(<label>);
$console_line .= qq(<input type="radio" name="$action_name" value="alert" id="alert_thread" onclick="javascript:vblock('thread_control_reason-$id_name');vnone('lock_term_select-$id_name');">);
$console_line .= qq(<span>警告</span>);
$console_line .= qq(</label>);


	# ▼ ピン開閉ボックス
	{
		$console_line2 .= qq(
		<label>
		<input type="radio" name="$action_name" value="pin" id="pin_thread"><span>ピン開閉</span>
		</label>);
	}

	# ▼復活ボタン
	if($thread->{'deleted_flag'}){
		$console_line2 .= qq(<label style="color:#00f;">);
		$console_line2 .= qq(<input type="radio" name="$action_name" value="revive" id="revive_thread"><span>スレッド復活</span>);
		$console_line2 .= qq(</label>);
	} else{
		$console_line2 .= qq(<input type="radio" name="" disabled><strike style="color:#00f;">スレッド復活</strike>);
	}


	# 重複ＯＫの掲示板は、それを明記
	if($bbs->{'concept'} =~ /DOUBLE-OK/){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は、重複記事ＯＫの掲示板です。</strong>); }
	elsif($bbs->{'concept'} =~ /DOUBLE-GLAY/){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は、重複記事に厳しくない掲示板です。</strong>); }
	elsif($bbs->{'concept'} =~ /MODE-SOUDANN/){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は、個人的な相談に限り、重複ＯＫの掲示板です。</strong>); }
	elsif($bbs->{'concept'} =~ /MODE-CONCEPT/){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は、コンセプトが違えば、重複ＯＫの掲示板です。</strong>); }
	elsif($bbs->{'concept'} =~ /Sousaku-mode/ && $bbs->{'category'} eq "poemer"){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は創作系なので、重複記事の判断は慎重に。</strong>); }
	elsif($bbs->{'concept'} =~ /Sousaku-mode/ && $bbs->{'category'} eq "novel"){ $juufuku_alert = qq(<br><strong style="color:#f00;background-color:yellow;">★注意！ $bbs->{'title'}は創作系なので、重複記事の判断は慎重に。</strong>); }

my($submit_zero);
	if(!$use->{'ViewReportMode'}){
			if(Mebius::back_url_href()){
				$submit_zero .= qq(<input type="submit" name="console" value="スレッド操作→戻" class="console backurl">);
			} # $back_url_disabled
		$submit_zero .= qq(<input type="submit" name="console" value="スレッド操作" class="console white">);
	} else {
		$submit_zero .= qq(<input type="submit" name="console" value="Go" class="console white">);
	}

#<input type="hidden" name="pass" value="$pass2">

# 親記事操作エリア
$print .= utf8($sexvio_text);
$print .= qq($sub_line);
$print .= qq(<!-- ▼スレッド操作フォーム -->);


	if(!$use->{'ViewReportMode'}){

		$print .= qq(
		<form class="nomargin" action="$script" method="post" name="PostListFrm" style="font-size:90%;padding:0.3em;">
		<input type="hidden" name="mode" value="admin">
		<input type="hidden" name="moto" value=").e($bbs_kind).qq(">
		);

	}


$print .= qq(<input type="hidden" name="thread_control" value="1">);



	# 操作部分 ( 参照スレッドの場合は表示しない )
	if(!$use->{'NotViewConsole'}){
		$print .= qq(
		<span style="background:#5f5;padding:0.5em;">
		$console_line
		</span>
		<span style="background:#ddd;padding:0.5em;">
		$console_line2 
		</span>
		<div class="margin right">
		$lock_term_select_box
		<div id="thread_control_reason-$id_name" class="$reason_class">理由： $reason_selects</div>
		</div>
		);
	}

# 最終出力内容を定義
$print .= qq(
<div class="margin right">
$submit_zero
$back_url_hidden
$juufuku_alert
$date_alert
$res_alert
</div>

);

# ペナルティを与えるチェックボックス
#<span class="display-none" id="thread_penalty_check"><input type="checkbox" name="makewait_post" value="1" id="thread_penalty"><strong class="red"><label for="thread_penalty">ペナルティ</label></strong></span>


	if(!$use->{'ViewReportMode'}){

			if($thread->{'key'} == 3) { $print .= qq(<input type="hidden" name="past" value="1">); }
			else { $print .= qq(<input type="hidden" name="past" value="0">); }
		$print .= qq(</form>\n<!-- ▲スレッド操作フォーム -->\n\n);
	}

$print .= qq($admemo_line);

$print .= qq(</div>);

my($zero_line) = bbs_thread_view_zero_admin($thread);

$print .= $zero_line;

$print;

}


#-----------------------------------------------------------
# ゼロ記事
#-----------------------------------------------------------
sub bbs_thread_view_zero_admin{

my($tell_link);
my($use_thread) = @_;
my($my_admin) = Mebius::my_admin();
my($print);
my($q) = Mebius::query_state();

	# プロバイダ連絡用リンク
	if($my_admin->{'master_flag'} >= 100 && !$q->param('tell')){
		my $query = $ENV{'QUERY_STRING'};
		$query =~ s/&/&amp;/g;
		$tell_link = qq(
		<a href="?$query&amp;tell=1#DATA">P</a> / 
		<a href="?$query&amp;tell=1&amp;block=1#DATA">P-b</a> / 
		);
	}
	else{
		my $query = $ENV{'QUERY_STRING'};
		$query =~ s/&tell=1//g;
		$tell_link = qq(<a href="?$query">A</a> / );
	}

$print .= qq(\n<!-- ▼ゼロ記事 -->\n);

	# レス書き出し
	{
		my($res_core_view);
			if($q->param('for_provider') && $my_admin->{'master_flag'}){ ($res_core_view) = Mebius::BBS::Admin::res_core({},$use_thread,"0"); }
			else{ ($res_core_view) = Mebius::BBS::Admin::res_core({},$use_thread,"0"); }
		$print .= $res_core_view;
	}


	# サブ記事
	#if($subtopic_mode){ $print .= qq(<a href="$use_thread->{'bbs_kind'}.cgi?mode=view&amp;no=).e($use_thread->{'number'}).qq(">$main_thread->{'sub'}</a>のサブ記事です。); }
	#if($subtopic_mode && $my_admin->{'master_flag'}){ $print .= qq( [ <a href="sub$use_thread->{'bbs_kind'}.cgi?mode=view&amp;sview=1&amp;no=).e($use_thread->{'number'}).qq(">ソ\ース</a> ] ); }
	#if($subtopic_link && !$subtopic_mode){ $print .= qq(<br><br><a href="sub$use_thread->{'bbs_kind'}.cgi?mode=view&amp;no=).e($use_thread->{'number'}).qq(">→サブ記事に移動する</a>); }

$print .= qq(\n<!-- ▲ゼロ記事 -->\n);

#　記事メモを表示
my($memo_pri) = pri_memo_admin($use_thread->{'memo_body'},$use_thread->{'memo_editor'});
$print .= qq($memo_pri);

# 記事タグを取得
#if($concept !~ /NOT-TAG/ && $key ne "0"){
#require "${int_dir}main_tag.pl";
#($none,$none,$tag_line) = open_threadtag("VIEW THREAD DESKTOP","","",$moto,$in{'no'});
#if($tag_line){ $tag_line = qq(<div class="tag">$tag_line</div>); }
#}
#print qq($tag_line);

$print;

}


#---------------------------------------------------------
# 記事メモ
#---------------------------------------------------------

sub pri_memo_admin {

# 局所化
my ($memo_body,$memo_editor) = @_;
my($memo,$i,$memo_pri);
my($q) = Mebius::query_state();
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;

# リターン
#if($subtopic_mode){ return; }
my($name,$id,$trip,$memo_time,$memo_addr,$memo_host,$memo_number,$memo_account,$memo_date) = split(/=/,$memo_editor);
utf8($name,$memo_body,$memo_date);

my $memo_url = "/jak/$param->{'moto'}.cgi?mode=memo&amp;no=$param->{'no'}";

	# 記事メモを定義
	if($memo_body ){
			foreach(split(/<br>/,$memo_body)){
			#$_ = ad_auto_link($_);
			$_ =~ s/^\/\/(.+|$)/<span class="green">$1<\/span>/g;
			$memo .= "$_<br>";
			$i++;
			}


			if($trip){ $name = "$name☆$trip";}

			$memo_pri .= $html->href($memo_url,"記事メモ（編集する）");
			$memo_pri .= qq(　（<b>最終編集： $name</b><i>★$id</i> \($memo_date\) ）<br><br>$memo);
	} else{
		$memo_pri .= $html->href($memo_url,"▼この記事にメモをつけることが出来ます。");
		$memo_pri .= qq(<br>);
	}

# 整形
$memo_pri = qq(
\n<!-- ▼記事メモ -->
<div style="border:1px #000 solid;padding:0.5em;margin:1em 0.5em;margin-left:20%;">$memo_pri</div>
<!-- ▲記事メモ -->\n
);

$memo_pri;

}

#-----------------------------------------------------------
# 各種設定
#-----------------------------------------------------------
sub init_bbs_thread_view_admin{

my(%self);
my($q) = Mebius::query_state();

	if(Mebius::back_url_href()){
		$self{'disabled_class'} = " disabled";
	}

\%self;

}

package Mebius::BBS::Admin;
use Mebius::Export;

#------------------------------------------
# 返信部分 書き出し内容
#------------------------------------------
sub res_core{

# 宣言
my($use,$use_thread,$res_number) = @_;
my $shift_jis_data = $use_thread->{'res_data'}->{$res_number};
my($print,$checked,$combuf,$checked_first,$view_isp,$data_background_style);
my($view_host,$view_agent,$view_id,$view_trip,$view_name,$view_account,$view_user,$view_res_concept,$auto_name,$auto_name2,$view_editlink);
my($name_hitclass,$view_idclass,$agent_enc,$view_delete_com,$reason_style,$comment_background_style);
my($preview_number,$next_number,$image_view,$first_resnumber_id,$res_concept_text,$for_provider_link,$reporter_flag,$search,$newest_res_id,$comment_for_judge);
my $report = new Mebius::Report;
my $fillter = new Mebius::Fillter;
my($param) = Mebius::query_single_param();
my($q) = Mebius::query_state();
my($server_domain) = Mebius::server_domain();
my($my_admin) = Mebius::my_admin();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my($line) = Mebius::Encoding::hash_to_utf8($shift_jis_data);
my $nam = $line->{'handle'};
my $com = $line->{'comment'};
my $script = "./";
my($backurl_query_enc) = Mebius::back_url_param();
my($realmoto) = Mebius::BBS::real_bbs_kind($use_thread->{'bbs_kind'});

	# スレッド内検索
	if($param->{'word'}){
		($search) = main::bbs_tsearch($param->{'word'},"high-light","$shift_jis_data->{'handle'}☆$shift_jis_data->{'trip'}",$shift_jis_data->{'comment'},$line->{'id'},$line->{'account'},$line->{'user_agent'},$line->{'host'});
			if(!$search->{'hit'}){ return(); }
			if($search->{'high_lighted_comment'}){ ($com) = utf8_return($search->{'high_lighted_comment'}); }
	}

my($date_detail) = Mebius::Getdate("Get-second",$line->{'regist_time'});

	# ●プロバイダ連絡用
	if($param->{'for_provider'} || $param->{'provider'}){

		my($comment_splited,$comment);

		# 秒までの日付

		# 本文を選ぶ
		if($line->{'deleted'}){ $comment = $line->{'deleted'}; }
		else{ $comment = $com; }		

			foreach(split(/<br>/,$comment)){
				$comment_splited .= qq(&gt;$_<br>\n);
			}

		$print .= qq(<div style="text-align:left;line-height:1.4;color:$line->{'color'};margin:1em;" id="S$line->{'res_number'}">);
		$print .= qq(<strong>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</strong><br><br>\n);
		$print .= qq(ハンドルネーム： $line->{'handle'}<br>\n);
			if( my $addr = $line->{'addr'} ){
				$print .= qq(IPアドレス： ).e($line->{'addr'}).qq(<br>\n);
			}

		$print .= qq(リモートホスト： $line->{'host'}<br>\n);
			if($line->{'user_agent'}){
				$print .= qq(ユーザーエージェント： $line->{'user_agent'}<br>\n);
			}
		$print .= qq(投稿日時（日本時間）： $date_detail<br>\n);
		my $url = "$use_thread->{'url'}-$line->{'res_number'}";
		$print .= qq(投稿先のＵＲＬ： <a href=").e($url).qq(">).e($url).qq(</a> \( レス番：).e($line->{'res_number'}).qq( \)<br><br>);
		$print .= qq(【書きこまれた本文】： <br><br> $comment_splited\n);
		$print .= qq(</div><br>);

		return($print);
	}

my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($line);
my($handle_deleted_flag) = Mebius::BBS::handle_deleted_judge($line);

	# レス削除の初期チェック
	if($param->{'all_checked'}){ $checked = " checked"; }


	# 管理者
	if($line->{'user_agent'} eq "<A>"){
		$line->{'concept'} .= qq( Admin-regist);
	}

	# 本文の処理
	if($line->{'concept'} =~ /Admin-regist/) {
			#if($concept =~ /SUPERLINK/ && $line->{'handle'} =~ /対応中/){ $com = qq(<div style="background:#fdd;">$com</div>); } 
	}

	# 完全消去済み
	if($line->{'concept'} =~ /Vanished/){
		$view_delete_com .= qq(【完全削除済み】（管理者にしか見えません）<br><br>);
	}

	# 削除文の処理
	if($line->{'concept'} =~ /Revived-comment-?(?:<(.+)>)?/){
		$view_delete_com = qq (<span style="font-size:80%;color:#080;">レス復活 - $1</span><br>);
	}
	# 削除済みの表示
	elsif($comment_deleted_flag){

		$view_delete_com .= qq(<span style="font-size:80%;color:#f00;">);
		$view_delete_com .= qq(削除済);

			# ペナルティをつけた場合
			if($line->{'concept'} =~ /Penalty-done/){
				$view_delete_com .= qq( <em style="font-size:120%;">\( ペナルティあり \)</em> ); 
			}

		$view_delete_com .= qq(：$line->{'deleted'}<br></span><br>);
	}

# 自動リンク
($com) = main::ad_auto_link($com, $use_thread->{'number'},$use_thread->{'bbs_kind'});
($view_delete_com) = main::ad_auto_link($view_delete_com, $use_thread->{'number'},$use_thread->{'bbs_kind'});

	# 修正リンク表示
	if($my_admin->{'master_flag'}) {
		$view_editlink = qq(<a href=").e($use_thread->{'bbs_url_admin'}).q(?mode=edit_log&amp;no=).e($use_thread->{'number'}).q(&amp;res=).e($line->{'res_number'}).q(&amp;job=edit&amp;action=view">修正</a>┃); # &amp;pass=$pass
	}

	# プロバイダ通報リンク
	if($my_admin->{'master_flag'}) {
		$for_provider_link = qq(<a href="$ENV{'REQUEST_URI'}&amp;for_provider=1#S$line->{'res_number'}">通報</a>┃);
	}


# ISP表示
my($view_isp) = Mebius::Admin::user_control_link_isp_ref_host($line->{'host'}) . qq(┃);
($view_host) = Mebius::Admin::user_control_link_host($line->{'host'}) . qq(┃);

	# レスコンセプトを表示
	if($line->{'concept'}){
		$view_res_concept = qq(<div class="res_concept">$line->{'concept'}</div>);
	}

my($user_control_link) = Mebius::Admin::user_control_link_multi($line);

	# ＵＡ表示
	if($my_admin->{'master_flag'}){
		($agent_enc) = Mebius::Encode("",$line->{'user_agent'});
			if($use->{'search_hit'}->{'user_agent'}){ $view_agent = qq(<span style="background:yellow;">$user_control_link->{'user_agent'}</span>┃); }
			else{ $view_agent = qq($user_control_link->{'user_agent'}┃); }
	}

	# ＩＤ表示
	if($line->{'id'}){
		my($id_enc) = $line->{'id'};
		$id_enc =~ s/^([A-Z]+)=//g;
		$id_enc =~ s/_([A-Za-z0-9]+)$//g;

		$id_enc = Mebius::Encode("",$id_enc);

			if(exists $param->{'word'} && $param->{'id'}){
					if($use->{'search_hit'}->{'id'}){ $view_id = q(<strong class="hit">★).e($line->{'id'}).q(</strong>); }
					else{ $view_id = q(★).e($line->{'id'}); }
			}	else {
				if($use->{'search_hit'}->{'id'}){ $view_idclass = qq( class="hit"); }
					$view_id = qq(<a href=").e($use_thread->{'admin_url'}).q(&amp;word=).e($id_enc).q(&amp;id=1).e($backurl_query_enc).q(#S).e($line->{'res_number'}).q(").e($view_idclass).q(>★).e($line->{'id'}).q(</a>);
			}
	}


	# 「筆名呼びかけ」のオートリンク
	if($handle_deleted_flag){
		$auto_name2 = $auto_name = qq(削除済み);
	}

	else{
		$auto_name2 = $nam;
		$auto_name = $nam;
	}

$auto_name2 =~ s/'/\\'/g;
$auto_name =~ s/'/\\'/g;

	# トリップ表示
	if($line->{'trip'}){
		$view_trip = qq(☆$line->{'trip'});
		$nam = qq($nam$view_trip);
	}

	# 筆名表示
	if($use->{'search_hit'}->{'handle'}){ $name_hitclass = " hit"; }
	$nam =~ s/"/&quot;/g;
	$view_name .= qq(<a href="javascript:template\(\'◎$auto_name2様\\r\'\)" class="ats$name_hitclass"><strong>$nam</strong></a>);
		# 筆名が削除されている場合
		if($handle_deleted_flag){
			$view_name = qq(<strike>$view_name</strike> <span class="red">[筆名削除]</span>);
		}
	$view_name .= qq( \(<a href="javascript:template\(\'◎$auto_name様 No.$line->{'res_number'}\\r\'\)" class="ats">呼</a>);
	$view_name .= qq(/<a href="javascript:template\(\'&gt;&gt;$line->{'res_number'}\\r\'\)" class="ats">No</a>);

	# アカウント表示
	if($line->{'account'}){
		my($ac_style) = qq( class="hit") if($use->{'search_hit'}->{'account'});
		$view_account = qq(/<a href="$basic_init->{'auth_url'}$line->{'account'}/"$ac_style>$line->{'account'}</a>/$user_control_link->{'account'});
		if($line->{'concept'} =~ /Hide-account/){ $view_account .= qq(/<span title="アカウントを隠しています">隠</span>); }
	}
	elsif($use->{'search_hit'}->{'handle'}){ $nam = qq(<strong class="hit">$nam</strong>); }


	# 秘密板でのユーザーＩＤの表示
	#if($line->{'user_name'}){ $view_user = qq(/<a href="$mainscript?mode=member&amp;adfile=$scmoto&amp;type=edit&amp;user=$line->{'user_name'}">$line->{'user_name'}</a>); }
	if($line->{'user_name'}){ $view_user = qq(/$line->{'user_name'}); }

	# 画像の表示
	if($line->{'image_data'}){

		my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$server_domain,$realmoto,$use_thread->{'number'},$line->{'res_number'});
			if($image{'deleted'}){
				$image_view .= qq(<div class="deleted_image">);
				$image_view .= qq(【削除済みの画像】<br> );
				$image_view .= qq(<a href="$basic_init->{'main_url'}?mode=pallet-viewer-$realmoto-$use_thread->{'number'}-$line->{'res_number'}$backurl_query_enc">);
				$image_view .= qq(<img src="$image{'image_url_deleted'}" alt="$image{'title'}" class="paint_image">);
				$image_view .= qq(</a>);
				$image_view .= qq(</div>);
			}
			else{
				$image_view .= qq(<div>);
				$image_view .= qq(<a href="$basic_init->{'main_url'}?mode=pallet-viewer-$realmoto-$use_thread->{'number'}-$line->{'res_number'}$backurl_query_enc">);
				$image_view .= qq(<img src="$image{'samnale_url'}" alt="$image{'title'}" class="paint_image">);
				$image_view .= qq(</a>);
				$image_view .= qq(</div>);
			}
	}

	# 指定されたレスかどうかを判定 
	if($param->{'No'} ne ""){
		my($hit_flag,$first_flag) = Mebius::Page::Resnumber(undef,$line->{'res_number'},$param->{'No'});
			if($first_flag){ $first_resnumber_id = qq( id="RESNUMBER"); }
			if($hit_flag){ $data_background_style .= qq(background:#ff9;); }
	}

	# 帯 (管理者)
	if($line->{'concept'} =~ /Admin-regist/){
		$data_background_style .= qq(background:#cec;);
	}

	# 削除依頼の際、 本人確認のための表示
	if($param->{'backurl'}){

		# 局所化
		my($reporter_hit);

			if($param->{'reporter_id'} && $param->{'reporter_id'} eq $line->{'id'}){
				$reporter_flag .= qq( ID);
				$reporter_hit++;
			}
			if($param->{'reporter_account'} && $param->{'reporter_account'} eq $line->{'account'}){
				$reporter_flag .= qq( アカウント);
				$reporter_hit++;
			}
			if($param->{'reporter_trip'} && $param->{'reporter_trip'} eq $line->{'trip'}){
				$reporter_flag .= qq( トリップ);
				$reporter_hit++;
			}
			if($param->{'reporter_host'} && $param->{'reporter_host'} eq $line->{'host'}){
				$reporter_flag .= qq( ホスト名);
				$reporter_hit++;
			}
			if($param->{'reporter_agent'} && $param->{'reporter_agent'} eq $line->{'user_agent'}){
				$reporter_flag .= qq( UA);
				$reporter_hit++;
			}
			if($param->{'reporter_cnumber'} && $param->{'reporter_cnumber'} eq $line->{'cookie_char'}){
				$reporter_flag .= qq( Cookie);
				$reporter_hit++;
			}

			if($reporter_flag){
				$reporter_flag = qq(<div class="res_margin reporter">削除依頼しているユーザーと <strong class="red">$reporter_flag</strong> の $reporter_hit項目 が一致しています。 </div>);
			}
	}

	# 警告突破したレスの場合
	if($line->{'concept'} =~ /Alert-break(-)?(\[(.+?)\])?/){
		my($kind_of_alert);
			if($3){ $kind_of_alert = qq(\($3\)); }
		$res_concept_text .= qq(<span style="color:#f00;">※警告を突破して書きこまれました $kind_of_alert</span>);
		$res_concept_text = qq(<div style="background:#fdd;text-align:center;margin-top:1em;">$res_concept_text</div>);
	}
	if($line->{'concept'} =~ /From-other-site/){
		$res_concept_text .= qq(<span style="color:#ff9;">※外部サイトを経由？</span>);
		$res_concept_text = qq(<div style="background:#9f9;text-align:center;margin-top:1em;">$res_concept_text</div>);
	}


	if($comment_deleted_flag){
		$comment_for_judge = $line->{'deleted'};
	} else {
		$comment_for_judge = $com;
	}

	if( my $message = $fillter->each_comment_fillter_judge($comment_for_judge) ){
		$res_concept_text .= qq(<div style="background:#fbf;color:#000;text-align:center;margin-top:1em;">※コメントがフィルタされています。</div>);
	}

	if($use_thread->{'res'} == $res_number){
		$newest_res_id = qq( id="NEW_RES");
	}

# 管理データ部分開始
$print .= qq(<div class="reszone" id="S$line->{'res_number'}"><div class="resdata" $newest_res_id style="$data_background_style"$first_resnumber_id>);

	# 上下移動リンク
	if($my_use_device->{'mobile_flag'}){
		$print .= qq(<a href="#S$use_thread->{'res'}">▼</a> );
		$print .= qq(<a href="#TSEARCH">▲</a>┃);
	}

#管理データ部分
$print .= qq($view_editlink$for_provider_link$view_host$view_isp$date_detail┃);
$print .= qq($view_name$view_account$view_user\)┃$view_id┃);
$print .= qq(<a href=").e($use_thread->{'admin_url'}).qq(&amp;No=$line->{'res_number'}$backurl_query_enc#S$line->{'res_number'}">$line->{'res_number'}</a>);


$print .= qq(<br>$view_agent);
$print .= qq($user_control_link->{'cookie'});

	# コメントの背景色
	if($line->{'concept'} =~ /Vanished/){ $comment_background_style = qq(background:#bee;); }
	elsif($comment_deleted_flag){ $comment_background_style = qq(background:#fee;); }


$print .= qq(</div>);

	if( my $report_text = $use->{'report_detail'}){
		$com = $report->original_text_highlight($com,$report_text);
	}

	{
		my $res_comment_class = "rescomment";
		my $style = "margin:0em;" if($use->{'ViewReport'});
		$print .= qq(<div class="$res_comment_class" style="color:$line->{'color'};$comment_background_style$style">$view_delete_com$com$image_view$res_concept_text</div>);
	}

$print .= qq($reporter_flag);
$print .= qq($view_res_concept);


$print .= qq(</div>\n);

	# ●レス削除フォーム
	if($line->{'res_number'} ne "0"){

		$print .= qq(<div class="res_control">);

			if($param->{'backurl'}){ $print .= qq(<a href=").(Mebius::back_url_href()).qq(" class="green">戻る</a>　); }

			# レス操作ボックス
			#if(!$checked){ $checked_first = qq( checked); }

		my($realmoto) = Mebius::BBS::real_bbs_kind($use_thread->{'bbs_kind'});

			if(!$use->{'ViewReport'}){
				my($res_control_box) = Mebius::Reason::res_control_box_full_set({ unique_number => "$use_thread->{'bbs_kind'}-$use_thread->{'number'}-$line->{'res_number'}" , res_data => $line });
				$print .= $res_control_box;
			}

		# 実行ボタン
			if(!$use->{'ViewReport'}){
				$print .= qq(　<input type="submit" name="nopena" value="Go" class="console">);
			}

			# 実行ボタン ( 戻り先 )
			if(!$use->{'ViewReport'}){
					if($q->param('backurl')){ $print .= qq(　<input type="submit" name="nopena" value=" 戻 " class="backurl consol"> ); }

			}


		$print .= qq(</div>);

	}

$print;

}


1;
