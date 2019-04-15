
package Mebius::Page;
use strict;

#-----------------------------------------------------------
# レス番と基本データから現在のページ数 &r=([0-9]+) を割り出す
#-----------------------------------------------------------
sub NowPagenumber{

my($type) = @_;
my($page_number,$now_res_number) = now_page_number_bbs_thread(@_);
my($self);

	# 整形
	if($page_number){
			if($type =~ /Admin-view/){
				$self = qq(&amp;r=$page_number);
			}
			else{
				$self = qq(_$page_number);
			}
	}

return($self,$now_res_number);

}

#-----------------------------------------------------------
# 掲示板スレッド、現在のページ数 ( r=? )
#-----------------------------------------------------------
sub now_page_number_bbs_thread{

# 宣言
my($type,$now_res_number,$res_count,$per_page,$per_page_first) = @_;
my($page_number,$min_resnumber);
my($my_use_device) = Mebius::my_use_device();

	# ページ分割設定を取り込みする場合
	#if($type =~ /Desktop-view/){
	if($my_use_device->{'mobile_flag'}){
		($per_page,$per_page_first) = Mebius::Page::InitPageNumber("Mobile-view");
	}
	#elsif($type =~ /Mobile-view/){
	else {
		($per_page,$per_page_first) = Mebius::Page::InitPageNumber("Desktop-view");
	}

	# ゼロの割り算を防ぐ
	if(!$per_page){ return(); }

	# ●レス番の分割を済ませていない場合
	if($type =~ /Split-resnumber/){
		my($now_res_number) = Mebius::Page::SplitResnumber(undef,$now_res_number);
	}

	# ▼記事のレス数を参照する場合
	if(defined $res_count){

			# レスが「最新ページ」に位置する場合
			if($now_res_number > $res_count - $per_page_first){
				$page_number = undef;
			}
			# ゼロ記事の場合
			elsif($now_res_number == 0){
				$page_number = 1;
			}
			# レスが「２ページ目以降」に位置する場合
			else{
				# 割り切れない、余分なレス数を計算
				my $left_resnumber = ($now_res_number - 1) % $per_page;
				# 今のページが $per_page の単位で、何レス目に当たるかを計算
				my $justy_resnumber = ($now_res_number -1) - $left_resnumber;
				# 今のページが $per_page の単位で、何ページ目に当たるかを計算
				my $justy_page_number = $justy_resnumber / $per_page;
				# 割り切ったページ数を、さらに何レス目かに換算
				$page_number = ($justy_page_number*$per_page)+1;
			}
	# ▼記事のレス数を無視する場合
	} else {

			if($now_res_number == 0){
				0;
			} else {
				my $left_res_num = $now_res_number % $per_page;
				$page_number = $now_res_number - $left_res_num + 1;
			}
	}

}

#-----------------------------------------------------------
# レス番を分割
#-----------------------------------------------------------
sub SplitResnumber{

# 宣言
my($type,$resnumber) = @_;
my($min_resnumber);

	# レス番を分割 ( ハイフン区切り )
	my($resnumber1,$resnumber2) = split(/-/,$resnumber);
	$resnumber = $resnumber1;
	if($resnumber2 ne "" && $resnumber2 < $resnumber1){ $resnumber = $resnumber2; }

	# レス番を分割 ( カンマ区切り )
	foreach(split(/,/,$resnumber)){
			if($_ eq ""){ next; }
			if($min_resnumber eq "" || $_ < $min_resnumber){ $min_resnumber = $_; }
	}
	if(defined($min_resnumber)){ $resnumber = $min_resnumber; }

return($resnumber);

}

#-----------------------------------------------------------
# レス番の照合
#-----------------------------------------------------------
sub Resnumber{

# 宣言
my($type,$target_resnumber,$select_resnumber) = @_;
my($hit_flag,$first_hit_flag,$first_resnumber);

#$target_resnumber = 今回判定するレス（１個）
# $select_resnumber = レス番指定全体

	# ハイフン区切り
	if($select_resnumber =~ /^(\d+)-(\d+)$/){
		($first_resnumber) = split(/-/,$select_resnumber);
	}

	# カンマ区切り
	elsif($select_resnumber =~ /^(\d+),(\d+)/){
			foreach(split(/,/,$select_resnumber)){
				if($first_resnumber eq "" || $_ < $first_resnumber){
					$first_resnumber = $_;
				}
			}
	}
	
	# 区切りなし
	else{
		$first_resnumber = $select_resnumber;
	}

	# 最初のレスがヒットした場合
	if($first_resnumber eq $target_resnumber){ $first_hit_flag = 1; }

	# 直接指定で判定
	if($select_resnumber eq $target_resnumber){ $hit_flag = 1; }

	# カンマ区切りで判定
	foreach(split(/,/,$select_resnumber)){
		if($_ eq $target_resnumber){ $hit_flag = 1; }
	}

	# ハイフン区切りで判定
	if($select_resnumber =~ /\-/){
		my($start,$end) = split(/\-/,$select_resnumber);
		if($target_resnumber >= $start){ $hit_flag = 1; }
		elsif($target_resnumber <= $end){ $hit_flag = 1; }
	}

return($hit_flag,$first_hit_flag);

}

#-----------------------------------------------------------
# ページ分割数
#-----------------------------------------------------------
sub InitPageNumber{

# 宣言
my($type) = @_;
my($per_page,$per_first_page);
my($my_use_device) = Mebius::my_use_device();

	# デスクトップ版
	if($type =~ /Desktop-view/){
			# 容量制限版
			if($my_use_device->{'limited_datasize_flag'}){
				$per_page = 100;		# 容量制限版、各記事１ページあたりの、最大レス表示個数
				$per_first_page = 10;	# 容量制限版、各記事の最初のページでの、レス表示個数		
			}
			# デスクトップ版
			else{
				$per_page = 100;		# ＰＣ版、各記事１ページあたりの、最大レス表示個数
				$per_first_page = 50;	# ＰＣ版、各記事の最初のページでの、レス表示個数
			}
	}	
	# モバイル版
	elsif($type =~ /Mobile-view/){
		$per_page = 20;		# 携帯版、各記事１ページあたりの、最大レス表示個数
		$per_first_page = 10;	# 携帯版、各記事の最初のページでの、レス表示個数
	}

return($per_page,$per_first_page);


}



1;
