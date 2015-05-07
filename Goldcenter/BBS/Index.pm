
use strict;
package Mebius::BBS;
use Mebius::Export;

#-----------------------------------------------------------
# インデックスを更新 - strict
#-----------------------------------------------------------
sub index_file{

# 宣言
my($use,$moto,$thread_number) = @_;
my(undef,undef,undef,$new_key) = @_ if($use->{'ThreadStatusEdit'});
my($hit_flag,$newline,@renew_line,@pin,$FILE1,%self,$directory,%selef_renew,%data_format,%self_renew,$relay,@new_pin,%line_controled);
my $time = time;

	# 汚染チェック
	if(ref $use ne "HASH"){ die("Perl Die! $use is not HASH Reference."); }
	if($moto eq "" || $moto =~ /\W/){ return(); }
	if(ref $thread_number eq "" && $thread_number =~ /\D/ && !exists $use->{'line_control'}){ return(); }

# ファイル定義
my($bbs_path) = Mebius::BBS::path($moto);
	if($bbs_path->{'index_directory'}){ $directory = $bbs_path->{'index_directory'}; }
	else{ main::error("Can't set menu file."); }

	if($use->{'SubIndex'}){
			if($bbs_path->{'sub_index_file'}){ $self{'file'} = $bbs_path->{'sub_index_file'}; }
			else{ main::error("Can't set menu file."); }

	} else {
			if($bbs_path->{'index_file'}){ $self{'file'} = $bbs_path->{'index_file'}; }
			else{ main::error("Can't set menu file."); }
	}


my($FILE1,$read_write) = Mebius::File::read_write($use,$self{'file'},[$directory,$bbs_path->{'index_directory'}]);
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }	

# データ構造を定義
$data_format{'1'} = [('thread_num','last_modified','last_post_time','last_res_thread_number','bbs_title')];

