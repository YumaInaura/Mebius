
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# 戦況記録ファイル
#-----------------------------------------------------------
sub SituationFile{

# 宣言
my($init) = &Init();
my($use,$select_renew) = @_;
my($i,@renew_line,%data,$file_handle1,%renew,$renew,$max_view_index);

# ファイル定義
#my($web_data_directory) = Mebius::BaseInitDirectory();
$data{'directory1'} = "$init->{'adv_dir'}_log_adv/";
$data{'file1'} = "$data{'directory1'}situation.log";

# 最大行を定義
my $max_line = 100;

	# 最大表示行数
	if($use->{'MaxViewIndex'}){
		$max_view_index = $use->{'MaxViewIndex'};
	}
	else{
		$max_view_index = 5;
	}

	# ファイルを開く
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file1'}") || main::error("ファイルが存在しません。");
	}
	else{

		$data{'f'} = open($file_handle1,"+<$data{'file1'}");

			# ファイルが存在しない場合
			if(!$data{'f'}){
					# 新規作成
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$data{'directory1'});
						Mebius::Fileout("Allow-empty",$data{'file1'});
						$data{'f'} = open($file_handle1,"+<$data{'file1'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

	# トップデータを展開
	for(1..1){
		chomp($data{"top$_"} = <$file_handle1>);
	}

# トップデータを分解
($data{'key'}) = split(/<>/,$data{'top1'});

	# 更新用に内容を記憶
	if($use->{'TypeRenew'}){ %renew = %data; }

	# ファイルを展開
	while(<$file_handle1>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($comment1,$comment2,$date2,$lasttime) = split(/<>/);

			# 更新用
			if($use->{'TypeRenew'}){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$comment1<>$comment2<>$date2<>$lasttime<>\n");

			}

			# インデックス取得用
			if($use->{'TypeGetIndex'}){

				my($how_before) = Mebius::SplitTime("Color-view Plus-text-前 Get-top-unit",time - $lasttime);
				$data{'index_line'} .= qq(<tr><td class="noborder2">$comment1</td><td>$comment2</td><td class="right">$how_before</td></tr>);
					if($i >= $max_view_index){ last; }

			}

	}

	# ファイル更新
	if($use->{'TypeRenew'}){

			# 新しい行を追加
			if($use->{'TypeNewLine'}){
				my $time = time;
				my($date) = Mebius::Getdate(undef,time);
				unshift(@renew_line,"$use->{'NewComment1'}<>$use->{'NewComment2'}<>$date<>$time<>\n");
			}

			# 任意の更新とリファレンス化
			($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# トップデータを追加
		unshift(@renew_line,"$renew->{'key'}<>\n");

		# ファイル更新
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}


close($file_handle1);

	# パーミッション変更
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file1'});
	}

	# インデックス整形
	if($use->{'TypeGetIndex'}){
			if($data{'index_line'}){
				$data{'index_line'} = qq(<table class="situation">$data{'index_line'}</table>);
			}
	}

	# リターン
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}



#-----------------------------------------------------------
# 全戦況ページ
#-----------------------------------------------------------
sub ViewSituation{

# 局所化
my($init) = Init();
my($init_login) = init_login();
my($line,$form,$selects);


my($situation) = SituationFile({ TypeGetIndex => 1 , MaxViewIndex => 50 });

$main::sub_title = "戦況 | $main::title";

my $print .= qq(<h1>戦況</h1>);
$print .= qq($init_login->{'link_line'});
$print .= qq(
<h2 id="FIGHT">全キャラの戦況</h2>
$situation->{'index_line'}
);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => ["戦況"] },$print);

exit;

}

1;
