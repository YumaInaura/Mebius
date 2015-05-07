
use strict;
use Mebius::Directory;
use Mebius::State;
use Mebius::Roop;
use CGI;
package main;

#-----------------------------------------------------------
# グローバル変数化
#-----------------------------------------------------------
sub bbs_init_to_global{

my($use,$bbs) = @_;

# ●グローバル変数に代入(無条件で代入)
our($title,$head_title,$concept,$category,$style,undef,$rule_text,$textarea_first_input,$redcard) = 
	($bbs->{'title'},$bbs->{'head_title'},$bbs->{'concept'},$bbs->{'category'},$bbs->{'style'},undef,$bbs->{'rule_text'},$bbs->{'textarea_first_input'},$bbs->{'redcard'});
our(undef,undef,undef,$resedit_mode,$subtopic_link,$noindex_flag,$secret_mode,undef) = 
	(undef,undef,undef,$bbs->{'resedit_mode'},$bbs->{'subtopic_link'},$bbs->{'noindex_flag'},$bbs->{'secret_mode'});
our($past_num,$plus_bonus,$bbs_redirect,$another_idsalt) = 
	($bbs->{'past_num'},$bbs->{'plus_bonus'},$bbs->{'bbs_redirect'},$bbs->{'another_idsalt'});

	# メインパッケージのグローバル変数に代入（値が存在する場合にだけ代入）
	if($bbs->{'new_wait'} ne ""){ $main::new_wait = $bbs->{'new_wait'}; }
	if($bbs->{'norank_wait'} ne ""){ $main::norank_wait = $bbs->{'norank_wait'}; }
	if($bbs->{'i_max'} ne ""){ $main::i_max = $bbs->{'i_max'}; }
	if($bbs->{'m_max'} ne ""){ $main::m_max = $bbs->{'m_max'}; }
	if($bbs->{'home'} ne "" && !$main::admin_mode){ $main::home = $bbs->{'home'}; }
	if($bbs->{'max_msg'} ne ""){ $main::max_msg = $bbs->{'max_msg'}; }
	if($bbs->{'min_msg'} ne ""){ $main::min_msg = $bbs->{'min_msg'}; }

	# グローバル変数の調整

	# 新設定値を旧グローバル変数に調整
	if($bbs->{'concept'} =~ /Noads-mode/){
		$main::noads_mode = 1;
	}

}

package Mebius::BBS;

#-----------------------------------------------------------
# 会員制かどうかをジャッジ
#-----------------------------------------------------------
sub secret_judge{

my($moto) = @_;
my($flag);

my($query) = Mebius::query_state();
	if(!defined $moto){ $moto = $query->param('moto'); }

my($bbs) = Mebius::BBS::init_bbs_parmanent($moto);

	if($bbs->{'secret_mode'}){ $flag = 1; } 

$flag;

}

#-----------------------------------------------------------
# 掲示板設定を取得 ( オート )
#-----------------------------------------------------------
sub init_bbs_parmanent_auto{

my($self) = Mebius::BBS::init_bbs_parmanent({ Auto => 1 });

$self;

}


