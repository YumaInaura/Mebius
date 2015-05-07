
use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# いいね！する
#-----------------------------------------------------------
sub Crap{

# 宣言
my($type,$account,$file_number,$target_account) = @_;
my($i,@renew_line,%data,$file_handler,$directory2,$directory3,$file1,$topics_line,$index_line);



	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

	# ファイル名判定
	if($file_number eq "" || $file_number =~ /\D/){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = $account_directory;

	# ファイル選別
	if($type =~ /Diary-file/){
		$directory2 = "${directory1}crap_diary/";
		#$directory3 = "${directory2}diary_crap/";
		$file1 = "${directory2}${file_number}_dcrap.dat";
	}
	else{
		return();
	}

# ファイルを開く
open($file_handler,"<$file1");

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'count'},$data{'last_crap_time'}) = split(/<>/,$top1);

$data{'target'} = "${account}_$file_number";

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$lasttime2,$account2,$handle2) = split(/<>/);

		push @{$data{'good_accounts'}} , $account2;

			# トピックスを取得
			if($type =~ /Get-topics/ && $i <= 10){
				$topics_line .= qq(<a href="${main::auth_url}$account2/">$handle2</a>\n);

					# 削除用リンク
					if($main::myaccount{'file'} eq $account2 || $main::myaccount{'file'} eq $account || $main::myadmin_flag >= 1){
						$topics_line .= qq( (<a href="${main::auth_url}$account/?mode=crap&amp;mode=crap&amp;action_type=delete_crap&amp;target=diary&amp;diary_number=$file_number&target_account=$account2&amp;account_char=$main::myaccount{'char'}">x</a>)\n);
					}
			}


			# 新規いいね！
			if($type =~ /New-crap|Get-topics/){
					if($account2 eq $main::myaccount{'file'}){ $data{'craped_flag'} = 1; }
			}

			# 削除
			if($type =~ /Delete-crap/){
					if($account2 eq $target_account){ next; }
			}

			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$lasttime2<>$account2<>$handle2<>\n");
			}

	}

close($file_handler);

	# ハッシュ調整
	if(!$data{'count'}){ $data{'count'} = 0; }

# 調整
$data{'index_line'} = $index_line;
$data{'topics_line'} = $topics_line;

	# 新規いいね！
	if($type =~ /New-crap/){

			# 重複いいね！の場合
			if($data{'craped_flag'} && !$main::alocal_mode){ main::error("既にいいね！しています。"); }

		# 新しい行を追加
		unshift(@renew_line,"<>$main::time<>$main::myaccount{'file'}<>$main::myaccount{'name'}<>\n");

		# トップデータを変更
		$data{'count'}++;
		$data{'last_crap_time'} = $main::time;
	}

	# 削除
	if($type =~ /Delete-crap/){
		$data{'count'}--;
	}

$data{'good_num'} = $data{'count'};

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory2);
		#Mebius::Mkdir(undef,$directory3);

		# ファイル更新
		unshift(@renew_line,"$data{'key'}<>$data{'count'}<>$data{'last_crap_time'}<>\n");
		Mebius::Fileout(undef,$file1,@renew_line);

	}


return(%data);

}

#-----------------------------------------------------------
# いいね！ランキング（日毎）
#-----------------------------------------------------------
sub CrapRankingDay{

# 宣言
my($type,$yearf,$monthf,$dayf) = @_;
my(undef,undef,undef,undef,$max_view) = @_ if($type =~ /Get-topics/);
my(undef,undef,undef,undef,$crap_count,$account,$diary_number,$diary_subject) = @_ if($type =~ /New-crap|Delete-crap|Delete-diary/);
my($i,@renew_line,%data,$file_handler,$max_line,$rank_in_flag,$topics_line,$delete_crap_hit_flag);

# 最大行数
my $max_line = 10;

# いいね！を記録する最小ポイント
my $crap_count_border = 2;

	# 最大表示行数
	if(!$max_view){ $max_view = 10; }

	# リターン
	if($yearf =~ /\D/ || $yearf eq ""){ return(); }
	if($monthf =~ /\D/ || $monthf eq ""){ return(); }
	if($dayf =~ /\D/ || $dayf eq ""){ return(); }

# ファイル定義
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $directory1 = "${auth_log_directory}_crap_ranking_diary/";
my $file1 = "${directory1}${yearf}_${monthf}_${dayf}_crap_ranking_diary.log";

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
($data{'key'},$data{'wday'},$data{'lasttime'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# 局所化
		my($not_push_flag);

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$crap_count2,$account2,$diary_number2,$diary_subject2) = split(/<>/);

			# トピックス取得用
			if($type =~ /Get-topics/ && $i <= $max_view){
				$topics_line .= qq(<a href="${main::auth_url}$account2/d-$diary_number2">$diary_subject2</a> ($crap_count2)\n);
			}


			# 新規いいね！用
			if($type =~ /New-crap/){

					# 既存のいいね！数を超えて、ランクインしたかどうかを判定
					if($crap_count > $crap_count2){
						$rank_in_flag = 1;
					}

					# 重複分を判定
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$not_push_flag = 1;
					}

			}


			# いいね！を削除した場合
			if($type =~ /Delete-crap/){

					# 重複分を判定
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$delete_crap_hit_flag = 1;
						$not_push_flag = 1;
					}

			}

			# 行を削除する場合
			if($type =~ /Delete-diary/){

					# 重複分を判定
					if("$account2-$diary_number2" eq "$account-$diary_number"){
						$not_push_flag = 1;
					}

			}

			# 行を追加
			if($type =~ /Renew/ && $i <= $max_line && !$not_push_flag){
				push(@renew_line,"$key2<>$crap_count2<>$account2<>$diary_number2<>$diary_subject2<>\n");
			}

	}

