
package Mebius;

#-----------------------------------------------------------
# URL���C��
#-----------------------------------------------------------

sub Fixurl{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$url) = @_;

my $jak_directory = "/jak/";

	# ���Ǘ��p���畁�ʗp�� (���e��)
	if($type =~ /Admin-to-normal/){

		# �V���[�v�ȍ~���폜
		$url =~ s/#S([0-9]+)//g;
		$url =~ s/#(RES|RESNUMBER)//g;

		# ���X��
		$url =~ s/&gt;&gt;([0-9]+)/No\.$1/g;

		# ���ʂȈ������Ȃ���
		$url =~ s/&amp;(wdhost|wdage|wdac|all)=([0-9])//g;
		#$url =~ s/&amp;backurl=(.+?)($| |(<br>)|#|&amp;)/$2/g;
		$url =~ s/(\?|&amp;)backurl=([\w\%]+)//g;

		# �폜�˗��f���ł́A���|�[�^�[�p�̈������폜
		$url =~ s/(\?|&amp;)reporter_(id|host|trip|account|agent|cnumber)=([\w\%]+)//g;

		# ���X�\��
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;No=([0-9\-]+)/\/_$1\/$2\.html-$3/g;

		# �e���X
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;r=([0-9a-z\-]+)/\/_${1}\/${2}_${3}.html/g;
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;No=([0-9\-]+)#S([0-9]+)/\/_$1\/$2\.html-$3/g;

		# �g�єł��o�b�ł�
		$url =~ s/\/_([a-z0-9\_]+)\/k([0-9_])\.html/\/_$1\/$2\.html/g;

		# �L��������
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9]+)&amp;word=(.+)/\/_$1\/?mode=view&amp;no=$2&amp;word=$3/g;

		# �ʋL��
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=view&amp;no=([0-9a-z]+)/\/_$1\/$2\.html/g;

		# �L����������
		$url =~ s/${jak_directory}([a-z0-9]+)\.cgi\?mode=find&amp;([a-zA-Z0-9\%\&\=]+)/\/_$1\/?mode=find&amp;$2/g;

		# ���G�����y�[�W
		$url =~ s!${main::main_url}\?mode=pallet-viewer-([a-z0-9]+)-([0-9]+)-([0-9]+)!/_main/pallet-viewer-$1-$2-$3.html!g;

		# �f���s�n�o
		$url =~ s!${jak_directory}([a-z0-9]+).cgi($|[^\?])!/_$1/$2!g;

		# CGI�ėp
		$url =~ s!${jak_directory}(\w+?).cgi\?mode=([\w-]+)!/_$1/$2.html!g;

		# �ujak�v�u�`.cgi�v���Ȃ���
		$url =~ s/${jak_directory}/\//g;
		$url =~ s/([\w]+)\.cgi//g;

		# �������͕��A�G�X�P�[�v
		$url =~ s/\[%\]/%/g;

			# �������ݎ��̃I�[�g�����N
			if($main::in{'auto_link'}){
				foreach(@main::auto_link_tag){
				my($ch_txt,$ch_url)= split(/=/,$_);
					$url =~ s/\Q$ch_txt\E/<a href=\"${main::guide_url}$ch_url\">$1$ch_txt\<\/a>/g;
				}
			}

			# �h���C����W�J
			foreach(@main::all_domains){
				# https �� http ��
				$url =~ s!https://$_/!http://$_/!g;
			}
	}


	# �����ʗp����Ǘ��p��
	if($type =~ /Normal-to-admin/){
		
		# MOVE�����N����
		$url  =~ s/([0-9a-z\-]+)#a/$1/g;
		$url  =~ s/([0-9a-z\-]+)#c/$1/g;

		# ���A���d�f�B���N�g��
		$url  =~ s/_([0-9a-z]+)_([0-9a-z]+)\//_$1\//g;

		# �g�єłt�q�k���o�b�łt�q�k��
		#$url =~ s/_([0-9a-z]+)\/km0.html/_$1\//g;
		#$url =~ s/_([0-9a-z]+)\/k([0-9a-z]+)\.html/_$1\/$2\.html/g;
		#$url =~ s/_([0-9a-z]+)\/k([0-9]+)/_$1\/$2/g;

		# �ʃ��X�t�q�k
		$url =~ s/_([a-z0-9]+)\/([0-9]+)\.html-([0-9,\-]+)/jak\/$1\.cgi?mode=view&amp;no=$2&amp;No=$3#RESNUMBER/g;
		$url =~ s/#RESNUMBER#S([0-9]+)/#S$1/g;
		$url =~ s/#RESNUMBER#RESNUMBER//g;

		# �L���t�q�k
		$url =~ s/_([a-z0-9]+)\/([0-9]+)\.html/jak\/$1\.cgi?mode=view&amp;no=$2/g;

		if($type =~ /Multi-fix/){
			$url =~ s/(\w+)-(\w+)-(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2-$3-$4/g;
			$url =~ s/(\w+)-(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2-$3/g;
			$url =~ s/(\w+)-(\w+).html/$main::realmoto\.cgi?mode=$1-$2/g;
			$url =~ s/(\.\/)?([0-9]+)\.html/$1$main::realmoto\.cgi?mode=view&amp;no=$2/g;
			$url =~ s/(\w+).html/$main::realmoto\.cgi?mode=$1	/g;
		}

		# �L���y�[�W�߂���̂t�q�k
		$url =~ s/_([a-z0-9]+)\/([0-9]+)_([0-9a-z]+)\.html/jak\/$1\.cgi?mode=view&amp;no=$2&amp;r=$3/g;

		# �f���C���f�b�N�X�t�q�k
		$url =~ s/_([a-z0-9]+)\/([^0-9a-z])/jak\/$1\.cgi$2/g;

		# ���[���y�[�W
		$url =~ s/rule.html/?mode=rule/g;

		# ���G�����y�[�W
		#$url =~ s!/_main/pallet-viewer-([a-z0-9]+)-([0-9]+)-([0-9]+)\.html!${main::main_url}?mode=pallet-viewer-$1-$2-$3!g;

		# �ėpURL ��-��-��-.html
		$url =~ s!/_(main)/(.+)(\-[.]+)?(\-[.]+)?(\-[.]+)?\.html!/jak/$1.cgi?mode=$2$3$4!g;

		# CGI�ėp
		#$url =~ s!/_(\w+)/([\w-]+).html!/jak/$1.cgi\?mode=$2!g;

		# SNS
		$url =~ s/jak\/auth.cgi/_auth\//g;

		# SSL
		$url =~ s!h?ttp://([a-zA-Z0-9\.]+)/jak/!$basic_init->{'admin_http'}://$1/jak/!g

	}

return($url);

}

1;

