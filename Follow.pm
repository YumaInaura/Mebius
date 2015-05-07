
use strict;
package Mebius::Follow;
use Mebius::Export;

#-----------------------------------------------------------
# DBI からデータを取得して、内容を決定
#-----------------------------------------------------------
sub get_all_follow{

# 宣言
my($type) = @_;
my(%type); foreach(split(/\s/,$type)){	$type{$_} = 1; } # 処理タイプを展開
my(undef,%regist) = @_ if($type{'New-regist'});
my(undef,%bbs_list) = @_ if($type{'Get-index'});
my($i,@renew_line,%data,$file_handler,$line,$hit_index,$maxview_line);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($my_use_device) = Mebius::my_use_device();
my $times = new Mebius::Time;
my $bbs_status = new Mebius::BBS::Status;

# 基本設定を取得
	if($my_use_device->{'smart_phone_flag'}){
		$maxview_line = 5;
	}	else {
		$maxview_line = 2;
	}

# フォローデータを取得
my $data = $bbs_status->fetchrow_main_table();
#my($data) = Mebius::BBS::Status::all_records();

	# ファイルを展開
	foreach(@$data){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		#chomp;
		#my($hash) = Mebius::Encoding::hash_to_shift_jis($_);
		my $hash = $_;

		my($server_domain2,$realmoto2,$moto2,$bbs_title2,$thread_number2,$thread_subject2,$res_number2,$res_handle2,$res_cnumber2,$res_account2,$lasttime2)
		 = ($hash->{'server_domain'},$hash->{'real_bbs_kind'},$hash->{'bbs_kind'},$hash->{'bbs_title'},$hash->{'thread_number'},$hash->{'subject'},$hash->{'res_number'},$hash->{'last_handle'},$hash->{'cnumber'},$hash->{'account'},$hash->{'regist_time'});


			# ●インデックス取得用
			if($type{'Get-index'}){

					# 情報をゲットする掲示板かどうか
					if(!$bbs_list{$moto2}){ next; }

					# 自分の投稿はエスケープ
					if(!Mebius::alocal_judge()){
							if($res_account2 && $res_account2 eq $my_account->{'file'}){ next; }
							if($res_cnumber2 && $res_cnumber2 eq $my_cookie->{'char'}){ next; }
					}

					# 古い投稿はエスケープ
					#if(time > $lasttime2 + (7*24*60*60)){ next; }

					# 時刻
					my($lastminute) = $times->how_before($lasttime2);

					# マイページのフォローライン
					if($type{'MYPAGE'}){
						$line .= qq(<tr>);
						$line .= qq(<td>);
							if($res_number2 eq "0"){ $line .= qq(<span class="red">New!</span> ); }
						$line .= qq(<a href="http://$server_domain2/_$realmoto2/$thread_number2.html">$thread_subject2</a>);
						$line .= qq(</td>);
						$line .= qq(<td><a href="http://$server_domain2/_$realmoto2/$thread_number2.html#S$res_number2" class="handle">( $res_handle2 )</a></td>);
						$line .= qq(<td> ( <a href="http://$server_domain2/_$moto2/" class="bbs">$bbs_title2</a> ) </td>);
						$line .= qq(<td>$lastminute</td>);
						$line .= qq(</tr>\n);
					}

					# ヘッダのフォローライン
					else{

							# 最大表示行数に達している場合
							if($hit_index >= $maxview_line){ last; }

						# ヒットカウンタ
						$hit_index++;

							# 携帯版
							if($type{'Mobile-view'}){
								$line .= qq(<a href="http://$server_domain2/_$realmoto2/$thread_number2.html">$thread_subject2</a>);
								$line .= qq( <a href="http://$server_domain2/_$realmoto2/$thread_number2.html#S$res_number2" class="handle">( $res_handle2 )</a> $lastminute);
							} elsif($my_use_device->{'smart_flag'}){


								my($smart_phone_line) = Mebius::BBS::Index::view_thread_menu_core_for_smart_phone($hash,{ NoBorder => 1 });
								$line .= $smart_phone_line;

							# デスクトップ版
							} else{

									# 区切り記号
									if($hit_index >= 2){ $line .= qq( ┃ ); }

									# 新規投稿の場合
									if($res_number2 eq "0"){ $line .= qq(<span class="red">New!</span> ); }

								# 表示行
								$line .= qq(<a href="http://$server_domain2/_$realmoto2/$thread_number2.html">$thread_subject2</a> );
								$line .= qq(( <a href="http://$server_domain2/_$realmoto2/$thread_number2.html#S$res_number2" class="handle">$res_handle2</a> ) $lastminute);
								$line .= qq( - <a href="http://$server_domain2/_$moto2/" class="bbs">$bbs_title2</a> ); # http://$main::base_server_domain
							}
					}

			}


	}


	# インデックス取得
	if($type{'Get-index'}){
		return($line);
	}


return(%data);

}

1;

