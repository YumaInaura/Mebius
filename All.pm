
use strict;
use Mebius::Basic;
use Mebius::Directory;
use File::Copy::Recursive qw(rcopy);

package Mebius::BBS;

#-----------------------------------------------------------
# 全ての掲示板
#-----------------------------------------------------------
sub AllBBS{

# 宣言
my($type) = @_;
my($directory_foreach,$line);

# 設定ディレクトリを定義
my $get_directory = "${main::int_dir}_init_bbs/";

# コピー元 / コピー先 ディレクトリ
#my @copy_directory = 
#(
#"${main::int_dir}<moto>_cnt->${main::int_dir}_bbs_data/_<moto>_bbs_data/->_crap_count_<moto>",
#"",
#"",
#""
#);

#"${main::int_dir}_thread_tag/<moto>_tag->${main::int_dir}_bbs_data/_<moto>_bbs_data/->_thread_tag_<moto>",

#../bsj/${moto}_log/
#../bsj/${moto}_cnt/
#../bsj/_sendmail/${moto}/
#../bsj/_kr/${moto}_kr/
#../bsj/_thread_tag/${moto}_tag/
#../bsj/${moto}_idx.log
#../bsj/${moto}_pst.log
#../bsj/_kr/$moto/
#../bsj/_handle/_${moto}_handle/
#../bsj/_bbs_index/_${moto}_index/ ( コピー )


# ディレクトリを取得
my(@directory) = Mebius::GetDirectory(undef,$get_directory);

	# ディレクトリを展開
	foreach $directory_foreach (@directory){

		# 局所化
		my($copy_foreach);

		# 拡張子とファイル名を分解
		my($moto2,$tail2) = split(/\./,$directory_foreach);

				# 処理を回避する場合
				if($tail2 ne "ini"){ next; }
				if($moto2 =~ /\W/){ next; }

			# 表示用
			$line .= qq(\n<br$main::xclose>$moto2);

				# ディレクトリ名を一斉変更する場合
				if($type =~ /Rename-directory/){

					# ディレクトリ作成 (基本)
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/");
					
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_pv_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_thread_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_kr_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_sendmail_${moto2}");
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_handle_${moto2}");


# ディレクトリ名を変更 (PV)
#{
#	my $from_directory = "${main::int_dir}_pv/_${moto2}_pv/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_pv_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ディレクトリ名を変更 (記事データの編集履歴)
#{
#	my $from_directory = "${main::int_dir}_thread_edit_history/_${moto2}_thread_edit/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_thread_edit_history_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ディレクトリ名を変更 (筆名ランキング)
#{
#	my $from_directory = "${main::int_dir}_handle/_bbs_ranking_handle/_${moto2}_ranking_handle/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_handle_ranking_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ディレクトリ名を変更 (記事タグ)
#{
#	my $from_directory = "${main::int_dir}_thread_tag/_${moto2}_tag/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_tag_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ディレクトリ名を変更 (お知らせメール)
#{
#	my $from_directory = "${main::int_dir}_sendmail/${moto2}/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_sendmail_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ディレクトリ名を変更 (関連記事)
#{
#	my $from_directory = "${main::int_dir}_kr/${moto2}/";
#	my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_kr_${moto2}/";
#		if(rename($from_directory,$to_directory)){
#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
#		}
#}

# ファイルコピー (過去ログインデックス)
#my $copy_from_file = "${main::int_dir}${moto2}_pst.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/${moto2}_pst.log";
#unlink($copy_to_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

# ファイルコピー (過去ログインデックス)
for(1..10){
	my $copy_from_file = "${main::int_dir}${moto2}_pst${_}.log";
	my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/${moto2}_pst${_}.log";
	unlink($copy_to_file);
	&File::Copy::copy($copy_from_file,$copy_to_file);
	chmod($main::logpms,$copy_to_file);
}

# ファイルコピー (掲示板インデックス)
#my $copy_from_file = "${main::int_dir}${moto2}_idx.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/index_${moto2}.log";
#unlink($copy_to_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

# ファイルコピー (PVランキングファイル)
#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}");
#my $copy_from_file = "${main::int_dir}_pv_ranking/${moto2}_pvall.log";
#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/pvall_${moto2}.log";
#my $unlink_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}/pvall_${moto2}.log";
#unlink($copy_to_file);
#unlink($unlink_file);
#&File::Copy::copy($copy_from_file,$copy_to_file);
#chmod($main::logpms,$copy_to_file);

					#rmdir("${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}");


						# コピー元/コピー先のディレクトリを定義
						#foreach $copy_foreach (@copy_directory){

							# 分割
							#my($from_directory,$to_directory1,$to_directory2) = split(/->/,$copy_foreach);

								# 調整
							#	$from_directory =~ s/<moto>/$moto2/g;
							#	$to_directory1 =~ s/<moto>/$moto2/g;
							#	$to_directory2 =~ s/<moto>/$moto2/g;
							#	my $to_directory_all = "$to_directory1$to_directory2";

								# ディレクトリ作成
							#	Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/");
							#	Mebius::Mkdir(undef,$to_directory1);
								#Mebius::Mkdir(undef,$to_directory_all);

								# ディレクトリ名を変更
							#	if(rename($from_directory,$to_directory_all)){
							#		$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory_all);
							#	}

								# ディレクトリ名を"復帰"
								#if(rename($to_directory_all,$from_directory)){
								#	$line .= qq(\n<br$main::xclose>rename $to_directory_all -&gt; $from_directory);
								#}

								#rename($to_directory_all,$from_directory);

								# ディレクトリを再帰的にコピー
								#if($from_directory && $to_directory){
								#	&File::Copy::Recursive::rcopy($from_directory, $to_directory_all);
								#	$line .= qq(\n<br$main::xclose>copy $from_directory -&gt; $to_directory);
								#}

						#}
				}

	}

print qq(Content-type:text/html\n\n$line);exit;

}



1;
