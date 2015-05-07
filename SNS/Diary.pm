
use strict;
package Mebius::SNS::Diary;
use Mebius::SNS::Path;
use Mebius::SNS::Feed;use Mebius::SNS::Crap;use Mebius::Export;
use base qw(Mebius::Base::Data Mebius::Base::DBI);

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# テーブル名
#-----------------------------------------------------------
sub main_table_name{
"sns_diary";
}

#-----------------------------------------------------------
# メモリテーブル名
#-----------------------------------------------------------
sub main_memory_table_name{

my($table_name) = main_table_name() || die("Can't decide main table name.");

my($memory_table_name) = Mebius::DBI->table_name_to_memory_table_name($table_name);

$memory_table_name;

}

#-----------------------------------------------------------
# レコードの更新
#-----------------------------------------------------------
sub update_or_insert_main_table{

my($update) = @_;
my($table_name) = main_table_name() || die("Can't decide main table name.");

my($column) = main_table_column();
my($adjusted_set) = Mebius::DBI->adjust_set($update,$column);

$adjusted_set->{'unique_target'} = "$adjusted_set->{'account'}-$adjusted_set->{'diary_number'}";

#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($adjusted_set); }

Mebius::DBI->update_or_insert_with_memory_table(undef,$table_name,$adjusted_set,"unique_target");

$adjusted_set;

}

#-----------------------------------------------------------
# カラムの設定
#-----------------------------------------------------------
sub main_table_column{

# データ定義
my $column = {
unique_target => { PRIMARY => 1 } , 
diary_key => { int => 1 , other_names => { key => 1 }  } ,  
account => {  } , 
diary_number => { int => 1 , other_names => { number => 1 }  } , 
last_res_number => { int => 1 , other_names => { res => 1 }  } ,
last_regist_time => { int => 1 , other_names => { lastrestime => 1 }  } ,
post_time => { int => 1 , other_names => { posttime =>  }  } ,
last_update_time => { int => 1 } ,
last_handle => { other_names => { lasthandle => 1 } } ,
owner_handle => { other_names => { handle => 1 }  } ,
owner_last_regist_time => { int => 1 , other_names => { owner_lastres_time => 1 } } , 
last_account => { } , 
alert_thread => { int => 1 } , 
hidden_from_list => { int => 1 } , 
subject => { } ,
};

$column;

}

