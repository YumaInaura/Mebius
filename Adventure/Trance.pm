
use strict;
use File::Copy;
use File::Path;
package Mebius::Adventure;

#-----------------------------------------------------------
# �����X�^�[�g
#-----------------------------------------------------------
sub Trance{

	if($main::in{'type'} eq "do"){ &TranceAccount(); }
	else{ &TranceAccountView(); }

}

#-----------------------------------------------------------
# �f�[�^�ڍs�t�H�[��
#-----------------------------------------------------------
sub TranceAccountView{

# �錾
my($use) = @_;
my($form,$guide_line);
my($init) = &Init();
my($init_login) = init_login();

# Cookie���Q�b�g
my($cookie) = Mebius::get_cookie("MEBI_ADV");
my($cookie_id,$cookie_password) = @$cookie;

			# ��������
			if(!$use->{'TypePreview'}){
				$guide_line .= qq(<h2>����</h2>);
				$guide_line .= qq(<ul>);
				$guide_line .= qq(<li>���܂ł̃��r�A�h��ID�́A���r�E�X�����O�̑����A�J�E���g�Ƌ��ʉ����܂����B</li>);
				$guide_line .= qq(<li>�ȑO�̃L�����f�[�^�́A<strong class="red">���r�E�X�����O�̃A�J�E���g</strong>�Ɉ����p�����Ƃ��o���܂��B</li>);
				$guide_line .= qq(<li>�܂��͑����A�J�E���g��<a href="${main::auth_url}" target="_blank" class="blank">���O�C���i�܂��͐V�K�o�^�j</a>�����܂܁A�{�y�[�W���J���Ă��������B</li>);
				$guide_line .= qq(<li>���ɁA<strong class="red">���Ȃ������܂Ŏg���Ă����L�����N�^�[��ID�ƃp�X���[�h</strong>����͂���ƁA�f�[�^�̈��p�����������܂��B</li>);
				$guide_line .= qq(<li>�f�[�^�̈��p������������ƁA����ȍ~��<strong class="red">���r�E�X�����O�̃A�J�E���g</strong>�Ƀ��O�C�����邱�ƂŁA�����ăQ�[�������y���݂��������܂��B</li>);
				$guide_line .= qq(<li>�ЂƂ̃L�����f�[�^�ɂ��A�֘A�t������A�J�E���g�͈�����ł��̂ł����ӂ��������B</li>);
				$guide_line .= qq(</ul>);
			}

# �t�H�[��
$form .= qq(<h2>�f�[�^�̈��p��</h2>);

	# SNS�ւ̃��O�C���`�F�b�N
	if(!$main::myaccount{'file'}){
		my($backurl) = Mebius::back_url({ TypeRequestURL => 1 });
		$form .= qq(�f�[�^���ڍs����O�ɁA�����A�J�E���g��<a href="${main::auth_url}?backurl=$backurl->{'url_encoded'}">���O�C���i�܂��̓A�J�E���g��V�K�쐬�j</a>���Ă��������B);
	}
	# ���O�C�����Ă���ꍇ
	else{

		$form .= qq(<form action="$init->{'script'}" method="post"><div>);
		$form .= qq(<input type="hidden" name="mode" value="trance"$main::xclose>);
		$form .= qq(<input type="hidden" name="type" value="do"$main::xclose>);


			# �v���r���[
			if($use->{'TypePreview'}){

				$form .= qq(<h3>���r�E�X�����O �A�J�E���g(�V)</h3><a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a>);


				# �ߋ��̃L�����f�[�^���擾
				require Mebius::Adventure::Charactor;
				my($old_adv) = &File(undef,{ FileType => "OldId" , id => $main::in{'id'} });
				my($status) = &CharaStatus({ TypeNotGetForm => 1 },$old_adv);
				$form .= qq(<h3>���L�����f�[�^</h3>\n);
				$form .= qq($status);

				# �A�J�E���g�����ɑ��݂���ꍇ
				my($new_adv) = &File("Allow-empty-id",{ FileType => "Account" , id => $main::myaccount{'file'} });
					if($new_adv->{'f'}){
						my($status) = &CharaStatus({ TypeNotGetForm => 1 },$new_adv);
						$form .= qq(<h3>���ɑ��݂���f�[�^ (�㏑���폜����܂�)</h3>\n);
						$form .= qq($status);
					}

				$form .= qq(<p><span 	class="alert">����L�̃L�����f�[�^���A�A�J�E���g�Ɉ����p���ł��ǂ��ł����H</span></p>);
		$form .= qq(<p><span class="alert">�������ǃf�[�^�������p���ƁA���̃A�J�E���g��A���̃L�����f�[�^�Ƃ̊֘A�t���͏o���Ȃ��Ȃ邽�߁A�����ӂ��������B</span></p>);
				$form .= qq(<input type="hidden" name="id" value="$main::in{'id'}"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="hidden" name="pass" value="$main::in{'pass'}"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="submit" name="submit" value="�f�[�^�̈��p�������s����" class="isubmit"$main::xclose>);
			}
			# ����
			else{

				$form .= qq(���Ȃ��̃��r�E�X�����O �A�J�E���g <a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a> ( ���̃A�J�E���g�ɁA���܂ł̃L�����f�[�^�������p����܂� )<br$main::xclose><br$main::xclose>);
				$form .= qq(�Q�[���Ŏg���Ă����L����ID (��) <input type="id" name="id" value="$cookie_id"$main::xclose><br$main::xclose>);
				$form .= qq(�Q�[���Ŏg���Ă����p�X���[�h (��) <input type="password" name="pass" value="$cookie_password"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="submit" name="preview" value="�f�[�^�̈��p�������s����(�m�F)" class="ipreview"$main::xclose>);
			}


		$form .= qq(</form></div>);
	}

my $print .= qq(<h1>���f�[�^�̈��p��</h1>);
$print .= qq($init_login->{'link_line'});
$print .= qq($guide_line$form);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���r�A�h�̌Â��f�[�^���ȍ~
#-----------------------------------------------------------
sub TranceAccount{

# �錾
my($init) = &Init();
my(%renew_new,%renew_old,$trance_error_line,$bonused_flag,$print);

# �A�N�Z�X����
my($host) = main::axscheck("Post-only ACCOUNT");

	# SNS�ւ̃��O�C���`�F�b�N
	if(!$main::myaccount{'file'}){
		main::error(qq(�f�[�^���ڍs����O�ɁA�����A�J�E���g��<a href="${main::auth_url}?backurl=">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B));
	}

# ID���`
my $old_id = $main::in{'id'};
my $new_id = $main::myaccount{'file'};

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$new_id)){ main::error("�A�J�E���g�����ςł��B"); }
	if($old_id eq "" || $old_id =~ /[^0-9a-z]/){ main::error("�L����ID���ςł��B"); }


# ���f�[�^���J��
my($old_adv) = &File("",{ FileType => "OldId" , id => $old_id });

	# �f�[�^�ڍs�ς݂��ǂ������`�F�b�N
	if($old_adv->{'trance_to_account'}){
		my $message = qq(���ɂ��̃L�����f�[�^ ( $old_id ) �́A�A�J�E���g ( $old_adv->{'trance_to_account'} ) �Ƀf�[�^�������p����Ă��܂��B);
			if(Mebius::alocal_judge() || $init->{'mente_mode'}){
				$trance_error_line .= qq(<p class="red">$message</p>);
			}
			else{
				main::error($message);
			}
	}

# �V�����f�[�^���J��
my($new_adv) = &File("",{ FileType => "Account" , id => $new_id });

	# �f�[�^�ڍs�ς݂��ǂ������`�F�b�N
	if($new_adv->{'trance_from_account'}){
		my $message = qq(���ɂ��̃A�J�E���g ( $new_id ) �́A�Â��L�����f�[�^ ( $new_adv->{'trance_from_account'} ) �����p���I����Ă��܂��B);
			if(Mebius::alocal_judge() || $init->{'mente_mode'}){
				$trance_error_line .= qq(<p class="red">$message</p>);
			}
			else{
				main::error($message);
			}
	}


	# ���O�C�����s�񐔂��擾
	my(%login_missed) = Mebius::Login::TryFile("Adventure-file By-form Get-hash",$main::xip);

			# �����̃��O�C�����s����������ꍇ�̓G���[��
			if($login_missed{'error_flag'}){
				main::error($login_missed{'error_flag'});
			}

	# ���f�[�^�̃p�X���[�h�`�F�b�N
	if($old_adv->{'pass'} eq $main::in{'pass'} && $old_adv->{'pass'} && $old_adv->{'f'}){}
	# �p�X���[�h�F�؂Ɏ��s�����ꍇ
	else{
		Mebius::Login::TryFile("Adventure-file Login-missed By-form Renew",$main::xip,$old_id,$main::in{'pass'});
		main::error("���r�A�h��ID�ƃp�X���[�h����v���܂���B");
	}

	# �v���r���[
	if($main::in{'preview'}){
		&TranceAccountView({ TypePreview => 1 });
	}

	# ����������t�@�C���X�V������ǉ�

	# ���Ɉڍs��̃A�J�E���g�����݂���ꍇ
	if($new_adv->{'f'}){
		# �o�b�N�A�b�v���쐬
		my $copy_success_flag = File::Copy::copy($new_adv->{'file'},$new_adv->{'overwrite_file'});
	}

	# �V�����f�[�^���X�V
	if($new_adv->{'directory'}){ File::Path::rmtree($new_adv->{'directory'}); }
	else{ main::error("�f�B�e�N�g������`�ł��܂���B"); }


%renew_new = %$old_adv;
$renew_new{'trance_from_account'} = $old_id;
$renew_new{'trance_from_time'} = time;
my $bonus_per = 1.5;
	if($old_adv->{'gold'} + $old_adv->{'bank'} >= 1){
		$renew_new{'gold'} = int($renew_new{'gold'} * $bonus_per);
		$renew_new{'bank'} = int($renew_new{'bank'} * $bonus_per);
		$bonused_flag = 1;
	}
$renew_new{'pass'} = "";
$renew_new{'salt'} = "";
$renew_new{'first_host'} = $host;
$renew_new{'first_agent'} = $main::agent;
$renew_new{'first_time'} = time;
$renew_new{'id'} = $new_id; # �����L���O�ɔ��f�p
my($renewed_new_adv) = &File("Renew",{ FileType => "Account" , id => $new_id , TypeTrance => 1 },\%renew_new);

# �Â��f�[�^���X�V
$renew_old{'trance_to_account'} = $new_id;
$renew_old{'trance_to_time'} = time;
&File("Renew",{ FileType => "OldId" , id => $old_id },\%renew_old);

# �A�C�e���q�ɂ̃f�[�^���R�s�[
require Mebius::Adventure::Item;
my($new_adv_for_item) = &File(undef,{ FileType => "Account" , id => $new_id  });
my($item_old) = &ItemStock("Old-file Get-hash",undef,$old_adv);
my($item_new) = &ItemStock("Get-hash Test",undef,$new_adv_for_item);
my $copy_success_flag = &File::Copy::copy($item_old->{'file'},$item_new->{'file'});

# CCC
#Mebius::AccessLog(undef,"Adventure-trance",qq($item_old->{'file'} => $item_new->{'file'}));

# �L�^
Mebius::AccessLog("Not-unlink-file","Adventure-trance-character-data","$old_id �� $new_id");

$print .= qq(<p> ���r�A�h�̋�ID ( $old_id ) �� ���r�E�X�����O�A�J�E���g ( $new_id ) �ɔ��f�����܂����B</p>);

	if($copy_success_flag){
		$print .= qq(<p>�A�C�e���q�ɂ̓��e�������p���܂����B</p>);
	}

	if($bonused_flag){
		$print .= qq(<p> ���p���{�[�i�X�Ƃ��� �������A�����z�� $bonus_per �{�ɑ����܂����B </p>);
	}

	# �G���[ (�Ǘ��Ҋm�F�p)
	if($trance_error_line){
		$print .= qq($trance_error_line);
	}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

