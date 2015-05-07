
use strict;
package Mebius::SNS::URL;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------

sub new{
my $class = shift;
bless {} , $class;
}

#-----------------------------------------------------------
# アカウントのURL
#-----------------------------------------------------------
sub account_url{
my $self = shift;
my($url) = $self->url(@_);
$url->{'account'};
}

#-----------------------------------------------------------
# アカウントの相対URL
#-----------------------------------------------------------
#sub account_url{
#my $self = shift;
#my($url) = $self->url(@_);
#$url->{'account_relative'};
#}

#-----------------------------------------------------------
# スレッドのURL
#-----------------------------------------------------------
sub diary_url{
my $self = shift;
my($url) = $self->url(@_);
$url->{'thread'};
}

#-----------------------------------------------------------
# スレッドのURL
#-----------------------------------------------------------
sub diary_url_move{
my $self = shift;
my($url) = $self->url(@_);
$url->{'thread_move'};
}

#-----------------------------------------------------------
# スレッドの相対URL
#-----------------------------------------------------------
sub diary_relative_url{
my $self = shift;
my($url) = $self->url(@_);
$url->{'thread_relative'};
}

#-----------------------------------------------------------
# アカウントへのリンク
#-----------------------------------------------------------
sub account_link{

my $self = shift;
my $account = shift;
my $handle = shift;
my $sharp = shift;
my($text);

	if($account eq ""){ return(); }

	if($handle){
		$text = $handle . ' @' . $account;
	} else {
		$text = '@' . $account;
	}

my $link = $self->account_link_free_text($account,$text,$sharp);

$link;

}


#-----------------------------------------------------------
# アカウントへのリンク
#-----------------------------------------------------------
sub account_link_free_text{

my $self = shift;
my $account = shift;
my $text = shift;
my $sharp = shift;
my $html = new Mebius::HTML;
my($class);

	if($account eq ""){ return(); }
	if($text eq ""){
		$text = "\@$account";
		$class = "ac";
	}

my $account_url = $self->account_url($account);
	if($sharp){
		$account_url .= qq(#$sharp);
	}

my $link = $html->href($account_url,$text,{ class => $class });

$link;

}



#-----------------------------------------------------------
# URL
#-----------------------------------------------------------
sub url{

my $self = shift;
my($account,$diary_number,$res_number) = @_;
my($basic_init) = Mebius::basic_init();
my(%self);

	# アカウント名判定
	if(Mebius::Auth::account_name_error($account)){ return(); }
	if($diary_number =~ /[^0-9]/){ return(); }

$self{'account'} = Mebius::URL->relative_or_full_url("$basic_init->{'auth_url'}$account/");
$self{'account_relative'} = e($basic_init->{'auth_relative_url'}).e($account).q(/);
my $diary_path = "d-$diary_number";
$self{'thread_relative'} = e($self{'account_relative'}).e($diary_path);
$self{'thread'} = e($self{'account'}).e($diary_path);
$self{'thread_move'} = e($self{'account'}).e($diary_path).q(#S).e($res_number) if(defined $res_number);

\%self;

}

1;