#-----------------------------------------------------------
# テーブル作成
#-----------------------------------------------------------
sub create_main_table{

my($table_name) = main_table_name() || die("Can't decide main table name.");

# データ定義
my($set) = main_table_column();

Mebius::DBI->create_table_with_memory(undef,$table_name,$set);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub content_target_setting{
my $self = shift;
my $setting = ["account","number"];
$setting;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_setting_for_multi_data{

my $self = shift;

my $adjust_data = {
content_targetA => ["account"],
content_targetB => ["number","diary_number"],
};

$adjust_data;

}


#-----------------------------------------------------------
# 日記へのコメント履歴 ( あなたのコメント履歴 )
#-----------------------------------------------------------
sub comment_history{

# 宣言
my($type,$account) = @_;
my(undef,undef,$max_view_topics) = @_ if($type =~ /Get-topics/);
my(undef,undef,$new_account,$new_diary_number,$new_res_number) = @_;
my($FILE1,%self,@renew_line,@index_line,$hit_topics,$hit_renew_status_flag,$renew_file_flag,@data,@sorted_index_line,$i);
my($my_account) = Mebius::my_account();
my $times = new Mebius::Time;
my $time = time;

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# トピックスの最大表示行数
	if(!$max_view_topics){
		$max_view_topics = 4;
	}


# ファイル定義
my $file1 = "${account_directory}resdiary_history.log";

# ファイルを開く
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || main::error("File is not exists ");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($type =~ /Renew/){
						Mebius::Fileout("Allow-empty",$file1);
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($type =~ /Renew|Flock/){ flock(2,$FILE1); }
	
# トップデータを分解
chomp(my $top1 = <$FILE1>);
($self{'concept'},$self{'last_get_news_time'}) = split(/<>/,$top1);

	# ●ファイルを展開(A-2)
	while(<$FILE1>){

		my %data;
		$i++;

		# この行を分解
		chomp;
		($data{'key'},$data{'account'},$data{'diary_number'},$data{'my_last_res_number'},$data{'my_regist_time'},$data{'regist_date'},
		$data{'subject'},$data{'last_regist_time'},$data{'res'},$data{'owner_handle'},$data{'last_account'},$data{'last_handle'},
		$data{'owner_lastres_time'},$data{'owner_lastres_number'},$data{'last_get_diary_time'}) = split(/<>/);

			if($data{'account'} =~ /^[0-9a-z]+$/ && $data{'diary_number'} =~ /^[0-9]+$/){
				$data{'unique_target'} = "$data{'account'}-$data{'diary_number'}";
			}

		push @data , \%data;

			# ▼ファイル更新用
			if($type =~ /Renew/){ 

					# 最大記録行数を超えた場合
					if($i >= 100){ next; }

					# 同じ記事の場合
					if($data{'unique_target'} eq "$new_account-$new_diary_number"){
						next;
					}

				# 更新行を追加
				push @renew_line  , Mebius::add_line_for_file([$data{'key'},$data{'account'},$data{'diary_number'},$data{'my_last_res_number'},$data{'my_regist_time'},$data{'regist_date'},
				$data{'subject'},$data{'last_regist_time'},$data{'res'},$data{'owner_handle'},$data{'last_account'},$data{'last_handle'},
				$data{'owner_lastres_time'},$data{'owner_lastres_number'},$data{'last_get_diary_time'}]);

			}

	}

	# ●ファイル更新用
	if($type =~ /Renew/){

			# ▼新しくレスをする場合
			if($type =~ /New-res/){

				# 日記データを取得
				my($diary) = Mebius::SNS::Diary::thread_file($new_account,$new_diary_number);
				unshift(@renew_line,"<>$new_account<>$new_diary_number<>$new_res_number<>$time<>$main::date<>$diary->{'subject'}<>$time<>$new_res_number<>$diary->{'res_data'}->[0]->{'handle'}<>$account<>$my_account->{'name'}<>$diary->{'owner_lastres_time'}<>$diary->{'owner_lastres_number'}<>\n");
			}

		# トップデータを追加
		unshift(@renew_line,"$self{'concept'}<>$self{'last_get_news_time'}<>\n");

		# ファイル更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;

	}

close($FILE1);

	# パーミッション変更して、リターンする
	if($type =~ /Renew/){
		Mebius::Chmod(undef,$file1);
		return(%self);
	}

my($adjusted_index_line) = foreach_data_and_get_dbi_data(\@data);

	# ●配列をソート
	if($type =~ /Get-topics/){
		@sorted_index_line = sort { $b->{'last_regist_time'} <=> $a->{'last_regist_time'} } @{$adjusted_index_line};
	} else {
		@sorted_index_line = @$adjusted_index_line;
	}

my($view_line) = foreach_all_data_and_decice_html_view(\@sorted_index_line,$account,$type,$max_view_topics);

	# ●トピックスを取得する場合
	if($type =~ /Get-topics/){
		$self{'topics_line'} = $view_line;
			if(!$self{'topics_line'}){
				$self{'topics_line'} = qq(履歴はありません。);
			}
			my($how_before_renew) = $times->how_before($self{'last_get_news_time'});
		$self{'topics_line'} = qq(<h3$main::kstyle_h3>\n<a href="./aview-history#DIARY">あなたのコメント履歴</a> </h3><div class="line-height-large">$self{'topics_line'}</div>\n);
			if($hit_topics){
				$self{'topics_line'} .= qq(<div class="right">);
				$self{'topics_line'} .= qq(更新： $how_before_renew　);
					if($hit_topics > $max_view_topics){
						$self{'topics_line'} .= qq(<a href="./aview-history#DIARY">→続きを見る</a>　);
					}
				$self{'topics_line'} .= qq(</div>);
			}
	}

	# ●インデックス取得する場合
	if($type =~ /Get-index/){
		$self{'index_line'} = $view_line;
		$self{'index_line'} = qq(<table summary="日記へのコメント" class="width100">$self{'index_line'}</table>);
	}

return(%self);

}

#-----------------------------------------------------------
# データの展開
#-----------------------------------------------------------
sub foreach_data_and_get_dbi_data{

my($data) = @_;
my(@dbi_query,@index_line);
my $dbi = new Mebius::DBI;

	# データベースから最新データを取得
	foreach(@{$data}){
		my $escaped_query = $dbi->escape($_->{'unique_target'});
		push @dbi_query ,qq(unique_target='$escaped_query');
	}

my $dbi_query = join " OR " , @dbi_query;
#my($dbi_data) = Mebius::SNS::Diary->fetchrow_on_hash_main_memory_table("WHERE $dbi_query",undef,{ Debug => 0 });
my($dbi_data) = Mebius::SNS::Diary->fetchrow_on_hash_main_table("WHERE $dbi_query",undef,{ Debug => 0 });

	# ● 配列を展開(A-2)
	foreach my $data (@{$data}){

		my %dbi;

		# DBIのデータを、使いやすいようにハッシュに代入する
		my $dbi_unique_data = $dbi_data->{$data->{'unique_target'}};

			# DBIに登録がある場合
			if($dbi_unique_data){

				%dbi = %{$dbi_unique_data};

			# DBIに登録がない場合、スレッドからデータを取得してDBIに登録すると同時に、今回のセッションでも正しい値を返す
			} else {

				my($diary) = Mebius::SNS::Diary::thread_state($data->{'account'},$data->{'diary_number'});


					# キー判定
					if(!$diary->{'f'}){ next; }
					if($diary->{'deleted_flag'}){ next; }

					# データ更新
					if($diary->{'subject'}){

						my %update = %dbi;
						my($diary_utf8) = Mebius::Encoding::hash_to_utf8($diary);
						my($adjusted_set) = update_or_insert_main_table($diary_utf8);

						# DBIに登録された値を、そのまま今回のセッションの値として使う
						%dbi = %$adjusted_set;

					}

			}

		# インデックス行に追加 (更新行では”ない”ため注意) 
		push @index_line, { data => $data , dbi => \%dbi } ;

	} 

\@index_line;

}

#-----------------------------------------------------------
# ファイルとDBIの内容に応じて、HTMLでの表示内容を定義
#-----------------------------------------------------------
sub foreach_all_data_and_decice_html_view{

my($all_data,$account,$type,$max_view_topics) = @_;
my($html_view,$i,$hit_topics);
my $times = new Mebius::Time;
my $sns_url = new Mebius::SNS::Path;
my $html = new Mebius::HTML;

	if(!$max_view_topics){
		$max_view_topics = 5;
	}


	# 渡値のチェック
	if(ref $all_data ne "ARRAY"){ return(); }

	# ●ファイルを再展開
	foreach my $hash (@{$all_data}){


		my $data = $hash->{'data'};
		my $dbi = $hash->{'dbi'};

		# ラウンドカウンタ
		$i++;

		# この行を分割
		chomp;

		my $diary_url = $sns_url->diary_url($data->{'account'},$data->{'diary_number'});
		my $diary_link = $html->href($diary_url,$dbi->{'subject'});
		my $diary_url_move = $sns_url->diary_url_move($data->{'account'},$data->{'diary_number'},$dbi->{'last_res_number'});


			# ▼トピックス取得用
			if($type =~ /Get-topics/ && $hit_topics < $max_view_topics){


				$html_view .= qq(<div>);
				$html_view .= $diary_link;
				$html_view .= qq( -　);
				$html_view .= $html->href($diary_url_move,"$dbi->{'last_handle'}\($dbi->{'last_res_number'}\)",{ title => "\@$dbi->{'last_account'}" });

					#if($dbi->{'last_regist_time'} > $data->{'my_regist_time'} && time < $dbi->{'last_regist_time'} + (1*24*60*60)){
						$html_view .= qq(　 );
						$html_view .= $times->how_before($dbi->{'last_regist_time'});
					#}

				$html_view .= qq(</div>\n);
				$hit_topics++;
			}

			# ▼インデックス取得用
			if($type =~ /Get-index/){


					# 最大表示行数
					if($i > 20){ next; }

				my($regist_time_before2) = $times->how_before($data->{'my_regist_time'});

					$html_view .= qq(<tr>);
					$html_view .= qq(<td>$diary_link);

					$html_view .= qq( \( );
					$html_view .= $html->href("$diary_url#S$data->{'my_last_res_number'}",$dbi->{'last_res_number'});
					$html_view .= qq(	\)</td>);

					$html_view .= qq(<td>);
					$html_view .= $html->href($sns_url->account_url($data->{'account'}),"$dbi->{'owner_handle'} \@$data->{'account'}");

					$html_view .= qq(<td>);

						# アカウント主の新着レスがある場合
						if($dbi->{'owner_last_regist_time'} > $data->{'my_regist_time'} && time < $dbi->{'owner_last_regist_time'} + (3*24*60*60)){
							my($newres_time_before2) = $times->how_before($dbi->{'owner_last_regist_time'});
								$html_view .= e($dbi->{'owner_handle'}).qq(さん\(アカウント主\)が $newres_time_before2 に更新しました。);
						}

						# 新着レスがある場合
						if($dbi->{'last_regist_time'} > $data->{'my_regist_time'} && time < $dbi->{'last_regist_time'} + (3*24*60*60) && $data->{'my_regist_time'} != $dbi->{'owner_last_regist_time'}){
							my($newres_time_before2) = $times->how_before($dbi->{'last_regist_time'});
								$html_view .= e($dbi->{'last_handle'}).qq(さんが $newres_time_before2 に更新しました。);
						}

						# 新着レスがない場合
						if($account eq $dbi->{'last_account'}){
							my($newres_time_before2) = $times->how_before($data->{'my_regist_time'});
							$html_view .= qq( <span style="color:#999;">あなたが最後に更新しました。</span>);
						}

					$html_view .= qq(</td>);

					$html_view .= qq(</tr>\n);

			}

	}

$html_view;

}

#-----------------------------------------------------------
# クエリからSNS日記を操作、レポートを更新
#-----------------------------------------------------------
sub query_to_control{

my(%control);
my($param) = Mebius::query_single_param();
my($table_name) = Mebius::Report::main_table_name();
my($my_account) = Mebius::my_account();
my $package = __PACKAGE__;
my($init_directory) = Mebius::BaseInitDirectory();

require "${init_directory}auth_crap.pl";


	foreach my $key ( keys %$param ){

		my($account,$thread_number,$res_number);

			if($key =~ /^sns_diary_push_good_([0-9a-z]+)_([0-9]+)$/){
				Mebius::Auth::CrapStart($1,$2);
				last;
			# レスの操作
			} elsif($key =~ /^sns_diary_res_([0-9a-z]+)_(\d+)_(\d+)$/ && $param->{$key} ne ""){

				$account = $1;
				$thread_number = $2;
				$res_number = $3;

				$control{$account}{$thread_number}{'res'}{$res_number} = $param->{$key};

				if(Mebius::Admin::admin_mode_judge() || $my_account->{'admin_flag'}){
					Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$account' AND targetB='$thread_number' AND report_res_number='$res_number' AND content_type='sns_diary';");
				}

			} elsif ($key =~ /^sns_diary_([0-9a-z]+)_(\d+)$/ && $param->{$key} ne ""){

				$account = $1;
				$thread_number = $2;

				$control{$account}{$thread_number}{'thread'} = $param->{$key};

					if(Mebius::Admin::admin_mode_judge() || $my_account->{'admin_flag'}){
						Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$account' AND targetB='$thread_number' AND report_type_res_or_thread='Thread' AND content_type='sns_diary';");
					}

			}

	}

my($controled) = control(\%control);

$controled;

}


#-----------------------------------------------------------
# SNS 日記を操作
#-----------------------------------------------------------
sub control{

my $package = __PACKAGE__;	
my($control) = @_;
my($indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);
my(@control_reses,%self);
my $sns_feed = new Mebius::SNS::Feed;
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();


	# ● 全てのアカウントを展開
	foreach my $account ( keys %$control ){ 

		my(%controled_thread,%controled_thread_year_month);

		# 汚染チェック１
		if(Mebius::Auth::account_name_error($account)){ next(); }

		# プロフィールを開く
		my($account_data) = Mebius::Auth::File("Option Get-hash ReturnRef",$account);
			if(!$account_data->{'f'}){ next; }

		# ロック開始
		Mebius::lock("auth$account");

		# 最後に操作したアカウントを覚えておく
		push @{$self{'controled_account'}} , $account;

			# ▼全ての日記を展開
			foreach my $diary_number ( keys %{$control->{$account}} ){ 

				my(@renew_line,%renew_top_data,$diary_handler,%renew_res);

				# 使いやすいようにするための代入
				my $res_control = $control->{$account}->{$diary_number}->{'res'};
				my $thread_control = $control->{$account}->{$diary_number}->{'thread'};

					# 汚染チェック２
					if($diary_number eq "" || $diary_number =~ /[^0-9]/){ next; }

				# ディレクトリ定義
				my($diary) = Mebius::SNS::Diary::thread_file({ Flock1 => 1 },$account,$diary_number);
					if(!$diary->{'f'}){ next; }

					# ●スレッドの操作 (権限チェック必須)
					if(Mebius::SNS::admin_judge() || $my_account->{'id'} eq $account){

						# 復活させる場合
						if($thread_control eq "revive" && (Mebius::SNS::admin_judge() || allow_user_revive_judge($account,$diary))){

								#$type .= qq( Revive-diary);
								$renew_top_data{'key'} = "1";
								$flag = 1;

								# 全メンバーの新着日記に復活
								#Mebius::Auth::all_members_diary("Revive-diary New-file Renew",$account,$diary_number);
								#Mebius::Auth::all_members_diary("Revive-diary Alert-file Renew",$account,$diary_number);

									# ペナルティの解除 
									if(Mebius::SNS::admin_judge() && $diary->{'penalty_done'}){
										Mebius::Authpenalty("Repair",$account);
										Mebius::AuthPenaltyOption("Penalty",$account,-3*24*60*60);
										$renew_top_data{'penalty_done'} = 0;
									}

								$package->revive_on_status($diary);

							# 削除済みの場合は、管理者でなければ操作できないように
							} elsif( ($diary->{'key'} eq "4" || $diary->{'key'} eq "2") && !Mebius::SNS::admin_judge()){
								0;

							# ▼ロックする場合
							} elsif($thread_control eq "lock"){
								$renew_top_data{'key'} = "0";
								$flag = 1;
								$self{'thread_delete_flag'} = 1;

							# ▼ロック解除する場合
							} elsif($thread_control eq "unlock"){
								$renew_top_data{'key'} = "1";
								$flag = 1;
								$self{'thread_delete_flag'} = 1;

							# ▼削除する場合
							}	elsif($thread_control eq "delete" || ($thread_control eq "penalty" && Mebius::SNS::admin_judge())){

								#$type .= qq( Delete-diary);
									if(Mebius::SNS::admin_judge()){ $renew_top_data{'key'} = "4"; } else { $renew_top_data{'key'} = "2"; }
								$flag = 1;

								# マイメビの新着一覧から削除
								Mebius::Auth::FriendIndex("Delete-diary",$account,$diary_number);

								# 全メンバーの新着日記から削除
								#Mebius::Auth::all_members_diary("Delete-diary New-file Renew",$account,$diary_number);
								#Mebius::Auth::all_members_diary("Delete-diary Alert-file Renew",$account,$diary_number);

									# ペナルティをつける
									if($thread_control eq "penalty" && Mebius::SNS::admin_judge() && !$diary->{'penalty_done'}){

										Mebius::Authpenalty("Penalty",$account,"","SNSの日記 - $diary->{'subject'}","$basic_init->{'auth_url'}$account/d-$diary_number");
										Mebius::AuthPenaltyOption("Penalty",$account,3*24*60*60);
										$renew_top_data{'penalty_done'} = 1;
									}

								my($date) = Mebius::now_date();
								$renew_top_data{'control_account'} = $my_account->{'id'};
								$renew_top_data{'control_time'} = time;
								$self{'thread_delete_flag'} = 1;

								# SNSの新着フィードから削除
								$sns_feed->update_main_table({ deleted_flag => 1 },{ WHERE => { content_type => "sns_diary" , account => $account , data1 => $diary_number  } });

								$package->delete_on_status($diary);

							}
					}

					# あとで日記のメニューファイルを一斉更新するための処理 ( ハッシュのキー名を揃える )
					if($renew_top_data{'key'} ne ""){
						$controled_thread{$diary_number} = \%renew_top_data;
						$controled_thread_year_month{$diary->{'year'}}{$diary->{'month'}}{$diary_number} = \%renew_top_data;
						#$controled_thread{$diary_number} = $renew_top_data{'key'};
						#$controled_thread{$diary_number}{'control_time'} = $renew_top_data{'control_time'};
						#$controled_thread{$diary_number}{'control_account'} = $renew_top_data{'control_account'};
						#$controled_thread_year_month{$diary->{'year'}}{$diary->{'month'}}{$diary_number}{'key'} = $renew_top_data{'key'};
						#$controled_thread_year_month{$diary->{'year'}}{$diary->{'month'}}{$diary_number}{'control_time'} = $renew_top_data{'control_time'};
						#$controled_thread_year_month{$diary->{'year'}}{$diary->{'month'}}{$diary_number}{'control_account'} = $renew_top_data{'control_account'};
					}

					# ファイルを展開する
					foreach my $data (@{$diary->{'data_line'}}){

						# 局所化
						my($res_control_type);

							# ▼レスの操作
							if($data->{'res_number'} eq "0"){ 0; } # 0番のレスは削除できない
							elsif($res_control->{$data->{'res_number'}} eq "delete"){ $res_control_type = "delete"; }
							elsif($res_control->{$data->{'res_number'}} eq "penalty" && Mebius::SNS::admin_judge()){ $res_control_type = "penalty"; }
							elsif($res_control->{$data->{'res_number'}} eq "revive"){ $res_control_type = "revive"; }

							# 削除行がヒットした場合
							if($res_control_type){

						# 操作したレスを記憶
								push(@{$self{'control_reses'}},$data->{'res_number'});

								# 発言者のアカウントデータを開く
								#my(%account) = Mebius::Auth::File("Not-file-check Option",$data->{'account'});

									# 削除する
									if($data->{'key'} eq "1" && ($res_control_type eq "delete" || $res_control_type eq "penalty")){

										$renew_res{$data->{'controler_file'}} = $my_account->{'id'};
										($renew_res{$data->{'control_date'}}) = Mebius::now_date();

											if($data->{'account'} eq $my_account->{'id'}){ $renew_res{$data->{'res_number'}}{'key'} = 3; $flag = 1; }
											elsif($account eq $my_account->{'id'}){ $renew_res{$data->{'res_number'}}{'key'} = 2; $flag = 1; }
											elsif(Mebius::SNS::admin_judge()){ $renew_res{$data->{'res_number'}}{'key'} = 4; $flag = 1; }



									# 復活させる
									} elsif($res_control_type eq "revive"){
										$renew_res{$data->{'res_number'}}{'key'} = 1; $flag = 1;
									}

									# 管理者削除の場合、ペナルティを与える
									if($res_control_type eq "penalty" && Mebius::SNS::admin_judge()){
										Mebius::Authpenalty("Penalty",$data->{'account'},$data->{'comment'},"SNS - $data->{'account'} -  $diary->{'subject'}","$basic_init->{'auth_url'}$data->{'account'}/d-$diary_number#S$data->{'res_number'}");
										$renew_res{$data->{'penalty_done'}} = 1;
										# SNSペナルティ
										Mebius::AuthPenaltyOption("Penalty",$data->{'account'},6*60*60);
									}
						
									# 管理者復活の場合、ペナルティを差し引く
									if($res_control_type eq "revive" && $data->{'res_concept'} =~ /Penalty-done/ && Mebius::SNS::admin_judge()){
										Mebius::Authpenalty("Repair",$data->{'account'});
										$renew_res{$data->{'penalty_done'}} = 0;
										# SNSペナルティ
										Mebius::AuthPenaltyOption("Penalty",$data->{'account'},-6*60*60);
									}

							}

					}

					# 日記単体ファイルを書き出し
					if($flag){
						Mebius::SNS::Diary::thread_file({ Renew => 1 , renew_top_data => \%renew_top_data , renew_res => \%renew_res },$account,$diary_number);
					}

			}

			# 自分の日記インデックスを更新
			if(%controled_thread){
				Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => \%controled_thread , file_type => "now" },$account);
			}

			foreach my $year ( keys %controled_thread_year_month ){
					foreach my $month ( keys %{$controled_thread_year_month{$year}} ){
						Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => $controled_thread_year_month{$year}{$month} , file_type => "month" },$account,$year,$month);
					}
			}

		# ロック解除
		Mebius::unlock("auth$account");

	}

