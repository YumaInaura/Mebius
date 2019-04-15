
use strict;
package Mebius::Question::URL;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 質問本体
#-----------------------------------------------------------
sub question{

my $self = shift;
my $question_number = shift;
my $init = Mebius::Question->init();
my($url);

$url = "$init->{'base_url'}?q=$question_number";

$url;

}

#-----------------------------------------------------------
# サイトマップ
#-----------------------------------------------------------
sub sitemap{

my $self = shift;
my $year = shift;
my $month = shift;
my $init = Mebius::Question->init();
my($url);

$url = "$init->{'base_url'}sitemap-$year-$month.xml";

$url;


}


1;
