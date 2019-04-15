
use strict;
use Mebius::RegistCheck;
package Mebius::Echeck;

#-----------------------------------------------------------
# このパッケージの基本設定
#-----------------------------------------------------------
sub init{

# 設定内容を渡す
return(
"index.cgi",
"${main::int_dir}_echeck/"
);

}

#-----------------------------------------------------------
# 全投稿チェック
#-----------------------------------------------------------
sub Start{

# 宣言
my($type,%in) = @_;

# モード振り分け

	# コメント登録
	if($in{'type'} eq "put_comment"){
		&Datafile("Renew Html Backup",$in{'select'},$in{'file'},$in{'comment'},$in{'handle'},undef,$in{'bbsmode'},$in{'subject'});
	}

	# ファイルのレス削除
	elsif($in{'type'} eq "delete_comment"){
		&Datafile("Delete Html",$in{'select'},$in{'file'},$in{'delete_time'},$in{'delete_num'});
	}

	# ファイルの削除
	elsif($in{'type'} eq "delete_file"){
		&Datafile("Alldelete Html",$in{'select'},$in{'file'});
	}

	# スレッド１個を表示
	elsif($in{'type'} eq "thread"){
		&Index("From-BBS-thread",$in{'select'},$in{'file'});
	}

	# インデックスを表示
	else{
		&Index("Index",$in{'select'},$in{'file'});
	}

}

