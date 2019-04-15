
package Mebius::BBS::All;
use strict;

use Mebius::Directory;
use Mebius::Basic;
use Mebius::Directory;
use Mebius::BBS::Res;
use Mebius::Crypt;

use File::Copy::Recursive qw(rcopy);



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub BEGIN{
our $all_insert_hit = undef;

}

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 全ての掲示板
#-----------------------------------------------------------
sub all_bbs_foreach{

# 宣言
my $self = shift;
my $type = shift;
my($directory_foreach,$line);
my($share_directory) = Mebius::share_directory_path();	
my($init_directory) = Mebius::BaseInitDirectory();

	#if(Mebius::allow_user_name_error("admin")){
	#	die Mebius::allow_user_name_error("admin");
	#}

# 設定ディレクトリを定義
my $get_directory = "${init_directory}_init_bbs/";


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

			my $thread_log_directory = "${share_directory}_bbs_data/_${moto2}_bbs_data/_thread_log/";

				if($type =~ /All-res-data-to-database/){
					$self->all_res_data_to_database($thread_log_directory,$moto2);
				}

			# 表示用
			#$line .= qq(\n<br$main::xclose>$moto2);

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

					# ディレクトリ名を変更 (過去ログインデックス)
					{
						my $from_directory = "${main::int_dir}_bbs_index/_${moto2}_index/";
						my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_past_index/";
							if(rename($from_directory,$to_directory)){
								$line .= qq(\n renamed $from_directory -&gt; $to_directory);
							}
					}

					# ディレクトリ名を変更 (記事メモ)
					{
						my $from_directory = "${main::int_dir}_bbs_memo_history/_${moto2}_memo_history/";
						my $to_directory = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_memo/";
							if(rename($from_directory,$to_directory)){
								$line .= qq(\n renamed $from_directory -&gt; $to_directory);
							}
					}

					# ファイルコピー (過去ログインデックス)
					{
						my $copy_from_file = "${main::int_dir}_maxres/${moto2}_maxres.log";
						my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/maxres_threads.log";
						unlink($copy_to_file);
						File::Copy::copy($copy_from_file,$copy_to_file);
						Mebius::Chmod(undef,$copy_to_file);
					}

					# ファイルコピー (削除済みインデックス)
					{
						my $copy_from_file = "${main::int_dir}_deleted/${moto2}_deleted.cgi";
						my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/deleted_threads.log";
						unlink($copy_to_file);
						File::Copy::copy($copy_from_file,$copy_to_file);
						Mebius::Chmod(undef,$copy_to_file);
					}

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

					# ディレクトリ名を変更 (記事ディレクトリ)
					#{
					#	my $from_directory = "${init_directory}${moto2}_log";
					#	my $to_directory = "${init_directory}_bbs_data/_${moto2}_bbs_data/_thread_log";
					#		if(rename($from_directory,$to_directory)){
					#			$line .= qq(\n<br$main::xclose>rename $from_directory -&gt; $to_directory);
					#		}
					#}

					# ディレクトリ名を変更 (サブ記事ディレクトリ)
					#{
					#	my $from_directory = "${init_directory}sub${moto2}_log";
					#	my $to_directory = "${init_directory}_bbs_data/_${moto2}_bbs_data/_sub_thread_log";
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
					#Mebius::Chmod(undef,$copy_to_file);

					# ファイルコピー (過去ログインデックス)
					#for(1..10){
					#	my $copy_from_file = "${main::int_dir}${moto2}_pst${_}.log";
					#	my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/${moto2}_pst${_}.log";
					#	unlink($copy_to_file);
					#	File::Copy::copy($copy_from_file,$copy_to_file);
					#	Mebius::Chmod(undef,$copy_to_file);
					#}

					# ファイルコピー (掲示板インデックス)
					#my $copy_from_file = "${main::int_dir}${moto2}_idx.log";
					#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_index_${moto2}/index_${moto2}.log";
					#unlink($copy_to_file);
					#&File::Copy::copy($copy_from_file,$copy_to_file);
					#Mebius::Chmod(undef,$copy_to_file);

					# ファイルコピー (PVランキングファイル)
					#Mebius::Mkdir(undef,"${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}");
					#my $copy_from_file = "${main::int_dir}_pv_ranking/${moto2}_pvall.log";
					#my $copy_to_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/pvall_${moto2}.log";
					#my $unlink_file = "${main::int_dir}_bbs_data/_${moto2}_bbs_data/_other_${moto2}/pvall_${moto2}.log";
					#unlink($copy_to_file);
					#unlink($unlink_file);
					#&File::Copy::copy($copy_from_file,$copy_to_file);
					#Mebius::Chmod(undef,$copy_to_file);

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

#print qq(Content-type:text/html\n\n$line);

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub all_res_data_to_database{

my $self = shift;
my $directory = shift || return();
my $bbs_kind = shift || return();
my $bbs_res = new Mebius::BBS::Res;
my $crypt = new Mebius::Crypt;
my(@insert,$hit,@insert);
our($all_insert_hit);

my @directory = Mebius::Directory::get_directory($directory);
my $max_round = 10;

	foreach my $file (@directory){

		$hit++;

			#if($hit > $max_round){ last; }
			#	if($hit < 50){ next; }

		my($hit_round);

		my($thread_number) = split(/\./,$file);
		my %thread =Mebius::BBS::thread({ GetAllLine => 1 },$bbs_kind,$thread_number);

			foreach my $key ( keys %thread  ){
				my $value = $thread{$key};
			#	print $value . "\n";
			}

			foreach my $data (@{$thread{'all_line_hash'}}){
				$hit_round++;
				my(%insert);
				my $target = $bbs_res->new_target();
				my %insert = (%{$data},( target => $target , bbs_kind => $bbs_kind , thread_number => $thread_number ));
				push @insert , \%insert;
				$all_insert_hit++;
			}

			if(@insert > 5000){
				$bbs_res->insert_main_table(\@insert);
				@insert = ();
				print "Inserted.\n";
			}

		print "$bbs_kind - $hit threads. \n";

	}

	if(@insert){
		$bbs_res->insert_main_table(\@insert);
		print "Last Inserted.\n";
	}

print "all insert nums is $all_insert_hit.\n";
#$bbs_res->insert_main_table(\@insert);

}



1;
