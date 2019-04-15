
use strict;
package Mebius::BBS::Path;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{

my $class = shift;

	if(ref $_[0] eq "HASH"){
		my %hash_copy = %{$_[0]};
		bless \%hash_copy , $class;
	} else {
		bless { bbs_kind => shift , thread_number => shift } , $class;
	}

}

#-----------------------------------------------------------
# 全てのURL情報を取得する
#-----------------------------------------------------------
sub get_all_url{
my $self = shift;
my $use = shift;

my($url) = Mebius::BBS::url($self->{'thread_number'},$self->{'bbs_kind'},$self->{'res_number'},$use);
$url;
}


#-----------------------------------------------------------
# 記事データページのURL
#-----------------------------------------------------------
sub thread_usefull_url_adjusted{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($url) = $self->get_all_url($use);

	if(Mebius::Admin::admin_mode_judge()){
		$url->{'thread_usefull_url_admin'};
	} else {
		$url->{'thread_usefull_url'};
	}

}


#-----------------------------------------------------------
# スレッドのURL
#-----------------------------------------------------------
sub thread_url_adjusted{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($url) = $self->get_all_url($use);

	if(Mebius::Admin::admin_mode_judge()){
		$url->{'thread_url_admin'};
	} else {
		$url->{'thread_url'};
	}

}


#-----------------------------------------------------------
# 掲示板のURL
#-----------------------------------------------------------
sub bbs_url_adjusted{

my $self = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($url) = $self->get_all_url($use);

	if(Mebius::Admin::admin_mode_judge()){
		$url->{'bbs_url_admin'};
	} else {
		$url->{'bbs_url'};
	}

}
package Mebius::BBS;

#-----------------------------------------------------------
# スレッドのURL ( 一般 )
#-----------------------------------------------------------
sub thread_url{

my($url) = url(@_);
my $self = $url->{'thread_url'};

}


#-----------------------------------------------------------
# スレッドのURL ( 一般 )
#-----------------------------------------------------------
sub thread_url_move{

my($url) = url(@_);
my $self = $url->{'thread_url_move'};

}

#-----------------------------------------------------------
# スレッドのURL ( 一般 )
#-----------------------------------------------------------
sub thread_url_number{

my($url) = url(@_);
my $self = $url->{'thread_url_number'};

}

#-----------------------------------------------------------
# スレッドのURL ( 一般 )
#-----------------------------------------------------------
sub bbs_url{

my($url) = url(undef,$_[0]);
my $self = $url->{'bbs_url'};

}


#-----------------------------------------------------------
# スレッドのURL ( 管理用 )
#-----------------------------------------------------------
sub bbs_url_admin{

my($url) = url(undef,$_[0]);
my $self = $url->{'bbs_url_admin'};

}

#-----------------------------------------------------------
# スレッドのURL ( 管理用 )
#-----------------------------------------------------------
sub thread_url_admin{

my($url) = url(@_);
my $self = $url->{'thread_url_admin'};

}