#-----------------------------------------------------------
# 掲示板設定を取得 ( メモリ常駐 )
#-----------------------------------------------------------
sub init_bbs_parmanent{

my $use = shift if(ref $_[0] eq "HASH");
my($realmoto) = @_;
my $bbs_object = Mebius::BBS->new();

	if($use->{'Auto'}){
		my($query) = Mebius::query_state();
		$realmoto = $bbs_object->true_bbs_kind();
	}

	if(!$realmoto){ return(); }

# State Parmanent （呼び出し） 2.30
my $HereName1 = "init_bbs_parmanent";
my $HereKey1 = $realmoto; # => 必ず掲示板毎にユニークなキーを指定すること、単一のキーだとすべての設定が同一になってしまう
my($state) = Mebius::State::call_parmanent(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

my($bbs) = Mebius::BBS::init_bbs(undef,$realmoto);

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	# State Parmanent （保存） 2.30
	if($HereName1){ Mebius::State::save_parmanent(__PACKAGE__,$HereName1,$HereKey1,$bbs); }

return($bbs);

}

#-----------------------------------------------------------
# 設定ファイルを読み込み
#-----------------------------------------------------------
sub init_bbs{

# 宣言
my($type,$realmoto) = @_;
my($basic_init) = Mebius::basic_init();
my $use = $type if(ref $_[0] eq "HASH");
my(undef,$select_file) = @_;
my(undef,undef,%renew) = @_ if($type =~ /Renew/);
my($filehandle1,$top1,$top2,$top3,$top4,$top5,$top6);
my($initfile,%bbs,@renewline);

	# 汚染チェック
	if($realmoto =~ /\W/ || $realmoto eq ""){ return(); }

# ファイル定義
my($bbs_file) = Mebius::BBS::InitFileName(undef,$realmoto);

# ハッシュ結合 ( %bbs を定義していなくても、どの位置でも処理しやすいように、ハッシュ結合の形を取る )
(%bbs) = (%bbs,%$bbs_file);

	#if($type =~ /Select-datafile/){ $bbs{'file'} = $select_file; }	# ローカル変換用

# 設定ファイルを読み込む
$bbs{'f'} = open($filehandle1,"<",$bbs{'file'}) && ($bbs{'alive'} = 1);
chomp(my $top1 = <$filehandle1>);
chomp(my $top2 = <$filehandle1>);
chomp(my $top3 = <$filehandle1>);
chomp(my $top4 = <$filehandle1>);
chomp(my $top5 = <$filehandle1>);
close($filehandle1);

# データを分解
($bbs{'title'},$bbs{'head_title'},$bbs{'concept'},$bbs{'category'},$bbs{'style'},$bbs{'setumei'},$bbs{'rule_text'},$bbs{'textarea_first_input'},$bbs{'redcard'}) = split(/<>/,$top1);
($bbs{'sousaku_mode'},$bbs{'noads_mode'},$bbs{'chat_mode'},$bbs{'resedit_mode'},$bbs{'subtopic_link'},$bbs{'noindex_flag'},$bbs{'secret_mode'},undef) = split(/<>/,$top2);
($bbs{'past_num'},$bbs{'plus_bonus'},$bbs{'bbs_redirect'},$bbs{'another_idsalt'},$bbs{'report_thread_number'},undef) = split(/<>/,$top3);
($bbs{'new_wait'},$bbs{'norank_wait'},$bbs{'i_max'},$bbs{'m_max'},$bbs{'max_msg'},$bbs{'min_msg'},$bbs{'home'}) = split(/<>/,$top4);
($bbs{'allow_thread_master_delete'}) = split(/<>/,$top5);

# 別名を定義
$bbs{'use_sub_thread'} = $bbs{'subtopic_link'};
$bbs{'kind'} = $bbs{'true_kind'} = $realmoto;

# ハッシュの調整
$bbs{'flag'} = 1;

	# 削除依頼記事へのリンク
	if($bbs{'report_thread_number'}){
		$bbs{'report_thread_href'} = qq($basic_init->{'report_bbs_url'}$bbs{'report_thread_number'}.html);
	}	else {
		my($init_category) = Mebius::BBS::init_category_parmanent($bbs{'category'});
		$bbs{'report_thread_href'} = qq($basic_init->{'report_bbs_url'}$init_category->{'report_number'}.html);
	}
	if(!$bbs{'report_thread_href'}){
		$bbs{'report_thread_href'} = qq($basic_init->{'report_bbs_url'});
	}

	# 処理タイプを展開
	foreach(split(/\s/,$bbs{'concept'})){
		$bbs{"concept->$_"} = 1;
	}

	# ●ファイル更新する場合
	if($type =~ /Renew/){

			foreach(keys %renew){
				$bbs{$_} = $renew{$_};
			}

		# 更新内容
		push(@renewline,"$bbs{'title'}<>$bbs{'head_title'}<>$bbs{'concept'}<>$bbs{'category'}<>$bbs{'style'}<>$bbs{'setumei'}<>$bbs{'rule_text'}<>$bbs{'textarea_first_input'}<>$bbs{'redcard'}<>\n");
		push(@renewline,"<><><>$bbs{'resedit_mode'}<>$bbs{'subtopic_link'}<>$bbs{'noindex_flag'}<>$bbs{'secret_mode'}<><>\n");
		push(@renewline,"$bbs{'past_num'}<>$bbs{'plus_bonus'}<>$bbs{'bbs_redirect'}<>$bbs{'another_idsalt'}<>$bbs{'report_thread_number'}<><>\n");
		push(@renewline,"$bbs{'new_wait'}<>$bbs{'norank_wait'}<>$bbs{'i_max'}<>$bbs{'m_max'}<>$bbs{'max_msg'}<>$bbs{'min_msg'}<>$bbs{'home'}<>\n");
		push(@renewline,"$bbs{'allow_thread_master_delete'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$bbs{'file'},@renewline);

	}

# ハッシュを返してリターン
return(\%bbs);

}


#-----------------------------------------------------------
# 全ての設定ファイルを扱う ( 未使用 => MOD_PERL の BEGIN ブロックで使いたい )
#-----------------------------------------------------------
sub init_bbs_all{

# ファイル定義
my($use) = @_;
my($directory_path) = Mebius::BBS::directory_path();
my($directory);

	# ディレクトリの扱い
	if($directory_path->{'init_bbs'}){ $directory = $directory_path->{'init_bbs'}; }
	else{ die("Perl Die! Can't get Directorty path."); }

# ディレクトリのすべてのファイルを取得
my(@directory) = Mebius::GetDirectory(undef,$directory);

	# すべてのファイルを展開
	foreach my $file_name (@directory){

			# ▼正常に設定ファイルである場合
			if($file_name =~ /^(\w+)\.ini$/){

					# 全ての設定ファイルを読み込んでメモリに常駐させる ( MOD_PERL 利用時 )
					if(exists $use->{'get_init_parmanent'}){
							Mebius::BBS::init_bbs_parmanent($1);
					}
			}

			# ▼設定ファイルとしての拡張子でない場合
			else{
				next;
			}
	}

}


#-----------------------------------------------------------
# bbs_kind から掲示板のカテゴリ設定を取得
#-----------------------------------------------------------
sub init_category_parmanent_from_bbs_kind{

my($bbs_kind) = @_;
my($self) = init_category_parmanent({ bbs_name_to_category_name => $bbs_kind });
$self;

}

#-----------------------------------------------------------
# 掲示板の種類から、カテゴリを抽出
#-----------------------------------------------------------
sub bbs_kind_to_category_kind{

my($bbs_kind) = @_;

	my($init_bbs) = Mebius::BBS::init_bbs_parmanent($bbs_kind);

$init_bbs->{'category'};

}

#-----------------------------------------------------------
# カテゴリ設定を読み込み ( MOD_PERL 環境下ではメモリ半常駐 )
#-----------------------------------------------------------
sub init_category_parmanent{

my($target_category_name) = @_;
my($use) = @_ if(ref $_[0] eq "HASH");

	#if(@_ >= 2){ die("Perl Die! Many value is setting"); }

	# 掲示板名からカテゴリ名を自動設定
	if($use->{'bbs_name_to_category_name'}){
		my($init_bbs) = Mebius::BBS::init_bbs_parmanent($use->{'bbs_name_to_category_name'});
		$target_category_name = $init_bbs->{'category'};
	}

	# 必須値のチェック
	if(!$target_category_name){ return(); }
	if($target_category_name =~ /\W/){ return(); }

# State Parmanent （呼び出し） 1.10
my $HereName1 = "init_category_parmanent";
my $HereKey1 = $target_category_name;
my($state) = Mebius::State::call_parmanent(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }

my($category) = Mebius::BBS::init_category($use,$target_category_name);

	# State Parmanent （保存） 1.10
	if($HereName1){ Mebius::State::save_parmanent(__PACKAGE__,$HereName1,$HereKey1,$category); }

return($category);

}

#-----------------------------------------------------------
# カテゴリ設定を読み込み
#-----------------------------------------------------------
sub init_category{

# 宣言
my($type,$category) = @_;
my $use = $type if(ref $type eq "HASH");
my($init_directory) = Mebius::BaseInitDirectory();
my(undef,undef,%renew) = @_ if($type =~ /Renew/);
my($filehandle1,%category,@renewline,$initfile,$init_bbs,$directory);

	# 必須値のチェック
	if($category eq ""){ return(); }
	if($category =~ /\W/){ return(); }

	# ファイル定義
my($directory_path) = Mebius::BBS::directory_path();
	if($directory_path->{'init_category'}){ $directory = $directory_path->{'init_category'}; }
	else{ die("Perl Die! Can't get Directorty path."); }
$initfile = "${directory}$category.ini";

# 設定ファイルを読み込む
open($filehandle1,"<",$initfile) || return({});
	if($type =~ /Renew/){ flock($filehandle1,1); }
chomp(my $top1 = <$filehandle1>);
close($filehandle1);

# データを分解
($category{'title'},$category{'report_number'},$category{'rule'},$category{'refer_bbs'},$category{'concept'}) = split(/<>/,$top1);
$category{'name'} = $category;

	# ファイルを更新
	if($type =~ /Renew/){
			foreach(keys %renew){
				$category{$_} = $renew{$_};
			}
		push(@renewline,"$category{'title'}<>$category{'report_number'}<>$category{'rule'}<>$category{'refer_bbs'}<>$category{'concept'}<>\n");
		Mebius::Fileout(undef,$initfile,@renewline);
	}

	# 調整
	if($init_bbs->{'delete_bbsno2'}){ $category{'report_number'} = $init_bbs->{'delete_bbsno2'}; }

# リターン
return(\%category);

}

#-----------------------------------------------------------
# 全ての設定ファイルを扱う ( 未使用 => MOD_PERL の BEGIN ブロックで使いたい )
#-----------------------------------------------------------
sub init_category_all{

# ファイル定義
my($use) = @_;
my($directory_path) = Mebius::BBS::directory_path();
my($directory);

	# ディレクトリの扱い
	if($directory_path->{'init_category'}){ $directory = $directory_path->{'init_category'}; }
	else{ die("Perl Die! Can't get Directorty path."); }

# ディレクトリのすべてのファイルを取得
my(@directory) = Mebius::GetDirectory(undef,$directory);

	# すべてのファイルを展開
	foreach my $file_name (@directory){

			# ▼正常に設定ファイルである場合
			if($file_name =~ /^(\w+)\.ini$/){

					# 全ての設定ファイルを読み込んでメモリに常駐させる ( MOD_PERL 利用時 )
					if(exists $use->{'get_init_parmanent'}){
							Mebius::BBS::init_category_parmanent($1);
					}

			}

			# ▼設定ファイルとしての拡張子がない場合は無視
			else{
				next;
			}
	}

}




#-----------------------------------------------------------
# 最大レス達成スレッドを記録する（掲示板毎）
#-----------------------------------------------------------
sub Maxres{

# 宣言
my($type,$bbs_kind,$thread) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($maxres_handler,$maxres_logfile,@renewline);
my $time = time;

	# ファイル定義
	{
		my($index_directory) = Mebius::BBS::index_directory_path_per_bbs($bbs_kind);
			if($index_directory){
				$maxres_logfile = "${index_directory}maxres_threads.log";
			} else {
				warn("Can't decide file.");
				return();
			}
	}

# ファイルを開く
open($maxres_handler,"<",$maxres_logfile);

# ファイルロック
if($type =~ /Renew/){ flock($maxres_handler,1); }

# トップデータ
chomp(my $top1 = <$maxres_handler>);
my($tkey,$tlasttime) = split(/<>/,$top1);

	# ファイルを展開
	while(<$maxres_handler>){
		chomp;
		my($postnumber2,$subject2,$res2,$poster2,$lasttime2,$laster2,$key2) = split(/<>/);
		if($postnumber2 eq $thread->{'postnumber'}){ next; }
		push(@renewline,"$postnumber2<>$subject2<>$res2<>$poster2<>$lasttime2<>$laster2<>$key2<>\n");
	}

close($maxres_handler);

	# ファイル更新
	if($type =~ /Renew/){

		# 新しく追加する行
	unshift(@renewline,"$thread->{'postnumber'}<>$thread->{'subject'}<>$thread->{'res'}<>$thread->{'posthandle'}<>$thread->{'lasttime'}<>$thread->{'lasthandle'}<>$thread->{'key'}<>\n");

		# レスが新しい順にソート
		@renewline = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @renewline;	# ソート

		# トップデータを追加
			if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline,"$tkey<>$time<>\n");
		
		# 更新
		Mebius::Fileout(undef,$maxres_logfile,@renewline);
	}


}


#-----------------------------------------------------------
# 現行ログのトップデータ
#-----------------------------------------------------------
sub NowFile{

# 宣言
my($type,$moto) = @_;
my(%nowfile,$index_handler);

# 汚染チェック
$moto =~ s/\W//g;
if($moto eq ""){ return; }

# 記事データを開く
open($index_handler,"<${main::int_dir}${moto}_idx.log") || return();

	# ファイルロック
	if($type =~ /Renew/){ flock($index_handler,1); }

# １行目データを分解
chomp(my $top1 = <$index_handler>);
($nowfile{'new_postnumber'},$nowfile{'new_posttime'},$nowfile{'last_restime'},$nowfile{'last_resed_postnumber'},$nowfile{'title'}) = split(/<>/,$top1);

close($index_handler);

return(%nowfile);


}



1;