\%self;

}

#-----------------------------------------------------------
# 日記単体ファイルの呼び出し ( State )
#-----------------------------------------------------------
sub thread_state{

my($account,$diary_number) = @_;

# Near State （呼び出し） 2.30
my $HereName1 = "thread_state";
my $StateKey1 = "$account-$diary_number";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my($self) = Mebius::Auth::diary(undef,$account,$diary_number);

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$self); }

$self;

}

#-----------------------------------------------------------
# 日記単体ファイル
#-----------------------------------------------------------
sub thread_file{
my($self);
	if(ref $_[0] eq "HASH"){
		($self) = Mebius::Auth::diary(@_);
	} else {
		($self) = Mebius::Auth::diary(undef,@_);
	}

$self;
}



#-----------------------------------------------------------
# アカウント毎の、日記の月別インデックス
#-----------------------------------------------------------
sub index_file_per_account{

my $use = shift if(ref $_[0] eq "HASH");
my($account,$year,$month) = @_;
my(@renew_line,$FILE1,%self,$file1);

	# 汚染チェック
	if(Mebius::Auth::account_name_error($account)){ return(); }

# ファイル・ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account) || return();
	
	if($use->{'file_type'} eq "now"){
		$file1 = $self{'file'} = "${account_directory}diary/${account}_diary_index.cgi";
	} elsif($use->{'file_type'} eq "month") {
			if($year eq "" || $year =~ /[^0-9]/){ return(); }
			if($month eq "" || $month =~ /[^0-9]/){ return(); }
		$file1 = $self{'file'} = "${account_directory}diary/${account}_diary_${year}_${month}.cgi";
	} else {
		die("");
	}

# 月別インデックスを開く
open($FILE1,"<",$file1);

	if($use->{'Renew'}){ flock($FILE1,1); }

	if($use->{'file_type'} eq "now"){
		chomp(my $top = <$FILE1>);
		($self{'newest_diary_number'}) = split(/<>/,$top);
	}

	# すべての行を展開
	while(<$FILE1>){

		my (%data,@other_data);

		chomp $_;
		($data{'key'},$data{'diary_number'},$data{'subject'},$data{'res'},$data{'dates'},$data{'post_time'},$data{'control_account'},$data{'control_time'},@other_data) = split(/<>/,$_);
		($data{'year'},$data{'month'},$data{'day'},$data{'hour'},$data{'minute'},$data{'second'}) = split(/,/,$data{'dates'});

		if($data{'key'} eq "2" || $data{'key'} eq "4"){ $data{'deleted_flag'} = 1; }

		push @{$self{'data_line'}} , \%data;
		push @{$self{'res_line'}} , \%data;

			# ファイル更新用
			if($use->{'Renew'}){
				my($renew) = Mebius::Hash::control(\%data,$use->{'renew_line'}->{$data{'diary_number'}});
				push @renew_line , Mebius::add_line_for_file([$renew->{'key'},$renew->{'diary_number'},$renew->{'subject'},$renew->{'res'},$renew->{'dates'},$renew->{'post_time'},$renew->{'control_account'},$renew->{'control_time'},@other_data]);
			}

	}
close($FILE1);

	if($use->{'new_line'}){
		unshift @renew_line , $use->{'new_line'};
	}

	# ヒットした場合のみ、月別インデックスを書き出し
	if($use->{'Renew'} && @renew_line >= 1){

			if($use->{'file_type'} eq "now"){
				my($renew) = Mebius::Hash::control(\%self,$use->{'renew_top_data'});
				unshift @renew_line , Mebius::add_line_for_file([$renew->{'newest_diary_number'}]);
			}

		Mebius::Fileout("",$file1,@renew_line);
	}

\%self;

}


