
use strict;
package Mebius::SNS::CommentBoad;

#-----------------------------------------------------------
# クリエリを元に伝言板レスを操作する
#-----------------------------------------------------------
sub query_to_control{


my($table_name) = Mebius::Report::main_table_name() || die ;
my(%control);
my($param) = Mebius::query_single_param();

	# クエリを展開
	foreach( keys %$param ) {

			# レス番指定で操作する場合
			if($_ =~ /^sns-comment-delete-by-res_number-([0-9a-z]+)-(\d+)(-(\d{4,}))?$/ && $param->{$_} ne ""){

					my $account = $1;
					my $target = $2;
					my $year = $4;

						if($year){
							$control{$account}{'control_years'}{$year} = 1;
						}

					$control{$account}{'res_number'}{$target}{'type'} = $param->{$_};
				Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$account' AND report_res_number='$target' AND content_type='sns_comment_boad';");

			# 投稿時刻指定で操作する場合 ( 旧形式 )
			} elsif($_ =~ /^sns-comment-delete-by-regist_time-([0-9a-z]+)-(\d+)(-(\d{4,}))?$/ && $param->{$_} ne ""){

					my $account = $1; 
					my $target = $2;
					my $year = $4;

						if($year){
							$control{$account}{'control_years'}{$year} = 1;
						}

					$control{$account}{'res_number'}{$target}{'type'} = $param->{$_};

			}

	}

	# アカウントごとに伝言板の内容を操作する
	foreach my $account ( keys %control ){

		my %years = %{$control{$account}{'control_years'}} if($control{$account}{'control_years'});

		# ロック開始
		main::lock("auth$account");

		# ファイル操作
		my($controled) = log_file({ Control => 1 , Renew => 1  },$account,$control{$account});

			if($controled->{'controled_years'}){
				%years = (%years,%{$controled->{'controled_years'}});
			}

			# 現行ファイルで操作した投稿年に応じて、年ごとの過去ログファイルも操作
			foreach my $year ( keys %years){
				log_file({ Control => 1 , Renew => 1 , year => $year },$account,$control{$account});
			}

		# ロック解除
		main::unlock("auth$account");

	}


}

#-----------------------------------------------------------
# ログファイル ( メモリ )
#-----------------------------------------------------------
sub log_file_state{

# Near State （呼び出し） 2.30
my $HereName1 = "log_file_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my($return) = log_file(@_);

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$return); }

$return;

}