# トップデータを読み込み
my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
%self = (%self,%$split_data);

	# 新規作成した場合
	if($read_write->{'file_touch_flag'}){
		$self_renew{'thread_num'} = "0";
		$self_renew{'last_modified'} = time;
	}

	# ファイル消失
	if($self{'thread_num'} eq "" && !$read_write->{'file_touch_flag'}){ $self{'file_broken_flag'} = 1;}

	# エラー対策
	if($use->{'Renew'} && ($self{'thread_num'} eq "") && !$read_write->{'file_touch_flag'}) {
		$self{'file_broken_flag'} = 1;
		close($FILE1);
		main::error("Can't open index file.");
	}

	# インデックスを展開
	while (<$FILE1>) {

		my($not_push_renew_line_flag,%line);

		# ( 1-A )
		$line{'natural_line'} = $_;
		push(@{$self{'all_line'}},$line{'natural_line'});

		# 行を分解 ( 1-B )
		chomp;
		($line{'thread_number'},$line{'subject'},$line{'last_res_number'},$line{'post_handle'},$line{'last_modified'},$line{'last_handle'},$line{'key'}) = split(/<>/);
		$self{'thread'}{$line{'thread_number'}} = \%line;
		push @{$self{'all_line_on_hash'}} , \%line;

		$self{'i'}++;
		$self{'hit_index'}++;

			# ●更新のための処理
			if($use->{'Renew'}){

					# ▼新規投稿するとき、記事が溢れた場合、過去ログにする
					if($use->{'NewThread'} && $self{'i'} >= $use->{'max_line'} && $use->{'max_line'}) {
						#push(@{$self{'flow_data_line'}},$_);  # 使っていない変数のようだ
						Mebius::BBS::BePastThread(undef,$moto,$line{'thread_number'});
					}

					# ▼HITした記事
					elsif(exists $use->{'line_control'}->{$line{'thread_number'}}) { 

						my($new_pin_flag);
						my $control = $use->{'line_control'}->{$line{'thread_number'}};
						$line_controled{$line{'thread_number'}} = 1; # ファイル復元用

						# ヒットした場合
						$hit_flag = 1;

							# 各値を変更
						# 任意の更新とリファレンス化
						my($line_renew) = Mebius::Hash::control(\%line,$control);

							# ピン止めする場合
							if($control->{'key'} eq "2"){
								$not_push_renew_line_flag = 1;
								$new_pin_flag = 1;
							}

							# スレッドを削除する場合
							if($control->{'type'} =~ /^(Delete)(Soon)?$/){

									$not_push_renew_line_flag = 1;
									deleted_thread_index_file($moto,$line{'natural_line'});

							}

						# 書きこむ行を定義
						($newline) = Mebius::add_line_for_file_and_format([$line_renew->{'thread_number'},$line_renew->{'subject'},$line_renew->{'last_res_number'},$line_renew->{'post_handle'},$line_renew->{'last_modified'},$line_renew->{'last_handle'},$line_renew->{'key'}]);

							# 新しくピン止めする
							if($new_pin_flag){
									push(@new_pin,$newline);
							}

							# ソートしない場合は、このまま行を更新
							if(!$use->{'Sort'} && $newline){
									if(!$not_push_renew_line_flag){
										push(@renew_line,$newline);
									}
							}

					}

					# ピン止め記事
					elsif($line{'key'} == 2) {
							if(!$not_push_renew_line_flag){
								push(@pin,$line{'natural_line'});
							}
					}

					# その他の記事
					else{
							if(!$not_push_renew_line_flag){
								push(@renew_line,$line{'natural_line'});
							}
					}
			}

	}

	# ●記事が現行ログにない場合、修復 ( もしくはスレッド復活処理をおこなう )
	foreach my $thread_number (keys %{$use->{'line_control'}}) {

			# 既に操作済みの場合は処理しない
			if($line_controled{$thread_number}){ next; }
			# 削除した場合（なおかつ、行が見つからなかった場合）は修復しない
			if($use->{'line_control'}->{$thread_number}->{'type'} =~ /^(Delete)(Soon)?$/){ next; }

		# 元記事を取得
		my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$moto,$thread_number);

		# 修復するハンドルネーム
		my $repair_handle = "";

			if($repair_handle eq ""){ $repair_handle = $thread->{'lasthandle'}; }
		# 修復するキー
		my $repair_key = $new_key;
			if($repair_key eq ""){ $repair_key = 1; }
		unshift(@renew_line,"$thread_number<>$thread->{'subject'}<>$thread->{'res'}<>$thread->{'posthandle'}<>$time<>$repair_handle<>1<>\n");

	}

	# 新しい行を追加 ( ソートありの場合 )
	if($use->{'Sort'}){ unshift(@renew_line,$newline); }

	# 記事を追加
	if($use->{'new_line'}){ unshift(@renew_line,$use->{'new_line'}); }
	if(@pin >= 1){ unshift(@renew_line,@pin); }
	if(@new_pin >= 1){ unshift(@renew_line,@new_pin); }

	# SSS
	# 最終レスのあった記事番号を更新 (トップデータ内)
	if($use->{'RegistRes'} && $use->{'Sort'} && ref $thread_number eq ""){
		$self_renew{'last_res_thread_number'} = $thread_number;
	}

	# ファイル更新
	if($use->{'Renew'} && !$self{'file_broken_flag'} && @renew_line >= 1){

			# トップデータの扱い
			if($use->{'RegistRes'}){
				$self_renew{'last_modified'} = time;
			}

		# 任意の更新とリファレンス化
		my($renew) = Mebius::Hash::control(\%self,\%self_renew,$use->{'select_renew'});

		# データフォーマットからファイル更新
		Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew,\@renew_line);

	}

# ファイルを閉じる
close($FILE1);

	# パーミッション変更
	if($use->{'Renew'}){ Mebius::Chmod(undef,$self{'file'}); }

	# 一定確率でバックアップ (新)
	if($use->{'Renew'} && !$self{'file_broken_flag'} && (rand(25) < 1 || Mebius::alocal_judge())){
		Mebius::make_backup($self{'file'});
	}
	elsif($self{'file_broken_flag'} && $self{'flock_flag'}){
		Mebius::return_backup($self{'file'});
	}

