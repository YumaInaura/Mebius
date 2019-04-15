
package Mebius::Adventure;
use strict;

#-----------------------------------------------------------
# ランキングページを表示
#-----------------------------------------------------------
sub ViewRanking{

# 宣言
my($init) = &Init();
my($init_login) = init_login();
my($maxview,$print);
our($advmy);

	# 表示数
	if($main::in{'viewall'}){ $maxview = 1000; }
	else{ $maxview = 100; }

# ランキング取得
my($menber_list);
my($line,undef,$flow_flag) = &RankingFile({ TypeGetIndex => 1 , MaxViewIndex => $maxview , SelectJobName => $main::in{'jobname'} , Sort => $main::in{'sort'} },{},$advmy);

# CSS定義
$main::css_text .= qq(
div.sort{margin:1em 0em;word-spacing:0.5em;background:#ddf;padding:0.5em 1em;}
div.jobname_sort{margin:1em 0em;word-spacing:0.5em;background:#ff9;padding:0.5em 1em;}
);

# 並び替えの種類
my @sort_mode = (
"=>レベルが高い順",
"level_low=>レベルが低い順",
"maxhp=>最大HP順",
"gold=>所持金順",
"login=>ログイン時間順",
"name=>名前順"
);

$print .= <<"EOM";
<h1>メンバーリスト</h1>
$init_login->{'link_line'}
$init->{'ads1_formated'}
EOM

$print .= qq(
<h2>一覧</h2>
$init->{'reset_limit'} 日以上行動していないキャラクタは非表\示になります。（キャラデータは残るので、その後もログインは可能\です）。<br>
$init->{'charaon_day'} 日以上行動していないキャラクターはグレーで表\示されます。);

# 各種並べ替えリンク
$print .= qq(<div class="sort">並べ替え：\n);
	foreach(@sort_mode){
		my($sort_type,$sort_title) = split(/=>/,$_);
			if($main::in{'sort'} eq $sort_type){ $print .= qq($sort_title); }
			elsif($sort_type eq ""){ $print .= qq(<a href="$init->{'script'}?mode=ranking">$sort_title</a>); }
			else{ $print .= qq(<a href="$init->{'script'}?mode=ranking&amp;sort=$sort_type">$sort_title</a>); }
		$print .= qq(\n);
	}
$print .= qq(</div>);

	# 職業での並び替えリンク
$print .= qq(<div class="jobname_sort">職業：\n);
	require Mebius::Adventure::Job;
	my(@jobnames) = &SelectJob("Get-jobname");
	if($main::in{'jobname'} eq ""){ $print .= qq(全職業\n); }
	else{ $print .= qq(<a href="$init->{'script'}?mode=ranking">全職業</a>\n); }
	foreach(@jobnames){
		my($jobname_encoded) = Mebius::Encode(undef,$_);
		if($main::in{'jobname'} eq $_){ $print .= qq($_\n); }
		else{ $print .= qq(<a href="$init->{'script'}?mode=ranking&amp;jobname=$jobname_encoded">$_</a>\n); }
	}
$print .= qq(</div>);

# ランキング本体部分
$print .= qq($line);

	# 溢れている場合
	if($flow_flag || Mebius::alocal_judge()){
		$print .= qq(<br><a href="$init->{'script'}?$main::postbuf&amp;viewall=1">→ランキングの続きを表\示</a><br><br>);
	}


$print .= "$init->{'ads1_formated'}\n";

$print .= qq(</div>);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => ["ランキング"] },$print);

exit;

}