#──────────────────────────────
# 日記インデックス
#──────────────────────────────
sub view_index_per_account{

# ファイル定義
my $use = shift if(ref $_[0] eq "HASH");
my($file_type,$account,$year,$month) = @_;
my($diary_index,$index,$i,$hit);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();


# ファイルを開く
($index) = Mebius::SNS::Diary::index_file_per_account({ file_type => $file_type } , $account,$year,$month);

	# 現行インデックスを読み込み
	foreach(@{$index->{'data_line'}}){

		my($link,$mark,$line);
		my($data) = Mebius::Encoding::hash_to_utf8($_);
		my $month_and_day = "$data->{'month'}月$data->{'day'}日";

			if($i >= $use->{'max_view_line'} && $use->{'max_view_line'}){ last; }

		$i++;

		my $diary_url = Mebius::SNS::Path->diary_relative_url($account,$data->{'diary_number'});

			if($data->{'key'} eq "0"){ $mark .= qq(<span class="lock"> - ロック中</span> ); }

			# 普通に表示する
			if($data->{'key'} eq "0" || $data->{'key'} eq "1"){

				$hit++;
					if(time < $data->{'post_time'} + 3*24*60*60){ $mark .= qq(<span class="red"> - new!</span> ); }
				$diary_index .= qq(<li><a href=").e($diary_url).q(">).e($data->{'subject'}).qq(</a> ($data->{'res'}) - $month_and_day$mark);

			# 削除済みの場合
			} elsif(Mebius::SNS::admin_judge() || allow_user_revive_judge($account,$data)){
				my($text);
					if($data->{'key'} eq "2"){ $text = qq( アカウント主により削除); }
					elsif($data->{'key'} eq "4"){ $text = qq( 管理者により削除); }
					#if(Mebius::SNS::admin_judge()){
						$text .= qq( <a href="$diary_url" class="red">$data->{'subject'}</a>);
						#if(Mebius::alocal_judge()){ $text .= qq($data->{'control_time'}); }
					#}
				$diary_index .= qq(<li>$text - $month_and_day</li>);
			}

			# 日記操作フォーム
			if(Mebius::SNS::admin_judge()){
				my($diary_control_form) = Mebius::SNS::Diary::thread_control_select_parts({ MenuMode => 1 },$account,$data); # ハッシュ ( $_ )の名前を揃えること
					if($diary_control_form){ $diary_index .= qq(<div>$diary_control_form</div>); }
			}
	}

	if($diary_index){
		$diary_index = qq(<ul>$diary_index</ul>);
			if(Mebius::SNS::admin_judge()){ 
				($diary_index) = Mebius::SNS::Diary::thread_control_form_around($diary_index);
			}
	}


$diary_index,$index;

}

