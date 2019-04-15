
use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# ���ʂ̐ݒ�
#-----------------------------------------------------------
sub InitMessage{

my(%init);

# ���b�Z�[�W�P�ʂ�����̍ő啶����
$init{'max_length_message'} = 5000;

# ���b�Z�[�W�P�ʂ�����̍ő啶���� ( �薼 )
$init{'max_length_subject'} = 50;

# �P��������̃��b�Z�[�W�ő呗�M��
$init{'max_message_perday'} = 50;

# ���M / ��M�ʂ̑т̐F
$init{'send_color_style'} = "background:#fee;border-color:#f99;";
$init{'catch_color_style'} = "background:#eef;border-color:#99f;";

# �Ǘ��҂Ƃ��ĔF�����郌�x��
if($main::myadmin_flag >= 5){ $init{'admin_flag'} = 1; }


return(%init);

}

#-----------------------------------------------------------
# �A�J�E���g��Ԃ̃`�F�b�N
#-----------------------------------------------------------
sub LevelCheckMessage{

# �錾
my($type,%account,$enemy_account) = @_;
my($error_message);

	# ����Ǝ����̃L�[�`�F�b�N
	if(!$account{'justy_flag'}){ $error_message = qq($account{'name_link'} ����ɂ͌��݁A���b�Z�[�W�𑗐M�ł��܂���B); }

	# ���M/��M�������Ȃ��ꍇ
	elsif(!$account{'allow_message_flag'}){ $error_message = qq($account{'name_link'} ����ɂ͌��݁A���b�Z�[�W�t�H�[�����g���錠��������܂���B); }

	# �G���[�������\������ꍇ	
	if($type =~ /Error-view/ && $error_message && !$main::myadmin_flag){
		main::error("$error_message");
	}

return($error_message);

}

#-------------------------------------------------
# �������X�^�[�g
#-------------------------------------------------
sub MessageFormStart{

	# ���o�C������
	if($main::device_type eq "mobile"){
		main::kget_items();
	}

	# �^�C�g����`
	$main::sub_title = qq(���b�Z�[�W | $main::title);
		if($main::myaccount{'file'}){
			$main::head_link3 = qq(&gt; <a href="${main::auth_url}$main::in{'account'}/?mode=message">���b�Z�[�W</a>);
		}


	# ���[�h�U�蕪��
	if($main::in{'account'} eq ""){ &MessageHistoryAllMemberView(undef); }
	elsif($main::in{'type'} eq "send_message"){ &SendMessage(undef,$main::in{'to'}); }
	elsif($main::in{'type'} eq "control_message"){ &ControlMessage(undef,$main::in{'account'}); }
	elsif($main::in{'type'} eq "view"){ &MessageView("Message-view",$main::in{'account'},$main::in{'message_id'}); }
	elsif($main::in{'type'} eq "history"){ &MessageHistoryAccountView(undef,$main::in{'account'},$main::in{'account2'}); }
	elsif($main::in{'type'} eq "" && $main::in{'to'}){ &MessageView("Brand-new-form",$main::in{'account'}); }
	elsif($main::in{'type'} eq "box" || $main::in{'type'} eq ""){ &MessageBoxView(undef,$main::in{'account'}); }
	else{ main::error("���̃��[�h�͑��݂��܂���B"); }

exit;

}

#-----------------------------------------------------------
# ���b�Z�[�W�P�̂̉{�� �� ���M�t�H�[��
#-----------------------------------------------------------
sub MessageView{

# �錾
my($type,$message_account,$message_id,$error_message) = @_;
my(%init) = &InitMessage();
my($line,%to_account,%message_account,%message,$first_input_subject,$first_input_textarea);
my($first_input_to_account,$form,$not_useform_message,%box,$plustype_check_friend_to,$plustype_check_friend_from);

# CSS��`
$main::css_text .= qq(
textarea.message{width:100%;height:200px;}
td.message{vertical-align:top;}
div.not_useform{padding:1em;margin:1em 0em;background:#dee;}
div.error_message{padding:0.5em 1em;background:#fee;margin:1.0em;}
div.alert_box{padding:1em;border:solid 1px #f00;margin:1em 5%;}
div.message_handle{margin-bottom:2em;}
);

	# �����̌����`�F�b�N
	my($error_mylevel) = &LevelCheckMessage(undef,%main::myaccount);
	$not_useform_message .= $error_mylevel;

	# �ő呗�M���̐���
	if($main::myaccount{'today_send_message_num'} > $main::myaccount{'maxsend_message'}){
		$not_useform_message .= qq(�����̍ő呗�M���𒴂��Ă��܂��A�����܂ő҂��Ă��������B);
	}

	# �������̃��b�Z�[�W�ł͂Ȃ��ꍇ
	# �������ӁI���� ( ���l�Ƀ��b�Z�[�W���{������Ȃ��悤�� �y�K�����̎��_�ŃG���[�ɂ��邱�Ɓz)
	if($message_account ne $main::myaccount{'file'}){
			if($init{'admin_flag'}){ $not_useform_message .= qq(���Ȃ��̃��b�Z�[�W�{�b�N�X�ł͂���܂���B); }
			else{ main::error("���Ȃ��̃��b�Z�[�W�{�b�N�X�ł͂���܂���B"); }
	}

	# ���M�҂̃A�J�E���g���J��
	(%message_account) = Mebius::Auth::File("File-check-error Option",$message_account);

	# ���ׂẴ{�b�N�X�̃����N���擾
	my($select_box_links) = &MessageBoxAllLinks("",$message_account);

	# ���V�K���M�t�B�[��
	if($type =~ /Brand-new-form/){

		# �A�N�Z�X����
		main::axscheck("Login-check");

		# ������`
		(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$main::in{'to'});

		# �w�b�_�����N���`
		$main::head_link4 .= qq(&gt; �V�K���M);

	}

	# �� ���b�Z�[�W���{������ꍇ
	if($type =~ /Message-view/){

			# �����̃��b�Z�[�W�{�b�N�X�ł͂Ȃ��ꍇ
			if($main::myaccount{'file'} ne $message_account){
					if($init{'admin_flag'}){ }
					else{ main::error("���Ȃ��̃��b�Z�[�W�ł͂���܂���B"); }
			}

		# ���b�Z�[�W�f�[�^���擾
		(%message) = &MessageFile("Get-hash File-check-error Open-message",$message_account,$message_id);

		# �������郁�b�Z�[�W�{�b�N�X���擾
		(%box) = &MessageBox("Get-hash-only",$message_account,$message{'boxtype'});

		# �w�b�_�����N���`
		$main::head_link4 .= qq(&gt; <a href="./?mode=message&amp;boxtype=$message{'boxtype'}">$box{'title'}</a>);
		$main::head_link5 .= qq(&gt; $message{'subject'});

			# �e��G���[
			if($message{'deleted_flag'}){
					if($init{'admin_flag'}){ $not_useform_message .= qq(���̃��b�Z�[�W�͍폜�ς݂ł��B); }
					else{ main::error("���̃��b�Z�[�W�͍폜�ς݂ł��B"); }
			}

		# �����ɑ��M�������b�Z�[�W�̏ꍇ�́A���M�t�H�[����\�����Ȃ�
		if($message{'from_account'} eq $main::in{'account'}){ 
			$not_useform_message .= qq(���������M�������b�Z�[�W�ł��B);
		}

		# ����̃A�J�E���g���擾
		(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$message{'from_account'});

	}

	# �������}�C���r�݂̂ɑ��M�������Ă���ꍇ
	if($main::myaccount{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_from .= qq( Friend-check);
	}
	# ���肪�}�C���r�݂̂ɑ��M�������Ă���ꍇ
	if($to_account{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_to .= qq( Friend-check);
	}


# ���݂��̋֎~�ݒ���`�F�b�N
my($deny_flag1,$deny_message1) = Mebius::Auth::FriendStatus("Check-status Deny-check $plustype_check_friend_from",$message_account,$to_account{'file'});
$not_useform_message .= $deny_message1;
my($deny_flag2,$deny_message2) = Mebius::Auth::FriendStatus("Check-status Deny-check $plustype_check_friend_to",$to_account{'file'},$message_account);
$not_useform_message .= $deny_message2;

# �N��`�F�b�N
#my($error_age_gyap) = Mebius::Auth::AgeGyap("Allow-together-adult",$to_account{'age'},$main::myaccount{'age'},1);
#$not_useform_message .= $error_age_gyap;

# ����̌����`�F�b�N
my($error_enemy_level) = &LevelCheckMessage(undef,%to_account);
$not_useform_message .= $error_enemy_level;

	# ���������O�C�����Ă��Ȃ��ꍇ ( �G���[���b�Z�[�W�������� )
	if(!$main::myaccount{'file'}){
		$not_useform_message = qq(���b�Z�[�W�@\�\\���g���ɂ�<a href="${main::auth_url}?backurl=$main::selfurl_enc">���O�C��</a>���Ă��������B);
	}

	# �t�H�[���̏�������
	# �薼
	if($main::ch{'subject'}){ $first_input_subject = $main::in{'subject'}; }
	elsif($type =~ /Message-view/){
			if($message{'subject'} =~ /^Re:/){
				$first_input_subject = qq($message{'subject'});
			}
			else{
				$first_input_subject = qq(Re: $message{'subject'});
			}
	}
	if($first_input_subject eq "" && $main::postflag){ $first_input_subject = "(����)"; }
	# ����
	if($main::in{'to'}){ $first_input_to_account = $main::in{'to'}; }
	elsif($type =~ /Message-view/){ $first_input_to_account = qq($message{'from_account'}); }

	# �{��
	if($main::postflag){
		$first_input_textarea = $main::in{'comment'};
		$first_input_textarea =~ s/<br>/\n/g;
	}

	# HTML�̒�`
	if($type =~ /Message-view/){

		# ���������N
		my($view_message) = Mebius::auto_link($message{'message'});

		$line .= qq(<h1$main::kstyle_h1>$message{'subject'}</h1>\n);
		$line .= qq($select_box_links);
		#$line .= qq(<h2$main::kstyle_h2>����</h2>\n);
			if($message{'boxtype'} eq "send"){ $line .= qq(<h2 style="$init{'send_color_style'}$main::kstyle_h2_in">���M</h2>\n); }
			else{ $line .= qq(<h2 style="$init{'catch_color_style'}$main::kstyle_h2_in">��M</h2>\n); }

		$line .= qq(<div class="message_handle">);
		$line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
		#$line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);

			if($message{'from_account'} eq $message_account){ $line .= qq( ( <a href="./?mode=message&amp;type=history&amp;account2=$message{'to_account'}">����</a> ) ); }
			else{ $line .= qq( ( <a href="./?mode=message&amp;type=history&amp;account2=$message{'from_account'}">����</a> ) ); }

		$line .= qq(</div>\n);
		$line .= qq(<div class="line-height">$view_message</div>\n);
		$line .= qq(<div class="right">$message{'senddate'}</div>\n);

	}
	elsif($type =~ /Brand-new-form/){
		$line .= qq(<h1$main::kstyle_h1>���b�Z�[�W�̑��M</h1>\n);
		$line .= qq($select_box_links);
		$line .= qq(<h2$main::kstyle_h2>�V�K���M</h2>\n);
		$line .= qq($to_account{'name_link'} ����ɔ���J�̃��b�Z�[�W�𑗂�܂��B\n);
	}


	# �v���r���[�b�菈�u
	if($ENV{'REQUEST_METHOD'} eq "POST" && $main::in{'comment'}){
		$form .= qq(<h2$main::kstyle_h2>�v���r���[</h2>);
		$form .= qq(<section>);
		my($preview) = Mebius::auto_link($main::in{'comment'});
		$form .= qq($preview);
		$form .= qq(</section>);
	}

# �t�H�[���n�܂�
$form .= qq(<h2$main::kstyle_h2>���M�t�H�[��</h2>\n);

	# �G���[���b�Z�[�W
	if($error_message){
		$form .= qq(<div style="color:#f00;" class="error_message">�G���[�F $error_message</div>\n);
	}


$form .= qq(<form action="./" method="post"$main::sikibetu>\n);
$form .= qq(<div>\n);
$form .= qq(<div class="right">�����͂��� $message_account{'today_left_message_num'}�� ���M�ł��܂��B</div>\n);
$form .= qq(<input type="hidden" name="mode" value="message"$main::xclose>\n);
$form .= qq(<input type="hidden" name="type" value="send_message"$main::xclose>\n);
$form .= qq(<input type="hidden" name="message_id" value="$main::in{'message_id'}"$main::xclose>\n);
$form .= qq(<input type="hidden" name="to" value="$first_input_to_account"$main::xclose>\n);
$form .= qq(<input type="hidden" name="account" value="$message_account"$main::xclose>\n);
$form .= qq(<input type="hidden" name="return_message_id" value="$message_id"$main::xclose>\n);
$form .= qq(<table summary="���M�t�H�[��">\n);

# ����̕\��
$form .= qq(<tr>\n);
$form .= qq(<td class="message">����</td>\n);
$form .= qq(<td>$to_account{'name'} - $to_account{'file'}</td>\n);
$form .= qq(</tr>\n);

# �������͗�
$form .= qq(<tr>\n);
$form .= qq(<td class="message">����</td>\n);
$form .= qq(<td><input type="text" name="subject" value="$first_input_subject"$main::xclose></td>\n);
$form .= qq(</tr>\n);

# �{�����͗�
$form .= qq(<tr>\n);
$form .= qq(<td class="message">�{��</td>\n);
$form .= qq(<td><textarea name="comment" class="message">$first_input_textarea</textarea></td>\n);
$form .= qq(</tr>\n);

# ���ӗ�
$form .= qq(<tr>\n);
$form .= qq(<td></td>\n);
$form .= qq(<td class="line-height">\n);
$form .= qq(<span style="color:#080;" class="size90">���S�p$init{'max_length_message'}�����܂ő��M�ł��܂��B�@���e�͔���J�ł����A<a href="${main::auth_url}message.html" target="_blank" class="blank">���M����</a>�̂݌��J����܂��B</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">�����p���p�A�o��ړI�ł̗��p�A�����f�ȗ��p�͂������������B�Ǘ���K�v���Ɣ��f�����ꍇ�A���b�Z�[�W���e��<strong>�Ǘ��҂�����</strong>�����Ă��������ꍇ������܂��B</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">�����M���e�͈Í�������܂���B�N���W�b�g�J�[�h�ȂǁA�d�v�ȏ��𑗂�Ȃ��ł��������B</span>\n);
$form .= qq(</td>\n);
$form .= qq(</tr>\n);


# ���M�{�^��
$form .= qq(<tr>\n);
$form .= qq(<td></td>\n);
$form .= qq(<td>\n);
$form .= qq(<input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview"$main::xclose>\n);
$form .= qq(<input type="submit" value="���̓��e�ő��M����" class="isubmit"$main::xclose>\n);
$form .= qq(</td>\n);
$form .= qq(</tr>\n);

$form .= qq(</table>\n);

# �ق��̒���
$form .= qq(<div class="line-height alert_box">\n);
#$form .= qq(<span style="color:#f00;" class="size90">���N��o�^���U���Ă̂����p�́A��΂ɂ������������B�A�J�E���g���b�N�A���p��~�Ȃǂ̏��u����点�Ă��������ꍇ������܂��B</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">�����b�Z�[�W�t�H�[���͈��̏����ŃI�[�v�����܂��B�����͗\\��\�Ȃ��ɕύX�ƂȂ�A���b�Z�[�W�t�H�[�����g���Ȃ��Ȃ�ꍇ������܂��B</span><br$main::xclose>\n);
$form .= qq(</div>\n);


$form .= qq(</div>\n);
$form .= qq(</form>\n);

	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS/){
		$form = qq(SNS�͌��݁A�X�V��~���ł��B);
	}



# HTML�V�����o��
my $print = qq($line);

	if($not_useform_message){ $print .=  qq(<div class="not_useform">$not_useform_message</div>); }
	if(!$not_useform_message || $init{'admin_flag'}){ $print .=  qq($form); }

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���b�Z�[�W�𑗐M����
#-----------------------------------------------------------
sub SendMessage{

# �錾
my($type,$to_account) = @_;
my(%init) = &InitMessage();
my(%to_renew,%from_renew,$view_line,$plustype_message_view,$plustype_check_friend_from,$plustype_check_friend_to,%renew_option,%renew_account,%renew_target_account);

# �A�N�Z�X����
main::axscheck("Post-only Login-check ACCOUNT");

	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS/){
		main::error("SNS�͌��݁A�X�V��~���ł��B");
	}

# ����̃A�J�E���g���J��
my(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$to_account);

# �����`�F�b�N
&LevelCheckMessage("Error-view",%main::myaccount,$to_account{'file'});
&LevelCheckMessage("Error-view",%to_account,$main::myaccount{'file'});



	# �����̍ő呗�M�����z���Ă���ꍇ
	if(!$main::myadmin_flag && $main::myaccount{'today_send_message_num'} > $main::myaccount{'maxsend_message'}){
		main::error("�����̍ő呗�M���𒴂��Ă��܂��B�����܂ő҂��Ă��������B");
	}

	# �������}�C���r�݂̂ɑ��M�������Ă���ꍇ
	if(!$main::myadmin_flag && $main::myaccount{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_from .= qq( Friend-check-error);
	}
	# ���肪�}�C���r�݂̂ɑ��M�������Ă���ꍇ
	if(!$main::myadmin_flag && $to_account{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_to .= qq( Friend-check-error);
	}

# ���݂��̋֎~�ݒ���`�F�b�N
Mebius::Auth::FriendStatus("Check-status Deny-check-error $plustype_check_friend_from",$main::myaccount{'file'},$to_account{'file'});
Mebius::Auth::FriendStatus("Check-status Deny-check-error $plustype_check_friend_to",$to_account{'file'},$main::myaccount{'file'});

	# �N��`�F�b�N
	#Mebius::Auth::AgeGyap("Allow-together-adult Error-view",$to_account{'age'},$main::myaccount{'age'},1);

	# �G���[/�v���r���[���̃��[�h��`
	if($main::in{'message_id'}){
		$plustype_message_view .= qq( Message-view);
	}
	else{
		$plustype_message_view .= qq( Brand-new-form);
	}

	# �e��G���[
	if(length($main::in{'comment'})/2 > $init{'max_length_message'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"�{�������������߂ł��B");
	}
	if($main::in{'comment'} =~ /^$|^([\s�@]+)$/){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"�{������͂��Ă��������B");
	}
	if(length($main::in{'subject'})/2 > $init{'max_length_subject'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"�薼�����������߂ł��B");
	}
	if($main::in{'subject'} =~ /^$|^([\s�@]+)$/){
		$main::in{'subject'} = "(����)";
	}

	# �v���r���[
	if($main::in{'preview'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'});
	}

	# �����b�Z�[�W�ɕԐM�����ꍇ�A�����b�Z�[�W�ɕԐM�}�[�N��t����
	if($main::in{'return_message_id'}){
		MessageFile("Return-message Renew",$main::myaccount{'file'},$main::in{'return_message_id'});
	}

# ���b�Z�[�W�t�@�C���ɋL�^������e���`
$to_renew{'message'} = $main::in{'comment'};
$to_renew{'subject'} = $main::in{'subject'};
$to_renew{'to_handle'} = $to_account{'name'};
$to_renew{'from_handle'} = $main::myaccount{'name'};
$to_renew{'to_account'} = $to_account{'file'};
$to_renew{'from_account'} = $main::myaccount{'file'};
$to_renew{'boxtype'} = "catch";

# ���b�Z�[�W�t�@�C���ɋL�^������e���`
$from_renew{'message'} = $main::in{'comment'};
$from_renew{'subject'} = $main::in{'subject'};
$from_renew{'to_handle'} = $to_account{'name'};
$from_renew{'from_handle'} = $main::myaccount{'name'};
$from_renew{'to_account'} = $to_account{'file'};
$from_renew{'from_account'} = $main::myaccount{'file'};
$from_renew{'boxtype'} = "send";

# �V�������b�Z�[�WID���`
my($to_message_id) = Mebius::Crypt::char(undef,30);

# �V�������b�Z�[�WID���`
my($from_message_id) = Mebius::Crypt::char(undef,30);

# ����̃��b�Z�[�W�{�b�N�X�Ƀ��b�Z�[�W���쐬
MessageFile("New-message Renew",$to_account,$to_message_id,%to_renew);

# ����̃��b�Z�[�W�{�b�N�X ( ��M�� ) ���X�V
MessageBox("Renew New-message",$to_account,"catch",$to_message_id);

# ����̃A�J�E���g���Ƃ̑���M�������X�V
MessageHistoryAccount("Renew New-message",$to_account,$main::myaccount{'file'},$to_message_id);

# �����̃��b�Z�[�W�{�b�N�X�Ƀ��b�Z�[�W���쐬
MessageFile("New-message Renew",$main::myaccount{'file'},$from_message_id,%from_renew);

# �����̃��b�Z�[�W�{�b�N�X ( ���M�� )���X�V
MessageBox("Renew New-message",$main::myaccount{'file'},"send",$from_message_id);

# �����̃A�J�E���g���Ƃ̑���M�������X�V
MessageHistoryAccount("Renew New-message",$main::myaccount{'file'},$to_account,$from_message_id);

# �O�����o�[�̑��M�������X�V
MessageHistoryAllMember("Renew New-message",$to_account,$to_message_id);

# �����̃I�v�V�����t�@�C�����X�V
#$renew_option{'plus->today_send_message_num'} = 1;
#$renew_option{'last_send_message_yearmonthday'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_option);

# ���� ( ���M�� )�̃t�@�C�����X�V
$renew_account{'+'}{'today_send_message_num'} = 1;
$renew_account{'last_send_message_yearmonthday'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_account);

# ����t�@�C�����X�V
$renew_target_account{'+'}{'unread_message_num'} = 1;
Mebius::Auth::File("Renew",$to_account,\%renew_target_account);

# ��M����ɁA�����[���𑗐M
my %mail;
$mail{'url'} = "$to_account{'file'}/?mode=message&type=view&message_id=$to_message_id";
$mail{'comment'} = $to_renew{'message'};
$mail{'subject'} = qq($main::myaccount{'name'}���񂩂烁�b�Z�[�W���͂��܂����B);
Mebius::Auth::SendEmail(" Type-message",\%to_account,\%main::myaccount,\%mail);

# �N�b�L�[���Z�b�g
#Mebius::set_cookie();

# �\�����e���`
Mebius::Redirect(undef,"${main::auth_url}$main::myaccount{'file'}/?mode=message");
$view_line .= qq(���M���܂����B(<a href="${main::auth_url}$to_account/">���߂�</a>));

# �^�C�g����`
$main::sub_title = qq(���b�Z�[�W�̑��M);
$main::head_link4 = qq(&gt; ���M);

my $print = $view_line;

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���b�Z�[�W�P�̃t�@�C��
#-----------------------------------------------------------
sub MessageFile{

# �錾
my($type,$account,$message_id,%renew) = @_;
my(%message,@renew_line,$message_handler);

	# �����`�F�b�N
	if($account =~ /^$|\W/){ main::error("����̃A�J�E���g�����ςł��B"); }

	# �����`�F�b�N���邱��
	if($message_id =~ /^$|\W/){ main::error("���b�Z�[�WID���w�肵�Ă��������B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �f�B���N�g�� / �t�@�C����`
my $directory1 = "${account_directory}message/";
my $directory2 = "${directory1}_log_message/";
my $file = "${directory2}${message_id}_message.dat";

	# �X�V�t���O
	if($type =~ /Renew/){
		$message{'renew_flag'} = 1;
	}

	# �t�@�C�����J��
	if($type =~ /File-check-error/){ open($message_handler,"<$file") || main::error("���b�Z�[�W�����݂��܂���B"); }
	else{ open($message_handler,"<$file"); }

		if($type =~ /Renew/){ flock($message_handler,1); }
	chomp(my $top1 = <$message_handler>);
	chomp(my $top2 = <$message_handler>);
	chomp(my $top3 = <$message_handler>);
	chomp(my $top4 = <$message_handler>);
	close($message_handler);

	# �g�b�v�f�[�^�𕪉�
	($message{'concept'},$message{'to_account'},$message{'from_account'},$message{'to_handle'},$message{'from_handle'}) = split(/<>/,$top1);
	($message{'subject'},$message{'message'},$message{'boxtype'}) = split(/<>/,$top2);
	($message{'sendtime'},$message{'lasttime'},$message{'open_time'},$message{'senddate'}) = split(/<>/,$top3);
	($message{'addr'},$message{'host'},$message{'agent'},$message{'cnumber'},$message{'encid'}) = split(/<>/,$top4);

	# ���n�b�V���̒���

	# �폜�ς݂̏ꍇ
	if($message{'concept'} =~ /Deleted/){
		$message{'deleted_flag'} = 1;
	}

	# �J�����폜������Ă��Ȃ��ꍇ
	if($message{'concept'} !~ /Deleted/ && !$message{'open_time'}){
		$message{'natural_flag'} = 1;
	}

	if(time < $message{'sendtime'} + 3*24*60*60){
		$message{'new_flag'} = 1;
	}

	# �C�ӂ̍X�V
	if($type =~ /Renew/){
			foreach(keys %renew){
					if(defined($renew{$_})){ $message{$_} = $renew{$_}; }
			}
	}

	# �V�K���M
	if($type =~ /New-message/){
		$message{'encid'} = main::id();
		$message{'addr'} = $main::addr;
		$message{'host'} = $main::host;
		$message{'agent'} = $main::agent;
		$message{'cnumber'} = $main::cnumber;
		$message{'sendtime'} = $main::time;
		$message{'senddate'} = $main::date;
	}

	# �ԐM�����ꍇ
	if($type =~ /Return-message/){
			if($message{'concept'} =~ /Return-message/){
				$message{'renew_flag'} = 0;
			}
			else{
				$message{'concept'} .= qq( Return-message);
			}
	}

	# ���b�Z�[�W���폜����ꍇ
	if($type =~ /Delete-message/){
			# ���ɍ폜�ς݂̏ꍇ
			if($message{'concept'} =~ /Deleted/){
				$message{'renew_flag'} = 0;
			}
			# �폜����
			else{
				$message{'success_flag'} = 1;
				$message{'concept'} .= qq( Deleted);
			}
	}

	# ���b�Z�[�W�𕜊�����ꍇ
	if($type =~ /Revive-message/){
			# ���ɍ폜�ς݂̏ꍇ
			if($message{'concept'} =~ /Deleted/){
				$message{'concept'} =~ s/(\s?)Deleted//g;
				$message{'success_flag'} = 1;
			}
			# �폜�ς݂Ŗ����ꍇ
			else{
				$message{'renew_flag'} = 0;
			}
	}

	# ���J������ꍇ ???
	if($type =~ /Open-message/ && $message{'to_account'} eq $main::myaccount{'file'} && !$message{'open_time'} && !$message{'deleted_flag'}){

		my(%renew_box);
		$message{'renew_flag'} = 1;
		$message{'open_time'} = time;
		$type .= qq( Renew);
			$renew_box{'point->opened_message'} = 1;
			MessageBox("Renew",$account,$message{'boxtype'},undef,%renew_box);

			# �A�J�E���g�{�̂̐V�����b�Z�[�W�������炷
			my($renewed_account) = Mebius::Auth::File("Renew ReturnRef",$account,{ '-' => { unread_message_num => 1 } });

				# SSS �}�C�i�X�̌������C�� 2013/1/22 (��)
				if($renewed_account->{'unread_message_num'} <= -1){
					Mebius::Auth::File("Renew",$account,{ 'unread_message_num' => 0 });
				}

	}


	# �t�@�C���X�V
	if($type =~ /Renew/ && $message{'renew_flag'}){

		# ���ʂ̍X�V���`
		$message{'lasttime'} = time;

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);

		# �X�V�s��̒�
		push(@renew_line,"$message{'concept'}<>$message{'to_account'}<>$message{'from_account'}<>$message{'to_handle'}<>$message{'from_handle'}<>\n");
		push(@renew_line,"$message{'subject'}<>$message{'message'}<>$message{'boxtype'}<>\n");
		push(@renew_line,"$message{'sendtime'}<>$message{'lasttime'}<>$message{'open_time'}<>$message{'senddate'}<>\n");
		push(@renew_line,"$message{'addr'}<>$message{'host'}<>$message{'agent'}<>$message{'cnumber'}<>$message{'encid'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}


return(%message);

}

#-----------------------------------------------------------
# ���b�Z�[�W�{�b�N�X���{������
#-----------------------------------------------------------
sub MessageBoxView{

# �錾
my($type,$account) = @_;
my(%init) = &InitMessage();
my($plustype_box,$select_box_links,%box,$index_line);

	# �ΏۃA�J�E���g���J��
	my(%account) = Mebius::Auth::File(undef,$account);

	# ���O�C���`�F�b�N
	if(!$main::myaccount{'file'}){ main::error(qq(���̋@\�\\���g���ɂ�<a href="${main::auth_url}?backurl=$main::selfurl_enc">���O�C��</a>���Ă��������B)); }

	# �����`�F�b�N
	#&LevelCheckMessage(undef,%main::myaccount);

	# �����̃��b�Z�[�W�{�b�N�X�ł͂Ȃ��ꍇ �������K�����̎��_�ŃG���[��\�����邱�Ɓ�����
	if(!$account{'myprof_flag'} && !$init{'admin_flag'}){ main::error("���Ȃ��̃��b�Z�[�W�{�b�N�X�ł͂���܂���B"); }

	# ���ׂẴ{�b�N�X�̃����N���擾
	my($select_box_links) = &MessageBoxAllLinks("Box-view",$account);

	# ���b�Z�[�W�{�b�N�X���擾
	if($main::in{'boxtype'} eq ""){
		(%box) = &MessageBox("Get-index",$account,"catch",10); 
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});
		(%box) = &MessageBox("Get-index",$account,"send",10); 
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});

	}
	else{
		(%box) = &MessageBox("Get-index",$account,$main::in{'boxtype'},undef,$main::in{'page'});
		$main::head_link4 = qq(&gt; $box{'title'});
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});
	}

# �����N
my($sns_multi_link) = main::footer_link();

my $print .= qq(
$sns_multi_link
<h1$main::kstyle_h1>���b�Z�[�W�{�b�N�X</h1>
$select_box_links
$index_line
$sns_multi_link
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

#-----------------------------------------------------------
# �S���b�Z�[�W�{�b�N�X�̑I�������N
#-----------------------------------------------------------
sub MessageBoxAllLinks{

# �錾
my($type,$account,$relay_type) = @_;
my($select_box_links);

# �S�{�b�N�X�̎�ނ��`
my(@message_box) = ("catch","send");

	# ���b�Z�[�W�{�b�N�X��W�J
	foreach(@message_box){
		my($line2);
		my(%box2) = &MessageBox("Get-hash-only",$account,$_);
			$line2 .= qq($box2{'title'});
				if($_ eq "send"){ $line2 .= qq(($box2{'all_message'})); }
				else{ $line2 .= qq(($box2{'natural_message'}/$box2{'all_message'})); }
				if($_ ne $main::in{'boxtype'}){ $line2 = qq(<a href="./?mode=message&amp;boxtype=$_">$line2</a>); }
			$select_box_links .= qq($line2\n);
	}

	# �����N��`
	if($main::in{'boxtype'} eq "" && $type =~ /Box-view/){
		$select_box_links = qq(�S�� $select_box_links\n);
		$main::head_link3 = qq(&gt; ���b�Z�[�W);
	}
	else{
		$select_box_links = qq(<a href="./?mode=message">�S��</a> $select_box_links\n);
	}
	$select_box_links = qq(<div class="word-spacing">$select_box_links</div>);

return($select_box_links);

}

#-----------------------------------------------------------
# ���b�Z�[�W�{�b�N�X
#-----------------------------------------------------------
sub MessageBox{

# �錾
my($type,$account,$boxtype) = @_;
my(%init) = &InitMessage();
my(undef,undef,undef,$maxview_index,$page_number) = @_ if($type =~ /Get-index/);
my(undef,undef,undef,$message_id,%renew) = @_ if($type =~ /Renew/);
my(%box,@renew_line,$message_handler,$file,$hit_index,$index_line,$i_index);

	# �ő�\���s��
	if(!$maxview_index){
			if($main::kflag){ $maxview_index = 10; }
			else{ $maxview_index = 20; }
	}
	if(!$page_number){ $page_number = 1; }

#if($main::alocal_mode){ $maxview_index = 3; }

	# �����`�F�b�N
	if($type =~ /Delete-message|New-message/){
			if($message_id =~ /^$|\W/){ main::error("���b�Z�[�WID���w�肵�Ă��������B"); }
	}

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account)){ main::error("�A�J�E���g�� ( $account ) ���ςł��B"); }
	if($boxtype =~ /^$|\W/){ main::error("���b�Z�[�W�{�b�N�X ( $boxtype) �̎w�肪�ςł��B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �f�B���N�g����`
my $directory = "${account_directory}message/";

	# �t�@�C���̒�`
	$file = "${directory}${account}_message-box_$boxtype.log";

	# �t�@�C�����J��
	open($message_handler,"<",$file);

		# �t�@�C�����b�N
		if($type =~ /Renew/){ flock($message_handler,1); }

	# �g�b�v�f�[�^�𕪉�
	chomp(my $top1 = <$message_handler>);
	($box{'concept'},$box{'title'},$box{'all_message'},$box{'opened_message'},$box{'deleted_message'},$box{'lastcatch_time'},$box{'last_time'}) = split(/<>/,$top1);

	# �n�b�V���𒲐�
	if($boxtype eq "catch"){ $box{'title'} = "��M��"; }
	elsif($boxtype eq "send"){ $box{'title'} = "���M�ς�"; }

	# �ςȃf�[�^���C��
	if($box{'opened_message'} > $box{'all_message'}){
		$box{'opened_message'} = $box{'all_message'};
	}

	$box{'natural_message'} = $box{'all_message'} - $box{'opened_message'};
	if(!$box{'all_message'}){ $box{'all_message'} = 0; }
	if(!$box{'natural_message'}){ $box{'natural_message'} = 0; }
	if(!$box{'opened_message'}){ $box{'opened_message'} = 0; }
	if(!$box{'deleted_message'}){ $box{'deleted_message'} = 0; }


	$box{'new_message'} = 0;


		# �Ō�̎�M���炵�΂炭�o�߂��Ă���ꍇ�́A�t�@�C����W�J���Ă̐V���`�F�b�N�������Ȃ�Ȃ�
		if($type =~ /Get-new-status/ && time >= $box{'lastcatch_time'} + 3*24*60*60){
			$type .= qq( Get-hash-only);
		}

		# �n�b�V���݂̂��擾����ꍇ
		if($type =~ /Get-hash-only/){
			close($message_handler);
			return(%box);
		}

	# �t�@�C����W�J
	while(<$message_handler>){

		# �Ǐ���
		my($mark2);

		# ���E���h�J�E���^
		$i_index++;
			if($init{'admin_flag'}){ $mark2 .= qq( $i_index); }

		# �s�𕪉�
		chomp;
		my($message_id2) = split(/<>/);

		# �X�V�擾�p ( 2012.08.21 �̃t�B�[�h�d�l�ύX�Ɋ֌W���āA���g�p? )
		if($type =~ /Get-new-status/){

			# ���b�Z�[�W�f�[�^���擾
			my(%message) = MessageFile("Get-hash",$account,$message_id2);

				# �e��l�N�X�g/���X�g
				if(!$message{'new_flag'}){ last; }

				# �V�����b�Z�[�W��
				if($message{'new_flag'} && $message{'natural_flag'}){ $box{'new_message'}++; }

		}

		# �C���f�b�N�X�擾�p
		if($type =~ /Get-index/){

			# �Ǐ���
			my($style_subject);
	
			# ���b�Z�[�W�f�[�^���擾
			my(%message) = MessageFile("Get-hash",$account,$message_id2);

			# �ԐM�ς݂̏ꍇ
			if($message{'concept'} =~ /Return-message/ && $boxtype ne "send"){
				$style_subject = qq( style="color:#080;");
			}

			# �J���ς݂̏ꍇ
			elsif($message{'open_time'} && $boxtype ne "send"){
				#$mark2 .= qq( <span style="color:#66f;" class="size80";>[ �J���ς� ]</span>); 
				$style_subject = qq( style="color:#999;");
			}

			# �폜�ς݂̏ꍇ
			if($message{'concept'} =~ /Deleted/){
				if($init{'admin_flag'}){ $mark2 .= qq( <span style="color:#f00;" class="size80";>[ �폜�ς� ]</span>); }
				else{ next; }
			}
			
			# �q�b�g�J�E���^
			else{
				$hit_index++;
			}

				# �ő�\���s���ɒB�����ꍇ
				if($hit_index > 0 && $hit_index < $page_number){ next; }
				if($hit_index >= $maxview_index + $page_number){ last; }

			$index_line .= qq(<tr>\n);

			# �폜�`�F�b�N�{�b�N�X
			$index_line .= qq(<td>\n);
			$index_line .= qq(<input type="checkbox" name="message_id_$message_id2" value="1"$main::xclose>\n);
			$index_line .= qq(</td>\n);

			# ���b�Z�[�W����
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="./?mode=message&amp;type=view&amp;message_id=$message_id2"$style_subject>$message{'subject'}</a>\n);
			$index_line .= qq(</td>\n);

			# ���M���̃A�J�E���g
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
			$index_line .= qq(</td>\n);

			# ����̃A�J�E���g
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);
			$index_line .= qq(</td>\n);

			# ���M / ��M����
			$index_line .= qq(<td>\n);
			$index_line .= qq($message{'senddate'}\n);
			$index_line .= qq(</td>\n);

			# �}�[�N
			$index_line .= qq(<td>\n);
			$index_line .= qq($mark2\n);
			$index_line .= qq(</td>\n);
			$index_line .= qq(</tr>\n);

		}

			# �t�@�C���X�V�p
			if($type =~ /Renew/){
				push(@renew_line,"$message_id2<>\n");
			}

	}

	close($message_handler);

	# �V�K���M�̏ꍇ
	if($type =~ /New-message/){

			# �Ō�̎�M����
			if($boxtype ne "send"){ $box{'lastcatch_time'} = $main::time; }

		# �S���b�Z�[�W��
		$box{'all_message'}++;

		# �V�����s��ǉ�
		unshift(@renew_line,"$message_id<>\n");

	}

	# �C���f�b�N�X�擾�p
	if($type =~ /Get-index/){

		# �Ǐ���
		my($h2_style);

		# �т̐F
		if($boxtype eq "send"){ $h2_style = "$init{'send_color_style'}$main::kstyle_h2_in"; }
		else{ $h2_style = "$init{'catch_color_style'}$main::kstyle_h2_in"; }

			if($boxtype eq $main::in{'boxtype'}){
				$box{'index_line'} .= qq(<h2 style="$h2_style">$box{'title'}($box{'all_message'})</h2>);
			}
			else{
				$box{'index_line'} .= qq(<h2 style="$h2_style"><a href="./?mode=message&amp;boxtype=$boxtype">$box{'title'}($box{'all_message'})</a></h2>);
			}

			if($index_line){
					$box{'index_line'} .= qq(<form action="./" method="post"$main::sikibetu>);
					$box{'index_line'} .= qq(<div>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="mode" value="message"$main::xclose>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="type" value="control_message"$main::xclose>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="account" value="$account"$main::xclose>\n);
					$box{'index_line'} .= qq(<table summary="���[���ꗗ">\n);
					$box{'index_line'} .= qq(<th></th><th>����</th><th>���M��</th><th>����</th><th>���t</th><th></th>\n);
					$box{'index_line'} .= qq($index_line\n);
					$box{'index_line'} .= qq(</table>\n);
					$box{'index_line'} .= qq(<div class="right">\n);
					$box{'index_line'} .= qq(<input type="submit" name="delete" value="���b�Z�[�W�폜"$main::xclose>\n);
						if($init{'admin_flag'}){
							$box{'index_line'} .= qq(<input type="submit" name="revive" style="color:#00f;" value="���b�Z�[�W����"$main::xclose>\n);
						}

					$box{'index_line'} .= qq(</div>\n);
					$box{'index_line'} .= qq(</div>\n);
					$box{'index_line'} .= qq(</form>\n);
			}
			else{
				$box{'index_line'} .= qq(<div class="margin">���͉�������܂���B</div>);
			}


			# �y�[�W�߂��胊���N���擾
			if($box{'all_message'} >= $maxview_index){
				my $prev = $page_number - $maxview_index;
				my $next = $page_number + $maxview_index;
				$box{'page_links'} .= qq(�y�[�W�F );
					if($prev >= 1){ $box{'page_links'} .= qq(<a href="./?mode=message&amp;boxtype=$boxtype&amp;page=$prev">��</a>\n); }
					else{  $box{'page_links'} .= qq(��\n); }
					if($next <= $box{'all_message'}){ $box{'page_links'} .= qq(<a href="./?mode=message&amp;boxtype=$boxtype&amp;page=$next">��</a>\n); }
					else{ $box{'page_links'} .= qq(��\n); }
			}

	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

			# �ŏI�X�V����
			$box{'last_time'} = time;

			# �n�b�V���̈�ĕύX
			foreach(keys %renew){
					if(defined($renew{$_})){ $box{$_} = $renew{$_}; }
					if($_ =~ /^point->(\w+)$/){ $box{$1} += $renew{$_}; }
					if($_ =~ /^text->(\w+)$/){ $box{$1} .= $renew{$_}; }
			}

		# �f�B���N�g�����쐬
		Mebius::Mkdir(undef,$directory);

		# �g�b�v�f�[�^��ǉ�
	unshift(@renew_line,"$box{'concept'}<>$box{'title'}<>$box{'all_message'}<>$box{'opened_message'}<>$box{'deleted_message'}<>$box{'lastcatch_time'}<>$box{'last_time'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}

return(%box);


}

#-----------------------------------------------------------
# ���b�Z�[�W��Ԃ̕ύX
#-----------------------------------------------------------
sub ControlMessage{

# �錾
my($type,$account) = @_;
my(%init) = &InitMessage();
my($selected_flag,$delete_message_num,%boxtype,%boxtype_opened_message,$unread_num);

	# �����̃��b�Z�[�W�{�b�N�X�łȂ��ꍇ
	if($account ne $main::myaccount{'file'} && !$init{'admin_flag'}){
		main::error("�����̃��b�Z�[�W�ł͂Ȃ����߁A�폜�ł��܂���B");
	}

	# �^�C�v���w�肳��Ă��Ȃ��ꍇ
	if($type !~ /Revive-message|Delete-message/){
			if($main::in{'delete'}){ $type .= qq( Delete-message); }
			elsif($main::in{'revive'} && $init{'admin_flag'}){ $type .= qq( Revive-message); }
			else{ main::error("���s�^�C�v���w�肵�Ă��������B"); }
	}

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$main::myaccount{'file'}){ main::error("���b�Z�[�W���폜����ɂ́A���O�C�����Ă��������B"); }

	# ����
	foreach(split(/&/,$main::postbuf)){

		# �f�[�^����
		my($key2,$value2) = split(/=/,$_);

			# ���b�Z�[�WID���q�b�g�����ꍇ
			if($key2 =~ /^message_id_(\w+)$/){
				my $message_id2 = $1;
				$selected_flag = 1;
					# ���b�Z�[�W�̏�Ԃ�ύX (�폜)
					if($type =~ /Delete-message/){
						my(%message) = MessageFile("Delete-message Renew",$account,$message_id2);
							if($message{'success_flag'}){

									# ���J���ł���΁A�폜�ɂ���Ċ��ǐ������炷
									if(!$message{'open_time'} && $account ne $message{'from_account'}){
										$unread_num--;
									}
								$boxtype{"$message{'boxtype'}"}--;
									if($message{'open_time'}){ $boxtype_opened_message{"$message{'boxtype'}"}--; }
							}
					}

					# ���b�Z�[�W�̏�Ԃ�ύX (����)
					elsif($type =~ /Revive-message/){
						my(%message) = MessageFile("Revive-message Renew",$account,$message_id2);
							if($message{'success_flag'}){
									# ���J���ł���΁A�폜�ɂ���Ċ��ǐ��𑝂₷
									if(!$message{'open_time'} && $account ne $message{'from_account'}){
										$unread_num++;
									}
								$boxtype{"$message{'boxtype'}"}++;
									if($message{'open_time'}){ $boxtype_opened_message{"$message{'boxtype'}"}++; }
							}
					}
			}
	}

	# �A�J�E���g�{�̃t�@�C�����X�V (���b�Z�[�W���ǐ��̕ύX�j
	if($unread_num){
		my(%renew_account);
		$renew_account{'+'}{'unread_message_num'} = $unread_num;
		Mebius::Auth::File("Renew",$account,\%renew_account);
	}

	# �S���b�Z�[�W����ύX
	foreach(keys %boxtype){
		my(%renew_box);
		$renew_box{"point->all_message"} = $boxtype{$_};
		$renew_box{"point->opened_message"} = $boxtype_opened_message{$_};
		$renew_box{"point->deleted_message"} = - $boxtype{$_};
		MessageBox("Renew",$account,$_,undef,%renew_box);
	}

# �����I�΂�Ă��Ȃ��ꍇ
#if(!$selected_flag){ main::error("���b�Z�[�W��I�����Ă��������B"); }

# ���_�C���N�g
Mebius::Redirect(undef,"${main::auth_url}$account/?mode=message");

return();


}
#-----------------------------------------------------------
# �A�J�E���g������̑���M�����y�[�W��\������
#-----------------------------------------------------------
sub MessageHistoryAccountView{

# �錾
my($type,$account1,$account2) = @_;
my(%init) = &InitMessage();

# CSS��`
$main::css_text .= qq(
div.message{}
div.message_handle{margin-bottom:1.5em;margin-top:1.0em;}
);


	# �����̃��b�Z�[�W�{�b�N�X�łȂ��ꍇ�̓G���[��
	if($account1 ne $main::myaccount{'file'} && !$init{'admin_flag'}){
		main::error("���Ȃ��̃��b�Z�[�W�ł͂���܂���B");
	}


# ���ׂẴ{�b�N�X�̃����N���擾
my($select_box_links) = MessageBoxAllLinks("",$account1);

# ����̃A�J�E���g���J��
my(%account2) = Mebius::Auth::File("File-check-error",$account2);

# �C���f�b�N�X���擾
my(%history) = MessageHistoryAccount("Get-index",$account1,$account2);

my $print = qq(
<h1$main::kstyle_h1>����M����</h1>
$select_box_links
$history{'index_line'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �A�J�E���g������̑���M����
#-----------------------------------------------------------
sub MessageHistoryAccount{

# �錾
my($type,$account,$account2,$message_id) = @_;
my(%init) = &InitMessage();
my($view_line,$history_handler,%history,$i,@renew_line,$index_line,$hit_index);

	# �����`�F�b�N
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if(Mebius::Auth::AccountName(undef,$account2)){ return(); }
	if($type =~ /New-message/ && $message_id =~ /^$|\W/){ return(); }
	if($account eq $account2){ return(); }

# �ő�L�^�s��
my $maxline_index = 50;

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

#my($account2_directory) = Mebius::Auth::account_directory($account2);

# �t�@�C����`
my $directory1 = "${account_directory}message/_account_message/";
my $file = "${directory1}${account2}_account_message.log";

# �t�@�C�����J��
open($history_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($history_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$history_handler>);
($history{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J����
	while(<$history_handler>){
		
		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($message_id2) = split(/<>/);

			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

				# �Ǐ���
				my($mark2,$h2_style,$h2);

				# �ő�\�����𒴂����ꍇ�A�I��
				if($i >= 10){ last; }

				# ���b�Z�[�W�f�[�^���擾
				my(%message) = Mebius::Auth::MessageFile("Get-hash",$account,$message_id2);

				# �폜�ς݂̏ꍇ
				if($message{'deleted_flag'}){
					next;
				}

				# �q�b�g�J�E���^
				$hit_index++;

					# �}�[�N��`
					if($message{'boxtype'} eq "send"){
						$mark2 .= qq( <span style="color:#f00;">( ���M )</span>);
						$h2_style = qq( style="$init{'send_color_style'}$main::kstyle_h2_in");
						$h2 = qq(<h2$h2_style>$message{'subject'}</h2>);
					}
					else{
						$h2_style = qq( style="$init{'catch_color_style'}$main::kstyle_h2_in");
						$h2 = qq(<h2$h2_style><a href="./?mode=message&amp;type=view&amp;message_id=$message_id2">$message{'subject'}</a></h2>);
					}

				# �\���s���`
				$index_line .= qq(<div>);
				$index_line .= qq($h2);
				$index_line .= qq(<div class="message_handle"><a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>$mark2</div>);
				$index_line .= qq(<div class="line-height">$message{'message'}</div>);
				$index_line .= qq(<div class="right">$message{'senddate'}</div>);

					# �ԐM�����N
					#if($message{'from_accodunt'} ne $account){
					#	$index_line .= qq(<div class="right"><a href="">�ԐM����</a></div>\n);
					#}

				$index_line .= qq(</div>\n);

			}

			# �t�@�C���X�V�p
			if($type =~ /Renew/){

					# �ő�o�^�s���ɒB�����ꍇ
					if($i >= $maxline_index){ last; }

				# �X�V�s��ǉ�
				push(@renew_line,"$message_id2<>\n");

			}

	}

close($history_handler);

	# �C���f�N�X�擾�p
	if($index_line){
		$history{'index_line'} = $index_line;
	}

	# �V�����s��ǉ�����ꍇ
	if($type =~ /New-message/){
		unshift(@renew_line,"$message_id<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g�����쐬
		Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$history{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}

# ���^�[��
return(%history);

}

#-----------------------------------------------------------
# ���b�Z�[�W�̑��M�������{��
#-----------------------------------------------------------
sub MessageHistoryAllMemberView{

# �錾
my($type) = @_;
my($view_line);

# ���M�������擾
my(%send_history) = MessageHistoryAllMember("Get-index");

# �^�C�g����`
$main::sub_title = qq(���b�Z�[�W�̑��M���� | $main::title );
	if($main::myaccount{'file'}){ $main::head_link3 = qq(&gt; <a href="${main::auth_url}$main::myaccount{'file'}/?mode=message">���b�Z�[�W</a>); }
	else{ $main::head_link3 = qq(&gt; ���b�Z�[�W); }
$main::head_link4 = qq(&gt; ���M����(�S�����o�[));

# �\�����e���菬��
$view_line .= qq(<h1$main::kstyle_h1>���b�Z�[�W�̑��M���� (�S�����o�[)</h1>);
#$view_line .= qq(<span style="color:#f00;">���N����U���Ă̗��p�𔭌����ꂽ�ꍇ�́A�ᔽ�����m�ɕ�����ӏ��iURL�A���X�ԂȂǁj�����񎦂̏�A���萔�ł���<a href="http://aurasoul.mb2.jp/_delete/">�폜�˗��f����</a>�܂ł��񍐂��������B</span><br$main::xclose><br$main::xclose>);
$view_line .= qq($send_history{'index_line'});


my $print = qq($view_line);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




#-----------------------------------------------------------
# ���b�Z�[�W�̑��M���� ( �S�����o�[ )
#-----------------------------------------------------------
sub MessageHistoryAllMember{

# �錾
my($type,$to_account,$message_id) = @_;
my(%init) = &InitMessage();
my(@renew_line,$history_handler,%send_history);
my($i_index,$index_line);

# �f�B���N�g�� / �t�@�C����`
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $file = "${auth_log_directory}message_history.log";

# �ő�o�^�s��
my $maxline_index = 50;

	# �t�@�C�����J��
	open($history_handler,"<$file");

		# �t�@�C�����b�N
		if($type =~ /Renew/){ flock($history_handler,1); }

	# �g�b�v�f�[�^�𕪉�
	chomp(my $top1 = <$history_handler>);
	($send_history{'concept'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$history_handler>){

		# ���E���h�J�E���^
		$i_index++;

		# �s�𕪉�
		chomp;
		my($to_account2,$message_id2) = split(/<>/);

			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

				# �Ǐ���
				my(%account2);

				# ���b�Z�[�W���J��
				my(%message) = MessageFile("Get-hash",$to_account2,$message_id2);

				$index_line .= qq(<tr>\n);

					# ���M�҂̃A�J�E���g���J��
					if($init{'admin_flag'}){
						(%account2) = Mebius::Auth::File("Option",$message{'from_account'});
					}

					# ���b�Z�[�W����
					if($init{'admin_flag'}){
						$index_line .= qq(<td>\n);
						#$index_line .= qq(<a href="./$message{'to_account'}/?mode=message&amp;type=view&amp;message_id=$message_id2">$message{'subject'}</a>\n);
						$index_line .= qq($message{'subject'}\n);
						$index_line .= qq(</td>\n);
					}

				# ���M�҂̃A�J�E���g
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
					if($init{'admin_flag'}){ $index_line .= qq( ($account2{'today_left_message_num'} / $account2{'maxsend_message'}) ); }
				$index_line .= qq(</td>\n);

				# ����̃A�J�E���g
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);
				$index_line .= qq(</td>\n);

				# ���M / ��M����
				$index_line .= qq(<td>\n);
				$index_line .= qq($message{'senddate'}\n);
				$index_line .= qq(</td>\n);

				$index_line .= qq(</tr>\n);
			}

			# �X�V�s��ǉ�
			if($type =~ /Renew/){
					if($i_index >= $maxline_index){ last; }
				push(@renew_line,"$to_account2<>$message_id2<>\n");
			}
	}
	
	close($history_handler);

	# �C���f�b�N�X�擾�p
	if($type =~ /Get-index/){
		$send_history{'index_line'} .= qq(<table summary="���M����">\n);
			if($init{'admin_flag'}){ $send_history{'index_line'} .= qq(<th>����</th>\n); }
		$send_history{'index_line'} .= qq(<th>���M��</th><th>����</th><th>���t</th>\n);
		$send_history{'index_line'} .= qq($index_line\n);
		$send_history{'index_line'} .= qq(</table>\n);

	}

	# �V�K���M�����ꍇ
	if($type =~ /New-message/){
		unshift(@renew_line,"$to_account<>$message_id<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		#Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$send_history{'concept'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}


return(%send_history);


}



1;
