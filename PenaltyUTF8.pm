
use strict;
package Mebius::Penalty;
use Mebius::Host;
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
sub my_isp_data{

my $self = shift;
my $host = new Mebius::Host;
my $my_isp = $host->my_isp();

my %data = Mebius::penalty_file("Isp",$my_isp);

\%data;

}

#-----------------------------------------------------------
# ペナルティを与える
#-----------------------------------------------------------
sub add{

my $self = shift;
my $target = shift;
my $use = shift;
my $relay_use = Mebius::Operate->overwrite_hash($use,{ Penalty => 1 });
$self->control($target,$relay_use);


}

#-----------------------------------------------------------
# ペナルティをキャンセル
#-----------------------------------------------------------
sub cancel{

my $self = shift;
my $target = shift;
my $use = shift;

my $relay_use = Mebius::Operate->overwrite_hash($use,{ Cancel => 1 });
$self->control($target,$relay_use);

}


#-----------------------------------------------------------
# ペナルティファイルを一斉に操作
#-----------------------------------------------------------
sub control{


my $self = shift;
my $target = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($relay_type);

	if($use->{'Penalty'}){
		$relay_type .= qq( Penalty);
	} elsif($use->{'Cancel'}){
		$relay_type .= qq( Repair);
	} else {
		die("Please select mode.");
	}

my $host = $target->{'host'};
my $cookie = $target->{'cnumber'};
my $mobile_uid = $target->{'mobile_uid'};
my $account = $target->{'account'};

my $subject = $use->{'place'} || $use->{'subject'};
my $comment = $use->{'comment'} || $target->{'text'} || $target->{'comment'};
my $url = $use->{'url'};
my $count = $use->{'count'} || 1;
my $reason = $use->{'reason_text'};

	if($use->{'source'} eq "utf8"){
		shift_jis($subject,$comment,$reason);
	}

my @other_data = ($subject,$comment,$url,$count,$reason);

	if($cookie){
		Mebius::penalty_file("Cnumber Renew $relay_type",$cookie,@other_data);
	}
	if($host){
		Mebius::penalty_file("Host Renew $relay_type",$host,@other_data);
	}
	if($mobile_uid){
		Mebius::penalty_file("Agent Renew $relay_type",$mobile_uid,@other_data);
	}
	if($account){
		Mebius::penalty_file("Account Renew $relay_type",$account,@other_data);
	}


}


1;