#-----------------------------------------------------------
# アカウント毎の、月別の、大メニュー
#-----------------------------------------------------------

sub all_diary_index_file_per_account{

my($account,$max_month) = @_;
my($i,$line,$FILE1,%self);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 全インデックスを読み込み
open($FILE1,"<","${account_directory}diary/${account}_diary_allindex.cgi");
	while(<$FILE1>){
		my(%data);
		$i++;

		my($key,$year,$month) = split(/<>/,$_);
		($data{'key'},$data{'year'},$data{'month'}) = split(/<>/,$_);
		push @{$self{'data_line'}} , \%data;

			if($i > $max_month){ last; }

		my($month_index_line) = Mebius::SNS::Diary::view_index_per_account("month" , $account,$year,$month);

			if($month_index_line){
					if($key eq "1"){
						$line .= qq(<h3><a href="$basic_init->{'auth_relative_url'}$account/diax-$year-$month">$year年$month月</a></h3>);
					}
				$line .= $month_index_line;
			}
	}
close($FILE1);

return($line);

}

#-----------------------------------------------------------
# 0番投稿エリアの表示内容を定義
#-----------------------------------------------------------
sub view_zero_res{

my $use = shift if(ref $_[0] eq "HASH");
my($account,$diary,$data) = @_;
$data ||= $diary->{'res_data'}->[0];
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();
my($view_line);

	# 日記本体の削除フォーム
	if(!Mebius::Report::report_mode_judge()){

			my $id = "sns_diary_control_form_${account}_$diary";

		my($diary_control_form) = Mebius::SNS::Diary::thread_control_select_parts($account,$diary);
	
			if($diary_control_form){

					if(!Mebius::SNS::admin_judge()){
						$view_line .= qq(<div class="right size90"><a href="javascript:vswitch\(').e($id).q('\);" class="fold">→日記の操作</a></div>);
						$view_line .= qq(<div class="none" id=").e($id).q(">);
					}
				$view_line .= qq(<h2>操作</h2>日記本体： );
				$view_line .= qq($diary_control_form);
				$view_line .= qq( <input type="submit" value="実行する">);
			}
		if(!Mebius::SNS::admin_judge()){ $view_line .= qq(</div>); }
	}


$view_line .= qq(<h2>本文</h2>);

my($zero_res_line) = Mebius::SNS::Diary::view_res_core({ max_res_number => $diary->{'res'} } , $account, $diary->{'number'} , $data);
$view_line .= $zero_res_line;

	if($use->{'crap_line'}){

			$view_line .= qq(<div class="under_main_diary">);
			$view_line .= qq(<div class="crap_line">$use->{'crap_line'}</div>);
			$view_line .= qq(<div class="right spacing">);
				if($my_account->{'login_flag'}){
					$view_line .= qq(<a href=").e($my_account->{'profile_url'}).qq(feed">→フィードへ</a>);
				}
			$view_line .= qq( <a href=").e($basic_init->{'auth_url'}).qq(aview-alldiary.html#S$account-$diary->{'number'}">→全メンバーの新着日記へ</a>);
			$view_line .= qq(</div>);
			$view_line .= qq(</div>);
	}




$view_line;

}