\%self;

}

#-------------------------------------------------
#  削除した親記事を、ユーザー可視のインデックスとして記録
#-------------------------------------------------
sub deleted_thread_index_file{

my($moto,$deleted_line) = @_;
my ($line,$i,$sub,$no,$sub,$res,$nam,$last,$lastman,$key);
my($init_directory) = Mebius::BaseInitDirectory();
my($query) = Mebius::query_state();

	if($moto =~ /\W/ || $moto eq ""){ return(); }

# ファイル定義
my($directory) = Mebius::BBS::index_directory_path_per_bbs($moto);
my $file = "${directory}deleted_threads.log";

chomp $deleted_line;
$line .= qq($deleted_line\n);

	# 題名も削除する場合
	if($query->param('delete_title')){
		my($no,$sub,$res,$nam,$last,$lastman,$key) = split(/<>/,$line);
		$line = "$no<>題名削除済み<>$res<>$nam<>$last<>$lastman<>$key<>\n";
	}

open(DELETED_IN,"<",$file);
	while(<DELETED_IN>){
		$i++;
			if($i <= 30) { $line .= $_; }
	}
close(DELETED_IN);

# 書き出す
Mebius::Fileout(undef,$file,$line);

}

package Mebius::BBS::Index;
use Mebius::Export;

#-----------------------------------------------------------
# スレッドの一覧を表示するためのコア処理
#-----------------------------------------------------------
sub view_thread_menu_core_for_smart_phone{

# 宣言
my $data = shift;
my $use = shift if(ref $_[0] eq "HASH");
($data) = Mebius::Encoding::hash_to_utf8($data) if($use->{'SJIS'});
my($class,$line,$status_mark);

# 局所化
my $regist_time = $data->{'last_regist_time'} || $data->{'regist_time'} || $data->{'last_modified'};
my($how_before) = Mebius::second_to_howlong({ ColorView => 1 , GetLevel => "top" , HowBefore => 1 },time - $regist_time) if $regist_time > 1;

# 各種代入
my $res = $data->{'res'} || $data->{'res_number'} || $data->{'last_res_number'} || 0;
my($bbs_url) = Mebius::BBS::bbs_url($data->{'bbs_kind'});
my($thread_url) = Mebius::BBS::thread_url($data->{'thread_number'},$data->{'bbs_kind'});
my($thread_url_move_to_last_res) = Mebius::BBS::thread_url_move($data->{'thread_number'},$data->{'bbs_kind'},$res);
my $last_handle_view = ($data->{'last_handle'} || $data->{'poster_handle'}) . "($res)";

		# 背景色を定義
	if($use->{'hit_round'} % 2 != 0){ $class .= qq( colored); }
	if($use->{'NoBorder'}){
		$class .= qq( lsm noborder);
	}else{
		$class .= qq( lsm);
	}

$line .= qq(<div class="bdbcolor $class">);

# スレッド本体へのリンク
$line .= qq(<div class="ell">);
$line .= qq(<a href=").e($thread_url).q(">).e($data->{'subject'}).q(</a>);
$line .= qq(</div>);

	# 最終レスへのリンク
	if($use->{'pv_ranking_mode'}){
		$line .= qq( ${res}pv );
	}	elsif($last_handle_view && $data->{'key'} ne "2"){
		$line .= qq(<div class="right">);

			if($use->{'use_sub_thread_flag'}){
				$line .= qq(<span class="gray">本編 ：</span> );
			}

		$line .= $how_before.q( );
		$line .= q(<a href=").e($thread_url_move_to_last_res).q(">).e($last_handle_view).q(</a>);
		$line .= qq(</div>);
	}

	# サブ記事へのリンク
	if($use->{'sub_thread_last_handle'}){
		$line .= qq(<div class="right">);
		$line .= qq(<span class="gray">サブ ： </span>$use->{'sub_thread_last_handle'});
		$line .= qq(</div>);
	}

	# 掲示板へのリンク
	if($data->{'title'}){
		$line .= qq(<div class="right">);
		$line .= qq(<a href=").e($bbs_url).q(">).e($data->{'title'}).q(</a> );
		$line .= qq(</div>);
	}



$line .= qq(</div>);


$line;

}


