
use strict;
use Mebius::RenewStatus;
use Mebius::Mode;
use Mebius::SNS;
package Mebius::Auth;
use Mebius::Export;

#-----------------------------------------------------------
# SNSの個別の日記を開く
#-----------------------------------------------------------
sub diary{

# 宣言
my($use,$shift,$type);
if(ref $_[0] eq "HASH"){ $use = shift; } else { $type = shift; } 
my($account,$diary_number) = @_;
my(undef,undef,undef,$renew) = @_ if($type =~ /Renew/ || $use->{'Renew'});
my($diary_handler,%hash,$i,@renew_line);
my($basic_init) = Mebius::basic_init();

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){
		warn "acount name is empty or strange.";
		return({});
	}
	if($diary_number =~ /^d-([0-9]+)$/){ $diary_number = $1; } # d-343 などのモードをそのまま使う時 
	if($diary_number =~ /\D/ || $diary_number eq ""){
		warn "diary number is empty or strange.";
		return({});
	}


# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 各種ハッシュを定義
$hash{'url'} = "$basic_init->{'auth_url'}${account}/d-$diary_number";
$hash{'number'} = $diary_number;
$hash{'account'} = $account;

# ファイル定義
my $file = "${account_directory}diary/${account}_diary_${diary_number}.cgi";

	# 日記ファイルを開く
	if($type =~ /File-check-error|Level-check-error/){ ($hash{'f'} = open($diary_handler,"<",$file)) || main::error("この日記は存在しません。"); }
	else{ ($hash{'f'} = open($diary_handler,"<",$file)); }

	# ファイルロック
	if(($type =~ /Renew/ || $use->{'Renew'}) ||  $use->{'Flock1'}){ flock(1,$diary_handler); }

chomp(my $top1 = <$diary_handler>);

# データを分解
($hash{'key'},$hash{'number'},$hash{'subject'},$hash{'res'},$hash{'postdates'},$hash{'posttime'},$hash{'lastrestime'},$hash{'control_datas'},$hash{'last_account'},$hash{'last_handle'},$hash{'owner_lastres_time'},$hash{'owner_lastres_number'},$hash{'concept'},$hash{'control_account'},$hash{'control_time'},$hash{'penalty_done'},$hash{'owner_handle'},$hash{'hidden_from_list'}) = split(/<>/,$top1);
($hash{'year'},$hash{'month'},$hash{'day'},$hash{'hour'},$hash{'min'},$hash{'sec'}) = split(/,/,$hash{'postdates'});

	# 別名の登録 ( DBI 登録のためにも、ハッシュを同じ名前にする )
	{

		$hash{'diary_number'} = $diary_number;
		if($hash{'concept'} =~ /Penalty-done/){ $hash{'penalty_done'} = 1; }
	}

	# ハッシュ調整
	if($hash{'key'} eq "2" || $hash{'key'} eq "4"){
		$hash{'deleted_flag'} = 1;
			#if($hash{'concept'} !~ /Deleted/){ $hash{'concept'} .= qq( Deleted); }
	}
	#if($hash{'concept'} =~ /Deleted/){ $hash{'deleted_flag'} = 1; }

	# いいね！判定
	if($type =~ /Crap-check/){
			if($hash{'concept'} =~ /Not-ranking-crap/){ $hash{'not_crap_ranking_flag'} = 1; }
			if($hash{'concept'} =~ /Not-crap/){ $hash{'not_crap_flag'} = 1; }
	}

	# ●日記ファイルを展開 ( 限定 )
	while(<$diary_handler>){

		my(%data,@other_adta);

		# ラウンドカウンタ
		$i++;

		chomp;
		($data{'key'},$data{'res_number'},$data{'account'},$data{'name'},$data{'id'},$data{'trip'},$data{'comment'},$data{'dates'},$data{'color'},$data{'xip'},$data{'controler_file'},$data{'control_date'},$data{'res_concept'},@other_adta) = split(/<>/);

		if($data{'res_number'} eq "0"){
			$hash{'owner_handle'} ||= $data{'name'};
			$hash{'handle'} = $data{'name'};
		}

	 # 別名
	$data{'handle'} = $data{'name'};

		push(@{$hash{'res_data'}},\%data);
		push(@{$hash{'data_line'}},\%data);
	#	$hash{'res_data_on_hash'}{$data{'res_number'}} =  \%data;


		my($renew) = Mebius::Hash::control(\%data,$use->{'renew_res'}->{$data{'res_number'}}) if($type =~ /Renew/ || $use->{'Renew'});

#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash($use->{'renew_res'}->{$data{'res_number'}}); }

		# 更新行を追加
		push @renew_line, Mebius::add_line_for_file([$renew->{'key'},$renew->{'res_number'},$renew->{'account'},$renew->{'name'},$renew->{'id'},$renew->{'trip'},$renew->{'comment'},$renew->{'dates'},$renew->{'color'},$renew->{'xip'},$renew->{'controler_file'},$renew->{'control_date'},$renew->{'res_concept'},@other_adta]);

	}

close($diary_handler);

	# レベルチェック
	if($type =~ /Level-check-error/){
			if($hash{'deleted_flag'}){ main::error("この日記は存在しないか、削除済みです。"); }
	}

	# ファイル更新
	if($type =~ /Renew/ || $use->{'Renew'}){

			if($use->{'push_line'}){
				push @renew_line , $use->{'push_line'};
			}


		# トップデータを一斉更新
		my($renew_top_data) = Mebius::Hash::control(\%hash,$use->{'renew_top_data'},$renew);


		# トップデータを追加
	unshift @renew_line,
	Mebius::add_line_for_file([$renew_top_data->{'key'},$renew_top_data->{'number'},$renew_top_data->{'subject'},$renew_top_data->{'res'},$renew_top_data->{'postdates'},
	$renew_top_data->{'posttime'},$renew_top_data->{'lastrestime'},$renew_top_data->{'control_datas'},$renew_top_data->{'last_account'},$renew_top_data->{'last_handle'},
	$renew_top_data->{'owner_lastres_time'},$renew_top_data->{'owner_lastres_number'},$renew_top_data->{'concept'},$renew_top_data->{'control_account'},$renew_top_data->{'control_time'},$renew_top_data->{'penalty_done'},$renew_top_data->{'owner_handle'},$renew_top_data->{'hidden_from_list'}]);
		Mebius::Fileout(undef,$file,@renew_line);



		# データベースを更新
		my($renew_top_data_utf8) = Mebius::Encoding::hash_to_utf8($renew_top_data);
		Mebius::SNS::Diary::update_or_insert_main_table($renew_top_data_utf8);

	}

return(\%hash);

}



1;