#-----------------------------------------------------------
# 日記のレス毎に、表示を定義
#-----------------------------------------------------------
sub view_res_core{

my $use = shift if(ref $_[0] eq "HASH");
my($account,$diary_number,$original_data) = @_;
my $fillter = new Mebius::Fillter;
my($parts) = Mebius::Parts::HTML();
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
#my $account_handle = Mebius::SNS::Account->all_account_handle();
my $data = Mebius::Encoding::hash_to_utf8($original_data);
my($key,$res_number,$account2,$id,$trip,$comment,$dates,$color,$xip,$controler_file,$control_date) = ($data->{'key'},$data->{'res_number'},$data->{'account'},$data->{'id'},$data->{'trip'},$data->{'comment'},$data->{'dates'},$data->{'color'},$data->{'xip'},$data->{'controler_file'},$data->{'control_date'});
my($view_line,$deleted,$rescontrol_box,$control_flag,$divclass,$adsflag1,$adsflag2,$class,$name);
	

	if($use->{'DbiHandle'}){
		$name = $original_data->{'handle'};
	} else {
		$name = $data->{'name'};
	}

# 時刻整形
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
my($viewdate) = sprintf("%04d/%02d/%02d %02d:%02d", $year,$month,$day,$hour,$min);

	# 行頭の改行を削除
	if($my_use_device->{'smart_flag'} || $my_use_device->{'mobile_flag'}){
		($comment) = Mebius::Text::DeleteHeadSpace(undef,$comment);	
	}

	if( my $message = $fillter->each_comment_fillter($comment)){
		$comment = $message;
	}

	if( my $message = $fillter->each_comment_fillter($name)){
		$name = $message;
	}


# オートリンク
($comment) = auto_link($comment,$use->{'max_res_number'});

	# 文字色の整形
	my $style = qq( style="color:#$color;") if(length($color) == 3);

	# 削除済みの場合
	if($key eq "3"){ $deleted = qq(投稿者-$account2-により削除);  }
	elsif($key eq "2"){ $deleted = qq(アカウント主により削除); }
	elsif($key eq "4"){ $deleted = qq(管理者-$controler_file-により削除); }

	# 削除時間を整形
	if($control_date){ $control_date = qq(( $control_date )); }

	# レスが削除済みの場合、表示を整形する
	if($deleted){
			if(Mebius::SNS::admin_judge()){
				$comment = qq(<span class="cdeleted">【$deleted】 $control_date - 管理者にだけ本文が見えます<br$main::xclose><br$main::xclose>$comment</span>);
			}
			else{
				$deleted = qq(<span class="cdeleted">【$deleted】 $control_date</span>);
				$comment = qq($deleted);
				$rescontrol_box = undef;
			}
		$name = "";
	}


	# 0レス以外では報告ボックス、または削除操作部分を表示する
	if($res_number ne "0"){

			# ▼報告ボックス
			if(Mebius::Report::report_mode_judge()){

			# ▼コメントの操作ボックス
			} else {

					my $input_name = "sns_diary_res_${account}_${diary_number}_${res_number}";

					# 削除チェックボックス(一般用)
					if($key eq "1" && $res_number ne "0" && ($account eq $my_account->{'id'} || $data->{'account'} eq $my_account->{'id'}) && control_mode_judge() && !Mebius::SNS::admin_judge()){
						$rescontrol_box .= qq(<label><input type="checkbox" name=").e($input_name).qq(" value="delete"> <span class="alert">このレスを削除</span></label>);
					}

					# レス操作ラジオボックスの整形 （管理者用）
					if(Mebius::SNS::admin_judge()){
						$rescontrol_box .= qq(<label>);
						$rescontrol_box .= qq( <input type="radio" name=").e($input_name).qq(" value="" checked>);
						$rescontrol_box .= qq(<span>);
						$rescontrol_box .= qq(未選択);
						$rescontrol_box .= qq(</span>);
						$rescontrol_box .= qq(</label>);
					}

					# レス操作ラジオボックスの整形 （管理者用）
					if(Mebius::SNS::admin_judge()){
						$rescontrol_box .= qq(<label>);
						$rescontrol_box .= qq( <input type="radio" name=").e($input_name).qq(" value="no-reaction">);
						$rescontrol_box .= qq(<span>);
						$rescontrol_box .= qq(対応しない);
						$rescontrol_box .= qq(</span>);
						$rescontrol_box .= qq(</label>);
					}


					# 罰削除ラジオボックス（管理者用）
					if(Mebius::SNS::admin_judge() && !$deleted){
						my($disabled_buf) = $parts->{'disabled'} if($deleted);
						$rescontrol_box .= qq(<label>);
						$rescontrol_box .= qq(<input type="radio" name=").e($input_name).qq(" value="penalty"$disabled_buf>);
						$rescontrol_box .= qq(<span class="red select">罰削除</span>);
						$rescontrol_box .= qq(</label>);
					}

					# 削除ラジオボックス（管理者用）
					if(Mebius::SNS::admin_judge() && !$deleted){
						my($disabled_buf) = $parts->{'disabled'} if($deleted);
						$rescontrol_box .= qq(<label>);
						$rescontrol_box .= qq(<input type="radio" name=").e($input_name).qq(" value="delete"$disabled_buf>);
						$rescontrol_box .= qq(<span class="select">削除</span>);
						$rescontrol_box .= qq(</label>);
					}

					
					# 復活ラジオボックス（管理者用）
					if(Mebius::SNS::admin_judge() && $deleted){
						my($disabled_buf) = $parts->{'disabled'} if(!$deleted);
						$rescontrol_box .= qq(<label>);
						$rescontrol_box .= qq(<input type="radio" name=").e($input_name).qq(" value="revive"$disabled_buf>);
						$rescontrol_box .= qq(<span class="select blue">復活</span>);
						$rescontrol_box .= qq(</label>);
					}

					# レス操作ラジオボックスの整形 （共通）
					if($rescontrol_box){
						$rescontrol_box = qq(<div class="res_control">$rescontrol_box</div>);
						$control_flag = 1;
					}

			}
	}


	# スタイルを定義
	if($key ne "1" && Mebius::SNS::admin_judge()){ $divclass = qq( class="admin_deleted"); }

	# 表示内容
	{

			# 投稿者が自分の場合、筆名の色を変える
			if($data->{'account'} eq $account){ $class = qq( class="me"); }

		$view_line .= qq(<div$divclass>);
		$view_line .= qq(<p id="S$res_number" class="s"$style><a href="$basic_init->{'auth_url'}$data->{'account'}/"$class>$name \@$data->{'account'}</a><br$main::xclose><br$main::xclose>$comment</p>);


		$view_line .= q(<div class="date">);
		$view_line .= e($viewdate).q( - );

			# 各レス番へのリンク
			if($my_account->{'login_flag'} && $use->{'select_res_number'} ne $res_number){
				$view_line .= q(<a href="./d-).e($diary_number).q(-).e($res_number).q(#S).e($res_number).q(">No.).e($res_number).q(</a>);
			} else {
				$view_line .= q(No.).e($res_number);
			}
		$view_line .= q(</div>); # $delete
			if($my_account->{'master_flag'}){ $view_line .= qq( $xip); }
		$view_line .= qq($rescontrol_box);
		$view_line .= qq(</div>);

			# ▼削除依頼のチェックボックス
			if(Mebius::Report::report_mode_judge_for_res()){
				my($report_check_box) = Mebius::Report::report_check_box_per_res({  },"sns_diary_${account}_${diary_number}_${res_number}") if($data->{'key'} eq "1" && $res_number ne "0");
				$view_line .= $report_check_box;
			}
	}

	# 関連記事の表示
	#if($key eq "1" && $res_number eq "0"){ $view_line .= qq($account{'kr_oneline'}); }

return($view_line,$control_flag);

}

#-----------------------------------------------------------
# スレッド操作用のパーツ
#-----------------------------------------------------------
sub thread_control_select_parts{

my $use = shift if(ref $_[0] eq "HASH");
my($account,$diary) = @_;
my($my_account) = Mebius::my_account();
my($diary_control_form);

my $diary_number = $diary->{'number'} || $diary->{'thread_number'} || $diary->{'diary_number'};

	if(Mebius::SNS::admin_judge() || $account eq $my_account->{'id'}){

			my $input_name = "sns_diary_${account}_$diary_number";

			$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="" checked><span>未選択</span></label>);

				if(Mebius::SNS::admin_judge()){
					$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="no-reaction"><span>対応しない</span></label>);
				}

				if($diary->{'key'} eq "0"){
					$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="unlock"><span>ロック解除</span></label>);
				} elsif($diary->{'key'} eq "1") {
					$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="lock"><span>ロック</span></label>);
				}

				if((!$use->{'MenuMode'} && !$diary->{'deleted_flag'}) || Mebius::SNS::admin_judge()){
					$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="delete"><span>削除</span></label>);
				}

				if(Mebius::SNS::admin_judge() && !$diary->{'penalty_done'}){
					$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="penalty"><span class="red">罰削除</span></label>);
				}

				if(Mebius::SNS::admin_judge() || allow_user_revive_judge($account,$diary)){
						if($diary->{'deleted_flag'}){
							$diary_control_form .= q(<label><input type="radio" name=").e($input_name).q(" value="revive"><span class="blue">復活</span></label>);
								if(!Mebius::SNS::admin_judge() && allow_user_revive_judge($account,$diary)){
									$diary_control_form .= qq( <span class="guide">※削除後、しばらく経つと復活できなくなります。</span>);
								}
						} else {
							#$diary_control_form .= q(<strike class="blue">復活</strike>);
						}
				}

	} else {
		0;
	}

$diary_control_form;

}

