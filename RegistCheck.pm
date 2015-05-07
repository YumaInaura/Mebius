
use strict;
use Mebius::Echeck;
use Mebius::Regist;
use Mebius::Auth;
package Mebius::Regist;
use Mebius::Export;

#-----------------------------------------------------------
# ID�ƃp�X���[�h�̐V�K�o�^�`�F�b�N
#-----------------------------------------------------------
sub PasswordCheck{

# �Ǐ���
my($type,$id,$pass,$pass2,$id_minlength,$pass_minlength,$id_maxlength,$pass_maxlength) = @_;

$id = e($id);
$pass = e($pass);
$pass2 = e($pass2);


	# ID�̍ŏ�/�ő啶����
	if(!$id_minlength){ $id_minlength = 3; }
	if(!$id_maxlength){ $id_maxlength = 10; }

	# �p�X���[�h�̍ŏ�/�ő啶����
	if(!$pass_minlength){ $pass_minlength = 6; }
	if(!$pass_maxlength){ $pass_maxlength = 20; }

	# ID�`�F�b�N
	if($type !~ /Not-check-(id|account)/){
		my($id_error_flag) = Mebius::Auth::AccountName(undef,$id);
			if($id_error_flag){ $main::e_com .= $id_error_flag; }
	}

	# �p�X���[�h�`�F�b�N�̂��߂̏���
	my ($first_word_password) = substr($pass,0,1);
	my ($two_word_password) = substr($pass,0,2);

	# �p�X���[�h�`�F�b�N
	if($pass eq ""){
		$main::e_com .= qq(�p�X���[�h����͂��Ă��������B<br>);
	}
	elsif(length($pass) < $pass_minlength || length($pass) > $pass_maxlength){
		$main::e_com .= qq(�p�X���[�h�͔��p $pass_minlength - $pass_maxlength���� �œ��͂��Ă��������B<br>);
	}
	elsif($pass =~ /^(123|abc)/i){
		$main::e_com .= qq(�p�X���[�h�� [ 123 ] [ abc ] �ȂǁA�P���ȑg�ݍ��킹���g��Ȃ��ł��������B<br>);
	}
	elsif($pass =~ /^(\Q$first_word_password\E)+$/){
		$main::e_com .= qq(�p�X���[�h�� [ 1111 ] �ȂǁA�P���ȑg�ݍ��킹���g��Ȃ��ł��������B<br>);
	}
	elsif($pass =~ /^(\Q$two_word_password\E)+$|(\Qtwo_word_password\E){3,}/){
		$main::e_com .= qq(�p�X���[�h�� [ 1212 ] �ȂǁA�P���ȑg�ݍ��킹���g��Ȃ��ł��������B<br>);
	}
	elsif($pass =~ /(pass)/i){
		$main::e_com .= qq(�p�X���[�h�ɂ��̃t���[�Y \( $1 \) �͎g���܂���B<br>);
	}
	elsif($pass =~ /^(\d{1,6})$/){
		$main::e_com .= qq(���������̒Z������́A�p�X���[�h�ɂ͏o���܂���B�A���t�@�x�b�g��L����D��܂��Ă��������B<br>);
	}

	# �m�F�p�p�X���[�h�̃`�F�b�N
	if($type !~ /Not-confirm-password/){
			if($pass && $pass2 eq ""){
				$main::e_com .= qq(�m�F�p�̃p�X���[�h����͂��Ă��������B<br>);
			}
			elsif($pass ne $pass2){
				$main::e_com .= qq(�p�X���[�h�Ɗm�F�p�̃p�X���[�h����v���܂���B<br>);
			}
	}

	# ID�ƃp�X���[�h�����Ă���ꍇ
	if($id && $pass && (index($pass,$id) >= 0 || index($id,$pass) >= 0)){
		$main::e_com .= qq(�A�J�E���g���ƃp�X���[�h���������Ă��܂��B<br>); 
	}

	# �A�J�E���g����ID�����Ă���ꍇ
	my($encid) = main::id();
	if($encid && $pass && (index($pass,$encid) >= 0 || index($encid,$pass) >= 0)){
		$main::e_com .= qq(�A�J�E���g�� ��ID <i>$encid</i> ���������Ă��܂��B$encid,$pass<br>); 
	}

	# �G���[
	if($type =~ /Error-view/ && $main::e_com){
		main::error("$main::e_com");
	}

return();

}

#-----------------------------------------------------------
# �f���̑薼�`�F�b�N
#-----------------------------------------------------------
sub SubjectCheckBBS {

# �錾
my($type,$subject,$comment,$bbs_concept) = @_;
my($zatudan_flag,$sometime_flag,$alert_flag,$deai_flag);

# �薼�G���R�[�h
my($subject_encoded) = Mebius::Encode(undef,$subject);

# �m�F��̋L��
my $please_find_url = "./?mode=find&amp;word=$subject_encoded";

	# ���o��n
	if($subject =~ /(�ގ�|�ޏ�)(.*)(��W|�ق���|�~����)/x){ $deai_flag = 1; }
	if($deai_flag){
		$alert_flag = "�o��n";
		$main::a_com .= qq(���薼�`�F�b�N - �o��n�Ƃ��Ďg���₷���L���ł͂���܂��񂩁H�@�o��n���p���N����Ȃ��悤�A�\\���ɂ����ӂ��������B<br>);
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}

	# ���悭����L��
	if($subject =~ /((����)(���k)|���o�i)/x){
		$sometime_flag = 1;
	}
	if($sometime_flag){
		$alert_flag = "�悭����L��";
		$main::a_com .= qq(���薼�`�F�b�N - �悭����L�� ( $subject ) �͏d���L���Ƃ��č폜����₷���Ȃ�܂��B�@���ɓ����e�[�}�̋L�����Ȃ����ǂ����A<a href="$please_find_url">���m�F</a>���������B<br>);
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}

	# ���悭����G�k�L��
	if($bbs_concept !~ /ZATUDANN-OK1/){
			if($subject =~ /
				(�ɂ�(�l|�q|�e))
				|((��)�ł�)(.*)(�b��|����)
				|(���e)
				|(�G�k|������)
				|(�ɐl)
				|(������ׂ�)
			/x){ $zatudan_flag = 1; }
	}

	if($zatudan_flag){
		$main::a_com .= qq(���薼�`�F�b�N - �e�[�}�̂Ȃ��G�k�L�� ( $subject ) �́A�d���L���Ƃ��č폜����₷���Ȃ�܂��B�@���Ɂu�����G�k�n�v�̋L�����Ȃ����A<a href="$please_find_url">���m�F</a>���������B<br>);
		$alert_flag = "�悭����G�k";
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}


return(undef,$alert_flag);

}




#-------------------------------------------------
# ���ӓ��e�̃`�F�b�N
#-------------------------------------------------
	# �������̃R�c �F
	# �P�D�y�悭���錾���񂵁z�͕��͂��P�s���`�F�b�N���Ĉꊇ����B
	# �Q�D�y�����ʍr�炵�A�P���\���n�z�̓o�b�h�L�[���[�h�̗ʂ��`�F�b�N�B
	# �R�D�y����ȊO�̓��e�z�́A���͑S�̂���y�L�[���[�h�g�ݍ��킹�z���`�F�b�N�B�i�`�F�[�����e����̎��̂悤�Ɂj
	# �S�D�y�ǂ����e�z�y���ԓ��ł��g�������ȕ\���z�̓|�C���g��Ⴍ���邩��O�ݒ���B
	# �T�D�y�����̃T���v���z���W�߂ĉ��P�ɓw�߂邱�ƁB
#-------------------------------------------------
sub EvilCheck{

# �錾
my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($check2) = ($check);
my($error_flag,$error_border_keyword,$evilnum,$alert_flag,$comment_split,$evilnum_fraze,$evilflag_kajou,$check_oneline,$good_flag);
my($error_type,$error_subject,$alert_subject,$point_view,$check_flag_buf,$alert_border_keyword,$evilnum_light,$evil_word);
my($fraze_check_flag);
my($error_border_fraze,@kajou_word,$alert_border_fraze);
my($badword_keyword,@badword_keyword,@badword_fraze,$badword_fraze,$check_line,$keyword_check_flag,$alert_type);
my($period_num,$i,$error_odds,@delreport_word,$guchi_flag);

	# ���^�[������ꍇ
	if($concept =~ /NOT-ECHECK/){ return(); }

# �`�F�b�N�p�ɃX�y�[�X�A���s�����폜
$check =~ s/(\s|�@|�A|�E)//g;

	# ���͗ʂɉ����ă{�[�_�[���C�����㉺������
	if($type =~ /Sousaku/){ $error_odds = 5.0; }
	elsif($category eq "narikiri"){ $error_odds = 3.0; }
	elsif(length($check) <= 25*2){ $error_odds = 0.25; }
	elsif(length($check) <= 50*2){ $error_odds = 0.5; }
	elsif(length($check) >= 500*2){ $error_odds = 1.5; }
	elsif(length($check) >= 1000*2){ $error_odds = 2.0; }
	else{ $error_odds = 1.0; }

	# �ő吔��ݒ� - ��ʌn
	$error_border_keyword = 5*$error_odds;
	$alert_border_keyword = 3*$error_odds;
	$error_border_fraze = 2*$error_odds;
	$alert_border_fraze = 1*$error_odds;

	# ���s�𖳎����ă`�F�b�N
	if($check2 =~ /
			(�`����)(.{0,100})(�؍�|�ݓ�)
			|(�؍�|�ݓ�)(.{0,100})(�`����)
		/x){

		$evilnum_fraze++;
		$check_oneline = $&;
		$error_subject = " �t���[�Y�i���s�����j";
	}


	# ���̏����i���k�Ȃǁj�ł́A�L�[���[�h�̑g�ݍ��킹�`�F�b�N�������Ȃ�Ȃ�
	if($check =~ /���k(�ł�|�o��|������|������|������)|������(��������|������)/){ $good_flag = 1; }

	# �����͂��P�s���W�J���ă`�F�b�N
	if(!$good_flag){

			# �{����W�J
			foreach $comment_split (split(/<br>/,$check2)){

				# �Ǐ���
				my($evil_buf,$warai_flag,$comment_split_omitted);
				my $comment_split_pure = $comment_split;
		
					# ���E���h�J�E���^
					if(length($comment_split) >= 2*5){ $i++; }

					# ���O
					if($comment_split =~ /(��|��|�l)(��|��|�Ȃ�)/x){
						next;
					}

					# ���p���͏��O
					if($comment_split =~ /^(&gt;|��)/x){
						next;
					}

				# �J�b�R�̒��g�����O����
				$comment_split =~ s/(�u)(.+?)(�v)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(�)(.+?)(�)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(�w)(.+?)(�x)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(�g)(.+?)(�h)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(\s|�@|�A)//g;


					# �΂��`�F�b�N
					if($comment_split =~ /(�Ԃ�|������|www|�߯|�v�b)|(\(|�i)(�m|����|��|��)|(�m|����|��|��)$/){
						$warai_flag = 1;
						$evilnum_fraze += 0.1;
						push(@badword_fraze,$&);
					}


					# ���L�[���[�h�ʔ��� ( �G���[���� )
					if(!$good_flag){
						$evilnum += ($comment_split =~ s/((��|��|�u)(��|�l)|�N�Y|\Q��\E|�N�\|(�A�z|����|����)|(��|�E)((��|�U)(��|�C)|(��|\Q�[\E)(��|��|�G|�F))([^(�Ȃ��)]|$))/$&/g);
						$evilnum += ($comment_split =~ s/((����|�L��|��)(��|��|�C|�B|��|�X)|(�Ӳ)|(��(��)?��|�L��)(��|��|�G|�F)(��)?)/$&/g);
						$evilnum += ($comment_split =~ s/(���h|\Q�~�[\E|(^|[^��])��|����)/$&/g);
						$evilnum += (($comment_split =~ s/(www|������)/$&/g) * 0.2);
						$evilnum += (($comment_split =~ s/(	\(��	|	�i��	|	��$	)/$&/xg) * 0.2);
						$evilnum += (($comment_split =~ s/(	\(�{	|	�i�{	|	�{$	)/$&/xg) * 0.5);
						$evil_word .= qq( $1);

					}


					# ��s����
					if($comment_split =~ /����s/x){
						$guchi_flag = 1;
					}

					# �����܂�̃t���[�Y - ( ��|�C���g���Z )
					if($comment_split =~ /(
							 (��(��|��)�E(��|���Ă�(��|��)))
							|((����|����)(�z|���)|���Ȃ�) (��|�E) ((��|�U)(��|�C|��|�b)|(��|\Q�[\E) (��|��|�G|�F))
							|((������|�S��)(��|��|�u)(��|�l))
							# �}�W�����n
							|
								# �L�[���[�h�P
								(
								(\Q����[\E|\Q�`���[\E|��)|(�܂�|�܂�|�}�W|�}�a|�n�H)(��)?|�ق�(��)?��|�߂���|���`��|��(�O|�܂�)(��|��)|�j�q|���q
								|(��((��|��)(��|��)|�O)|����|�A���^|�M��|���Ȃ�|����)
								|((�{��|�ق��(��)?|�z���g)��|����)
								|(������)
								|(��|�N�\\)
								
								)
								# �L�[���[�h2
								(.{0,15})
								# �L�[���[�h3
								(
									(�ނ�|���J)(��|�c�N)
									|(����|�L��|��)(��|��|�C|�B|��|�X|����|w|��)|(�Ӳ)|(��(��)?��|�L��)(��|��|�G|�F)
									|(��|�E)((��|�U)(��|�C|��|�b|������)|(��|\Q�[\E)(��|��|�G|�F|\Q�[\E))
									|����
									|�J�X|�N�Y|����
									|�N�\\
									|\Q��\E
									|(ks|����)
									|((�C��|����)��)((��|���)��)
									|(�E����)(��|������)
									|(�ӂ���(��|��)��)
									|(������|�E�P��)
									|(�Ӗ�|����|�C�~)(�s|��|�t|��)
									|(���f|�E��)
								)
							|(\Q��\E|�N�\\)(��|�E)((��|�U)(��|�C|��|�b)|(��|\Q�[\E)(��|��|�G|�F))
							|(������|\Q�E�P��\E)(��ł�����)
							|(��|��)((��|�ق�)��)(.{1,5})?(�΂�|�n��|((�C��|����)��)((��|���)��)|�K�L|��S)
							|(���q|(�`��|����)(\Q�[\E|��|�E)(�V|��))(�����Ȃ�|((��|��)���Ă񂶂�)|������(��)?�񂶂�)
							|(��������(�Ă񂶂�|�����))
							|(��)(������)
							|(�Ȃ�(��)?(��)?�񂶂�)(��(��|��|\Q�[\E))
							|(\Q��\E|�N�\\)(�Ǘ�|�ア|�΂���|�΂���|�j|��)
							# �r���n
							|(�����|���O��|�K�L|��S)(.{1,20})(�����|���Ȃ���)
							# �E�[�[�[�[�[�[�[�n
							|(UZEEEEEEEEEEE)
							|(^|[^�������Ƃ̂ق����])(��(��)?��|\Q�E\E(�b)?\Q�[\E)(\Q�[�[\E|�`�`|(�G|�F|��|��){2,})
							|(��(��)?��|�L(��)?��)(�G|�F|��|��|\Q�[\E){2,}
							|((��|��|�u)(��|�l)(�J�X|����))
							#|(����ł���)
							|(^|[^(�i])(\Q��\E|\Q�^�q\E)(��|��)
							|(��|������|�A�^�}|�](���X)?)(��)?
								((���v|�������傤��)((.{1,20})?(�H|\?)|��|�ł���|$)|(��������|�΂���|�C�J����|�������|������|�ǂ�����(��|��)��))
							|(�Q��)
							|(�ނ�|���J)(��|�c�N)(��)?(!|�I|(.{0,20})�{)
							# ���O�`�{�n
							|(���O|���܂�|����|�A���^|�M��|���Ȃ�)(.{1,10})?((�ז�|�W���}|�����)|(��(��������|������)))
							|(��)(������(��|��)|������)
							|(���Ȃ�|�M��|(��(�O|�܂�)|�Ă�(��|��)))(��)(����ȉ�|�A�z|����|����)
							|(�S�~|����|�n��|�o�J)(��)((��(�O|�܂�)(��|��)?)��)
							|(����)((��|��|��)��)
							# �����P��́A����ȏ�̌J��Ԃ�
							|((��|��)��|����|����|����|�L��|����|��|�U�R|�G��){3}
							|((��|����)����|������(.{1,4})|��������|��(�߂�|�܂�|�O)(��)?|�܂�)((��|��|�u|��)��|(��|��)��(��|��))
							|((�~|��)��(�a)?|��Ƃ�|�m������|�U�P��|�ނ�|�~|������)(��)([^��]|$)
							|(��)(.{1,5})?(\^\^)
							|(\Q�~�[\E)(�ǂ�|\Q��\E)(��|��)
							|(�N�\\|����|��|�N�Y)(.{1,10})?(�ǂ�|\Q��\E)
							|(�l�Ԃ�)(�N�Y)
							|(�r�b�`)
							|(�΂�|�n��|�G��|�U�R)
								(
									(��)(����|��)(��)|
									����(�Ȃ�|��(��|��)|�l(�G|�F))��(\?|�H|�I|!|(��)?��(�O|�܂�|��(��|��)))
								)
							|(����|�폜|�S��)(�~)
							|(�L��|����)((��|��|�C|�B)(��|�񂾂�|�񂾂���)|����|�߂�|��|w|��)
							# �Ώی���n
							|(�ނ�|���J)(��|�c�N)(.{1,20})(�搶|���t|�S�C|�ږ�|�ז�|�k|�΂�(��|��)|�o�o(�A|�@))
							|(�搶|���t|�S�C|�ږ�|�ז�|�k|�΂�(��|��)|�o�o(�A|�@))(.{1,20})((�ނ�|���J)(��|�c�N)|(������)|(������)|(����))
							# �r�b�N���}�[�N�n
							|(�ނ�|���J)(��|�c�N)(!|�I)
							# �P��ЂƂn
							|(�N�\\|����|��)(������|�W�W�C|�΂΂�|�o�o�A)
							|(����|�N|���O|���܂�|���Ȃ�)(��|��|��(��|�ق�)��)(.{1,20})?(�Ԃ�|�u�X)
							#
							|(��\\|��]|�჌�x��)(��|��|��|��)
							|(�\\|�])(�Ȃ�|����)(��|��|��|��)
							# ������ - �̏̌n
							|(�]((��|��)��|�����))
							|(����|�E���R|����|�E���`)(�����|�N|�N��|����)
							|(�㒎)(.{1,10})(�N|�N��)
							|(�U�R|�G��)(����)
							|(�o�o(�A|�@)|�΂�(��|��))(��|��|!|�I)
							|(�����I��)(����|����|�ނ�)
							|(��|��)(�U�R|�G��)
							|(�U�R|�G��)(��)(!|�I)
							|((��|��)�ɂ���(��)?�Ȃ�)(.{1,10})?((��|��)��(��|��(����|�ǂ�)))
							|(�ӂ���(��|��)��)(.{1,10})?(!|�I)
							|(���F(��|��)?|(��|��)��|�z���g|�ǂ���|������)(�N�Y|�J�X|�K�L|�N�\\)
							|(�S�~|��)(.{2,10})?(��Y)
							|(�l�Ƃ���)(�Œ�)
							|(���`|�q���C��|\Q�q�[���[\E)(�Ԃ�(�����)?��|�C���)
							|(�}�X�S�~|(�E�W|�v	)�e���r)	
						# ���茾�t�ɔ������t
							|(�F�B)(���Ȃ�)(����|������)
							# �΂��v���X
							|(����|����|���˂�(�H|\?)?|�c�t��(��)?|������|����|������|�K�C�W|�J�X)(.{1,10})?(ww|����)
							|((����|��)��(���Ă񂶂�|�������|���))
							|�ق�(���Ă�|��(!|�I))
							|(�ق�)(����|�R��)
							|(�}�W�L�`|�C�Ⴂ|��n(�O|�X)|�L�`�K�C)
							|(���)
							|(�Q��)(��)
							|((�\\|����)����)(�����)
							|(��x��)((�o��)?(��|��)(��|��)��)
							|(�o�Ă�(��|��)?)(!|�I|ww|����)
							|(����|�E�U)((��|��)����)
							|(����|�E�U)(��|�C)(.{0,20})(!|�I|������)
							# 2�����˂�p��n
							|(�v�M��|�߷ެ)(\Q�[\E|-)
							|(�e�������X|\Q�N�\�����^\E|\Q���۽\E)
							|(�����(��|�Ђ�)��)
							|((��|��|�u)(��)|�O�O(��|��))(�j�r|����|�J�X)
							|(����)(!|�I)
							|(�ނ�)(����)
							|(�N�\\)(�L��|�X��)
							|(����(��|��)|������|��Ƃ肪)(ww|����)
							|(\Q�X�C�[�c\E)(.{1,20})?(��)
							# ����Ȍn
							|(�X��|�f����|����)(��)?((��|��)(��|��)��)
							|(�X��|�f����|����)(����)(������|������(��(��|��)�Ȃ�|$)|(�o��|�ł�)(�s|��|��)?(��))
							# �M�����n
							|(�C�~�t|�Ӗ��s(��)?)(.{1,10})?(�Ȃ�(��)?������)
							# �ׂ��߂��n
							|(��|�z(.{1,10})?)((��������|��������)(�ǂ�|�ł�))
							|(�ڂ�|�{�P)(!!|�I�I)
							|(�΂�)(��(��|��)��)
							|(�Ƃ��Ƃ�)(������|������)
							# �΂��n
							|(�c�t)(.{1,20})?(ww|����|��)
							# ���ɂ����̃t���[�Y�n ( �c�_�n�H )
							|(����)(����)(�ނ���|��|�|���W�i)
							|(����(��)?)(��)
							|(���D��)(����|�l)
							|(����)(�����(\?|�H)|�o���܂���)
							|(�o�J|�n��)(��)(�ق��Ƃ���|�����Ƃ���)
							|(��)(���ۂ�)
							|(���w��|�c�t��(��|��)|�c��)	(�ł�(��|��)����|���Ⴀ��܂���)
							|(����|���Ȃ�|�A�i�^|�M��|���O|���܂�|�Ă�(��|��))(��)(������)(�؍�)(��)?(��)?(��|��)(��|��)
							|(���ꂵ��|���m)(�ɂ�)((��|�ق�)��)(����|����܂�)
							|((�Љ�|�l��)�̃S�~)
							|((�c�t|�t��)��)(�l��|�ӌ�)
							|(���܂��)(�c�t|�t��)
							|(�c�t����|���w�Z��|���w�Z��)(�K)(���܂����|��Ȃ�����)
							|(�c�t��(��)?|���w��)(���x��)
							|(�Q����)(�Q��)(����|�����Ȃ���)	
							#|(�a�@)(�s|��)(��)
							|(���_��|���_�a�@)	(.{1,10})?	(	(��|�f)�Ă��� | (�s|��)(��|����(��|��))	)
							|(���_�N��)(.{0,20})(��)
							|(��)(����(��|��))
							|((���f|�w�h|�ւ�)��)((�o|��)(��|����))
							|(�f���C)(��)?(����)
							|(���{��|��Ǔ_|��)(��)(�܂Ƃ���)?((�g��|�ǂ�)(�Ȃ�|��(��|��)))
							|(���{��)(.{1,10})?(�׋�������|�ǂ߂Ȃ�)(.{1,10})?(\?|�H)
							|(�����Ԃ�|�S�L�u��|��Ƃ�|�n��)(�ȉ�)
							|(�����܂ŗ����|����(��)?��)(����)
							|(�e��(�G|�F)|�Ă�(��|��)|��(�O|�܂�|��(��|��)))(��)(.+)(���낤��)
							|(�ڋ���|�ꐶ(.+)����(��|��))(.*)(��|ww|����|�m|��|����)
							|((��|�N�Y)��)([!�I�B]+)?$
					)/x){
						$evilnum_fraze++;
						$evil_buf = 1;
							push(@badword_fraze,$&);
					}

					# ���s�͏��O
					if($comment_split !~ /(�l|�ڂ�|�{�N|��|����|�I��|��|�킽��|������|(��|��)��|����)(��|����|��)/){
							if($comment_split =~ /
							(�S�~|�U�R(��|�C)?|�G��(��|�C)?|(��\\|��]|�Œ�|�ň�|�჌�x��)(��|��)?|�~���悤(��|��)?�Ȃ�|�N�\\)
								(�n��|�o�J|�f�u|��Y|���t|��|�j|���c|���|�z|�l��|�A�j��|��|�T��|����|\Q�~�[\E)
							/x){
								$evilnum_fraze++;
								$evil_buf = 1;
								push(@badword_fraze,$&);
							}
					}

					# �����܂�̃t���[�Y - ( ���|�C���g���Z )
					if($comment_split =~ /(����(��)?��)(�����)
						|(��(�`){3,}����)
						|(�e��)(���z|���킢����)
						|(���z|���킢����)(��)(�l|�z|���)
						|(���炢|����)(!!|�I�I)
						|(�ɂ�)(�l|�z)
						|((��|��)����)(������)
					/gx){
						$evilnum_fraze += 0.5;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}


					# �����܂�̃t���[�Y - ( ��|�C���g���Z )
					if($comment_split =~ /
						(��(��|��)(\?|�H))
					/x){
						$evilnum_fraze += 0.2;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}


					# �ƍ߃t���[�Y
					if($comment_split =~ /(���C�v)(���Ă��)/){
						$evilnum_fraze += 2;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# �󔒂���̃L�[���[�h
					if($comment_split_pure =~ /(�Ӂ@���@���@��@��)/){
						$evilnum_fraze++;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# �P�s�̒��Ły���̃t���[�Y�����z���g���Ă���ꍇ
					if($comment_split =~ /^
						(
							((��|��|��|�u)��)
							|((����|�L��|��)(��|��|�C|�B|��|�X)|(�Ӳ)|(��(��)?��|�L��)(��|��|�G|�F)(��)?)
							|((��|�E) ((��|�U)(��|�C|��|�b)|(��|\Q�[\E) (��|��|�G|�F)))
						)
						([�B|!|�I]+)?$/x){
						$evilnum_fraze++;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# ���ߏ蔽��
					if($comment_split =~ /
						(�r(��)?(��|��))	(.{0,10})	(�A(����|��)|���A��(����|��)����|�Œ�|[^�o]�����|(��|��)�Ȃ���|(��|��|�~)��(��|��|�Ȃ���))
						|(�r(��)?(��|��)) (.{0,10})? (���Ȃ���)
						|(���O|�N|���Ȃ�|�M��)(��|��|��)(�r�炵)
						|(�r�炵��)		(	(���O|�N|���Ȃ�|�M��)	|	(	(.{1,10})(����)(����)((��|�~)��������)	)	)
						|(.+)(��)(�r�炵(��|�ł�))
						|(����)(.{1,10})?(�΂�|�o��)
					/x){
						$evilflag_kajou = $evil_buf = 1;
						push(@kajou_word,"$&");

					}

					# ���u�폜�˗��o���܂����v�̔���
					if($comment_split =~ /(�폜�˗�)	(.{1,4})?	((�o|��)?(��)(�Ă���|�Ƃ�)?(�܂�|�܂���|�Ƃ�))/x){
						push(@delreport_word,$&);
					}

					# �Y���s���L��
					if($evil_buf){
							$check_oneline = $comment_split;
							$error_subject = " �t���[�Y�i�P�s���j";
					}

			}

	}


	# Echeck�L�^�p
	if($check_oneline){ $main::echeck_oneline = $check_oneline; }

	# �o�b�h���[�h��W�J
	foreach(@badword_keyword){
		if($badword_keyword){ $badword_keyword .= qq( / $_); }
		else{ $badword_keyword .= qq($_); }
	}

	# �o�b�h���[�h��W�J
	foreach(@badword_fraze){
		if($badword_fraze){ $badword_fraze .= qq( / $_); }
		else{ $badword_fraze .= qq($_); }
	}
	if($badword_fraze){ $badword_fraze = qq( ( <em>$badword_fraze</em> ) ); }

	# ���L�[���[�h�ʂŔ��� (�G���[)
	if($evilnum >= $error_border_keyword && !$error_flag){
		$main::e_com .= qq(���s�K�؂ȒP�ꂪ�������ߏ������߂܂���B<strong>�\\�����@</strong>�ɂ͏\\�����z�����������B ( ���� $evilnum_light pt / �ő� $alert_border_keyword pt )<br>);
		$error_flag = 1;
		$error_subject = qq(�s�K��-�L�[���[�h��);
		$keyword_check_flag = "error";
	}

	# ���t���[�Y�ł̃G���[����
	if($type !~ /Sousaku/ && $evilnum_fraze >= $error_border_fraze && !$error_flag){
		$main::e_com .= qq(���s�K�؂ȕ\\�����������߁A�������߂܂���B<br>);
		$error_flag = 1;
		$fraze_check_flag = "error";
	}

	# �L�[���[�h�ʂł̃A���[�g����
	if($evilnum >= $alert_border_keyword && !$error_flag && !$alert_flag){
		$main::a_com .= qq(���s�K�؂ȕ\\��$evil_word����������܂��񂩁H�@���e�}�i�[�ɂ͏\\�����z�����������B ( ���� $evilnum_light pt )<br>);
		$alert_flag = 1;
		$keyword_check_flag = "alert";
		$alert_subject = qq(�s�K��-�L�[���[�h��);
	}


	# ���t���[�Y�ł̃A���[�g����
	if($type !~ /Sousaku/ && $evilnum_fraze >= $alert_border_fraze && !$error_flag && !$alert_flag){
		$main::a_com .= qq(�����͒��ɁA�}�i�[���������\\��$badword_fraze�͂���܂��񂩁H<br$main::xclose>�@�@<span style="color:#f00;">�������e�ɂ�\�\\�����z�����������B </span> ( $evilnum_fraze / $alert_border_fraze )<br>);
		$alert_flag = 1;
		$alert_subject = qq(�s�K��-�t���[�Y);
		$fraze_check_flag = "alert";
	}

	# ���ߏ蔽���ւ̃A���[�g����
	if($evilflag_kajou){
		my($kajou_word);
			foreach(@kajou_word){
				if($kajou_word){ $kajou_word .= qq( / $_); }
				else{ $kajou_word .= qq($_); }
			}
			if($kajou_word){ $kajou_word = qq( ( $kajou_word ) ); }
		$main::a_com .= qq(���u�r�炵�v��u���[���ᔽ�v�ɁA������Ԃ��Ă��܂��񂩁H�@ $kajou_word <br$main::xclose>�@�r�炵�ɂ�<strong>��ؔ�������</strong>�A<a href="$main::delete_url">�폜�˗�</a>��������A���i�ǂ���̏������݂𑱂��Ă��������B<br>);
		$alert_subject = qq(�ߏ蔽��);
		$alert_flag = 1;
	}

	# �폜�˗��o���܂����`�ւ̃A���[�g����
	if(@delreport_word >= 1 && $category ne "mebi"){
		my($delreport_word);
			foreach(@delreport_word){
				if($delreport_word){ $delreport_word .= qq( / $_); }
				else{ $delreport_word .= qq($_); }
			}
			if($delreport_word){ $delreport_word = qq( ( $delreport_word ) ); }
		$main::a_com .= qq(��������$delreport_word�Ə������ނ��Ƃ́A�{���ɓK�؂ł����H�@<strong>����/�t����</strong>�ɂȂ肻���ȏꍇ�͂��������������B<br$main::xclose>);
		$alert_subject = qq(�폜�˗�);
		$alert_flag = 1;
	}

	# ��s�ւ̃A���[�g����
	if($guchi_flag){
		$main::a_com .= qq(����s(�O�`)�����������ꍇ�́A���i��蓊�e�}�i�[�ɒ��ӂ��Ă��������B�@���Ƃ���<strong>�u�������v�u���ˁv</strong>�Ȃǂ�\�\\���͂��������������B<br>);
		$alert_subject = qq(��s����);
		$alert_flag = 1;
	}

	# Echeck�m�F�p�̕\�� ( ���g�p )
	if($type =~ /Check-mode/){

		# �Ǐ���
		my($badword_error,$badword_alert);
		my $badword_all = $badword_fraze;

		# �����ɐ��`
		($evilnum,$evilnum_light,$evilnum_fraze)
			= Mebius::DefineNumber(undef,$evilnum,$evilnum_light,$evilnum_fraze);

			# ���L�[���[�h��
			if($keyword_check_flag eq "error"){
				$check_line .= qq(<strong class="red">$evilnum</strong>);
			}
			elsif($keyword_check_flag eq "alert"){
				$check_line .= qq(<strong class="green">$evilnum_light</strong>);
			}
			else{
				$check_line .= qq($evilnum);
			}
		$check_line .= qq( / $alert_border_keyword / $error_border_keyword ( num )<br$main::xclose>\n);


			# ���t���[�Y
			if($fraze_check_flag eq "error"){
				$check_line .= qq(<strong class="red">$evilnum_fraze</strong>);
			}
			elsif($fraze_check_flag eq "alert"){
				$check_line .= qq(<strong class="green">$evilnum_fraze</strong>);
			}
			else{
				$check_line .= qq($evilnum_fraze);
			}
		$check_line .= qq( / $alert_border_fraze / $error_border_fraze ( fraze )<br$main::xclose>\n);

			# �G���[�薼�̐��`
			if($error_flag){
				$error_flag = qq(<div><strong style="color:#f00;">��$error_subject<br$main::xclose><br$main::xclose>$check_oneline</strong><br$main::xclose><br$main::xclose>$badword_all</div><br$main::xclose><br$main::xclose>\n);

			}

			# �A���[�g�薼�̐��`
			elsif($alert_flag){
				$alert_flag = qq(<div><strong style="color:#080;">��$alert_subject<br$main::xclose><br$main::xclose>$check_oneline<br$main::xclose><br$main::xclose>$badword_all</strong></div>\n);
			}

	}

	# ��p
	if($alert_flag){
		push(@main::alert_type,"�}�i�[/���A�N�V����");
	}

	# ��Echeck�̋L�^
	if($error_flag){
		Mebius::Echeck::Record("","Evil","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}
	elsif($alert_flag){
		Mebius::Echeck::Record("","Evil","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}

# ���^�[��
return($error_flag,$alert_flag,$check_line);

}


#-----------------------------------------------------------
# �G�k���`�F�b�N
#-----------------------------------------------------------
sub ConvesationCheck{

# �錾
my($type,$comment) = @_;
my($error_flag,$alert_flag,$bad_word,$alert_border);

# �R�����g�̑S�����擾
my $comment_length = Mebius::GetLength(undef,$comment);

	# �{�[�_�[�ݒ�
	if($comment_length >= 250){ $alert_border = 3; }
	elsif($comment_length >= 75){ $alert_border = 2; }
	elsif($comment_length >= 25){ $alert_border = 1; }
	else{ $alert_border = 0.5; }

	# �{����W�J
	foreach(split(/<br>/,$comment)){

			# �G�k������
			if($comment_length < 1000){

					if($_ =~ /
						(���ȏЉ�)(.{1,10})?(�ł�|���܂�)
						|(����|��)(��|�Ђ�|����)
						|(����|���͂�)(������|�H�ׂĂ�)
						|(��|�ꏏ��|���������)(.{1,20})?((�b|�͂�)��)
						|(�F�B|���q)(��)(�Ȃ���)
						|(����|�Ȃ��|�ǂ��(��|�ӂ�)��)(��(�ׂ�|�񂾂�))
						|(����)((��|��)��ł�)((��|o|O|�n|��)(\.|�D)?(k|K|�j|��)| (�ǂ�|����)(.{1,10})?(\?|�H))
						|(����|�C�y��|�D����(�悤|��)��)(.{1,20})?((��|��)���)(������|��������)
						# �׋��n
						|(�e�X�g)(.{1,20})?(�׋�)
						|(����|�Z��|���w|����|�Љ�|���j|�̈�|�ƒ��|�p��)(.{1,20})?(���|�e�X�g|����|���|�ň�|���|�Ȗ�)
						|(���|����)(.{1,10})?(�Ȗ�)

						|(���|����|����|��T|���T|���T|����������|(��|��|��|��|��|�y|��)�j)(.{1,20})?
							(���w��|�n�Ǝ�|�I�Ǝ�|����|�g�̑���|�ȑւ�|�C�w���s|\Q�^����\E|�w�Z)

						|(���w��|�n�Ǝ�|�I�Ǝ�|����|�g�̑���|�ȑւ�|�C�w���s|�^����|�w�Z)(.{1,20})?
							(�A����|���|����|����|��T|���T|���T|(��|��|��|��|��|�y|��)�j)

						|(�׋�|��|����|�e�X�g)(.{1,20})?(�撣����|����΂���|���|�_��|�Z��)
						|(������|�͂�����)(����|�ǂ�|����)(.{1,20})?(\?|�H)
						|(���ꂩ��|(��|����)(����)?)(.{1,10})?(���|����|���͂�|�S�n��|(��)?���C|�p��|����|�m|�w�Z)
						|(����|���͂�|�S�n��|(��)?���C|�p��|����|�m)(.{1,20})?((�s|��)���Ă���(\Q�[\E|�`)+?��|����)
						# ����̗p���n
						|(����|���͂�|�S�n��|(��)?���C|�h��)(.{1,20})?(����)
						|(�����C)(.{1,20})?((��|�͂�)����)((��|��)��|(��|��)�܂�)
						|(��|��)((��|��)(��)(��|��)|��)(.{1,20})?(����)
						|(��)(�ɂȂ�����)(����)
						|(����|����)(�Q)(��|��|��(\Q�[\E|�`)?��)
						|(����)(�Q��|�˂�)(.{1,10})?(\?|�H)
						|(�m)(��)?(����)
						# �Z���ȂǕ����o���n
						|(������|(����|�ǂ�)��)()(.{1,20})?(�Z���)
							(�܂���|(��)(.{1,10})?(\?|�H))
						|(��)(.{1,10})?(�ł�|�I���(��|��))
						|(�p�\\�R��|PC|�o�b)(��)(���q)
						|(��(��|�j|�O|�l|��|�Z|�P|�Q|�R|�S|�T|�U)|(��|��)(��|�j|�O|�P|�Q|�R))(��)(�Ȃ�)
						|(�l|�ڂ�|�{�N|��|����|�I��|��|�킽��|������|�A�^�V|���^�V|����|�E�`)
							(
								 (��|��|��|��)(.{1,20})?(�m|����)
								|(��|��|��|��)(.{1,20})?(��(�w)? (��|�j|�O|�l|��|�Z|�P|�Q|�R|�S|�T|�U|1|2|3|4|5|6) |(��(�w)?|��(�Z)?)(��|�j|�O|�P|�Q|�R|1|2|3)|(�����܂�))
								|(��)(�����)
								|(��(����|��))((�o|����)����)
								|(��)(�w�Z)
								|(.{1,20})?(�Z��|(��)(�Z���))
								|(.{1,10})?(��|��)
							)
						|(�t����|�܂�)(��(�w)? (��|�j|�O|�l|��|�Z|�P|�Q|�R|�S|�T|�U) |(��(�w)?|��(�Z)?)(��|�j|�O|�P|�Q|�R))
						|(����)(����|����|���w��|���w��)
						|(�F�B|���q)(.{1,10})?(�Ȃ�܂���)
						|(����(����)?|��������|��U)(����)
						/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}

			}
#				|(��|���w��)

			# �Z���̏ꍇ ( A )
			if($comment_length < 1000){
					if($_ =~ /
						# ���ȏЉ�n
						(���ȏЉ�)
						|(�Ă�(\Q�^��\E|����|�̂�))
						|(\Q�^��\E|��|����)(.{1,10})?((��|o|O|�n|��)(\.|�D)?(k|K|�j|��)| (�ǂ�|����)(.{1,10})?(\?|�H))
						|(\Q�^��\E)(��|����)
						|((�F|�Ƃ�)(�B|����)|�F��)(�Ȃ�(�܂���|����)|�Ȃ�(��|��|��))
						|(�l|�ڂ�|�{�N|��|����|�I��|��|�킽��|������|�A�^�V|���^�V|����|�E�`)(.{1,10})?(�N��|�N��)
						# �҂����킹�n
						|(�ߌ�|�ߑO|((.{1,4})��(.{1,4})��) ) (.{1,20})? (��) (.{1,20})? (���܂�|����(��|����))
						|(�܂�)(����|������|(��|��)(�܂�))
						|(�͂₭|����)(����|����)
						# �׋�
						|(���낻��|��)(.{1,20})?((����|����|����)�e�X�g)
						# �`���b�g��n
						|(����)(��(\Q�[\E|�`)?��|(��(��|�l))|ww|����|$)
						|(����)(����)
						|((�N|����)��)(.{1,10})?(���肵��|�b��|�͂Ȃ�| (��|��)(�܂���|�܂���|�Ȃ���|�Ȃ���) | (����)(.{1,10})?(\?|�H) )
						|(������|���낢��|�F�X)(�b��|����|�͂Ȃ�)
						|((��|��)(����|��Ȃ�))(.{1,10})?(��������|�Ԏ�)
						|(�����Ă�)
						|(��|�Ђ�)(�Ȃ�|��|�`)
						|(��)(��(��)?���)(.{1,10})?(\?|�H)
						|((��|�Ȃ�)��)(�b)(����)
						|(��|�Ȃ�)((�b|�͂�)��)
						#|(�����)(�`)
						
						|(�^����|�Ăю̂�)
						|(�΂��΂�|�o�C�o�C)
						|(�܂�)(.{1,10})?((�͂�|�b)��(��|��|��|��))
						|^(�����)
						|(����|�ł�)(.{1,10})?(�x)(��|����)
						# �Ăьn
						|(����) (��) (��ł�|�т܂�|��(��|����)��)
						# ��
						|(����)(.{1,20})?(�v���X|�}�C�i�X|�����|�ז�)
							/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}
			}

			# ���Z���̏ꍇ ( B )
			if($comment_length < 100){
					# 1.0�|�C���g���Z
					if($_ =~ /(

						 ((��|��)��H)(.{1,20})?((��|��)����)

						|(ALL)
						|(���₷��)
						|(�͂�|�b)(��)
						|(���ǂ�)(���܂���|����)
						|(�b)(���܂���|���悤)
						|(��|�����|��|����)(�낤|�낧|��܂���)

						|(�N��)(����)
						|(����|����)(�ł���|������)
						|(���������)
							)/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}
					# 0.5�|�C���g���Z
					if($_ =~ /(
						 (�v|�Ђ�)���Ԃ�
						#|(���|�X)(����)
						|(����΂�(��|��|��))
						|(����ɂ�(��|��|��))
						|((�͂���|�͂���|����|�n��)�܂���)
							)/x){
							$alert_flag += 0.5;
							$bad_word .= qq( $&);
					}
			}



	}

	# ��Echeck�̋L�^
	#if($error_flag){
	#	$main::e_com .= qq();
	#	Mebius::Echeck::Record("","Convesation","$comment");
	#	Mebius::Echeck::Record("","All-error","$comment");
	#}
	#els

	# �A���[�g����
	if($alert_flag >= $alert_border){
		push(@main::alert_type,"�`���b�g��/�G�k��");
		$alert_flag = qq(�`���b�g��/�G�k�� \($bad_word\));
		# ( $bad_word )
		$main::a_com .= qq(���������݂��G�k��/�`���b�g�����Ă��܂��񂩁H<br>\n);
		$main::a_com .= qq(�@�f����/�L���̃e�[�}�ɍ��������e�����Ă��������B<br>\n);
		$main::a_com .= qq(�@�ᔽ�������L���͍폜/���b�N�����Ă��������ꍇ������܂��B<br>\n);
		$main::a_com .= qq(�@�G�k������ꍇ��<a href="http://mb2.jp/_ztd/">���R�f����</a>�ȂǁA�G�k�n�̃R���e���c�������p���������B<br>\n);
		Mebius::Echeck::Record("","Convesation","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}
	else{
		$alert_flag = 0;
	}



return($error_flag,$alert_flag);

}


#-------------------------------------------------
#  �`�F�[�����e�̔���
#-------------------------------------------------
sub ChainCheck{

# �錾
my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($chain,$kasho_flag,$hari,$error_flag);
my($bad_word,$chain_flag);

# �`�F�b�N�̂��߂ɋ󔒂��폜 
$check =~ s/( |�@|<br>)//g;

#��t��(����|���|��(����|��)����) | 

	# ����
	if($check =~ /
	(
		 (��|��|��|�P|��|�J|��)��
		|((�Ⴄ|�ʂ�|����|�ق���|�ǂ�����)|([0-9]|�P|�Q|�R|�S|�T|�U|�V|�W|�X|�P�O|��|�O|�l|��|�Z|��|��|��|�\\|�H) (��|��|��))
			(��|�f����|�X��|�ڂ�|���X��|�Ƃ���)
	)
	(.{1,20})?
	(
		 (��|�\\|��) (��(��|�t)�� |���|��Ȃ���|��Ȃ����|���|�邾��|���Ă�|���Ă�|������|��(����|��)) | ��(������|����)

		|((����(��|��)(���|��))|(������(����|��))|(�u(����|������)))
				(.{1,100})?
					(��������|�����|��(�z|�v)��|�L�Z�L��)

		|(�������܂Ȃ�����)
				(.{1,100})?
					(����)


	)
	/x){
		$chain_flag = 1;
		$bad_word .= qq( $&); 
	}

	# ����
	if($check =~ /
		 (����(�A)?�y����(�A)?(�p�ӂ���|���p�ӂ�������))
		|(�y����(�A)?����(�A)?(�p�ӂ���|���p�ӂ�������))
		|(����)(��|��������|���X)(��)(����)(�l|���Ȃ�|�M��)(.{1,20})?(�K��|\Q�K�^\E)
		|(�����)(����)(�l|���Ȃ�|�M��)(.{1,20})?(�K��)(.{1,20})?(�ȓ���)
		|(\Q�R�s�[\E|�R�s�y)
			(
				 (������)(.{1,20})?(�A�h���X)(.{1,10})?((�o|��)��)((��|��)(�܂�)|(��|��)(���))
				|(����)((��|�܂�)����)
			)

		|(\Q�R�s�[\E|�R�s�y|�R�s����)(.{1,10})?(��|��|�\\)(���|����)(.{1,40})?(����|�摜|�肢|�A�h���X)
		| (��|�\\|��) (��(��|�t)��)(.{1,20})?((�܂�|��)����)((����|��)����)
		|((��|��|��|�P|��|�J)��)(.{1,20})?(\Q�R�s�[\E|�R�s�y)(������)(.{1,10})?((�o|��)��((��|��)(�܂�)|(��|��)(���)))
		|((��|��|��|�P|��|�J)��)(.{1,20})?(�S��(�e�X�g|ý�))(.{1,20})?(��|��|�\\)(��|����)
		|(�S��(�e�X�g|ý�))(.{1,20})?((��|��|��|�P|��|�J)��)(.{1,20})?(��|��|�\\)(��|����)

		|(\d)(��)((��|��|�\\)���)(.{1,20})?(���v��|���z��)
		|(\Q�A�����J�̃Q�[���ł�\E)
		|(�R�Ԃɏ������l�͋M����)
		|(�N���b�N|�د�)(�ł���|�o����)(�悤��)(.{1,20})?(�y|�z|\[|\])
		|(�y|�z|\[|\])(.{1,20})?(�N���b�N|�د�)(�ł���|�o����)(�悤��)
	/x){
		$chain_flag = 1;
		$bad_word .= qq( $&); 
	}

	# ����i�`�F�b�N�i�`�ӏ��Ɂj
	#if($comment_split =~ /(����|��|�T��)(�ȓ�)��/){ $bad_word .= qq( $&); }
	#elsif($comment_split =~ /(�R�s�y|\Q�R�s�[\E)(����|������|����)/){ $bad_word .= qq( $&); }


	# �`�F�b�N�a
	#if($comment_split =~ /(�܂킵��|�񂵂�)��������/){ $chain_flag = 1; $bad_word .= qq( $&); }
	#if($comment_split =~ /(�A�h���X)(.{1,20})?(�o��)(���܂�|���܂�)/){ $chain_flag = 1; $bad_word .= qq( $&); }


			# �u�R�s�[�v�̃L�[���[�h���d���肵�Ȃ�

	# �G���[��`
	if($chain_flag){
		$main::e_com .= qq(��<a href="$main::guide_url%A5%C1%A5%A7%A1%BC%A5%F3%C5%EA%B9%C6">�`�F�[�����e�͏������߂܂���B</a><br>
		�@���X�ƃR�s�[����鏑�����݂́A���f�ƂȂ�܂��̂ł��������������B<br>); 
		$error_flag = qq($bad_word);
		Mebius::Echeck::Record("","Chain");
		Mebius::Echeck::Record("","All-error");
	}

# ���^�[��
return($error_flag);

}




#-----------------------------------------------------------
# �I�[�o�[�t���[�`�F�b�N
#-----------------------------------------------------------
sub OverFlowCheck{

# �錾
my($type,$text) = @_;
my($comment_split,$i_comment);

	# �e�ʃI�[�o�[
	my $max_length = 2*10000;
	my($text_length) = length($text);
	if($text_length > $max_length){
			if($type !~ /Echeck-view/){
				Mebius::AccessLog(undef,"Regist-over-flow","�傫�����铊�e�f�[�^: $text_length�o�C�g / $text");
				Mebius::Echeck::Record("","Over-flow");
			}
		main::error("���e�f�[�^���傫�����܂��B$text_length�o�C�g / $max_length�o�C�g");
	}

	# ��������P�s������ꍇ�A�����ł����G���[��
	my $max_length_split = 2*2000;
	foreach $comment_split (split(/<br>/,$text)){
		$i_comment++;
		my($comment_split_length) = length($comment_split);
			if($comment_split_length > $max_length_split){
					if($type =~ /Echeck-view/){
					}
					else{
						Mebius::AccessLog(undef,"Regist-over-flow-line","�P�s���������铊�e: $comment_split_length�o�C�g / $comment_split");
						Mebius::Echeck::Record("","Over-flow");
						main::error("�P�s���������܂��B�K�x�ɉ��s���Ă��������B ( $i_comment�s�� �F $comment_split_length�o�C�g / $max_length_split�o�C�g )");
					}
			}
	}

return();

}


1;
