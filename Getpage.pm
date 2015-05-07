
# use strict;

use strict;
package Mebius::Getpage;
use LWP::Simple;

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_page{

my $self = shift;
my $url = shift;
my $html = LWP::Simple::get($url);

$html;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub get_on_array{

my $self = shift;
my $url = shift;
my @html = Mebius::getpage("Array",$url);

@html;
}




package Mebius;
use Socket;

#-----------------------------------------------------------
# �O���y�[�W���擾
#-----------------------------------------------------------
sub getpage{

# �錾
my($type,$get_url) = @_;
my($port0,$ipaddr,$domain,$sock_addr,$header,$html,@html);
my($domain,$get,$title,$request_uri,$http);

	# �֎~����t�q�k
	if($get_url =~ /pagead/){ return(); }

	# URL�`�F�b�N
	if($get_url =~ /(https?):\/\/([a-zA-Z0-9\.]+)(.*)/){ ($http,$domain,$get) = ($1,$2,$3); } else { return(); }

	# ���O�����
	#if($main::int_dir){ main::access_log("Get-page","type : $type / Get-url : http://$domain$get"); }

$port0 = getservbyname("$http", "tcp");
$ipaddr = &Socket::inet_aton($domain) or return("�z�X�g�����o�G���[�i$domain�j<br>\n");
$sock_addr = &Socket::pack_sockaddr_in($port0, $ipaddr);
socket(SOCK, PF_INET, SOCK_STREAM, 0) or return("�\�P�b�g�쐬�G���[�i $domain / $get / $ipaddr / $port0 �j<br>\n");
connect(SOCK, $sock_addr) or return("�T�[�o�[�ڑ��G���[�i $domain / $get / $ipaddr / $port0 �j<br>\n");

select(SOCK);
$|=1;
select(STDOUT);

# ���N�G�X�g���e�i���s�������Ȃ��j
print SOCK << "END_OF_DOC";
GET $get HTTP/1.0
Host:$domain
QUERY_STRING: 
Connection:close

END_OF_DOC


	# �w�b�_�𕪗�
	while(<SOCK>){
		$header .= $_;
			if(m/^\r\n$/){ last; }
	}

	# HTML�u����
	while(<SOCK>){

		push @html , $_;

		# �y�[�W�^�C�g�����擾
		if($_ =~ m!<title>(.+)</title>!){ $title = $1; }

		while(s/</&lt;/is){ };
		while(s/>/&gt;/is){ };

		#&jcode::convert(\$_, 'sjis');
		#  while(s/\r\n|\r|\n/<br>/is){ };

		$html .= qq($_<br>);
	}

close SOCK;

	# ���`����
	if($type =~ /Html/){
		$html =~ s/(.+)&lt;body&gt;//;
		$html =~ s/&lt;\/body&gt;(.+)//m;
	}

	# �^�C�g��
	if($type =~ /Title/){ 
			if($type =~ /Fix-title/){
				($title) = split(/ \| /,$title);
				$title =~ s/(\r|\n|\s+$)//g;
			}
		return($title); 
	}

	# �������O�����
	if($main::int_dir){ main::access_log("Get-page-successed","type : $type / Get-url : http://$domain$get / \n\n$header"); }

	if($type =~ /Header/){ return($header); }
	elsif($type =~ /Array/){ return(@html); }
	else{ return($html); }

return($header,$html,$title);

}


1;

