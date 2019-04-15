
use strict;
use File::Copy;
package Mebius;

#-------------------------------------------------
# バックアップディレクトリ
#-------------------------------------------------
sub mirror_backup_directory{

my(@directory);
my($var_directory) = Mebius::var_directory();
my @number = (1,15);

	foreach(@number){
		if(Mebius::alocal_judge()){
			push(@directory,"${var_directory}Apache2.2-backup$_/");
		}
		else{
			push(@directory,"${var_directory}www-backup$_/");
		}
	}


return(@directory);

}

#-------------------------------------------------
#  基本調整 - strict
#-------------------------------------------------
sub mirror_backup_file_from_to{

my($use,$file_full_pass) = @_;
my(@directory);
my($web_directory) = Mebius::www_directory();
my @backup_directory =  Mebius::mirror_backup_directory();

	# 値のチェック
	if($file_full_pass =~ m!(\.\./|\./)!){ die("Perl Die!  '$file_full_pass' is not full pass name."); }

	# ファイルのフルパスを変換
	foreach(@backup_directory){
		my $changed = (my $backup_file_full_pass = $file_full_pass) =~ s/^$web_directory/$_/;
			if($changed){
				push(@directory,$backup_file_full_pass);
			}
	}


@directory;

}

#-----------------------------------------------------------
# バックアップを作成
#-----------------------------------------------------------
sub make_backup{

# 宣言
my($use) = shift if(ref $_[0] eq "HASH");
my($original_file,@backup_files) = @_;
my($rand,$success_copy_num);

	if($original_file eq ""){
		warn("Perl warn! original file name is empty.");
		return("オリジナルファイルが設定されていません。");
	}
	if(@backup_files <= 0){ $backup_files[0] = "$original_file.bk"; }

	# 展開
	foreach my $backup_file (@backup_files){
			if($original_file eq $backup_file){ return("オリジナルファイルとバックアップファイルが同じです。"); }
		$success_copy_num += File::Copy::copy($original_file,$backup_file);
		Mebius::Chmod(undef,$backup_file);
	}

	if($success_copy_num >= 1){ 1; } else{ 0; }

}