#-----------------------------------------------------------
# ユーザーのエラー/アラート文章を記録
#-----------------------------------------------------------
sub Record{

# 宣言
my($type,$echeck_type,$comment) = @_;
my($line,$echeck_com,$file,$filehandle1,$directory,$file2,$url,$select,$file);
my($script,$directory) = &init();

# 汚染チェック
$echeck_type =~ s/[^\w-]//g;
if($echeck_type eq ""){ return; }
if($main::secret_mode){ return; }
if($main::mode eq "allregistcheck"){ return; } # チェック時にもエラーを記録してしまうことを回避

# ディレクトリ定義
if(${main::todayf}){ $select = $main::todayf; } else { return(); }

# ディレクトリを作成
Mebius::Mkdir("","$directory${select}_echeck");

	# 記録するＵＲＬを定義
	if($main::in{'res'}){
		$url = qq(http://$main::server_domain/jak/$main::realmoto.cgi?mode=view&no=$main::in{'res'}#S$main::in{'resnum'});
	}
	elsif($main::in{'mode'} eq "regist"){
		$url = qq(http://$main::server_domain/jak/$main::realmoto.cgi?mode=view&no=#S0);
	}
	elsif($main::in{'mode'} eq "comment"){
		$url = qq(${main::auth_url}$main::in{'account'}/viewcomment);
	}
	elsif($main::in{'mode'} eq "editprof"){
		$url = qq(${main::auth_url}$main::in{'account'}/);
	}
	elsif($main::in{'account'}){
		$url = qq(${main::auth_url}$main::in{'account'}/d-$main::in{'num'});
	}
	elsif($main::in{'mode'} eq "fdiary"){
		$url = qq(${main::auth_url}$main::pmfile/#DIARY);
	}
	else{
		$url = $main::postbuf;
	}

# ログファイルを書き込み(今日)
&Datafile("Renew FromBBS",$select,$echeck_type,$comment,"$main::in{'name'}",$url);

	# ログファイルを書き込み（全体）
	if(!$main::alocal_mode){
		&Datafile("Renew FromBBS",undef,$echeck_type,$comment,"$main::in{'name'}",$url);
	}

# リターン
return(1);

}

#-----------------------------------------------------------
# 全投稿判定 インデックス
#-----------------------------------------------------------
sub Index{

# 宣言
my($type,$select,$file) = @_;
my($script,$directory) = &init();
my($filehandle1,$file_selects,$line,$line2,$select_directory,$file_split,$menu_line);
my($i,$page_list,$dirhandle1,@filelist1,@filelist2);
my($open_directory,@dirlist1,$dirlist_links,$echeck_date_directory,$domain_links);
my($submit_form,$submit_form_disabled,@filelist_last);

# 開くディレクトリを定義
#if($select_directory eq "today"){ $select_directory = "_${main::todayf}_echeck"; }
$select =~ s/\W//g;
if($select){ $select_directory = qq(${select}_echeck/); }
$open_directory = "$directory$select_directory";

	# ファイル一覧を取得 ( .log 拡張子 )
	opendir($dirhandle1,$open_directory);
	@filelist1 = grep(/^([a-zA-Z0-9_\-]+)\.log/,readdir($dirhandle1));
	close $dirhandle1;
	@filelist1 = sort {$a cmp $b} @filelist1;

	# ファイル一覧を取得 ( .cgi 拡張子 )
	opendir($dirhandle1,$open_directory);
	@filelist2 = grep(/^([0-9]+)\.cgi/,readdir($dirhandle1));
	close $dirhandle1;
	push(@filelist1,@filelist2);

	# ディレクトリ一覧を取得
	opendir($dirhandle1,"${main::int_dir}_echeck");
	@dirlist1 = grep(/^([0-9]+)([\w]+)$/,readdir($dirhandle1));
	close $dirhandle1;

	# ディレクトリ一覧を展開
		if($select){ $dirlist_links .= qq(<a href="?mode=allregistcheck">基本</a> ); }
		else{ $dirlist_links .= qq(基本 ); }

	# 日付をソート
	@dirlist1 = sort @dirlist1;
	foreach $_ (@dirlist1){
			my($select2) = split(/_/,$_);
			my($style1) = qq( style="color:#f00";) if($select2 eq $main::todayf);
				if($select2 eq $select){ $dirlist_links .= qq(<span$style1>$select2日</span> ); }
				else{ $dirlist_links .= qq(<a href="?mode=allregistcheck&amp;select=$select2"$style1>$select2日</a> ); }
		}

	
	# リストを展開
	foreach $file_split (@filelist1){

		# 局所化
		my($filehandle1,$top_file1,$style_page_list);

		# 各ファイルのTOPデータを取得
		open($filehandle1,"<$open_directory$file_split");
		chomp($top_file1 = <$filehandle1>);
		my(undef,undef,undef,$tres) = split(/<>/,$top_file1);
		close($filehandle1);

		# 色を定義
		my($style_page_list);
			if($file_split =~ /error/i){ $style_page_list = qq( style="color:#f00"); }
			elsif($file_split =~ /alert/i){ $style_page_list = qq( style="color:#080"); }
			elsif($file_split =~ /hidden/i){ $style_page_list = qq( style="color:#555"); }
			elsif($file_split =~ /\.cgi$/){ $style_page_list = qq( style="color:#080";); }

		# ファイル名と拡張子を分解
		my($filename,$tail) = split(/\./,$file_split);
		my($filename,$tail2) = split(/_/,$filename);
	
		# ファイルの最終更新時刻を取得	
		my $lastmodified = (stat $file_split)[9];

		# さらに配列に追加
		push(@filelist_last,"$filename<>$tail<>$tres<>$style_page_list<>\n");


	}

	# 最終展開
	foreach(@filelist_last){

		chomp;
		my($filename,$tail,$tres,$style_page_list) = split(/<>/,$_);

			# ファイル一覧、ページ切り替えリンクを定義
			if($filename eq $file){ $page_list .= qq(<span$style_page_list>$filename</span>($tres) ); }
			else{ $page_list .= qq(<a href="?mode=allregistcheck&amp;file=$filename&amp;select=$select"$style_page_list>$filename</a>($tres) ); }

			# セレクトボックスを定義
			if($tail=~ /log$/){
				my($file_selects_selected);
				if($filename eq $file){ $file_selects_selected = $main::parts{'selected'}; }
				$file_selects .= qq(<option value="$filename"$file_selects_selected>$filename</option>\n);
			}
	}

# スレッドを開く
my($line) = &Datafile("Index $type",$select,$file);

# セレクトボックスの整形
$file_selects = qq(
<select name="file">
<option value="">なし</option>
$file_selects</select>
);

	# 変換行の整形
	if($line2){
		$line2 =~ s/</&lt;/g;
		$line2 =~ s/>/&gt;/g;
		$line2 =~ s/\n/<br>/g;
		$line2 = qq(<hr>&lt;&gt;&lt;&gt;&lt;&gt;$i&lt;&gt;<br>$line2<hr>);
	}

# ドメインリンクを取得
($domain_links) = Mebius::Domainlinks("And-localhost Admin-mode","$main::server_domain","$main::jak_url$script?$main::postbuf");
if($main::server_domain eq "localhost"){ $domain_links .= qq( - localhost-index ); }
else{ $domain_links .= qq( - <a href="http://localhost/jak/index.cgi?mode=allregistcheck">localhost-index </a>); }

# メニューを定義
$menu_line = qq(
<div style="font-size:100%;line-height:1.2;word-spacing:0.5em;margin:1em 0em;">
ドメイン： $domain_links
</div>

<div style="font-size:100%;line-height:1.2;word-spacing:0.5em;margin:1em 0em;">
ディレクトリ： $dirlist_links
</div>

<div style="font-size:100%;line-height:1.2;word-spacing:0.5em;">
ファイル： $page_list
</div>
);

# フォームを disabled にする場合
if($select){ $submit_form_disabled = $main::disabled; }

# フォームを定義
$submit_form = qq(
<h2>フォーム</h2>
<form action="$script" method="post">
筆名 <input type="text" name="handle" value=""$submit_form_disabled><br>
題名 <input type="text" name="subject" value=""$submit_form_disabled><br>
<textarea name="comment" style="width:50%;height:75px;"$submit_form_disabled></textarea>
<br>
ファイルタイプ：
$file_selects
　
カテゴリ： <input type="text" name="category" value="" style="width:5em;">
<input type="checkbox" name="bbsmode" value="sousaku"> 創作モード
<input type="hidden" name="type" value="put_comment">
<input type="hidden" name="mode" value="allregistcheck">
　
<input type="submit" name="comment_type" value="”悪”として登録" style="background:#fcc;"$submit_form_disabled>
<input type="submit" name="comment_type" value="”良”として登録" style="background:#ccf;"$submit_form_disabled>
</form>
);


# HTML
print "Content-type:text/html\n\n";

print qq(<html lang="ja">
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
<head>
<style type="text/css">
<!--
table{font-size:100%;margin:1em 0em 0em 0em;border:solid 1px #555;padding:0.5em 1em;color:#333;}
body{margin:1em 1em;}
h3{font-size:160%;padding:0.15em 0.3em;background:#fd0;}
td.flag{width:25em;text-align:center;}
td.data{padding:0em 0.5em;}
td{vertical-align:top;}
.red{color:#f00;}
.green{color:#080;}
li{line-height:1.4;}
td.flag{text-align:left;padding-left:2em;}
-->
</style>
<title>一斉判定 | $main::server_domain</title>
</head>);


print qq(
<body>
<h1 id="TOP">一斉判定 - $main::server_domain</h1>
$submit_form
<h2>リスト</h2>
$menu_line
$line2

$line
<h3>メニュー</h3>
$menu_line
$submit_form
</body>);

exit;

}


#-----------------------------------------------------------
# スレッドを開く
#-----------------------------------------------------------
sub Datafile{

# 宣言
my($type,$select,$file) = @_;
my($script,$directory) = &init();
my(undef,undef,undef,$newcomment,$newhandle,$newurl,$newbbsmode,$new_subject) = @_ if($type =~ /Renew/);
my(undef,undef,undef,$delete_time,$delete_num) = @_ if($type =~ /Delete/);
($newcomment) = qq($main::in{'comment'}) if($main::in{'comment'} && $newcomment eq "");
if($main::in{'sub'}){ $new_subject = $main::in{'sub'}; }
my($filename,$tail) = split(/\./,$file);
my($line,$line2,$i,$filehandle1,$error_num,$alert_num,$allow_num,$allallow_num,$select_directory,$allow_justhit_num,$error_justhit_num,$alert_justhit_num);
my($error_type_num,$allow_type_num,@renewline,$datafile,$datafile_backup,$newline);
my($new_comment_type,$newline,$lastmodified,@error_number_list,@alert_number_list,$newkey,$newcategory,$before_roupe_host2,$before_roupe_agent2,$hit);
my(@not_error_number,@not_allow_number);

# 権限チェック
if($type =~ /(Delete|Alldelete)/ && $main::admy_rank < $main::master_rank){ main::error("実行権限がありません。"); }

# ファイル定義
$select =~ s/\W//g;
if($select){ $select_directory = qq(${select}_echeck/); }
$file =~ s/[^a-zA-Z0-9_\-]//g;
if($file eq ""){ return(); }

$datafile = qq($directory$select_directory${file}_echeck\.log);

	# バックアップファイルを定義
	if($type =~ /Backup/){
		$datafile_backup = qq(${directory}_backup_echeck/${file}_echeck\.bk);
		Mebius::Mkdir("","${directory}_backup_echeck/");
	}

	# 掲示板からの登録の場合、記録するモードを定義
	if($type =~ /FromBBS/ && $type =~ /Renew/){
		if($main::bbs{'concept'} =~ /Sousaku-mode/){ $newbbsmode .= qq( sousaku); }
	}

	# 掲示板の記事から開く場合
	if($type =~ /From-BBS-thread/){
		$file =~ s/\D//g;
		my($thread) = Mebius::BBS::thread_state($file,$select);
		$datafile = $thread->{'file'};
			if(!-f $datafile){ main::error("ファイルが開けません。"); }
	}

	# .log ファイルが存在しない場合、.cgi ファイルを開く
	if(!-e $datafile && $file =~ /^([0-9]+)$/){
		$datafile = qq($directory$select_directory${file}\.cgi);
			if($type =~ /(Renew|Delete|Alldelete)/){ main::error("このファイルは変更できません。"); }
			if($main::admy_rank < $main::master_rank){ main::error("閲覧権限がありません。"); }
	}

	# ファイル１個を削除する場合
	if($type =~ /Alldelete/){
		unlink($datafile);
			if($type =~ /Html/){ &Index("",$select,$file); } # 無限ループに注意！
			else{ return(1); }
	}

	# ファイルの最終更新時刻を取得
	$lastmodified = (stat $datafile)[9];

	# ファイル更新の場合、古いファイル（先月のファイル）は削除
	if($type =~ /FromBBS/ && $type =~ /Renew/){
		if($main::time > $lastmodified + 3*24*24*60){ unlink($datafile); }
	}

	# ファイルを開く
	open($filehandle1,$datafile);

	# トップデータを分解
	my $top1 = <$filehandle1>; chomp $top1;
	my(undef,undef,undef,$tres) = split(/<>/,$top1);

		if(-f $datafile && $tres eq ""){ close($filehandle1); return(); }

		# ファイルを展開
		while(<$filehandle1>){

		# 局所化
		my($error_flag,$alert_flag,$style1,$style2,$h4,$style_all,$plustype_bbsmode);

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
	my($num2,$number2,$handle2,$enctrip2,$comment2,$date2,$host2,$encid2,$color2,$agent2,$user2,$deleted2,$account2,$comment_type2,$key2,$time2,$url2,$bbsmode2,$category2,$subject2) = split(/<>/);

		# コメントの全長を取得
		my $comment_length2 = Mebius::GetLength(undef,$comment2);
			
			# 掲示板の記事から開いた場合は、互換性のないデータを無効にする
			if($type =~ /From-BBS-thread/){
				($comment_type2,$key2,$time2,$url2,$bbsmode2,$category2,$subject2) = undef;
			}

				# ○ファイル更新の場合
				if($type =~ /(Renew|Delete)/){
		
					# 最大行数	
					if($type =~ /FromBBS/ && $i >= 200){ next; }
				
					# 削除処理
					if($type =~ /Delete/ && $time2 && $time2 eq $delete_time){ next; }
					if($type =~ /Delete/ && $num2 ne "" && !$time2 &&  $num2 eq $delete_num){ next; }

				# 更新行を追加
	push(@renewline,"$num2<>$number2<>$handle2<>$enctrip2<>$comment2<>$date2<>$host2<>$encid2<>$color2<>$agent2<>$user2<>$deleted2<>$account2<>$comment_type2<>$key2<>$time2<>$url2<>$bbsmode2<>$category2<>\n");

					next;

				}

			# ○インデックス取得の場合
			if($type =~ /Index/){

					# 各種モードを定義
					if($type !~ /FromBBS/){
							if($bbsmode2 =~ /sousaku/){ $plustype_bbsmode .= qq( Sousaku); }
					}

					# キーが無い場合は回避
					if($key2 eq "0"){ next; }

					# 海外ホストの場合
					if(!$main::in{'all_view'} && (($host2 && $host2 !~ /(^localhost$)|(\.(jp|net)$)/) && (($comment2 =~ s/ttp/$&/g) >= 3)) && !$main::alocal_mode){
						$line .= qq($h4<div>省略</div>);
						next;
					}

				# ヒットカウンタ
				$hit++;

				# 基本変換
					if($main::alocal_mode){
						($comment2) = main::base_change($comment2,"Local-test");
						($handle2) = main::base_change($handle2,"Local-test");
					}


				# 題名を判定
				my(undef,$error_flag_subject) = main::subject_check(undef,$subject2);
				# 題名を判定（掲示板用）
				my($error_flag_subject_bbs,$alert_flag_subject_bbs) = Mebius::Regist::SubjectCheckBBS(undef,$subject2);

				if($error_flag_subject){
					$subject2 = qq(<strong style="color:#f00;">$subject2</strong>);
					$error_flag = 1;
				}
				elsif($error_flag_subject_bbs){
					$subject2 = qq(<strong style="color:#f00;">$subject2 ($error_flag_subject_bbs)</strong>);
					$error_flag = 1;
				}
				elsif($alert_flag_subject_bbs){
					$subject2 = qq(<strong style="color:#080;">$subject2 ($alert_flag_subject_bbs)</strong>);
					$alert_flag = 1;
				}
				else{
					$subject2 = qq(<strong>$subject2</strong>);
				}

				# 性的内容の判定
				my($error_flag_sex,$alert_flag_sex,$sexnum,$sex_max) = Mebius::Regist::sex_check("Localtest$plustype_bbsmode Sjis-to-utf8",$comment2);
				if($error_flag_sex){ $sexnum = qq(<strong style="color:#f00;">$sexnum / $sex_max $error_flag_sex</strong>); $error_flag = 1; }
				if($alert_flag_sex){ $alert_flag_sex = qq(<strong style="color:#080;">$alert_flag_sex</strong>); $alert_flag = 1; }

				# マナー違反の判定
				my($error_flag_evil,$alert_flag_evil,$evil_data) = Mebius::Regist::EvilCheck("Localtest Check-mode $plustype_bbsmode",$comment2,$category2);
				if($error_flag_evil){ $error_flag = 1; }
				elsif($alert_flag_evil){ $alert_flag = 1; }

				# 雑談化チェック
				my($error_flag_convesation,$alert_flag_convesation) = Mebius::Regist::ConvesationCheck("Localtest Check-mode $plustype_bbsmode",$comment2,$category2); # if($main::in{'file'} =~ /convesation/i)
				if($error_flag_convesation){ $error_flag = 1; }
				elsif($alert_flag_convesation){ $alert_flag = 1; }

				# チェーン判定
				my($error_flag_chain) = Mebius::Regist::ChainCheck("Localtest$plustype_bbsmode",$comment2);
				if($error_flag_chain){ $error_flag_chain = qq(<strong style="color:#f00;">\($error_flag_chain\) </strong> ); $error_flag = 1; }

				# デコレーション判定
				my($error_flag_deco,$deconum,$decoper,$deco_max) = main::deco_check("Localtest$plustype_bbsmode",$comment2);
				if($error_flag_deco && $decoper >= $deco_max){ $decoper = qq(<strong style="color:#f00;">$decoper</strong>); $error_flag = 1; }
				if($error_flag_deco){ $error_flag_deco = qq(<strong style="color:#f00;">$error_flag_deco</strong>); $error_flag = 1; }

				# スペース判定
				my($error_flag_space,$spacenum,$space_max) = main::space_check("Localtest$plustype_bbsmode",$comment2);
				if($error_flag_space){
					$spacenum = qq(<strong style="color:#f00;">$spacenum</strong>);
					$error_flag_space = qq(<strong style="color:#f00;">$error_flag_space</strong>);
					$error_flag = 1;
				}

				# URL判定
				my($error_flag_url) = main::url_check("Localtest$plustype_bbsmode",$comment2);
				if($error_flag_url){
					$error_flag_url = qq(<strong style="color:#f00;">$error_flag_url</strong>);
					$error_flag = 1;
				}

				# 個人情報判定
				my($error_flag_private,$alert_flag_private) = Mebius::Regist::private_check("Localtest$plustype_bbsmode Sjis-to-utf8",$comment2);
				if($error_flag_private){ $alert_flag_private = qq(<strong style="color:#f00;">$error_flag_private</strong>); $error_flag = 1; }
				elsif($alert_flag_private){ $alert_flag_private = qq(<strong style="color:#080;">$alert_flag_private</strong>); $alert_flag = 1; }

				# 筆名判定
				my($error_flag_handle);
				if($handle2){
					($handle2,undef,$error_flag_handle) = Mebius::Regist::name_check($handle2);
					if($error_flag_handle){ $error_flag_handle = qq(<strong style="color:#f00;">$error_flag_handle</strong>); $error_flag = 1; }
				}

				# 投稿タイプ”悪”の場合
				if($comment_type2 eq "bad"){
					$h4 = qq(<h4 id="S$num2" style="background:#fbb;padding:0.5em;">悪 ( $num2 ) - $file</h4>);
					$style2 = qq( style="background:#fee;");
					$error_type_num++;
				}

				# 投稿タイプ”良”の場合
				elsif($comment_type2 eq "good"){
					$h4 = qq(<h4 id="S$num2" style="background:#bbf;padding:0.5em;">良 ( $num2 ) - $file</h4>);
					$style2 = qq( style="background:#eef;");
					$allow_type_num++;
				}

				# 投稿タイプ”普通”の場合
				else{
					$h4 = qq(<h4 id="S$num2" style="background:#9f9;padding:0.5em;">普通 ( $num2 ) - $file</h4>);

						# 前回の投稿からあまり時間がたっていない場合は色を変える
						if($type !~ /From-BBS-thread/ && $file !~ /delete/){
							my($next_flag);
								if($agent2 && $before_roupe_agent2 eq $agent2 || $host2 && $before_roupe_host2 eq $host2 || $key2 =~ /Redun/){
										if(!$main::in{'all_view'}){ $next_flag = 1; }
										else{ $style2 = qq( style="background:#ddd;font-size:80%;"); }
								}
							$before_roupe_host2 = $host2;
							$before_roupe_agent2 = $agent2;
								if($next_flag){ next; }
						}
				}
			
					# エラーがあれば文字色を変える
					if($error_flag){
						$style1 = qq( style="color:#f00;"); $error_num++;
						push(@error_number_list,qq(<a href="#S$num2">&gt;&gt;$num2</a>));
							if($comment_type2 eq "bad"){ $error_justhit_num++; }
					}
					elsif($alert_flag){
						$style1 = qq( style="color:#070;");
						$alert_num++;
						push(@alert_number_list,qq(<a href="#S$num2">&gt;&gt;$num2</a>));
							if($comment_type2 eq "bad"){ $alert_justhit_num++; }
					}
					else{
						$allow_num++;
						$allallow_num++;
							if($comment_type2 eq "good"){ $allow_justhit_num++; }
					}

					# うまく判定出来ていないレス番を記憶
					if($comment_type2 eq "bad" && !$error_flag && !$alert_flag){
						push(@not_error_number,qq(<a href="#S$num2">&gt;&gt;$num2</a>));
					}
					if($comment_type2 eq "good" && ($error_flag || $alert_flag)){
						push(@not_allow_number,qq(<a href="#S$num2">&gt;&gt;$num2</a>));
					}


				# 筆名など整形
				if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2</a>); }

				# 題名を整形
				if($subject2){ $subject2 = qq(<tr><td>題名</td><td class="data">$subject2</td><td class="flag"></td></tr>\n); }
				
				# 表示行を定義
				$line .= qq($h4
				<div$style_all>
				<div style="margin:1em;">
				<a href="$url2">$url2</a>　筆名： $handle2 　（ $date2 ）$agent2 $category2 	<strong style="color:#00f;">$bbsmode2</strong> </div>
				<div$style2><div$style1>$comment2</div>
				<table style="background:#ffc;">
				$subject2
				<tr><td>Data</td><td class="data">$comment_length2文字</td><td class="flag"></td></tr>
				<tr><td>Sex</td><td class="data">$sexnum</td><td class="flag">$error_flag_sex $alert_flag_sex</td></tr>
				<tr><td>Evil</td><td class="data">$evil_data</td><td class="flag">$error_flag_evil $alert_flag_evil</td></tr>
				<tr><td>Chain</td><td class="data">$error_flag_chain</td><td class="flag"></td></tr>
				<tr><td>Space</td><td class="data">$spacenum % / $space_max %</td><td class="flag">$error_flag_space</td></tr>
				<tr><td>Deco</td><td class="data">$decoper % / $deco_max %</td><td class="flag">$error_flag_deco</td></tr>
				<tr><td>Private</td><td></td><td class="flag">$alert_flag_private</td></tr>
				<tr><td>Convesation</td><td></td><td class="flag">$error_flag_convesation $alert_flag_convesation</td></tr>
				<tr><td>URL/Address</td><td></td><td class="flag">$error_flag_url</td></tr>
				<tr><td>Handle</td><td></td><td class="flag">$error_flag_handle</td></tr>
				</table>
				<div style="text-align:right;">
				<a href="?mode=allregistcheck&amp;file=$file&amp;time=$main::time#S$num2">更新</a>);
					if($datafile =~ /\.log$/){ $line .= qq(
				　<a href="?mode=allregistcheck&amp;type=delete_comment&amp;file=$file&amp;select=$select&amp;delete_time=$time2&amp;delete_num=$num2">削除</a>); }
				$line .= qq(
				　<a href="#TOP">▲</a>
				</div></div></div>
				);
			}

		}

		# ファイルを閉じる
		close($filehandle1);

	# ▼ファイルを更新する場合
	if($type =~ /(Renew|Delete)/){

			# コメントタイプを定義
			if($main::in{'comment_type'} =~ /悪/){ $new_comment_type = "bad"; }
			elsif($main::in{'comment_type'} =~ /良/){ $new_comment_type = "good"; }
			else{ $new_comment_type = "normal"; }

			# 記録するカテゴリを定義
			if($main::in{'category'}){ $newcategory = $main::in{'category'}; }
			elsif($main::category){ $newcategory = $main::category; }

		# 新しいキーを定義
		$newkey = 1;

		my($redun_flag) = main::redun("Echeck Not-error",60);
			if($redun_flag){ $newkey = "Redun"; }
			else{ $tres++; }

		# 新しく追加する行
		$newline = qq($tres<><>$newhandle<><>$newcomment<>$main::date<>$main::host<><><>$main::agent<><><>$main::pmfile<>$new_comment_type<>$newkey<>$main::time<>$newurl<>$newbbsmode<>$newcategory<>$new_subject<>\n);

			# 新しく追加する行 （行頭に追加）
			if($type =~ /Renew/ && $new_comment_type eq "bad"){ unshift(@renewline,$newline); }
			elsif($type =~ /Renew/ && $new_comment_type eq "good"){ push(@renewline,$newline); }
			elsif($type =~ /Renew/){ unshift(@renewline,$newline); }
	
			# トップデータを追加
			if($type =~ /(Renew|Delete)/){ unshift(@renewline,"<><><>$tres<>\n"); }

		# ファイルを更新
		Mebius::Fileout("Can-Zero",$datafile,@renewline);

			# バックアップを作成
			if($type =~ /Backup/ && $datafile_backup && rand(10) < 1){
				Mebius::Fileout("Allow-empty",$datafile_backup,@renewline);
			}

			# HTMLを表示、またはリターン
			if($type =~ /Html/){ &Index("",$select,$file); } # HTMLに戻る。無限ループに注意！
			else{ return(1); }

	}

	# 表示の整形
	if($type =~ /From-BBS-thread/){
			if(@error_number_list){ @error_number_list = qq(　( @error_number_list )); }
			if(@alert_number_list){ @alert_number_list = qq(　( @alert_number_list )); } else { @alert_number_list = undef; }
	}

# 調整計算
my $error_alert_justhit_num = $error_justhit_num + $alert_justhit_num;

# 表示行を整形する
my $return_line = qq(
<h3>$filename</h3>
<ul>
);

# 数値がカラの場合はゼロを代入
use Mebius::Text;
($alert_num,$error_num) = Mebius::IntNumber(undef,$alert_num,$error_num);

# 警告の集計

	# 掲示板の記事からの集計の場合
	if($type =~ /From-BBS-thread/){
		# 拒否
		$return_line .= qq(<li>\n);
		$return_line .= qq(拒否： \n);
		$return_line .= qq(<span style="color:#00f;">$error_num</span> / $hit);
		$return_line .= qq(　( @error_number_list )\n);
		$return_line .= qq(</li>\n);

		# 警告
		$return_line .= qq(<li>\n);
		$return_line .= qq(警告： \n);
		$return_line .= qq(<span style="color:#080;">$alert_num</span> / $hit);
		$return_line .= qq(　( @alert_number_list )\n);
		$return_line .= qq(</li>\n);


	}

	# 手動登録モードでの集計の場合
	else{
		$return_line .= qq(<li>\n);
		$return_line .= qq(制限： \n);
		$return_line .= qq(<span style="color:#080;">$alert_justhit_num</span>\n);
		$return_line .= qq( + <span style="color:#f00;">$error_justhit_num</span>\n);
		$return_line .= qq( = <strong style="color:#f50;">$error_alert_justhit_num</strong>);
		$return_line .= qq( / $error_type_num);
 		if(@not_error_number >= 1){ $return_line .= qq(<br$main::xclose> ( 未判定 @not_error_number )); }
		$return_line .= qq(</li>\n);
	}


# 許可の集計
$return_line .= qq(<li>\n);
$return_line .= qq(許可： );
	if($type =~ /From-BBS-thread/){
		$return_line .= qq(<span style="color:#00f;">$allallow_num</span> / $hit);
	}
	else{
		$return_line .= qq(<span style="color:#00f;">$allow_justhit_num</span>);
		$return_line .= qq( / $allow_type_num);
		$return_line .= qq( @not_allow_number);
	}
$return_line .= qq(</li>\n);


$return_line .= qq(<li>合計： $hit件</li>\n);


$return_line .= qq(</ul>);

$return_line .= qq(<div style="text-align:right;font-size:60%;">※このファイルを<a href="?mode=allregistcheck&amp;type=delete_file&amp;file=$file&amp;select=$select" style="color:#f00;">削除</a>する</div>\n);

$return_line .= qq($line);

# リターン
return($return_line);

}


1;