#-----------------------------------------------------------
# ランキング部分を取得
#-----------------------------------------------------------
sub RankingFile{

# 宣言
my($use,$select_renew,$adv) = @_;
my($init) = &Init();
my($line,$i,@RANKING,$flow_flag,$file_handle1,$max_view,%data,@renew_line);

# CSS定義
$main::css_text .= qq(
div.comment{width:20em;word-break:break-all;}
);

	# 処理タイプを定義
	if($use->{'TypeGetIndex'}){
			if($use->{'MaxViewIndex'}){ $max_view = $use->{'MaxViewIndex'}; }
			else{ $max_view = 100; }
	}
	elsif($use->{'TypeRenew'}){
	}
	elsif($use->{'TypeGetSelectOption'}){
	}
	# 処理タイプが指定されていない場合
	else{ die('Type is not decided'); }

	# ファイル定義 (ローカル)
	if(Mebius::alocal_judge()){
			if($use->{'FileType'} eq "Old"){
				$data{'file'} = "$init->{'adv_dir'}_log_adv/chara_alocal.log";
			}
			else{
				$data{'file'} = "$init->{'adv_dir'}_log_adv/character_alocal.log";
			}
	}
	# ファイル定義 (サーバー)
	else{
			if($use->{'FileType'} eq "Old"){
				$data{'file'} = "$init->{'adv_dir'}_log_adv/chara.log";
			}
			else{
				$data{'file'} = "$init->{'adv_dir'}_log_adv/character.log";
			}
	}

	# ファイルを開く
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file'}") || main::error("ファイルが存在しません。");
	}
	else{
		$data{'f'} = open($file_handle1,"+<$data{'file'}");

			# ファイルが存在しない場合は新規作成
			if(!$data{'f'}){
					if($use->{'TypeRenew'}){
						Mebius::Fileout("Allow-empty",$data{'file'});
						$data{'f'} = open($file_handle1,"+<$data{'file'}");
					}
					else{
						return(%data);
					}
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

# トップデータを分解
chomp($data{'top1'} = <$file_handle1>);
($data{'key'}) = split(/<>/,$data{'top1'});

	# ファイルを展開
	while(<$file_handle1>){

			# この行を分解
			chomp;
			my($key,$id2,$name,$level,$jobname,$hp,$maxhp,$gold,$comment,$lasttime,$host2,$number,$account,$itemname) = split(/<>/);

				# 配列に追加
				if($use->{'TypeGetIndex'}){ push(@RANKING,$_); }

				# セレクトを取得
				if($use->{'TypeGetSelectOption'}){
					my($selected2,$class1,$viewhp,$viewgold);
						if($use->{'TargetJobName'}){
								if(index($use->{'TargetJobName'},$jobname) < 0){ next; }
						}
						if($use->{'TypeViewHP'}){
							my($hp_comma,$maxhp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$hp,$maxhp]);
							$viewhp = qq( HP $hp_comma / $maxhp_comma );
						}
						if($use->{'TypeViewGold'}){
							my($gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$gold]);
							$viewgold = qq( 所持金 $gold_comma\G );
						}
						if($lasttime+$init->{'charaon_day'}*24*60*60 < time){ next; }
						if($use->{'TypeJudgeLevel'} && $adv->{'maxhp'} > $maxhp*$init->{'special_battle_gyap'}){
							$class1 = qq( class="disable");
							next;
						}
						if($id2 eq $adv->{'last_select_special_id'}){ $selected2 = $main::selected; }
					$data{'select_option_line'} .= qq(<option value="$id2"$class1$selected2>$name ( Lv.$level $jobname )$viewhp$viewgold</option>\n);
				}

				# 更新用
				if($use->{'TypeRenew'}){

						# 一定時間以上ログインしていないキャラ行は削除
						if($lasttime && time > $lasttime + $init->{'reset_limit'}*24*60*60){ next; }
						
						# 自分の場合
						if($id2 eq $adv->{'id'}){ next; }

					# 行を追加
					push(@renew_line,"$key<>$id2<>$name<>$level<>$jobname<>$hp<>$maxhp<>$gold<>$comment<>$lasttime<>$host2<>$number<>$account<>$itemname<>\n");

				}
	}


	# 新しい行
	if($use->{'TypeNewStatus'}){
	unshift(@renew_line,"1<>$adv->{'id'}<>$adv->{'name'}<>$adv->{'level'}<>$adv->{'jobname'}<>$adv->{'hp'}<>$adv->{'maxhp'}<>$adv->{'gold'}<>$adv->{'comment'}<>$adv->{'lasttime'}<><>$adv->{'number'}<>$adv->{'id'}<>$adv->{'item_name'}<>\n");
	}

	# ファイル更新
	if($use->{'TypeRenew'}){

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;
	}