#-----------------------------------------------------------
# ログファイルを開く
#-----------------------------------------------------------
sub log_file{

# 宣言

my($use,$account,$control) = @_;
my($logfile,$renew_flag,@renew_line,$comment_handler,$top1,@years,$now_file_flag,$past_file_flag,%self);
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my $admin_flag = 1 if($my_account->{'admin_flag'} || Mebius::Admin::admin_mode_judge());

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# プロフィールを開く
my(%account) = Mebius::Auth::File(undef,$account);

	# 年別ファイルを開く場合
	if($use->{'year'} =~ /^(\d+)$/){
		$past_file_flag = 1;
		$logfile = "${account_directory}comments/${account}_$use->{'year'}_comment.cgi";

	# 現行ファイルを開く場合
	} else {
		$now_file_flag = 1;
		$logfile = "${account_directory}comments/${account}_comment.cgi";
	}

# ●現行コメントを開く
$self{'f'} = open($comment_handler,"<",$logfile);

# ファイルロック
	if($use->{'Renew'}){
		flock($comment_handler,1);
	}

	# トップデータを分解、追加
	if($now_file_flag){
		$top1 = <$comment_handler>;
		push @renew_line , $top1;
	}

	# コメントファイルを展開
	while(<$comment_handler>){

		# 局所化
		my($newkey,$foreach,$control_flag,%data);

		# この行を分解
		chomp;
		($data{'key'},$data{'regist_time'},$data{'account'},$data{'name'},$data{'trip'},$data{'id'},$data{'comment'},$data{'dates'},$data{'ip'},$data{'res_number'},$data{'control_account'},$data{'control_handle'},$data{'concept'},$data{'text_color'}) = split(/<>/);
		$data{'main_account'} = $account;

		my($year,$month,$day,$hour,$min,$sec) = split(/,/,$data{'dates'});
		push @{$self{'res_data'}} , \%data;
		$self{'res_data_per_res_number'}{$data{'res_number'}} = \%data;

				# ▼削除の判断
				{ 

					my $value;


						# パラメータから、このレスに対して、操作がなされているかどうかを判定
						if($control->{'res_number'}->{$data{'res_number'}}->{'type'}){
							$value = $control->{'res_number'}->{$data{'res_number'}}->{'type'};
						} elsif($control->{'regist_time'}->{$data{'regist_time'}}->{'type'}) {
							$value = $control->{'regist_time'}->{$data{'regist_time'}}->{'type'};
						}

						# 操作の内容を判定
						if($data{'key'} eq "1" && $value eq "delete" && ($admin_flag || $account eq $my_account->{'id'} || $data{'account'} eq $my_account->{'id'})){ $control_flag = "delete"; }
						elsif($data{'key'} eq "1" && $value eq "penalty" && $admin_flag){ $control_flag = "penalty"; }
						elsif($data{'key'} ne "1" && $value eq "revive" && $admin_flag){ $control_flag = "revive"; }

				}

			# 削除行がヒットした場合
			if($control_flag){

					# 削除用に年度を記憶
					$self{'controled_years'}{$year} = 1; 

					# 削除する場合
					if($control_flag eq "delete" || $control_flag eq "penalty"){

							# プロフィールを開く
							#my(%account) = Mebius::Auth::File("Not-file-check",$account2);

							# 管理者投稿は削除できない
							#if($account{'admin'} && !$admin_flag){
							#	close($comment_handler);
							#	main::error("管理者のコメント ( $comment - No.$res ) は削除できません。");
							#}

							# 削除タイプを振り分け
							if($data{'account'} eq $my_account->{'id'}){ $newkey = 3; }
							elsif($account eq $my_account->{'id'}){ $newkey = 2; }
							elsif($admin_flag){
								$newkey = 4;
								$data{'control_account'} = $my_account->{'id'};
							}

						# 管理者削除の場合、ペナルティを与える
						if($admin_flag && $control_flag eq "penalty"){
								# 過去ファイルの場合のみ、ペナルティをつける（重複ペナルティの回避）
								if($past_file_flag){
									Mebius::Authpenalty("Penalty",$data{'account'},$data{'comment'},"SNS - $accountの伝言板 No.$data{'res_number'}","$basic_init->{'auth_url'}$data{'account'}/viewcomment#$data{'res_number'}");
									Mebius::AuthPenaltyOption("Penalty",$data{'account'},6*60*60);
								}
								# レスコンセプトを変更
								if($data{'concept'} !~ /Penalty-done/){ $data{'concept'} .= qq( Penalty-done); }
						}


					}

					# 復活する場合
					elsif($control_flag eq "revive" && $admin_flag){

						$newkey = 1;

							# 管理者復活の場合、ペナルティを減らす
							if($past_file_flag && $data{'res_concept'} =~ /Penalty-done/){
								Mebius::Authpenalty("Repair",$data{'account'});
							}

						# レスコンセプトの操作
						$data{'concept'} =~ s/(\s?)Penalty-done//g;

					}

				# 更新行を追加、削除証明フラグを立てる
			if($newkey){
				$data{'key'} = $newkey;
			}

	push(@renew_line,Mebius::add_line_for_file([$data{'key'},$data{'regist_time'},$data{'account'},$data{'name'},$data{'trip'},$data{'id'},$data{'comment'},$data{'dates'},$data{'ip'},$data{'res_number'},$data{'control_account'},$data{'control_handle'},$data{'concept'},$data{'text_color'}]));
				$renew_flag = 1;

			}
			else{ push @renew_line , "$_\n"; }
	}

close($comment_handler);

	# ログファイルを更新
	if($renew_flag && $use->{'Renew'}){ Mebius::Fileout("",$logfile,@renew_line); }

# リターン
return(\%self);

}



1;