close($file_handler);


	# トピックス取得用
	if($type =~ /Get-topics/){
			if($topics_line){ 
				$data{'topics_line'} = qq($topics_line);
			}
	}

	# いいね！を削除した場合
	if($type =~ /Delete-crap/){
			# 自分のランキングがあった場合
			if($delete_crap_hit_flag && $crap_count >= 3){
				# 新しい行を追加
				unshift(@renew_line,"<>$crap_count<>$account<>$diary_number<>$diary_subject<>\n");
			}
			else{
				$data{'not_renew_flag'}	= 1;
			}
	}

	# 新規いいね！をランキング登録
	if($type =~ /New-crap/){

			# ランクインした場合
			if(($i < $max_line || $rank_in_flag) && $crap_count >= $crap_count_border){
				Mebius::Auth::CrapRankingMonth("Renew New-ranking-in",$yearf,$monthf,$dayf);
			}
			# ランクインしなかった場合
			else{
				$data{'not_renew_flag'} = 1;
			}

		# 新しい行を追加
		unshift(@renew_line,"<>$crap_count<>$account<>$diary_number<>$diary_subject<>\n");

	}

	# ファイル更新
	if($type =~ /Renew/ && !$data{'not_renew_flag'}){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);
		#Mebius::Mkdir(undef,$directory2);
		
		# 配列をソート
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# 曜日を計算
		if($data{'wday'} eq ""){
			my(%date) = Mebius::TimeLocalDate(undef,$yearf,$monthf,$dayf);
			$data{'wday'} = $date{'wday'};
		}

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>$data{'wday'}<>$data{'lasttime'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}


return(%data);

}

#-----------------------------------------------------------
# いいね！ランキング（月毎、全体）
#-----------------------------------------------------------
sub CrapRankingMonth{

# 宣言
my($type,$yearf,$monthf,$dayf) = @_;
my($i,@renew_line,%data,$file_handler,$dayf_still_flag,$not_renew_flag,$index_line);

	# リターン
	if($yearf =~ /\D/ || $yearf eq ""){ return(); }
	if($monthf =~ /\D/ || $monthf eq ""){ return(); }
	if($type =~ /New-ranking-in/){
			if($dayf =~ /\D/ || $dayf eq ""){ return(); }
	}

# ファイル定義
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $directory1 = "${auth_log_directory}_crap_ranking_diary/";
my $file1 = "${directory1}${yearf}_${monthf}_crap_ranking_diary.log";

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
		my($key2,$dayf2) = split(/<>/);

			# インデックス取得用
			if($type =~ /Get-index/){	
	
				# 日毎のいいね！ランキングを取得
				my(%crap_ranking2) = Mebius::Auth::CrapRankingDay("Diary-file Get-topics",$yearf,$monthf,$dayf2,10);

				$index_line .= qq(<h3$main::kstyle_h3>$monthf/$dayf2 ($crap_ranking2{'wday'})</h3>\n);
				$index_line .= qq(<div class="line-height">$crap_ranking2{'topics_line'}</div>\n);
			}

			# 日が同一の場合
			if($dayf eq $dayf2){
				$dayf_still_flag = 1;
			}

			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$dayf2<>\n");
			}

	}

close($file_handler);

	# インデックス取得用
	if($type =~ /Get-index/){
			if($index_line){
				$data{'index_line'} = $index_line;
			}
	}

	# 新規いいね！
	if($type =~ /New-ranking-in/){
		# 既に日にちが登録されている場合
		if($dayf_still_flag){ $not_renew_flag = 1; }
		# まだ日にちが登録されていない場合
		else{ unshift(@renew_line,"<>$dayf<>\n"); }

	}


	# ファイル更新
	if($type =~ /Renew/ && !$not_renew_flag){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# 配列をソート
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

1;