#-----------------------------------------------------------
# スレッド操作フォーム
#-----------------------------------------------------------
sub thread_control_form{

my($account,$diary) = @_;
my($basic_init) = Mebius::basic_init();

my($self) = thread_control_select_parts($account,$diary);
$self = thread_control_form_around($self);

$self;

}
#-----------------------------------------------------------
# スレッド操作フォーム
#-----------------------------------------------------------
sub thread_control_form_around{

my $use = shift if(ref $_[0] eq "HASH");
my($now_parts) = @_;
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my($self);

my($back_url_input_hidden) = Mebius::back_url_input_hidden();

$self .= q(<form action=").e($basic_init->{'auth_url'}).q(" method="post" id="sns_diary_control"><input type="hidden" name="mode" value="skeditdiary">).$back_url_input_hidden.$now_parts;
$self .= $html->input("hidden","account_char",$my_account->{'char'});

	if(!$use->{'NotButton'}){
		$self .= q(<div class="margin"><input type="submit" value="操作を実行する"></div>);
	}

$self .= q(</form>);

$self;

}


#-----------------------------------------------------------
# いいね！エリア
#-----------------------------------------------------------
sub crap_line{

# 宣言

my($diary_number,$diary,$account) = @_;
my($crap_line);
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my $package = __PACKAGE__;

my %account = %$account;
my %diary = %$diary;

# いいね！情報を取得
my(%crap_shift_jis) = Mebius::Auth::Crap("Get-topics Diary-file",$account{'file'},$diary_number);
my($crap) = Mebius::Encoding::hash_to_utf8(\%crap_shift_jis);

# 整形
$crap_line .= qq(<div class="word-spacing line-height">);

$crap_line .= $html->input("hidden","target","diary");
$crap_line .= $html->input("hidden","action_type","new_crap");

$crap_line .= $package->good_button($crap);

#$crap_line .= qq(<img src="/pct/light1.png" alt="いいね！" style="width:20px;height:20px;"$main::xclose>いいね！($crap->{'count'})\n);


	# いいね！したアカウント一覧
	if($crap->{'topics_line'}){
		$crap_line .= qq( - $crap->{'topics_line'});
	}

	# いいね！ボタン（リンク形式）
	#if($my_account->{'login_flag'}){

			# アカウント設定によるいいね！禁止
	#		if(!$account{'allow_crap_diary_flag'}){
	#			$crap_line .= qq( -&gt; このメンバーは日記へのいいね！を許可していません。);
	#		}
			# 日記設定によるいいね！禁止
	#		elsif($diary->{'not_crap_flag'}){
	#			$crap_line .= qq( -&gt; この日記はいいね！を禁止しています。);
	#		}

			# ストップモード
	#		if($main::stop_mode =~ /SNS/){
	#			$crap_line .= qq( -&gt; 現在、SNSは更新停止中です。);
	#		}
			# いいね！を許可している場合
	#		elsif((!$crap->{'craped_flag'} && $account{'file'} ne $main::myaccount{'file'}) || Mebius::alocal_judge()){
	#			$crap_line .= qq( -&gt; <a href="./?mode=crap&amp;mode=crap&amp;action=new_crap&amp;target=diary&amp;diary_number=$diary_number&amp;account_char=$main::myaccount{'char'}" style="color:#080;">この日記にいいね！する</a>);

					# ランキング拒否している場合
	#				if($diary->{'not_crap_ranking_flag'} || $account{'osdiary'} eq "2"){
	#					$crap_line .= qq( \( ランキングには登録されません \) );
	#				}
	#		}
	#}

# 整形
$crap_line .= qq(</div>);

$crap_line;

}


#-----------------------------------------------------------
# 操作モードかどうかを判定
#-----------------------------------------------------------
sub control_mode_judge{

my($submode) = Mebius::Mode::submode();

	if($submode->{'3'} eq "all"){ 1; }

}


#-----------------------------------------------------------
# ファーストビューの広告
#-----------------------------------------------------------
sub ads_first_view{
my($ads) = decide_ads();
$ads->{'first_view'};
}

#-----------------------------------------------------------
# 0番下の広告
#-----------------------------------------------------------
sub ads_up{
my($ads) = decide_ads();
$ads->{'up'};
}

#-----------------------------------------------------------
# 0番下の広告
#-----------------------------------------------------------
sub ads_right{
my($ads) = decide_ads();
$ads->{'right'};
}

#-----------------------------------------------------------
# 0番下の広告
#-----------------------------------------------------------
sub ads_bottom{
my($ads) = decide_ads();
$ads->{'bottom'};
}


#-----------------------------------------------------------
# 広告を決定
#-----------------------------------------------------------
sub decide_ads{

my($ads1,$ads2,$ads_right,$ads_first_view);
my($my_use_device) = Mebius::my_use_device();

	# ローカルの場合
	if(Mebius::alocal_judge()){ 
		0;

	# 管理モードの場合
	} elsif(Mebius::Admin::admin_mode_judge()){
		0;

	# 携帯からの場合
	} elsif(Mebius::Device::use_device_mobile_judge()){
		($ads1) = main::kadsense();
			if($ads1){ $ads1 = qq(<hr>$ads1<hr>); }
	}

	# スマフォ用
	elsif($my_use_device->{'smart_flag'}){

		$ads1 = '
		<div class="diary_ads">
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* mobile tangle */
		google_ad_slot = "3446606142";
		google_ad_width = 300;
		google_ad_height = 250;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		';

		$ads2 = '
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* mobile bunner */
		google_ad_slot = "4674925464";
		google_ad_width = 320;
		google_ad_height = 50;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		';



		$ads_first_view = '
		<div class="ads_first_view">
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* スマフォバナー */
		google_ad_slot = "1226476247";
		google_ad_width = 320;
		google_ad_height = 50;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		';

	# PC用
	} else {

		$ads1 = '
		<div class="diary_ads">
		<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
		<!-- SNS（レクタングル大） -->
		<ins class="adsbygoogle"
		     style="display:inline-block;width:336px;height:280px"
		     data-ad-client="ca-pub-7808967024392082"
		     data-ad-slot="2628050761"></ins>
		<script>
		(adsbygoogle = window.adsbygoogle || []).push({});
		</script>
		</div>
		';


		#$ads1 = '
		#<div class="diary_ads">
		#<script type="text/javascript"><!--
		#google_ad_client = "ca-pub-7808967024392082";
		#/* SNS(レクタングル中) */
		#google_ad_slot = "0450176853";
		#google_ad_width = 300;
		#google_ad_height = 250;
		#//-->
		#</script>
		#<script type="text/javascript"
		#src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		#</script>
		#</div>
		#';

		$ads2 = '
		<div>
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* SNSビッグバナー */
		google_ad_slot = "4432696952";
		google_ad_width = 728;
		google_ad_height = 90;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		</div>
		';

		$ads_right = '
		<script type="text/javascript"><!--
		google_ad_client = "ca-pub-7808967024392082";
		/* SNS 日記 右 */
		google_ad_slot = "7887959321";
		google_ad_width = 160;
		google_ad_height = 600;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
		';
	}

		$ads1 =~ s/\t//g;
		$ads2 =~ s/\t//g;
		$ads_right =~ s/\t//g;
		$ads_first_view =~ s/\t//g;

{ up => $ads1 , bottom => $ads2 , right => $ads_right , first_view => $ads_first_view };


}

#-----------------------------------------------------------
# 日記用のオートリンク
#-----------------------------------------------------------
sub auto_link{

my($text,$max_res_number) = @_;

($text) = Mebius::auto_link($text);
$text =~ s/No\.([0-9]+)/auto_link_res_number_core($1,$max_res_number)/eg;

$text;

}

