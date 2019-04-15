
use strict;
use CGI;
package Mebius::BBS;

#-----------------------------------------------------------
# スレッドファイルのパス
#-----------------------------------------------------------
sub thread_file_path{

my $realmoto = shift;
my $thread_number = shift;

my($path) = Mebius::BBS::path($realmoto,$thread_number);

$path->{'thread_file'};

}

#-----------------------------------------------------------
# 記事ディレクトリのパス
#-----------------------------------------------------------
sub thread_directory_path{

my $realmoto = shift;
my $thread_number = shift;

my($path) = Mebius::BBS::path($realmoto);

$path->{'thread_directory'};

}

#-----------------------------------------------------------
# 旧過去ログのパス
#-----------------------------------------------------------
sub old_type_past_file_path{

my $realmoto = shift;

my($path) = Mebius::BBS::path($realmoto);

$path->{'old_past_file'};

}


#-----------------------------------------------------------
# パス
#-----------------------------------------------------------
sub path{

# 宣言
my $use = shift if(ref $_[0] eq "HASH");
my $realmoto = shift;
my $thread_number = shift;
#my($thread_number) = shift if($type{'Get-thread-file'});
#my($thread_number) = shift if($use->{'Target'} eq "thread_file");
my($file,%data);

# $motoを定義
my $sub_thread_flag = ( my $moto = $realmoto) =~ s/^sub(\w+)/$1/g;

	# 汚染チェック
	if($realmoto eq "" || $realmoto =~ /\W/){ return(); }
	if($moto eq "" || $moto =~ /\W/){ return(); }
	if($use->{'Target'} eq "thread_file"){
			if($thread_number eq "" || $thread_number =~ /\D/){ return(); }
	}

# 設定ディレクトリを取得
my($base_init_directory) = Mebius::BaseInitDirectory(undef);	

	# ▼基本ディレクトリ ( A )
	if($base_init_directory && $realmoto){
		$data{'base_directory'} = "${base_init_directory}_bbs_data/_${moto}_bbs_data/";
	} else { die("Perl Die! Can't setting BBS path"); }

	# ▼インデックス関係
	if($moto && $data{'base_directory'}){
		$data{'index_directory'} = "$data{'base_directory'}_index_${moto}/";
	} else{ die("Perl Die! Can't setting BBS path"); }

	# インデックスファイル
	if($moto && $data{'index_directory'}){
		$data{'index_file'} = "$data{'index_directory'}index_${moto}.log";
	} else{ die("Perl Die! Can't setting BBS path"); }

	# サブ記事用のインデックスファイル
	if($moto && $data{'index_directory'}){
		$data{'sub_index_file'} = "$data{'index_directory'}sub_index_${moto}.log";
	} else{ die("Perl Die! Can't setting BBS path"); }

	if($moto && $data{'base_directory'}){
		$data{'old_past_file'} = "$data{'base_directory'}_index_${moto}/${moto}_pst.log";
	} else{ die("Perl Die! Can't setting BBS path"); }

	# ▼スレッドディレクトリ
	if($base_init_directory && $realmoto){
		
			# CCC 2012/8/17 (金) → すぐに撤去可能
			#if(-d "${base_init_directory}${realmoto}_log/"){
			#	$data{'thread_directory'} = "${base_init_directory}${realmoto}_log/";
			#} else {
					if($sub_thread_flag){
						$data{'thread_directory'} = "$data{'base_directory'}_sub_thread_log/";
					} else {
						$data{'thread_directory'} = "$data{'base_directory'}_thread_log/";
					}
			#}
	} else{ die("Perl Die! Can't setting BBS path"); }

	# スレッドファイル
	if($thread_number){
			if($data{'thread_directory'}){
				$data{'thread_file'} = "$data{'thread_directory'}$thread_number.cgi";
			} else { die("Perl Die! Can't setting BBS path"); }
	}

	# サブ掲示板のインデックスファイル


	# リターン
	#if($type{'Get-thread-directory'}){
	if($use->{'Target'} eq "thread_directory"){
		return($data{'thread_directory'});

	} elsif($use->{'Target'} eq "thread_file"){
		return($data{'thread_file'});
	}
	#elsif($type{'Get-index-file'}){
	if($use->{'Target'} eq "index_file"){
		return($data{'index_file'});
	} else{
		return(\%data);
	}

}



1;
