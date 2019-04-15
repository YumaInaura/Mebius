
use strict;
package Mebius::Auth;
use Mebius::Query;

#-----------------------------------------------------------
# �T�[�o�[�ԃ��_�C���N�g
#-----------------------------------------------------------
sub ServerMove{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$server_domain) = @_;
my(undef,undef,$redirect_last_url,$plus_query,$exclusion_names) = @_ if($type =~ /Use-all-query/);
my($redirect_url_top,$doned_query,$doned,$max_doned,$redirect_url_plus);
my($q) = Mebius::query_state();

	# �����ő��
	if($type =~ /All-domains/){
		$max_doned = $basic_init->{'number_of_domains'};
	}
	elsif($type =~ /All-servers/){
		$max_doned = $basic_init->{'number_of_servers'};
	}

	# ����������
	{

		$doned = $main::in{'doned'};
			if(!$doned){ $doned = 1; }
		$doned_query = $doned + 1;
	}

	# ���_�C���N�g��� $dec_postbuf �����` ($decoded_query ����̏ꍇ�́AForeachQuery ���̏����ŕ⊮���� )
	if($type =~ /Use-all-query/){
		
		my($query) = Mebius::ForeachQuery(undef,undef,"doned,$exclusion_names");
		$redirect_url_plus = qq(?$query&doned=$doned_query);
			if($plus_query && $doned == 1){ $redirect_url_plus .= qq(&$plus_query); }
	}

	# �S�h���C�� ( Cookie�̂��߂̏��� )  
	if($type =~ /All-domains/){
			if($server_domain eq "sns.mb2.jp"){
				$redirect_url_top = "http://mb2.jp/_auth2/"
			}
			elsif($server_domain eq "mb2.jp"){
				$redirect_url_top = "http://aurasoul.mb2.jp/_auth/"
			}
			elsif($server_domain eq "aurasoul.mb2.jp"){
				$redirect_url_top = "http://sns.mb2.jp/"
			}
			elsif($server_domain eq "localhost"){
				$redirect_url_top = "http://localhost/_auth/"
			}
	}

	# �T�[�o�[��
	else{
			if($server_domain eq "aurasoul.mb2.jp" || $server_domain eq "sns.mb2.jp"){
				$redirect_url_top = "http://mb2.jp/_auth2/"
			}
			elsif($server_domain eq "mb2.jp"){
				$redirect_url_top = "http://sns.mb2.jp/"
			}
			elsif($server_domain eq "localhost"){
				$redirect_url_top = "http://localhost/_auth/"
			}
	}


	# �����񐔂��}�b�N�X�ɒB�����ꍇ
	if($type =~ /Direct-redirect/ && $doned >= $max_doned){

			# �N�G����������߂����擾
			my($backurl) = Mebius::back_url( $q->param('back_url') );

			# �߂�悪�w�肳��Ă���A�Ȃ������K��URL�̏ꍇ
			if($type =~ /Backurl/ && $backurl->{'url'}){
				Mebius::Redirect(undef,$backurl->{'url'});
			}
			# �ŏI�I�ȃ��_�C���N�g��URL
			elsif($redirect_last_url){
				Mebius::Redirect(undef,$redirect_last_url);
			}
			else{
				return();
			}
	}
	# �������_�C���N�g
	elsif($type =~ /Direct-redirect/ && $redirect_url_top){

#if($main::myadmin_flag >= 5){
#main::error("$redirect_url_top$redirect_url_plus");
#}

		Mebius::Redirect(undef,"$redirect_url_top$redirect_url_plus");
	}



return($redirect_url_top);

}

1;