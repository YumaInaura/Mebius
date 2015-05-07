
use strict;
package Mebius::BBS::URL;

#-----------------------------------------------------------
# おぶじぇくと しこう
#-----------------------------------------------------------

sub new {

my $class = shift;
#my $hash = shift;
my $hash = {};
bless $hash , $class;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub report_thread{

my $class = shift;
my $init_bbs = shift;
my($basic_init) = Mebius::basic_init();
my($self);
my($request_url_encoded) = Mebius::request_url_encoded();

	# 削除依頼記事へのリンク
	if($init_bbs->{'report_thread_number'}){
			if($ENV{'HTTP_COOKIE'}){
				$self = qq($basic_init->{'report_bbs_url'}?mode=view&amp;no=$init_bbs->{'report_thread_number'}&amp;report_url=$request_url_encoded);
			} else {
				$self = qq($basic_init->{'report_bbs_url'}$init_bbs->{'report_thread_number'}.html);
			}
	}	else {
		my($init_category) = Mebius::BBS::init_category_parmanent($init_bbs->{'category'});
			if($ENV{'HTTP_COOKIE'}){
				$self = qq($basic_init->{'report_bbs_url'}?mode=view&amp;no=$init_category->{'report_number'}&amp;report_url=$request_url_encoded);
			} else {
				$self = qq($basic_init->{'report_bbs_url'}$init_category->{'report_number'}.html);
			}
	}
	if(!$self){
		$self = qq($basic_init->{'report_bbs_url'});
	}

$self;

}

package Mebius::BBS;


#-----------------------------------------------------------
# URLから bbs_kind と スレッド番号を抽出
#-----------------------------------------------------------
sub thread_url_to_bbs_kind_and_other {

my($url) = @_;
my($bbs_kind,$thread_number);

	if($url =~ m!^https?://(?:[a-z0-9\.]+?)/_([a-z0-9]+?)/(?:([0-9]+?)(?:_[a-z0-9]+?)?.html)?!){
		$bbs_kind = $1;
		$thread_number = $2;
	} else {
		0;
	}

$bbs_kind,$thread_number;

}

#-----------------------------------------------------------
# URLからデータへ
#-----------------------------------------------------------
sub thread_url_to_thread_data{

my($bbs_kind,$thread_number) = thread_url_to_bbs_kind_and_other(@_);
my($self);

	if($bbs_kind && $thread_number){
		($self) = Mebius::BBS::thread_state($thread_number,$bbs_kind);
	}

$self;

}


1;