#-----------------------------------------------------------
# レス番のオートリンク
#-----------------------------------------------------------
sub auto_link_res_number_core{

my($res_number,$max_res_number) = @_;
my($submode) = Mebius::Mode::submode();
my($self);

	if($res_number <= $max_res_number){
		$self = "<a href=\"$submode->{'1'}-$submode->{'2'}-$1#S$1\">&gt;&gt;$1<\/a>";
	} else {
		$self = "&gt;&gt;$1";
	}

$self;

}


#-----------------------------------------------------------
# ユーザーが日記を復活できる場合
#-----------------------------------------------------------
sub allow_user_revive_judge{

my($account,$diary) = @_;
my($flag);
my($my_account) = Mebius::my_account();

	if($account eq ""){ return(); }
	if($account ne $my_account->{'id'}){ return(); }

	if($diary->{'control_datas'} eq "" && $diary->{'control_account'} eq "" && time < 1367286084 + 7*24*24*60){ # 荒らしで削除された可能性のある日記
		$flag = 1;
	} elsif($diary->{'control_account'} eq $my_account->{'id'} && $diary->{'control_time'} && time < $diary->{'control_time'} + 3*24*60*60){ # 自分で削除して、なおかつ、削除から一定時間経過していない日記
		$flag = 1;
	}

$flag;

}


#──────────────────────────────
# 全メンバーの新着日記
#──────────────────────────────
sub all_members_diary{

# 宣言
my($type,$max_view_topics) = @_;
my($my_use_device) = Mebius::my_use_device();
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my $times = new Mebius::Time;
my($i,$max_view,$style,$alldiary_handler,@new_diary_index,$file,@renew_line,$max_line,$topics_line,$hit_topics,$dbi_data,@topics);

	# DBIからデータを取得する
	{
		my $border_time;

			# どれぐらい前のデータまで取得するか
			if(Mebius::alocal_judge()){
				$border_time = time - 365*24*60*60;
			} else {
				$border_time = time - 3*24*60*60;
			}
		($dbi_data) = fetchrow_main_memory_table("WHERE post_time > $border_time");
	}

# 最大表示行数
$max_view = 50;

	if($my_account->{'admin_flag'}){ $max_view = 500; }
	if($my_use_device->{'mobile_flag'}){ $max_view = 25; }

# ソート
my @sorted_data = sort { $b->{'post_time'} <=> $a->{'post_time'} } @$dbi_data;

	# ファイルを展開
	foreach my $dbi (@sorted_data){

		# 局所化
		my($style,$mark2);

		# 行を分解
		chomp;
		my($key,$account2,$name,$num,$sub,$date,$resnumber2,$regist_time2) = 
			($dbi->{'diary_key'},$dbi->{'account'},$dbi->{'owner_handle'},$dbi->{'diary_number'},$dbi->{'subject'},$dbi->{'regist_date'},$dbi->{'last_res_number'},$dbi->{'last_regist_time'});
		my %data = %$dbi;

		$data{'url'} = qq($basic_init->{'auth_url'}/$account2/d-$num);
		$data{'content_type'} = "sns_diary";

		# ラウンドカウンタ
		$i++;

			# ●インデックス取得用
			if($type =~ /Get-index/ && !Mebius::Fillter::heavy_fillter($sub)){

				my($newdiary_index);

					# 表示最大行数に達した場合
					if($i > $max_view && !$param->{'word'}){ last; }


					# 削除済みの場合
					if($key ne "1"){
							if($my_account->{'admin_flag'} >= 1){ $mark2 .= qq( <span class="alert">[ 削除済み ]</span>); }
							else{ next; }
					}

					# ユーザーが新着一覧に載せなかった日記の場合 （管理者にだけ表示）
					if($dbi->{'hidden_from_list'}){
							if($my_account->{'admin_flag'} >= 1){ $mark2 .= qq( <span class="guide">[ 隠 ]</span>); }
							else{ next; }
					}

					# キーワード判定などで、トピックスに載せない記事 （ 新着一覧では灰色に ）
					if($key =~ /Deny-keyword/){ $style = qq( style="color:#888;"); }

					# ワード検索
					if($param->{'word'} ne ""){

						my($hit_flag);

							# 普通に検索
							if(index($sub,$param->{'word'}) >= 0){ $hit_flag = 1; }
							if(index($name,$param->{'word'}) >= 0){ $hit_flag = 1; }
							if(index($account2,$param->{'word'}) >= 0){ $hit_flag = 1; }

							# 管理者は本文からも検索可能に	
							if($my_account->{'master_flag'} && $param->{'comment'}){
								my($diary) = Mebius::SNS::Diary::thread_state($account2,$num);
									if(index($diary->{'res_data'}->[0]->{'comment'},$param->{'word'}) >= 0){ $hit_flag = 1; }
							}
							if(!$hit_flag){ next; }

					}

				#my $link1 = qq($account2/);


				#my($how_before_time2) = $times->how_before($dbi->{'post_time'});

				#$newdiary_index .= qq(<tr id="S$account2-$num">\n);
				#$newdiary_index .= qq(<td>);
				#$newdiary_index .= qq(<a href="$link2"$style>$sub</a>);
				#$newdiary_index .= qq($mark2</td>);
				#$newdiary_index .= qq(<td>);
				#$newdiary_index .= qq(<a href="$link1">$name - $account2</a>);
				#	if($type =~ /Alert-res-file/ && $resnumber2){ $newdiary_index .= qq( ( <a href="$link2#S$resnumber2">&gt;&gt;$resnumber2</a> )); }
				#$newdiary_index .= qq(</td>);
				#$newdiary_index .= qq(<td>$how_before_time2</td>\n);
				#$newdiary_index .= qq(</tr>\n);
				push @new_diary_index , \%data ;

			}

			#●トピックス取得用
			if($type =~ /Get-topics/ && !Mebius::Fillter::heavy_fillter($sub)){

				# 表示しない行
				if($dbi->{'hidden_from_list'} || $dbi->{'diary_key'} ne "1"){ next; }

				# ヒットカウンタ
				#$hit_topics++;

					# 表示最大行数に達した場合
				#	if($hit_topics > $max_view_topics){ last; }

				# リンクを定義
				#my $link1 = qq($main::adir$dbi->{'account'}/);
				#my $link2 = qq($main::adir$dbi->{'account'}/d-$num);

				# 時刻をゲット
				#my($how_before_time2) = $times->how_before($dbi->{'post_time'});

				# トピックスの表示行を定義
				#my $line = qq(<a href="$link2">$sub</a> - <a href="$link1">$dbi->{'owner_handle'}</a>　 $how_before_time2);
				$data{'time'} = $dbi->{'post_time'};
				push @topics , \%data ;
			}

	}


	# ●インデックスを返す
	if($type =~ /Get-index/){
		return(@new_diary_index);
	}

	# ●トピックスを返す
	if($type =~ /Get-topics/){
		return(\@topics);
		#return($topics_line);
	}


return();

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;
my $sns_url = new Mebius::SNS::URL;

my $url = $sns_url->diary_url($data->{'content_targetA'} || $data->{'account'},$data->{'content_targetB'} || $data->{'diary_number'});

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url_with_move{

my $self = shift;
my $data = shift;
my $sns_url = new Mebius::SNS::URL;

my $url = $sns_url->diary_url_move($data->{'content_targetA'} || $data->{'account'},$data->{'content_targetB'} || $data->{'diary_number'} , $data->{'last_response_target'} || $data->{'res_number'});

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"diary";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"sns";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub push_good_account_only{
1;
}



1;