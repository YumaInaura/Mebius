
use Mebius::Emoji;
use Mebius::Parts;
package main;
use strict;

#-----------------------------------------------------------
# 携帯Adsenseを取得
#-----------------------------------------------------------
sub kadsense{

# 宣言
my($type) = @_;
my($line1,$line2,$prace_view);

	# 重複処理を禁止
	if($main::done{'kadsense_get'}){ return(); }

	# 広告を表示しない場合
	if($main::noads_mode){ return(); }

	# ローカルの場合
	elsif($main::alocal_mode){ $line1 = $line2 = qq(広告 $type); }

	# 広告を表示する場合
	else{

			# PC->管理者の場合は、広告の所在をあらわす表示も追加
			if($main::myadmin_flag >= 5){ $prace_view = qq(広告 $type); }

		require "${main::int_dir}k_adsense.pl";
		my($ads1,$ads2) = main::do_kadsense($type);

			if($ads1){ $line1 = qq($prace_view$ads1); }
			if($ads2){ $line2 = qq($prace_view$ads2); }

	}

# 重複処理禁止フラグを立てる
$main::done{'kadsense_get'} = 1;

return($line1,$line2);

}

#-----------------------------------------------------------
# 携帯版 リンク処理
#-----------------------------------------------------------
sub kauto_link{

# 宣言
my($type,$comment,$thread_number,$res_number) = @_;
my($comment_split,$return_comment,$maxline_omit,$maxlength_omit,$comment_length_half,$omit_flag);
my($round,$omited_length,$omit_move,$omited_comment,$not_omited_length,$not_omited_comment,$omited_length_while,$return_omitlink);
our($concept,$realmoto);

	# 汚染チェック
	$thread_number =~ s/\D//g;
	$res_number =~ s/\D//g;

	# 本文省略幅の設定
	$maxline_omit = 15;		# 最大行数
	$maxlength_omit = 250;	# 最大文字数(全角)

	# クッキー設定がある場合、本文の省略閾値を変更
	if($type !~ /Preview/ && $main::ccut ne "0" && $main::ccut){

		$maxline_omit *= $main::ccut;
		$maxlength_omit *= $main::ccut;
	}


	# 余計な改行を削除
	if($type =~ /Loose/){ $comment =~ s/(<br>){5,}/<br><br><br><br><br>/g; }
	else{ $comment =~ s/(<br>){3,}/<br><br><br>/g; }

# 文末、文頭の改行を削除
$comment =~ s/^(<br>)+//g;
$comment =~ s/(<br>)+$//g;

	# タグがある場合、本文を省略しない（タグ壊れを防ぐ）
	if($comment =~ /<strong>/){ $type .= qq( Not-omit); }

	# 改行タグを携帯用に
	if($type !~ /Fix/){
		$comment =~ s/<br>/<br$main::xclose>/g;
	}

	# ○本文を１行ずつ展開
	foreach $comment_split (split(/<br$main::xclose>/,$comment)){

		# ラウンドカウンタ
		$round++;

		# 余計な全角スペースを削除
		$comment_split =~ s/^(　|\s){2,}/　　/g;
		$comment_split =~ s/(　|\s){2,}/　　/g;

		# 本文の文字数を計算
		$comment_length_half += length $comment_split;

			# 画像に閉じたグを追加
			if($type !~ /Fix/){
					if($main::bbs{'concept'} =~ /Upload-mode/){ $comment_split =~ s/<img (.+?)>/<img $1$main::xclose>/g;
			}

		# HTTP リンクを変換
		($comment_split) = Mebius::auto_link($comment_split);
			# レス番リンク
			if($thread_number){
				if($concept =~ /MODE-DELETE/){ $comment_split =~ s/No\.([0-9]+)(([,-])([0-9,]+)||$)/<span style="color:#f00;">#$1$2<\/span>/g; }
				else{ $comment_split =~ s/No\.([0-9]+)(([,-])([0-9,]+)||$)/<a href=\"$thread_number.html-$1$2#RES\">#$1$2<\/a>/g; }
			}

			# メールアドレスをリンク
			if($main::allowaddress_mode){
				$comment_split =~ s/([0-9a-z]+)\@([0-9a-z]+)\.([0-9a-z\.]+)/<a href=\"mailto:$1\@$2\.$3\">$1\@$2\.$3<\/a>/g; }
			}


			# その他の修正
			if($type =~ /Fix/){
				$comment_split =~ s/\?mode=my/\?mode=my&amp;k=1/g;
			}

			# 音楽ファイル
			if($realmoto =~ /^(ams|asx)$/){
				$comment_split =~ s/\/msc\/([a-z0-9_\-]+)\.mp3/\/_main\/?mode=msc-play&amp;file=$1&amp;k=1/g;
			}

			# 改行、文字数でレス省略
			if($type =~ /Omit/){

					# 前ループで表示最大値を超えていた場合、この行は省略行として扱う
					if($omit_flag){
						$omited_length += int(length($comment_split)/2);
						$omited_comment .= qq(<br$main::xclose>$comment_split);	
						$omit_flag = 2;
						next;
					}

					# 前ループで表示最大値を越えていない場合、本ループを処理
					else{

							# 最大改行に達した場合、第一フラグを立てる
							if($round > $maxline_omit){
								$omit_flag = 1; 
								$omit_move = qq(#R$round);
							}
							

							# 最大文字に達した場合、第一フラグを立てる
							if($comment_length_half >= $maxlength_omit*2){
								$omit_flag = 1; 
								$omit_move = qq(#R$round);

							}

							# 本文（省略なし）に改行を追加
							if($round >= 2){ $return_comment .= qq(<br$main::xclose>); }

							# あくまで調整処理
							# ▼文章全体が文字数オーバーしていて、なおかつこの１行も長い場合、１行をさらに細かく分割する 
							if($comment_length_half >= $maxlength_omit*2 && length($comment_split) >= $maxlength_omit*2*0.5){

								# 局所化
								my($comment_length_while_half,$round_while,$not_split_comment_while);
								my $comment_split_while = $comment_split;
								my $comment_length_prev_half = $comment_length_half - length($comment_split);	# 前回までの合計文字数を計算

									# この１行を特定文字で分解
									while($comment_split_while =~ /(.+?)(、|。|　)+?/g){

										# ラウンドカウンタ２、文字数計算
										$round_while++;
										$comment_length_while_half += length($&);

											# 省略する場合 ( この１行の文字数＋この区切り文章の文字数が一定値を越えた場合 )
											if($comment_length_while_half + $comment_length_prev_half >= $maxlength_omit*2*1.25 && $round_while >= 2){
												$omited_comment .= qq($1$2);
												$omit_flag = 2;
												$omited_length += int(length($&) / 2);
											}

											# 省略しない場合
											else{
												$return_comment .= qq($1$2);
											}

										# 区切れない文末を記憶
										$not_split_comment_while = $';
									}

									# １回も分割しなかった場合、この行をそのまま使う
									if($round_while <= 0){ $return_comment .= qq($comment_split_while); }

									# 区切れなかった部分を末尾に追加
									elsif($omit_flag == 2){
										$omited_comment .= qq($not_split_comment_while);
										$omited_length += int(length($') / 2);
									}
									else{
										$return_comment .= qq($not_split_comment_while);
									}

							}

							# 普通に本文を追加する場合
							else{
								$return_comment .= qq($comment_split);
							}
					}
			}
	
			# リターン本文を追加 ( もともと省略しないモードの場合 )
			else{
					if($round >= 2){ $return_comment .= qq(<br$main::xclose>); }
					if($type =~ /Resone/){ $return_comment .= qq(\n<a id="R$round"></a>); }
				$return_comment .= qq($comment_split);
			}

	}

	# ○本文を省略する場合
	if($type =~ /Omit/ && $omit_flag == 2){

		# 省略文字数の調整
		$omited_length += $omited_length_while;

		# 続きリンクを追加
		$return_comment =~ s/<br$main::xclose>$//g;
			if($res_number ne "" && $type =~ /Thread/){
				$return_omitlink = qq(<a href="$thread_number.html-$res_number$omit_move" id="C$main::no">続$omited_length</a>);
			}

		# プレビューの場合、どこから省略されるかを分かるように
		if($type =~ /Omit/ && $type =~ /Preview/){
			$return_comment .= qq(<br$main::xclose><br$main::xclose>
				<em>これ以上は省略表\示されます \($maxline_omit行以上 or $maxlength_omit文字以上\)</em><br$main::xclose>$omited_comment);
		}

	}

	# 行末の改行を削除
	$return_comment =~ s/(<br$main::xclose>+)$//g;

# リターン
return($return_comment,$omit_flag,$return_omitlink);

}

1;

