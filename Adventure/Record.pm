
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 連勝記録ファイル
#-----------------------------------------------------------
sub Record{

# 宣言
my($type,$maxview,$newhandle,$newcount,$new_id) = @_;
my($init) = &Init();
my($filehandle_winner,$logfile,$index_line,$top1,$i,$renew_hitflag,@renew_line);
my($topwinner_handle,$topwinner_count,$do_renew_flag);

	# 汚染チェックとリターン
	if($type =~ /Renew/){
		$newcount =~ s/\D//g;
			if($newcount eq ""){ return(); }
			if($newhandle eq ""){ return(); }
	}

	# インデックスの最大取得行数を設定
	if(!$maxview){ $maxview = 10; }

# ファイル定義
$logfile = "$init->{'adv_dir'}_log_adv/winner_record.log";

# ファイルが無い場合は作る
if($type =~ /Renew/ && !-f $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# ●連勝記録ファイルを開く
open($filehandle_winner,"+<$logfile");

	# ファイルロック
	if($type =~ /Renew/){ flock($filehandle_winner,2); }

# トップデータを分解
$top1 = <$filehandle_winner>; chomp $top1;
($topwinner_handle,$topwinner_count) = split(/<>/,$top1);

	# 最高連勝記録をインデックスに追加
	$index_line .= qq(<li>$topwinner_handle ： $topwinner_count連勝 ( 最高記録 )</li>);

	# ファイルを展開する
	while(<$filehandle_winner>){
	
	# ループカウンタ
	$i++;

	# 各行を分解する
	chomp;
	my($handle2,$count2,$year2,$month2,$id2) = split(/<>/);

		# ○ファイルを更新する場合
		if($type =~ /Renew/){
				if($year2 eq $main::thisyear && $month2 eq $main::thismonth){
					$renew_hitflag = 1;
						if($newcount > $count2){
							$handle2 = $newhandle;
							$count2 = $newcount;
							$id2 = $new_id;
							$do_renew_flag = 1;
						}
				}
			push(@renew_line,"$handle2<>$count2<>$year2<>$month2<>$id2<>\n");
		}

		# ○インデックスを取得
		if($type =~ /Index/){
			my $id_link;
				if($id2){ $id_link = qq( ( <a href="$init->{'script'}?mode=status&amp;id=$id2">$id2</a> ) ); }
				if($i >= $maxview){ last; }
			$index_line .= qq(<li>$handle2 $id_link ： $count2連勝 ( $year2年$month2月 )</li>);
		}

		# ○１行を取得
		#if($type =~ /Oneline/){
		#	if($i >= $maxview){ last; }
		#$index_line .= qq($handle2 ： $count2連勝 ($year2年$month2月));
		#}

	}

	# ファイルを更新する場合、トップデータ、セカンドデータを追加
	if($type =~ /Renew/){

		# 今月のデータがない場合は、そのまま記録する
		if(!$renew_hitflag){
			unshift(@renew_line,"$newhandle<>$newcount<>$main::thisyear<>$main::thismonth<>$new_id<>\n");
			$do_renew_flag = 1;
		}
	
		# 最高の連勝記録が更新された場合
		if($newcount > $topwinner_count){
			$topwinner_count = $newcount;
			$topwinner_handle = $newhandle;
			$do_renew_flag = 1;
		}

	# トップデータを追加
	unshift(@renew_line,"$topwinner_handle<>$topwinner_count<>\n");

	}

	# ファイルを更新
	if($type =~ /Renew/ && $do_renew_flag){
		seek($filehandle_winner,0,0);
		truncate($filehandle_winner,tell($filehandle_winner));
		print $filehandle_winner @renew_line;
	}

# ファイルを閉じる
close($filehandle_winner);

	# パーミッションを変更
	if($type =~ /Renew/){ Mebius::Chmod(undef,$logfile); }

	# 各種リターン
	if($type =~ /Index/){
			if($index_line){ $index_line = qq(<ul>$index_line</ul>); }
		return($index_line);
	}

	# トップ連勝者をリターン
	if($type =~ /Topwinner/){ return($topwinner_handle,$topwinner_count); }
	
	# 更新した場合のリターン
	if($type =~ /Renew/){ return(1); }

}


#-----------------------------------------------------------
# 連勝記録のインデックス
#-----------------------------------------------------------
sub ViewRecord{

# 宣言
my($index_line);
my($init) = &Init();
my($init_login) = init_login();

# 連勝記録を取得
($index_line) = &Record("Index",200);


# HTML
my $print  =qq(
<h1>連勝記録</h1>
$init_login->{'link_line'}
<h2>リスト</h2>
$index_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


1;