#-----------------------------------------------------------
# 他の掲示板へのリンク
#-----------------------------------------------------------
sub other_bbs_link_area{

my($category,$bbs_kind) = @_;
my($line,$other_bbs_line,$other_bbs_line_hidden);
my $bbs_status = new Mebius::BBS::Status;

# 同じカテゴリの他の掲示板
my $bbs_data_on_dbi = $bbs_status->fetchrow_on_hash_main_table("bbs_kind");

#my($bbs_data_on_dbi) = Mebius::BBS::Status::all_records_on_hash();

my(@other_bbs) = Mebius::BBS::BBSNameAray("Get-array",$category);
my $html = new Mebius::HTML;

	foreach(@other_bbs){

		my($line);

			if(ref $_ ne "HASH"){ next; }

		my $bbs_data = $bbs_data_on_dbi->{$_->{'kind'}};

			if($_->{'Close'}){ next; }

			if($bbs_kind eq $_->{'kind'}){
				$line .= qq( <span class="red">$_->{'title'}</span>);
				$line .= qq(\n);
			}	else {
				($line) .= $html->href("/_$_->{'kind'}/",$_->{'title'});
				$line .= qq(\n);
			}

			if($bbs_data->{'regist_time'} >= time - 7*24*60*60){
				$other_bbs_line .= $line;
			} else {
				$other_bbs_line_hidden .= $line;
			}

	}

	# 整形
	if($other_bbs_line || $other_bbs_line_hidden){

			my $id = "category_hidden_bbs_${category}";

		$other_bbs_line = qq(<hr>他の掲示板： <span class="other_bbs">$other_bbs_line</span>);

			if($other_bbs_line_hidden){
				$other_bbs_line .= q(<div class="none" id =").e($id).q(">);
				$other_bbs_line .= $other_bbs_line_hidden;
				$other_bbs_line .= q(</div>);
				$other_bbs_line .= qq(<a href="javascript:vswitch\(').e($id).q(','inline'\);" class="fold">…その他</a> );
			}
	}

$other_bbs_line;

}


