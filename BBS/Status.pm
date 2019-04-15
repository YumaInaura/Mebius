

use strict;
package Mebius::BBS::Status;
use base qw(Mebius::Base::DBI);
use Mebius::BBS::Status;

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
"follow";
}


#-----------------------------------------------------------
# テーブルのカラム名
#-----------------------------------------------------------
sub main_table_column{

my $column = {
bbs_kind => { PRIMARY => 1 },
real_bbs_kind => { } , 
server_domain => { } , 
thread_number => { int => 1 } ,
bbs_title => { } , 
res_number => { int => 1 } ,
last_handle => { } , 
subject => { } , 
cnumber => { } , 
account => { } , 
regist_time => { int => 1 } ,
all_regist_count => { int => 1 } , 
last_update_time => { int => 1  } , 
create_time => { int => 1  } , 

};

$column;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();

	if($param->{'type'} eq "create_bbs_form"){
		$self->create_bbs_form();
	} elsif($param->{'type'} eq "create_bbs"){
		$self->create_bbs();
	} else {
		die;
	}

exit;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_bbs_form{

my $self = shift;
my($print);
my $html = new Mebius::HTML;
my $bbs_status = new Mebius::BBS::Status;

	if(!Mebius::my_account()->{'master_flag'}){
			main::error("作成権限がありません。");
	}

$print .= $html->tag("h1","新しい掲示板の作成");
$print .= $html->start_tag("form",{ method => "post" });

$print .= $html->input("hidden","mode","bbs_status");
$print .= $html->input("hidden","type","create_bbs");
$print .= $html->input("text","bbs_kind","",{ placeholder => "例) comic " , autofocus => 1 });
#$print .= $html->input("text","category","",{ placeholder => "カテゴリ名。例) etc " });
#$print .= $html->input("text","bbs_title","");

$print .= $html->input("submit");

$print .= $html->close_tag("form");


Mebius::Template::gzip_and_print_all({ source => "utf8" },$print);

exit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub create_bbs{

my $self = shift;
my($param) = Mebius::query_single_param();

my $bbs_kind = $param->{'bbs_kind'} || main::error("何か入力して下さい。");
#my $category = $param->{'category'} || main::error("カテゴリを入力して下さい。");

	if($ENV{'REQUEST_METHOD'} ne "POST"){
		main::error("POST送信して下さい。");
	}

# , bbs_title => $param->{'bbs_title'}

my $bbs_status = new Mebius::BBS::Status;
$bbs_status->update_or_insert_main_table({ bbs_kind => $bbs_kind , regist_time => time  },{ Debug => 0 });

$self->make_new_bbs($bbs_kind);

Mebius::Redirect("","/jak/$bbs_kind.cgi?mode=init_edit");

exit;

}

#-----------------------------------------------------------
# 新しい掲示板を作る
#-----------------------------------------------------------
sub make_new_bbs{

my $self = shift;
my($bbs_kind) = @_;
my($bbs) = Mebius::BBS::init_bbs_parmanent($bbs_kind);
my($basic_init) = Mebius::basic_init();
my($index_file_path) = Mebius::BBS::index_file_path($bbs_kind) || die;

# 基本ディレクトリの作成
Mebius::Mkdir(undef,$bbs->{'data_directory'});

# 設定ファイル .ini の作成
Mebius::Fileout("Deny-f-file-return",$bbs->{'file'},"New BBS<>\n");

}



1;
