
use strict;
use File::Find;
use File::Basename;
package Mebius::Auth;
use Mebius::Export;
#use base qw(File::Basename);

#-----------------------------------------------------------
# アカウント一覧ファイル
#-----------------------------------------------------------
sub AccountListFile{

# 宣言
my($type) = @_;
my(undef,$new_account,$new_handle) = @_ if($type =~ /New-account|Edit-account/);
my(undef,$search_keyword) = @_ if($type =~ /Keyword-search-mode/);
my($i,@renew_line,%data,$file_handler,$file1,%account_still,$max_line);
my($init_directory) = Mebius::BaseInitDirectory();

# ファイル定義
my $directory1 = Mebius::SNS::all_log_directory_path() || die;

	# 検索用ファイルの場合
	if($type =~ /Search-file/){
		$file1 = "${directory1}all_account.log";
		$max_line = 50000;
	}
	# 新着用ファイルの場合
	elsif($type =~ /Normal-file/){
		$file1 = "${directory1}new_account.log";
		$max_line = 1000;
	}
	else{
		return();
	}

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1");
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$account2,$handle2) = split(/<>/);

			# ●インデックスを取得
			if($type =~ /Get-index/){

					if($handle2 eq ""){ $handle2 = "筆名未定"; }

					# キーワード検索
					if($type =~ /Keyword-search-mode/){
							if($account2 =~ /\Q$search_keyword\E/ || $handle2 =~ /\Q$search_keyword\E/){ }
							else{ next; }
					}

					# 最大表示数に達した場合
					else{
							if($i >= 100 & !$main::myadmin_flag){ last; }
							if($i >= 500){ last; }
					}

					# インデックス行を追加
					$data{'index_line'} .= qq(<li><a href="$account2/">$handle2 - $account2</a></li>);

			}

			# ディレクトリオープンの不可を減らすために、フラグを立てる
			$account_still{$account2} = 1;

			# ●ファイル更新用
			if($type =~ /Renew/){

				# 最大行数に達した場合
				if($i > $max_line){ last; }

				# 重複するアカウント名は削除
				if($type =~ /Edit-account/){
						if($account2 eq $new_account){ $handle2 = $new_handle; }
				}

				# 更新行を追加
				push(@renew_line,"$key2<>$account2<>$handle2<>\n");

			}

	}

close($file_handler);


	# ●ディレクトリから開く場合
	if($type =~ /Open-directory/){

		# 局所化
		my($directory_handler,$directory_foreach);

		# ディレクトリを開く
		opendir($directory_handler,"${init_directory}_id/");
		my @directory = grep(!/^\./,readdir($directory_handler));
		close $directory_handler;

			# ディレクトリファイルを展開
			foreach $directory_foreach (@directory){

				# 拡張子とアカウント名部分を分離する
				my($account2) = split(/\./,$directory_foreach);

					# 既に一覧ファイルに存在するアカウントは処理しない
					if($account_still{$account2}){ next; }

						# アカウントを開く
						my(%account2) = Mebius::Auth::File("Not-file-check Get-hash",$account2);

							# 行を追加する
							if($type =~ /Renew/){
										if($account2{'handle'}){ unshift(@renew_line,"<>$account2<>$account2{'handle'}<>\n"); }
							}
			}

	}

	# 新規アカウントを追加
	if($type =~ /New-account/){
			unshift(@renew_line,"<>$new_account<>$new_handle<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}

#-----------------------------------------------------------
# 全アカウントをディテクトリから取得
#-----------------------------------------------------------
sub all_account_from_directory{

# 宣言
my($use) = @_;
my $i = my $hit = my $done = 0;
our(@all_account);
my($share_directory) = Mebius::share_directory_path();	
my($init_directory) = Mebius::BaseInitDirectory();

File::Find::find( \&Mebius::Auth::find_account_directory, "${share_directory}_account/");

# マーク
#my $mark = "Old-save-data-tranced-2013-07-18";

	# 全アカウントを展開
	foreach my $account (@all_account){

		# ラウンドカウンタ
		$i++;

			# アカウント名判定
			if(Mebius::Auth::AccountName(undef,$account)){ next; }

		# HITカウンタ
		$hit++;

		# ディレクトリ定義
		my($account_directory) = Mebius::Auth::account_directory($account);
			if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

			# ▼金貨などのデータをコピー
			#if(exists $use->{'SaveDataCopy'} && $ARGV[0] eq "do"){

			#	my(%renew_account,$check);

			#		my(%now_account_data) = Mebius::Auth::File("Not-file-check",$account);

			#			if($now_account_data{'concept'} =~ /$mark/){
			#				print "$done / $i\t\t\@$account\t\tstill\n";
			#				next;
			#			}

			#		my(%old_account_data) = Mebius::Auth::File("Move-from-file Not-file-check",$account);

			#				if(!$old_account_data{'f'} || !$now_account_data{'f'}){
			#					print "$done / $i \t\t\@$account\t\tnot-file\n";
			#					next;
			#				}

			#		my($save_old) = Mebius::save_data({ FileType => "Account" },$account);

			#			foreach(keys %$save_old){
			#					if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
			#			}
			#			$renew_account{'.'}{'concept'} = " $mark";

			#		my(%renewed) = Mebius::Auth::File("Renew",$account,\%renew_account);

			#		$done++;

			# 出力
			print qq($done / $i\t\t\@$account\t\tdone \n);
			print qq($account => $account_directory\n);
			#}

		#print qq($account\n);

			my(%now_account_data) = Mebius::Auth::File("Not-file-check",$account);

				if(exists $use->{'FileToDBI'} && $ARGV[0] eq "do"){
					my($renew_utf8) = hash_to_utf8(\%now_account_data);
					$renew_utf8->{'account'} = $account;
					$done++;
					Mebius::SNS::Account->update_or_insert_main_table($renew_utf8);	
				}

				if(exists $use->{'FriendsToMainFile'} && ($ARGV[0] eq "do" || $ARGV[0] eq "test")){
					my(%friends) = Mebius::Auth::FriendIndex("",$account);
						if(ref $friends{'accounts'} eq "ARRAY"){
								Mebius::Auth::File("Renew Not-file-check",$account,{ friend_accounts => "@{$friends{'accounts'}}" });
						}
				}



	}

	if($ARGV[0] ne "do"){
		print "If you need some action , enter 'do' at command ( ARGV )";
	}

}


#-----------------------------------------------------------
# アカウントディレクトリを見つけた場合の処理
#-----------------------------------------------------------
sub find_account_directory{

# 宣言
our(@all_account,$i_file);

my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();	

# ディレクトリ名
my $path = $File::Find::name;

	# アカウントディレクトリを発見した場合
	if($path =~ m!^${share_directory}_account/\w/\w/(\w+)$!){

		$i_file++;

		my $account = $1;
		my($dir_name) = File::Basename::basename($path);

		print "$i_file Found : $path / account: $account\n";

			if($ARGV[0] eq "test"){ 
					if($account =~ /(aurayuma|aaaa)/){
						1;
						push(@all_account,$account);
					} else {
						print	" ...but escape.\n";
					}
			} else {
				push(@all_account,$account);
			}



	}

}

1;