#-----------------------------------------------------------
# バックアップから復元
#-----------------------------------------------------------
sub return_backup{

# 宣言
# ハッシュリファレンス → バックアップファイル → オリジナルファイルの順で渡す
my $use = shift if(ref $_[0] eq "HASH");
my($original_file,@backup_files) = @_;
my($basic_init) = Mebius::basic_init();
my($success,@error_message,$most_new_backup_file,$most_new_last_modified,$report_files_line);


	# 必須値のチェック
	if(!$original_file){ return("オリジナルファイルが指定されていません。"); }
	if(@backup_files <= 0){
		$backup_files[0] = "$original_file.bk";
		#return("バックアップファイルが指定されていません。");
	}


# ミラーバックアップディレクトリも自動的にバックアップ候補にする
my(@mirror_backup_file) = Mebius::mirror_backup_file_from_to(undef,$original_file);
	if(@mirror_backup_file){ push(@backup_files,@mirror_backup_file); }

# オリジナルのファイルデータを取得
my($original_stat) = Mebius::file_stat(undef,$original_file);
my $report_files_line .= qq($original_file\n\n);
	foreach(keys %$original_stat){
		$report_files_line .= qq($_ : $original_stat->{$_}\n);
	}

	# ● 実行判定

	# ▼オリジナルファイルのサイズが一定以上ある場合、消失していないと考えて、通常は復元しない => 暫定処理 
	if($original_stat->{'size'} >= 10_000){
		push(@error_message,"オリジナルファイルのサイズが ( $original_stat->{'size'} ) が大きく、ログが消失していない可能性が高いです。");
	}



	# ▼オリジナルファイル判定でエラーがなければ、バックアップファイル名を展開
	if(@error_message <= 0){


			# バックアップファイルを展開
			foreach my $backup_file (@backup_files){

				# 配列の中に undef があると自動的にバックアップファイル名を決めるように
				if(!defined $backup_file){
					$backup_file = "$original_file.bk";
				}

				# 全く同じファイルはコピーしない
				if($backup_file eq $original_file){
					push(@error_message,"オリジナルファイルとバックアップファイルが同一です。");
					next;
				}

				# Stat を取得
				my($backup_stat) = Mebius::file_stat(undef,$backup_file); 

				$report_files_line .= qq(\n\n$backup_file\n\n);
					foreach(keys %$backup_stat){
						$report_files_line .= qq($_ : $backup_stat->{$_}\n);
					}

					# バックアップファイルが存在しない場合
					if(!$backup_stat->{'f'}){
						push(@error_message,"バックアップファイルが存在しません。");
						next;
					}

					# オリジナルファイルが存在しない場合
					elsif(!$original_stat->{'f'}){
						push(@error_message,"オリジナルファイルが存在しません。");
						next;
					}

					# バックアップファイルのサイズがゼロの場合は当然復元しない
					elsif($backup_stat->{'size'} <= 0){
						push(@error_message,"バックアップファイルのサイズが $backup_stat->{'size'} です。");
						next;
					}

					# オリジナルファイルの方がファイルサイズが大きい場合、【ログは消失していない】と判定して次の判定へ
					#elsif($original_stat->{'size'} > $backup_stat->{'size'}){ push(@error_message,"オリジナルファイルのサイズが、バックアップファイルのサイズより大きいです。"); next; }

					# 最終更新日時の比較
					# バックアップのほうが新しい場合はありえない ( 変数を逆に渡してしまっている可能性がある )
					# また、更新日時が同一の場合は復帰しても意味がないため、実行しない
					#elsif($backup_stat->{'last_modified'} >= $original_stat->{'last_modified'}){ push(@error_message,"バックアップファイルの更新日時のほうが新しいです。"); next; }
					elsif($backup_stat->{'M'} < $original_stat->{'M'}){
						push(@error_message,"バックアップファイルの更新日時のほうが新しいです。");
						next;
					}

					# その他の場合はコピー候補に追加
					else{

						# 全てのバックアップファイル中で、更新日時が一番新しいものを選ぶ
							#if($backup_stat->{'last_modified'} >= $most_new_last_modified){
							#	$most_new_last_modified = $backup_stat->{'last_modified'}; 
							#	$most_new_backup_file = $backup_file;
							#}
							if(!$most_new_last_modified || $backup_stat->{'M'} < $most_new_last_modified){
								$most_new_last_modified = $backup_stat->{'M'}; 
								$most_new_backup_file = $backup_file;
							}

					}
			}

	}



	# ●コピーを実行
	if($most_new_backup_file){

		# ファイルコピー （壊れたファイル → 壊れたファイルのバックアップ）
		my($now_date) = Mebius::now_date_multi();
		my $broken_save_file = "$original_file.$now_date->{'ymdf'}.broken.bk";
		File::Copy::copy($original_file,$broken_save_file);
		Mebius::Chmod(undef,$broken_save_file);

		# ファイルコピー（バックアップ → 壊れたファイル）
		$success = File::Copy::copy($most_new_backup_file,$original_file);

			# 成功した場合
			if($success){
				# ログを取る
				Mebius::AccessLog(undef,"Return-from-backup","ファイルを復元しました。$most_new_backup_file => $original_file");
				Mebius::Email::send_email({ ToMaster => 1 , FromEncoding => "utf8" },undef,"ファイルを復元しました。"," $most_new_backup_file => $original_file \n\n$report_files_line");
				return(1);
			}
			else{
				push(@error_message,"ファイルコピーに失敗しました。");
			}

	}
	else{
		push(@error_message,"復元できるファイルがありませんでした。");
	}

	# 何らかの理由でファイルを復元しなかった場合、管理者にメールする
	if(@error_message >= 1){
		Mebius::Email::send_email({ ToMaster => 1 , FromEncoding => "utf8" },undef,"ファイルを復元しませんでした。"," $most_new_backup_file => $original_file / Error : @error_message \n\n$report_files_line");
	}

my $error_message = join ",", @error_message;
return($error_message);

}


1;
