
use strict;
package Mebius::BBS;
use Mebius::Export;

#-----------------------------------------------------------
# ナビゲーションリンク
#-----------------------------------------------------------
sub thread_navigation_links{

# 宣言
my $use_thread = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($moto,$thread_number,$newest_res_number) = ($use_thread->{'bbs_kind'},$use_thread->{'thread_number'},$use_thread->{'res'});
my($line,$view_link_prev,$view_link_next,$div_id,$move_id,$move_link_text,$mail_link);
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
my($my_access) = Mebius::my_access();
my $html = Mebius::HTML->new();
my $bbs_path = Mebius::BBS::Path->new( $use_thread );
my $bbs_url = $bbs_path->bbs_url_adjusted({ MainThread => 1 });
my $data_page_url = $bbs_path->thread_usefull_url_adjusted({ MainThread => 1 , r => 'data' });

	if($moto eq "" || $moto =~ /[^0-9a-z]/){ return(); }
	if($thread_number eq "" || $thread_number =~ /[^0-9]/){ return(); }


	# メール配信リンク
	{
		my $text;

				if($my_use_device->{'wide_flag'}){
					$text = "お知らせメール";
				} else {
					$text = "メール";
				}

				if(Mebius::Admin::admin_mode_judge() || !$my_access->{'level'} || $use_thread->{'keylevel'} < 1){
					$mail_link = e($text);
				 
				} else {
					$mail_link = $html->href("./?mode=cermail&amp;no=$thread_number",$text);
				}
	}

	# << >> のリンクを定義
	if($use->{'MoveSideLinks'}){

			if(Mebius::Admin::admin_mode_judge()){
					if($thread_number >= 2){ $view_link_prev = $html->href($bbs_path->thread_url_adjusted({ MainThread => 1 , slide => '-1' } ),"&lt;&lt;"); }
					else{ $view_link_prev = qq(&lt;&lt;); }
				$view_link_next = $html->href($bbs_path->thread_url_adjusted({ MainThread => 1 , slide => '+1' } ),"&gt;&gt;");
			} else {
					if($thread_number >= 2){ $view_link_prev = $html->href("./?mode=tmove&amp;no=$thread_number","&lt;&lt;"); }
					else{ $view_link_prev = qq(&lt;&lt;); }
				$view_link_next = $html->href("./?mode=tmove&amp;no=$thread_number&amp;next=1","&gt;&gt;");
			}

	}

	# 最上部と最下部の振り分け
	if($use->{'Top'}){
		$div_id = "a";

			if($newest_res_number && !$param->{'No'} && !$param->{'r'} && !$param->{'word'}){
				$move_link_text = qq(▼レス\().e($newest_res_number).q(\));
				$move_id = "S$newest_res_number";

			} else{
				$move_id = "c";
					if($my_use_device->{'smart_phone_flag'}){
						$move_link_text = qq(▼下へ);
					} else{
						$move_link_text = qq(▼ページ下);
					}
			}
	}
	else{
		$div_id = "c";
		$move_id = "a";
					if($my_use_device->{'smart_phone_flag'}){
						$move_link_text = qq(▲上へ);
					} else{
						$move_link_text = qq(▲ページ上);
					}
	}

	# スマフォ振り分け
	if($my_use_device->{'smart_flag'}){

		my $hidden_id = "thread_navigation_other_";
			$hidden_id .= "top" if($use->{'Top'});
			$hidden_id .= "bottom" if($use->{'Bottom'});

		$line .= qq(<div class="thread_navigation bbs_border bbs_colored line-height-large" id=").e($div_id).q(">).qq(\n);
		$line .= qq($view_link_prev\n);
		$line .= $html->href($data_page_url,"データ").qq(\n);
		$line .= qq(<a href=").e("#$move_id").qq(">).e($move_link_text).qq(</a>\n);

		$line .= qq($view_link_next\n);
		$line .= qq( <a href="javascript:vswitch\(').e($hidden_id).qq('\);" class="fold">…</a>);

		# Javascriptで展開させる部分
		$line .= qq(<div id=").e($hidden_id).q(" class="none">);
		$line .= qq( <a href=").e($main::home).q(" accesskey="0">TOP</a>).qq(\n);
		$line .= qq( ) . $html->href($bbs_url,"掲示板") . qq(\n);
		$line .= $mail_link;
		$line .= qq(</div>);

		$line .= qq(</div>);


	}	else{

	# 普通

		$line .= qq(<div class="thread_navigation bbs_border" id="$div_id">).qq(\n);
		$line .= qq($view_link_prev\n);
		$line .= qq(<a href="$main::home" accesskey="0">TOPページ</a>).qq(\n);
		$line .= qq( ) . $html->href($bbs_url,"掲示板TOP") . qq(\n);

		$line .= qq(<a href=").e($data_page_url).q(">記事データ</a>).qq(\n);
		$line .= qq( $mail_link);

		$line .= qq( <a href="#$move_id">${move_link_text}</a>\n);
		$line .= qq($view_link_next\n);

		$line .= qq(</div>);

	}

return($line);

}

#-----------------------------------------------------------
# 前のページへのリンク
#-----------------------------------------------------------
sub ThreadPreviewPage{

# 宣言
my($type,$thread_number,$nowpage_res_start,$res,$per_page_resview,$first_page_resview,$bbs_kind) = @_;
my($line,$cutres_number,$before_rpage,$move);
my($my_use_device) = Mebius::my_use_device();
my $bbs_path = Mebius::BBS::Path->new($bbs_kind,$thread_number);

# 重複禁止 / 許可
my($dupulication_switch) = Mebius::BBS::InitThreadDupulicationPage();

# 変数の説明
# $thread_number		記事ナンバー ( 計算には使わない )
# $res					記事に存在するレス数
# $first_page_resview		1ページ目に表示するレス数
# $per_page_resview			2ページ目以降で、１ページあたり何個までレスを表示するか

	# 最新ページの場合、自動的にページ数を定義
	if($nowpage_res_start eq "") {
		$type .= qq( First-page);
		$nowpage_res_start = $res - $first_page_resview + 1;
	}

	# もう前のページがない場合はリターン
	if($nowpage_res_start <= 1){ return; }

	# 「記事のレス数」が、２ページ目まで達していない場合は、リターン ( ページ重複を禁止する場合のみ。 )
	if($dupulication_switch eq "Deny"){
			if($res <= $first_page_resview){ return(); }
	}

	# ●「前のページ」の R番号 ( $in{'r'} )を計算
	# ▼最初のページの場合
	if($type =~ /First-page/){

		# 【２ページ目の最後のレス番】を計算 する( 例： 396 - 50 = 346 )
		my $second_page_last_resnumber = $res - $first_page_resview;

		# 【２ページ目の最後のレス番】の端数を出す ( 例： 346 % 100 = 46  )
		my $rest_resnumber = ($second_page_last_resnumber) % $per_page_resview;

		# 【２ページ目の最後のレス番】から【端数】を切り落として 1 を加える
			# 端数が出た場合は、普通に引き算する
			if($rest_resnumber != 0){
				$before_rpage = ($second_page_last_resnumber) - ($rest_resnumber) + 1;
			}
			# 端数が出なかった場合は、１ページ単位分のレス番を引き算する
			else{
				$before_rpage = ($second_page_last_resnumber) - ($per_page_resview) + 1;
			}

		#my $rest_resnumber = ($second_page_last_resnumber-1) % $per_page_resview;
		# 全体のレス数から、( 例： 346 - 46 + 1 = 301 )
		#$before_rpage = ($second_page_last_resnumber-1) - ($rest_resnumber + 1);

	}
	# ▼現在のページ数が少ない場合は、自動的に１ページ目を定義
	elsif($nowpage_res_start <= $per_page_resview){
		$before_rpage = 1;
	}
	# ▼2ページ目以降
	else{

		# 端数を計算
		my $rest = $nowpage_res_start % $per_page_resview;

			# 割り切れるページ数の場合
			if($rest == 1){
				$before_rpage = $nowpage_res_start - $rest +1 - $per_page_resview;
			}
			# 割り切れないページ数の場合
			else{
				$before_rpage = $nowpage_res_start - $rest +1;
			}
	}

	# ●何個のレスが省略されているかを計算 ( 単純な引き算 )
	{
		$cutres_number = $nowpage_res_start - 1;
	}

	# ●MOVE リンクを定義
	if($type =~ /First-page/){
		$move = $res - $first_page_resview;
	}
	else{
		$move = $nowpage_res_start - 1;
	}
	# 整形
	if($move){
			$move = qq(#S$move);
	}

# HTML を定義
my $prev_thread_url = $bbs_path->thread_usefull_url_adjusted({ r => $before_rpage });
$line .= qq(<div class="d_ryaku"><span class="ryaku">);
$line .= qq(<a href="$prev_thread_url$move">↑前のページ \($cutres_number件\)</a>);

	# 最新ページへのリンク
	if($my_use_device->{'smart_flag'}){

	} else{
			if($type =~ /First-page/){ $line .= qq( ｜ 最新ページ); }
			else{ $line .= qq( ｜ <a href="$thread_number.html#RES">最新ページ</a>); }
	}

$line .= qq(</span></div>);

# リターン
return($line);

}


#-----------------------------------------------------------
# 次のページへのリンクを取得
#-----------------------------------------------------------
sub ThreadNextPage{

# 宣言
my($type,$thread_number,$now_page_number,$thread_res,$per_page_resview,$first_page_resview,$bbs_kind) = @_;
my($line,$next,$cut,$rlink,$move);
my($my_use_device) = Mebius::my_use_device();
my $bbs_path = Mebius::BBS::Path->new($bbs_kind,$thread_number);

# 変数定義
my $now_res_start = $now_page_number;

# 重複禁止 / 許可
my($dupulication_switch) = Mebius::BBS::InitThreadDupulicationPage();

	# 「すべてのレスを表示」している場合は、表示する必要がないためリターン
	if($now_page_number eq "all"){ return(); }

	# 最新ページの場合は、次のページを表示する必要がないため、リターン
	if($now_res_start eq ""){ return(); }

	# 続きのページがない場合はリターン
	if($dupulication_switch eq "Allow"){
			if($now_res_start >= $thread_res - $per_page_resview + 1){ return; }	# ページ重複を許可する場合
	}
	# 続きのページがない場合はリターン
	elsif($dupulication_switch eq "Deny"){
			if($now_res_start >= $thread_res - $first_page_resview + 1){ return; }	# ページ重複を禁止する場合
	}
	else{
		return();
	}

	# ●「次のページ」のページ数を計算
	# 次のページが最新ページの場合
	if($now_res_start > $thread_res - $per_page_resview - $first_page_resview){
		$rlink = "";
		$cut = $first_page_resview;
	}
	# 次のページが２ページ目以降の場合
	else{
		my $rest = $now_res_start % $per_page_resview;
			#if($rest == 1){
				$next = $now_res_start - $rest + $per_page_resview + 1;
			#}
			#else{
			#	$next = $now_res_start - $rest + ($per_page_resview) + 1;
			#}
		$cut = $thread_res - $now_res_start - $per_page_resview + 1;
		$rlink = "_${next}";
	}

	# ●Moveを定義
	{

		# 端数を計算
		my $rest = $now_res_start % $per_page_resview;

			# ページ数が割り切れる場合
			if($rest == 1){
				$move = "#RES";
			}
			# 次のページが	「最新ページ」の場合 ( ここは適当に書いています )
			elsif($now_res_start + $per_page_resview >= $thread_res){
				$move = "#RES";
			}
			# 次のページが２ページ目以降の場合
			else{
				$move = $now_res_start + $per_page_resview;
				$move = "#S$move";
			}
	}

# HTMLを定義
my $next_thread_url = $bbs_path->thread_usefull_url_adjusted({ r => $next });
$line .= qq(<br><div class="d_ryaku"><span class="ryaku">);
$line .= qq(<a href="$next_thread_url$move">↓次のページを読む \($cut件\)</a>);

	# 最新ページへのリンク
	if($my_use_device->{'smart_phone_flag'}){
	}
	else{
		$line .= qq( ｜ <a href="$thread_number.html#RES">最新ページ</a>);
	}

$line .= qq(</span></div>);

return($line);

}




#-----------------------------------------------------------
# １ページ目と２ページ目の重複を許可する / 禁止するスイッチ
#-----------------------------------------------------------
sub InitThreadDupulicationPage{

# Allow か Deny
my $switch = "Allow";

return($switch);

}

1;