#-----------------------------------------------------------
# URL 全般
#-----------------------------------------------------------
sub url{

my $thread_number = shift;
my $bbs_kind = shift;
my $res_number = shift;
my %return;
my $use = shift if(ref $_[0] eq "HASH");
my($basic_init) = Mebius::basic_init();


	# サブ記事の場合
	if($use->{'SubThread'} && $bbs_kind !~ /^sub/){
		$bbs_kind = "sub$bbs_kind";
	} elsif($use->{'MainThread'}){
		$bbs_kind =~ s/^sub//g;
	}


	# パラメータの判定
	if(!Mebius::BBS::bbs_kind_judge($bbs_kind)){ return(); }
	if($thread_number && $thread_number =~ /[^0-9]/){ return(); }

	# 左右スライドの判定
	if($use->{'slide'}){
			if($use->{'slide'} =~ /^([-+])?[0-9]+$/){
				$thread_number += $use->{'slide'};
			} else {
				return();
			}
	}

	# データページなど
	if($use->{'r'}){

		if($use->{'r'} =~ /^[0-9a-z]+$/){

		} else {
			return();
		}
	}

# この位置
my($main_server_domain) = Mebius::main_server_domain($ENV{'SERVER_ADDR'});
my($admin_basic_url) = Mebius::Admin::basic_url($ENV{'SERVER_ADDR'});
#my($bbs_server_base_url_or_path) = bbs_base_url_or_path();
my $bbs_server_base_url_or_path = "http://$basic_init->{'bbs_domain'}/";

# BBSのURL
$return{'bbs_url'} = "${bbs_server_base_url_or_path}_$bbs_kind/"; #http://${main_server_domain}
$return{'bbs_url_admin'} = "${admin_basic_url}$bbs_kind.cgi";

	if(!Mebius::BBS::thread_number_judge($thread_number)){ return(\%return); }

$return{'thread_url'} = "$return{'bbs_url'}$thread_number.html";
$return{'thread_usefull_url'} = "$return{'bbs_url'}${thread_number}_$use->{'r'}.html";

$res_number ||= 0;
$return{'thread_url_move'} = "$return{'thread_url'}#S$res_number";
$return{'thread_url_number'} = "$return{'thread_url'}-$res_number";


$return{'thread_url_admin'} = "$return{'bbs_url_admin'}?mode=view&no=$thread_number";
$return{'thread_usefull_url_admin'} = "$return{'bbs_url_admin'}?mode=view&no=$thread_number&r=$use->{'r'}";



\%return;

}

#-----------------------------------------------------------
# インデックスファイル
#-----------------------------------------------------------
sub index_file_path{

my $bbs_kind = shift;
my($path) = Mebius::BBS::path($bbs_kind);

$path->{'index_file'};

}


#-----------------------------------------------------------
# 過去インデックス
#-----------------------------------------------------------
sub past_index_directory_path_per_bbs{

my $bbs_kind = shift;
my($path) = Mebius::BBS::path($bbs_kind);

$path->{'past_index_directory'};
}


#-----------------------------------------------------------
# 現行インデックス ディレクトリ
#-----------------------------------------------------------
sub index_directory_path_per_bbs{

my $bbs_kind = shift;
my($path) = Mebius::BBS::path($bbs_kind);

$path->{'index_directory'};
}

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
# ベースディレクトリ
#-----------------------------------------------------------
sub base_directory_path_per_bbs{

my($bbs_kind) = @_;
my($path) = path($bbs_kind);

$path->{'base_directory'};

}


#-----------------------------------------------------------
# パス
#-----------------------------------------------------------
sub path{

# 宣言
my $use = shift if(ref $_[0] eq "HASH");
my $realmoto = shift;
my $thread_number = shift;
my($share_directory) = Mebius::share_directory_path();
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
		#$data{'base_directory'} = "${base_init_directory}_bbs_data/_${moto}_bbs_data/";
		$data{'base_directory'} = "${share_directory}_bbs_data/_${moto}_bbs_data/";
	} else { die("Perl Die! Can't setting BBS path"); }

	# ▼インデックス関係
	if($moto && $data{'base_directory'}){
		$data{'index_directory'} = "$data{'base_directory'}_index_${moto}/";
	} else{ die("Perl Die! Can't setting BBS path"); }

	# 過去ログのインデックスディレクトリ
	if($moto && $data{'base_directory'}){
		$data{'past_index_directory'} = "$data{'base_directory'}_past_index/";
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

#-----------------------------------------------------------
# 掲示板の基本URL、または相対パスを返す
#-----------------------------------------------------------

sub bbs_base_url_or_path{

my($self);
my($basic_init) = Mebius::basic_init();
my($server_domain) = Mebius::server_domain();

	if($basic_init->{'bbs_domain'} eq $server_domain){
		$self = "/";
	} else {
		$self = "http://$basic_init->{'bbs_domain'}/";
	}

$self;

}




1;