# ファイルを閉じる
close($file_handle1);

	# パーミッション変更
	if($use->{'TypeRenew'}){ Mebius::Chmod(undef,$data{'file'}); }

	# インデックスの並び替え
	if($use->{'TypeGetIndex'}){
			if($use->{'Sort'} eq "login"){ @RANKING = sort { (split(/<>/,$b))[9] <=> (split(/<>/,$a))[9] } @RANKING; }
			elsif($use->{'Sort'} eq "name"){ @RANKING = sort { (split(/<>/,$a))[2] cmp (split(/<>/,$b))[2] } @RANKING; }
			elsif($use->{'Sort'} eq "gold"){ @RANKING = sort { (split(/<>/,$b))[7] <=> (split(/<>/,$a))[7] } @RANKING; }
			elsif($use->{'Sort'} eq "maxhp"){ @RANKING = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @RANKING; }
			elsif($use->{'Sort'} eq "level_low"){ @RANKING = sort { (split(/<>/,$a))[3] <=> (split(/<>/,$b))[3] } @RANKING; }
			else{ @RANKING = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @RANKING; }

		# 整形
		$line .= qq(<table class="adventure"><tr><th>順位</th><th>レベル</th><th>名前</th><th>職業</th><th>HP</th>);
			if($use->{'Sort'} eq "gold"){ $line .= qq(<th>ゴールド</th>); }
		$line .= qq(<th>コメント</th><th>SNS</th></tr>);

	}

	# ファイル内容を再展開
	if($use->{'TypeGetIndex'}){

		# 局所化
		my($i,$hit);

			# 配列を展開
			foreach(@RANKING){

				# カウンタ
				$i++;
	
				# この行を展開
				chomp;
				my($key,$id2,$name,$level,$jobname,$hp,$maxhp,$gold,$comment,$lasttime,$host2,$number,$account,$itemname) = split(/<>/);
				my($view_itemname,$class1,$mark1);

					# エスケープ処理
					if($id2 eq ""){ next; }

					# 職業で絞り込み
					if($use->{'SelectJobName'}){
						if($use->{'SelectJobName'} ne $jobname){ next; }
					}

				# カンマを付ける
				my($hp_comma,$maxhp_comma,$gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$hp,$maxhp,$gold]);

					#if($lasttime+$init->{'charaon_day'}*24*60*60 < $main::time){ $class1 = qq( class="disable"); }
					#elsif($adv->{'login_flag'} && $adv->{'maxhp'} < $maxhp*$init->{'select_battle_gyap'}){ $mark1 = qq( <span class="alert">( 戦 )</span> ); }
					#if($main::myadmin_flag >= 5){ $view_itemname = qq(<br>武器： $itemname); }

					# 最大表示行数に達した場合
					if($hit > $max_view) { $flow_flag = 1; last; }

				$hit++;
				#$rdate = $lasttime + (60*60*24*$init->{'reset_limit'});

				$line .= qq(<tr$class1>\n);
				$line .= qq(<td>$i</td>\n);
				$line .= qq(<td>$level</td>\n);

					# ステータスへのリンク
					# 旧データ
					if($use->{'TypeOldFile'}){
						$line .= qq(<td><a href="$init->{'script'}?mode=chara&amp;chara_id=$id2">$name</a> );
					}
					# 新データ
					else{
						$line .= qq(<td><a href="$init->{'script'}?mode=status&amp;id=$id2">$name</a> );
					}

					if($main::myaccount{'admin'}){ $line .= qq( - $id2); }
				$line .= qq($mark1</td>\n);

				$line .= qq(<td>$jobname</td><td class="hpcolor">$hp_comma / $maxhp_comma</td>\n);
						if($use->{'Sort'} eq "gold"){ $line .= qq(<td class="goldcolor">$gold_comma G</td>); }
				$line .= qq(<td><div class="comment">$comment$view_itemname</div></td>\n);
					if($account){ $account = qq(<a href="${main::auth_url}$account/">$account</a>); }
				$line .= qq(<td>$account</td>);
				$line .= qq(</tr>\n);

			}

		# 整形
		$line .= qq(</table>);

	}

return($line,$data{'select_option_line'},$flow_flag);

}



1;