#-----------------------------------------------------
# メニュー部分、１行処理 - strict
#-----------------------------------------------------
sub view_line_core{

# 宣言
my $self = shift;
my($type,$getline,$hit,$use) = @_; # ,$newnum,$newres_time,$newpost_time
my($mark,$class);
if($type =~ /Pv-ranking/){ (undef,undef,$mark) = @_; }
my($notlink_flag,$class,$status_mark,$line,$keyword,$td_poster,$submark_mobile,$mark_style_mobile,$tr_background_style,$lastname_sub_thread,$sub_thread_flag,%data,$bbs_link);
my($my_use_device) = Mebius::my_use_device();
my $time = time;
my $html = new Mebius::HTML;
my($subtopic_link,$moto) = ($main::subtopic_link,$main::moto || $use->{'bbs_kind'});

	if(ref $getline eq "HASH"){
		%data = (%data,%{$getline});
	} else {
		($data{'thread_number'},$data{'subject'},$data{'last_res_number'},$data{'post_handle'},$data{'last_modified'},$data{'last_handle'},$data{'key'}) = split(/<>/,$getline);
	}

my $bbs_path = Mebius::BBS::Path->new($moto,$data{'thread_number'});
my $thread_url = $bbs_path->thread_url_adjusted();
my $data = \%data;

# インデックスの１行を分解
my($num,$sub,$res,$nam,$last_regist_time,$lastname,$key)
	= ($data->{'thread_number'},$data->{'subject'},$data->{'last_res_number'} || $data->{'res_number'} || 0,$data->{'post_handle'} || $data->{'poster_handle'} ,$data->{'last_modified'} || $data->{'regist_time'},$data->{'last_handle'} || $data->{'handle'},$data->{'key'});

$data{'bbs_kind'} = $moto;

	# フィルタで非表示にする場合
	if(Mebius::Fillter::heavy_fillter(utf8_return($sub))){
		return();
	}


	# 第一マーク
	if($mark){ $notlink_flag = 1; }
	elsif($type =~ /PAST/){ $mark = "過"; $notlink_flag = 1; }
	elsif($key == 5){ $mark = "優"; }
	elsif($last_regist_time > time - 60*60*3){ $mark = "★"; $mark_style_mobile = qq(color:#f00;); }
	elsif($last_regist_time > time - 60*60*24){ $mark = "☆"; $mark_style_mobile = qq(color:#080;); }
	elsif($key == 2){ $mark = "＠"; }
	elsif($last_regist_time > time - 60*60*24*7 && $type !~ /Mobile-view/){ $mark = "∴"; }
	elsif($type !~ /Mobile-view/){ $mark = "─"; }
	if(!$notlink_flag && $type !~ /Mobile-view/){ $mark = qq(<a href="$thread_url#S${res}"$class>$mark</a>); }

	# 第二マーク
	if($key eq "0"){ $status_mark = qq( <span class="red">[ ロック ]</span>); }
	elsif($key == 9){ $status_mark = qq( <span class="red">[ 18 ]</span>); }
	elsif($key == 8){ $status_mark = qq( <span class="red">[ 15 ]</span>); }
	elsif($key == 2){ $status_mark = qq( <span class="red">[ ピン ]</span>); }
	#if($num == $newnum && $newpost_time + 24*60*60 > $time && $res <= 5){ $status_mark .= qq( <span class="red">New !</span>); }
	#elsif($newres_time == $last_regist_time && $last_regist_time + 6*60*60 > $time){ $status_mark .= qq( <span class="green">Res !</span>); }

	if($use->{'bbs_title'}){
		$data{'title'} = $use->{'bbs_title'};
		$bbs_link = $html->href($bbs_path->bbs_url_adjusted(),$use->{'bbs_title'});
	}

	# サブ記事モードの場合
	if($type !~ /PAST/ && ($subtopic_link eq "1" || $subtopic_link eq "2")){

		$sub_thread_flag = 1;

		my($sub_index) = Mebius::BBS::sub_index_state($moto);
		my($how_before_sub_thread) = Mebius::second_to_howlong({ ColorView => 1 , GetLevel => "top" , HowBefore => 1 },time - $sub_index->{'thread'}->{$num}->{'last_modified'}) if($sub_index->{'thread'}->{$num}->{'last_modified'});

		my($submark,$fastmark);
		my($res,$restime,$reser) = utf8_return($sub_index->{'thread'}->{$num}->{'last_res_number'},$sub_index->{'thread'}->{$num}->{'last_modified'},$sub_index->{'thread'}->{$num}->{'last_handle'});
			if($restime > time -  60*60*24){ $fastmark = qq(); }
		$submark = qq(<a href="/_sub$moto/${num}.html#S$res" class="subres2">$fastmark$reser ($res)</a> ); 

			# レスがある場合
			# モバイル版
			if($my_use_device->{'mobile_flag'}){
					if($res){ $submark_mobile = qq( <a href="/_sub$moto/${num}.html"$main::utn2>サブレス($res)</a>); }
			}
			# ▼スマフォ版
			elsif($my_use_device->{'smart_flag'}){
					if($res){
						my $link = $html->href("/_sub$moto/${num}.html#S$res","$reser($res)");
						$lastname_sub_thread = qq($how_before_sub_thread - $link);
						}
					else{
						$lastname_sub_thread = qq(<span class="gray">まだありません</span>);
					}
			}
			# ▼デスクトップ版
			else{
					if($res){
						$lastname = qq($submark); #k ( <a href="/_sub$moto/${num}.html" class="subres">$res</a> ) 
					}
					else{
						$lastname = "　";
					}
			}

	}

	# 作成者
	#if(!$category_mode){
		$td_poster = qq(<td>$nam</td>);
	#}

	# ●携帯版の表示
	if($my_use_device->{'mobile_flag'}){

		# 局所化
		my($background_color);

		# 背景色を定義
		if($hit % 2 != 0){ $background_color = qq(background:#eef;); }

		$line .= qq(<div style="${background_color}padding:0.3em 0em;text-align:center;">);
				if(length($sub) >= 30){ $line .= qq(<a href="$thread_url" style="$main::kfontsize_xsmall_in"$main::utn2>$sub</a>); }
				else{ $line .= qq(<a href="$thread_url"$main::utn2>$sub</a>); }
		$line .= qq(<br$main::xclose>);
		$line .= qq(<a href="$thread_url#S$res"$main::utn2>${res}レス</a>);
			if($lastname){ $line .= qq( $lastname); }
			if($mark){
					if($mark_style_mobile){ $line .= qq( <span style="$mark_style_mobile">$mark</span>); }
					else{ $line .= qq( $mark); }
			}

			if($submark_mobile){ $line .= qq(<br$main::xclose>$submark_mobile); }
		$line .= qq(</div>);
	}

	# ●スマフォ板の表示
	elsif($my_use_device->{'smart_flag'}){
		my ($smart_phone_line) = Mebius::BBS::Index::view_thread_menu_core_for_smart_phone(\%data,{ hit_round => $hit , use_sub_thread_flag => $subtopic_link , sub_thread_last_handle => $lastname_sub_thread });
		$line .= $smart_phone_line;
	}

	# ●デスクトップ版の表示
	else{

		my($tr_class);
	
		# 背景色を定義
			if($hit % 2 != 0){ $tr_class = qq( class="colored"); }

		$line .= qq(<tr$tr_class>);
		$line .= qq(<td>$mark</td>);
		$line .= qq(<td>);

		$line .= $html->href($thread_url,$sub);
			if($bbs_link){
				$line .= " ( " . $bbs_link . " ) ";
			}
		$line .= qq($status_mark);
		$line .= qq(</td>);
		$line .= qq($td_poster);
		$line .= qq(<td>$lastname</td>);
			if($type =~ /Pv-ranking/){ $line .= qq(<td>${res}pv</td>); }
			else{ $line .= qq(<td>$res回</td>); }
		$line .= qq(</tr>\n);
	}

return($line);

}

#-----------------------------------------------------------
# メニューをテーブル等で囲む
#-----------------------------------------------------------
sub round_menu{

my $self = shift;
my $relay_table = shift;
my $relay_line = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $print;
my($my_use_device) = Mebius::my_use_device();
my($thblock_poster);
my $subtopic_link = $main::subtopic_link;

# テーブルの TH 表記
my($th_res,$th_last) = ("返信","最終");
	if($subtopic_link eq "1" || $subtopic_link eq "2"){ ($th_res,$th_last) = ("本編","サブ記事"); }
	$thblock_poster = qq(<th class="td2">作成者</th>);
	if($main::submode2 eq "pvall"){ $th_res = "PV"; }

	# スマフォ振り分け
	if(($my_use_device->{'smart_phone_flag'} || $my_use_device->{'smart_flag'}) && $relay_line){

		my $ads = new Mebius::Ads;
		$print .= qq(<div class="bbs">);
			if(!$use->{'no_ads_flag'}){
				$print .= qq(<div class="ads_index bbs_border">);
				$print .= $ads->bunner();
				$print .= qq(</div>);
			}
	} else{
		$print .= qq(<table cellpadding="3" summary="記事一覧" class="table2 bbs"><tr><th class="td0">印</th>);
		$print .= qq(<th class="td1">題名</th>);
			if($use->{'Category'}){
				$print .= qq(<th style="width:5em;">掲示板</th>);
			}
		$print .= qq($thblock_poster<th class="td3">$th_last</th><th class="td4">$th_res</th></tr>);
	}

$print .= $relay_table . $relay_line;

	# 記事一覧の終わり部分
	if($my_use_device->{'smart_phone_flag'} || $my_use_device->{'mobile_flag'}){
		$print .= qq(</div>);
	}
	else{
		$print .= qq(</table>);
	}

$print;

}


1;

