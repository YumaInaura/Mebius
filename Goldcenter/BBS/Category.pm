
use strict;
use Mebius::BBS;
package Mebius::BBS::Category;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init{
my $self = shift;
my(%init);
$init{'BCL'}->[0] = "カテゴリ";

\%init;

}

#-----------------------------------------------------------
# モード分岐
#-----------------------------------------------------------
sub junction{

my $self = shift;
my($param) = Mebius::query_single_param();

	# 値のチェック
	if($param->{'category'} =~ /[^0-9a-z]/){
		Mebius->error("カテゴリの指定が不正です。");
	}

$self->index_view();

}

#-----------------------------------------------------------
# カテゴリのインデックス
#-----------------------------------------------------------
sub index_view{

my $self = shift;
my $init = $self->init();
my($param) = Mebius::query_single_param();
my($init_category) = Mebius::BBS::init_category_parmanent($param->{'category'});
my $init_category_utf8 = hash_to_utf8($init_category);
my $threads_dbi = Mebius::BBS::ThreadStatus->fetchrow_main_table({ category => $param->{'category'} });
my $bbs_all_hash = Mebius::BBS->all_bbs_hash();
my $html = new Mebius::HTML;
my($print,$index_line,$hit);

	# 各種チェック
my $all_category = Mebius::BBS->all_bbs_hash_per_category();
	if(!$all_category->{$param->{'category'}}){ Mebius->error("このカテゴリは存在しません。"); }

# 更新時間順にスレッドをソート
my @sorted_index = sort { $b->{'regist_time'} <=> $a->{'regist_time'} } @{$threads_dbi};

	# 展開
	foreach my $hash_data ( @sorted_index ){

		my $bbs_kind = $hash_data->{'bbs_kind'};
		my $bbs_title = $bbs_all_hash->{$bbs_kind}->{'title'};
			if($bbs_kind =~ /^sc/){ next; }

			if($index_line .= Mebius::BBS::Index->view_line_core(undef,$hash_data,$hit,{ bbs_kind => $bbs_kind , bbs_title => $bbs_title })){
					$hit++;
			}

			if($hit >= 100){
				last;
			}

	}


# HTMLを定義
$print .= qq(<div class="center">);
$print .= $html->tag("h1","$init_category_utf8->{'title'}カテゴリ",{ class => "bbs_title inline" });
$print .= Mebius::BBS::Index::other_bbs_link_area($param->{'category'});
$print .= qq(</div>);
$print .= Mebius::BBS::Index->round_menu(undef,$index_line,{ Category =>  });

# HTMLを出力
Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => "$init_category_utf8->{'title'}カテゴリ" , BCL => [$init_category_utf8->{'title'}] , css_files => ["bbs_all","blue1"]},$print);

exit;

}



1;
