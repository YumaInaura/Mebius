
use strict;
package Mebius::BBS::Thread;
#use base qw(Mebius::Encoding);
use base qw(Mebius::Base::Data);
use Mebius::Export;
 
#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub main_limited_package_name{
"bbs";
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub limited_package_name{
"thread";
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub content_target_setting{
my $self = shift;
my $setting = ["bbs_kind","thread_number"];
$setting;
}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub adjust_setting_for_multi_data{

my $self = shift;

my $hash = {
content_targetA => ["bbs_kind"] , 
content_targetB => ["number","thread_number"] , 
last_response_target => ["res"] , 
last_response_num => ["res"] , 
};


$hash;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sitemap_url{

my $self = shift;
my $year = shift;
my($basic_init) = Mebius::basic_init();
my $base_url = "http://$basic_init->{'bbs_domain'}/";
my($url);

$url = "${base_url}_main/bbs_sitemap_$year.xml";

}


#-----------------------------------------------------------
# レス番区切り表示モードで、広告の有無を定義する
#-----------------------------------------------------------
sub no_ads_judge_on_splited_res{

my $self = shift;
my $use_thread = shift;
my($param) = Mebius::query_single_param();
my($fillter_flag);

	# レス番表示の場合に、広告の表示有無を決定する
	if($param->{'No'}){

		my $res_numbers = $self->split_res_numbers($param->{'No'});

			foreach my $res_number (@$res_numbers){
				my $comment = $use_thread->{'res_data'}->{$res_number}->{'comment'};
				utf8($comment);
					if(Mebius::Fillter::basic(undef,$comment)){
						$fillter_flag = 1;
					}
			}
	} else {
		0;
	}

$fillter_flag;

}

#-----------------------------------------------------------
# $param->{'No'} などの指定からレス番を分解する
#-----------------------------------------------------------
sub split_res_numbers{

my $self = shift;
my $select = shift;
my @res_number;

	if($select =~ /^([0-9]+)$/){
		push @res_number , $1;
	}	elsif($select =~ /^([0-9]+)\-([0-9]+)$/){
		my $number1 = $1;
		my $number2 = $2;
			for($number1 .. $number2){
				push @res_number , $_;
			}
			for($number2 .. $number1){
				push @res_number , $_;
			}
	} elsif($select =~ /^([0-9]+),([0-9,]+)$/){
			foreach( split /,/ , $select ){
				push @res_number , $_;
			}
	} else {
		return();
	}

@res_number = sort { $a <=> $b } @res_number;

\@res_number;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url_with_response_history{

my $self = shift;
my $data = shift;
my $response_history = $data->{'response_target_history'};
my($url);

my $splited_response_history = join "," , (split(/\s/,$response_history));

my $thread_url = $self->data_to_url($data);

	if($splited_response_history){
		$url = "$thread_url-$splited_response_history";
	} else {
		$url = $thread_url;
	}

$url;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub thread_data_to_multi_data_for_status{

my $self = shift;
my $thread = shift;
my $thread_utf8 = hash_to_utf8($thread);
my(%hash);

$hash{'content_targetA'} = $thread_utf8->{'bbs_kind'};
$hash{'content_targetB'} = $thread_utf8->{'number'};
$hash{'content_create_time'} = $thread_utf8->{'posttime'};
$hash{'subject'} = $thread_utf8->{'subject'};
$hash{'last_modified'} = $thread_utf8->{'lastrestime'};
$hash{'last_handle'} = $thread_utf8->{'lasthandle'};
$hash{'last_response_target'} = $hash{'last_response_num'} = $thread_utf8->{'res'};
$hash{'deleted_flag'} = $thread_utf8->{'deleted_flag'};

\%hash;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url{

my $self = shift;
my $data = shift;

my $url = Mebius::BBS::thread_url($data->{'thread_number'} || $data->{'content_targetB'} , $data->{'bbs_kind'}  || $data->{'content_targetA'} );

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url_with_move{

my $self = shift;
my $data = shift;

my $url = Mebius::BBS::thread_url_move($data->{'thread_number'} || $data->{'content_targetB'} , $data->{'bbs_kind'}  || $data->{'content_targetA'} , $data->{'res_number'} || $data->{'last_response_target'});

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_url_with_number{

my $self = shift;
my $data = shift;

my $url = Mebius::BBS::thread_url_number($data->{'thread_number'} || $data->{'content_targetB'} , $data->{'bbs_kind'}  || $data->{'content_targetA'} , $data->{'res_number'} || $data->{'last_response_target'});

$url;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub mode_judge{

my $self = shift;
my $bbs = new Mebius::BBS;
my($param) = Mebius::query_single_param();
my($flag);

	if($bbs->access_judge() && $param->{'mode'} eq "view"){
		$flag = 1;
	} else {
		0;
	}

$flag;

}
#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub key_to_deleted_flag{

my $self = shift;
my $key = shift;
my($deleted_flag);

	if($key eq "4" || $key eq "6" || $key eq "7"){
		$deleted_flag = 1;
	}

$deleted_flag;

}


package Mebius::BBS;

#-----------------------------------------------------------
# 記事を取得
#-----------------------------------------------------------
sub thread_state{

my $use = shift if(ref $_[0] eq "HASH");
my $thread_number = shift;
my $target_bbs = shift; # この順番で良い

	if(@_ >= 1){ die("Perl Die! Too many value relayed. @_ "); }

	# 引き継ぎ
	if(defined $use->{'relay_thread'}){
		$thread_number = $use->{'relay_thread'}->{'thread_number'};
		$target_bbs = $use->{'relay_thread'}->{'realmoto'};
	}

	if($use->{'Auto'}){
		my($query) = Mebius::query_state();
		$target_bbs = $query->param('moto');
		#$thread_number = $query->param('no');
	}

	if($use->{'thread_number_query'}){
		my($query) = Mebius::query_state();
		$thread_number = $query->param($use->{'thread_number_query'});
	}

	if($use->{'SubThread'} && $target_bbs && $target_bbs !~ /^sub/){
		$target_bbs = "sub$target_bbs";
	}

	elsif($use->{'MainThread'} && $target_bbs && $target_bbs =~ /^sub/){
		$target_bbs =~ s/^sub//g;
	}

	if($thread_number =~ /\D/ || $thread_number eq ""){ warn("Perl warn! thread_number '$thread_number' is invalid "); return(); }
	if($target_bbs =~ /\W/ || $target_bbs eq ""){ warn("Perl warn! target_bbs '$target_bbs' is invalid "); return(); }

my $HereName1 = "thread_state";
my $HereKey1 = "$target_bbs-$thread_number";

my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , GetAllLine => 1 , Flock => 1 }, $target_bbs , $thread_number);

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,$thread); }

$thread;

}

#-----------------------------------------------------------
# 掲示板の記事データを取得
#-----------------------------------------------------------
sub thread{

# 宣言
my($use,$realmoto,$thread_number) = @_;
my(%self,$file,$FILE1,@renew_line,%data_format,$renew);
my $status = new Mebius::Status;
my($server_url) = Mebius::server_url();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my $thread_object = new Mebius::BBS::Thread;

	# 引き継ぎ
	if(defined $use->{'relay_thread'}){
			$thread_number = $use->{'relay_thread'}->{'thread_number'};
			$realmoto = $use->{'relay_thread'}->{'realmoto'};
	}

	# 汚染チェック
	if($realmoto eq "" || $realmoto =~ /[^0-9a-zA-Z]/){ return(); }
	if($thread_number eq "" || $thread_number =~ /\D/){ return(); }

# ファイル定義
my($thread_directory) = Mebius::BBS::thread_directory_path($realmoto);
	if(!$thread_directory){ warn("Perl warn! Can't decide thread directory path . \@_ is @_"); return(); }
	($self{'file'}) = Mebius::BBS::thread_file_path($realmoto,$thread_number);
	if(!$self{'file'}){ warn("Perl warn! Can't decide thread file path.  \@_ is @_"); return(); }

my %relay_use = %$use;
	if(!$use->{'AllowTouchFile'}){ $relay_use{'DenyTouchFile'} = 1; }
my($FILE1,$read_write) = Mebius::File::read_write(\%relay_use,$self{'file'},[$thread_directory]);
	if($read_write->{'f'}){ %self = (%self,%$read_write); } else { return(\%self); }

# トップデータを読み込み
%data_format = thread_top_data_format();
my($split_data) = Mebius::file_handle_to_hash(\%data_format,$FILE1);
%self = (%self,%$split_data);

	if(!@{$self{'all_line'}}){
		die("Perl Die! Thread Line is empty. ");
	}

# 重要な代入
my $top2 = <$FILE1>;
	if($top2){
		push(@{$self{'all_line'}},$top2); 
		chomp $top2;
		(undef,undef,$self{'zero_handle'},undef,$self{'zero_comment'},$self{'zero_date'},undef,undef,$self{'zero_color'},undef,undef,undef,$self{'zero_account'}) = split(/<>/,$top2);
	}

# ●ハッシュの調整
$self{'subject'} = $self{'sub'};
$self{'date'} = $self{'zero_date'};
$self{'lasttime'} = $self{'lastrestime'};
$self{'postnumber'} = $thread_number;
$self{'number'} = $self{'thread_number'} = $thread_number;
$self{'posthandle'} = $self{'zero_handle'};
$self{'realmoto'} = $self{'target_bbs'} = $self{'bbs_kind'} = $realmoto;

	# URL
	($self{'url'}) = Mebius::BBS::thread_url($thread_number,$realmoto);
	($self{'admin_url'}) = Mebius::BBS::thread_url_admin($thread_number,$realmoto);
	($self{'bbs_url_admin'}) = Mebius::BBS::bbs_url_admin($realmoto);

	# 自分の場合
	if($self{'zero_account'} && $self{'zero_account'} eq $my_account->{'id'}){ $self{'mythread_flag'} = 1; }

	# レス数が空の場合
	if(!$self{'res'}){ $self{'res'} = 0; }

	# 投稿グリニッジ標準時が無い場合、ゼロ記事の日付から換算
	if($self{'posttime'} eq "" && $self{'zero_date'}){
		my(%date) = Mebius::SplitMebiDate(undef,$self{'zero_date'});
		$self{'posttime'} = $date{'time'};
	}

# 削除情報
(undef,undef,$self{'control_lasttime'},$self{'control_reason'}) = split(/=/,$self{'delete_data'});

	# 警告フラグ
	if($self{'concept'} =~ /Alert-violation/ && time < $self{'control_lasttime'} + (7*24*60*60)){ $self{'alert_flag'} = 1; }


	# ●キーレベル判定 (A-1)
	if($self{'key'} eq "1" || $self{'key'} eq "5" || $self{'key'} eq "2"){ $self{'keylevel'} = 1; }
	elsif($self{'key'} eq "3"){ $self{'keylevel'} = 0.5; }
	elsif($self{'key'} eq "0"){
			if(!$self{'lock_end_time'} || $self{'lock_end_time'} > time){
				$self{'keylevel'} = 0;
				$self{'lock_flag'} = 1;
			}
			else{
				$self{'keylevel'} = 1;
			}
	}
	elsif($self{'key'} eq "4" || $self{'key'} eq "6" || $self{'key'} eq "7"){
		$self{'keylevel'} = -1;
		$self{'deleted_flag'} = 1;
	}
	else{ $self{'keylevel'} = -2; }

	# ●最大レスを達成したスレッドを記録する場合の判定 (A-2)
	if($use->{'TypeMaxResRecord'}){
			# 記録しない掲示板
			if($main::realmoto =~ /^(delete)$/ || $main::secret_mode || $main::bbs{'concept'} =~ /Chat-mode/ || $main::subtopic_mode){
				close($FILE1);
				return();
			}
			# 記事が削除済みなどの場合
			if($self{'keylevel'} < 0){
				close($FILE1);
				return();
			}
			# 既に記録済みの場合
			if($self{'concept'} =~ /Maxres-recorded2/){
				close($FILE1);
				return();
			}
		# コンセプトキーの変更、定義
		$self{'concept'} =~ s/ Maxres-recorded([0-9]+)?//g;
		$self{'concept'} .= qq( Maxres-recorded2);
		Mebius::AccessLog(undef,"Maxres-recorded");
	}

	# ▼全行を展開
	if($use->{'GetAllLine'} || $use->{'Renew'}){

			while(<$FILE1>){
				push(@{$self{'all_line'}},$_);
			}

			# ボディー部分だけを展開したいので、トップデータは shift する
			my @body_line = @{$self{'all_line'}};
			shift @body_line;

			foreach(@body_line){

				my(%res);
				chomp;

# データ分解
($res{'res_number'},$res{'cookie_char'},$res{'handle'},$res{'trip'},$res{'comment'},$res{'date'},$res{'host'},$res{'id'},$res{'color'},$res{'user_agent'},$res{'user_name'},$res{'deleted'},$res{'account'},$res{'image_data'},$res{'concept'},$res{'regist_time'},$res{'addr'}) = split(/<>/);
			$self{'res_data'}{$res{'res_number'}} = \%res;

				push @{$self{'all_line_hash'}},\%res;

				# ▼更新用
				if($use->{'Renew'}){ 

						# 行を編集
						my($res_renew) = Mebius::Hash::control(\%res,$use->{'res_edit'}->{$res{'res_number'}});

					# 更新行を定義
					my $renew_this_line = "$res_renew->{'res_number'}<>$res_renew->{'cookie_char'}<>$res_renew->{'handle'}<>$res_renew->{'trip'}<>$res_renew->{'comment'}<>$res_renew->{'date'}<>$res_renew->{'host'}<>$res_renew->{'id'}<>$res_renew->{'color'}<>$res_renew->{'user_agent'}<>$res_renew->{'user_name'}<>$res_renew->{'deleted'}<>$res_renew->{'account'}<>$res_renew->{'image_data'}<>$res_renew->{'concept'}<>$res_renew->{'regist_time'}<>$res_renew->{'addr'}<>\n";
						push(@renew_line,$renew_this_line);

					}
			}

	}

	# ●ファイル更新
	if($use->{'Renew'}){

		# 任意の更新とリファレンス化
		($renew) = Mebius::Hash::control(\%self,$use->{'select_renew'});

			if($use->{'new_line'}){ push(@renew_line,$use->{'new_line'}); }

		# データフォーマットからファイル更新
		Mebius::File::data_format_to_truncate_print(\%data_format,$FILE1,$renew,\@renew_line);

		my $renew_utf8 = hash_to_utf8($renew);
		Mebius::BBS::ThreadStatus->update_table($renew_utf8);

			#if($self{'key'} ne $renew->{'key'} && $thread_object->key_to_deletd_judge($renew->{'key'})){
			#	$status->delete_content();
			#}

	}

close($FILE1);

	# パーミッション変更
	if($use->{'Renew'}){ Mebius::Chmod(undef,$self{'file'}); }

	# ●詳細ハッシュを定義
	if($use->{'GetHashDetail'}){

		# 記事の新規投稿時刻から日付を分解
		my(%time1) = Mebius::Getdate("Get-hash",$self{'posttime'});
		%self = (%self,%time1);

			# 記事の過去ログ化日付を分解 ( 主に管理者削除用 )
			if($self{'bepast_time'}){
				my(%bepast_time) = Mebius::Getdate("Get-hash",$self{'bepast_time'});
					foreach( keys %bepast_time ){
							$self{"bepast_time_$_"} = $bepast_time{$_};
					}
			}

		# スタットデータを取得
		my($stat) = Mebius::file_stat("Get-stat",$self{'file'});

			# スタットデータを本ハッシュに結合
			foreach(keys %$stat){
					if(defined($stat->{$_})){ $self{"stat_$_"} = $stat->{$_}; }
			}

	}

	# ●最大レス達成スレッドを、各所に記録する
	if($use->{'TypeMaxResRecord'}){
		require "${main::int_dir}part_newlist.pl";
		Mebius::Newlist::Maxres("Renew",%self);
		Mebius::BBS::Maxres("Renew",$realmoto,\%self);
	}

	# ハッシュを返す
	if($use->{'ReturnReference'} || $use->{'ReturnRef'}){ return(\%self); } else{ return(%self); }


}




#-----------------------------------------------------------
# トップデータのフォーマット
#-----------------------------------------------------------
sub thread_top_data_format{

my %self;

$self{'1'} = [('concept','sub','res','key','lasthandle','lastrestime','delete_data','lastmodified','bepast_time','sexvio','poster_xip','delete_reserve_time','memo_editor','memo_body','admin_memo','lock_end_time','lastcomment','posttime','crap_count','sub_thread_res','ads_mode')];

%self;

}



1;

