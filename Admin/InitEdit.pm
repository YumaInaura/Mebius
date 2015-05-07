
use Mebius::BBS;
use strict;
package Mebius::Admin::InitEdit;

#-----------------------------------------------------------
# �ݒ�ύX�t�H�[��
#-----------------------------------------------------------
sub Start{

if($main::in{'type'} eq "edit_category"){ &EditCategory(); } 
if($main::in{'type'} eq "edit_bbs"){ &EditBBS(); } 
else{ &View(); }

exit;

}

#-----------------------------------------------------------
# �ݒ���
#-----------------------------------------------------------
sub View{

# �錾
my($line,$category_rule_textarea);
our($category,$moto);
my $bbs = Mebius::BBS->new();
my $bbs_kind = $bbs->root_bbs_kind();

# �����`�F�b�N
if($main::admy_rank < $main::master_rank){ main::error("����������܂���B"); }

# CSS ��`
$main::css_text .= qq(
input.text{width:20%;}
input.on-off{width:5em;}
table,th,tr,td{border-style:none;}
table{}
);


# �J�e�S���ݒ��ǂݍ���
my($init_bbs) = Mebius::BBS::init_bbs(undef,$main::moto);
my($init_category) = Mebius::BBS::init_category(undef,$init_bbs->{'category'});

# �e�L�X�g�G���A���`
$category_rule_textarea = $init_category->{'rule'};
$category_rule_textarea =~ s/<br>/\n/g;
$category_rule_textarea = Mebius::escape("Not-br",$category_rule_textarea);

$line .= qq( <a href="$main::home?allcord=1">�s�n�o�ɖ߂�</a>);
$line .= qq(�@<a href="./$main::script">�f���ɖ߂�</a>);
$line .= qq(�@<a href="/_${main::realmoto}/rule.html">���[����\\�� [�ʏ탂�[�h]</a>);

($line) .= &BBSForm();

$line .= qq(<h1>�J�e�S���ݒ� ( $init_category->{'title'} �J�e�S�� - $main::bbs{'category'} )</h1>);
$line .= qq(<form action="$main::script" method="post">\n);
$line .= qq(<input type="hidden" name="mode" value="init_edit">\n);
$line .= qq(<input type="hidden" name="moto" value="$bbs_kind">\n);
$line .= qq(<input type="hidden" name="type" value="edit_category">\n);
$line .= qq(<input type="hidden" name="category" value="$main::category">\n);
$line .= qq(�J�e�S����<br$main::xclose><input type="text" name="title" value="$init_category->{'title'}"><br$main::xclose><br$main::xclose>);
$line .= qq(�J�e�S���R���Z�v�g<br$main::xclose><input type="text" name="concept" value="$init_category->{'concept'}"><br$main::xclose><br$main::xclose>);
$line .= qq(�폜�˗��L��<br$main::xclose><input type="text" name="report_number" value="$init_category->{'report_number'}"><br$main::xclose><br$main::xclose>);
$line .= qq(�Q�Ƃ���f����<br$main::xclose><input type="text" name="refer_bbs" value="$init_category->{'refer_bbs'}"><br$main::xclose><br$main::xclose>);
$line .= qq(���[��<br$main::xclose> <textarea name="rule" style="width:70%;height:200px;">$category_rule_textarea</textarea><br$main::xclose>);
$line .= qq(<input type="submit"  value="���̓��e�ŕύX����"><br$main::xclose>);

$line .= qq(</form>);




my $print = qq($line);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# �f���̐ݒ�t�H�[��
#-----------------------------------------------------------
sub BBSForm{

# �錾
my($line,$rule_textarea,$redcard_textarea);
my($textarea_first_input_textarea);

# �f���ݒ���擾
my($bbs) = Mebius::BBS::init_bbs("Get-hash",$main::realmoto);

# �e�L�X�g�G���A���`
$rule_textarea = $bbs->{'rule_text'};
$rule_textarea =~ s/<br>/\n/g;
$rule_textarea = Mebius::escape("Not-br",$rule_textarea);

# �e�L�X�g�G���A���`
$redcard_textarea = $bbs->{'redcard'};
$redcard_textarea =~ s/<br>/\n/g;
$redcard_textarea = Mebius::escape("Not-br",$redcard_textarea);

# �e�L�X�g�G���A���`
$textarea_first_input_textarea = $bbs->{'textarea_first_input'};
$textarea_first_input_textarea =~ s/<br>/\n/g;
$textarea_first_input_textarea = Mebius::escape("Not-br",$textarea_first_input_textarea);

# ���������`
my($bbs_setumei) = Mebius::escape("Not-br",$bbs->{'setumei'});

$line .= qq(<h1>�f���ݒ� ( $bbs->{'title'} )</h1>);

$line .= qq(<table>);

$line .= qq(<form action="$main::script" method="post">\n);
$line .= qq(<input type="hidden" name="mode" value="init_edit">\n);
$line .= qq(<input type="hidden" name="type" value="edit_bbs">\n);
$line .= qq(<input type="hidden" name="moto" value="$main::realmoto">\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�f����</td>);
$line .= qq(<td><input type="text" name="title" value="$bbs->{'title'}" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�f����(�w�b�_)</td>\n);
$line .= qq(<td><input type="text" name="head_title" value="$bbs->{'head_title'}" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>CSS </td>\n);
$line .= qq(<td><input type="text" name="style" value="$bbs->{'style'}" class="text">);
$line .= qq( <span class="guide">���� /style/blue1.css </span>);
$line .= qq(</td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�閧 </td>\n);
$line .= qq(<td><input type="text" name="secret_mode" value="$bbs->{'secret_mode'}" class="text">);
$line .= qq( <span class="guide"> ����F aura �ȂǕ������ݒ�B</span></td>\n);
$line .= qq(</tr\n);

$line .= qq(<tr>\n);
$line .= qq(<td>������</td>\n);
$line .= qq(<td><input type="text" name="setumei" value="$bbs_setumei" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�R���Z�v�g</td>\n);
$line .= qq(<td><input type="text" name="concept" value="$bbs->{'concept'}" class="text" style="width:60%;"><br$main::xclose>\n);
$line .= qq(<span class="guide">);
$line .= qq(Upload-mode �A�b�v���[�h����);
$line .= qq( / Local-mode ���[�J�����[�h);
$line .= qq( / Chat-mode �`���b�g���[�h);
$line .= qq( / Sousaku-mode �n�� / Noads-mode �L���Ȃ� );
$line .= qq( / Strong-penalty ���y�i���e�B );
$line .= qq(</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�J�e�S��</td>\n);
$line .= qq( <td><input type="text" name="category" value="$bbs->{'category'}" class="text">);
$line .= qq( <span class="guide"> �����p�p�����Őݒ�B</span></td>\n);
$line .= qq(</tr>\n);


$line .= qq(<tr>\n);
$line .= qq(<td>�ꗥ�`���[�W���ԁi���X�j </td>\n);
$line .= qq( <td><input type="text" name="norank_wait" value="$bbs->{'norank_wait'}" class="text">);
$line .= qq( <span class="guide">��1 �c noindex,nofollow</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�V�K���e�̑҂����ԁi����j </td>\n);
$line .= qq( <td><input type="text" name="new_wait" value="$bbs->{'new_wait'}" class="text">);
$line .= qq( <span class="guide">�����p�����A���ԂŐݒ�B</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�ő啶����(���X) </td>\n);
$line .= qq( <td><input type="text" name="max_msg" value="$bbs->{'max_msg'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�ŏ�������(���X) </td>\n);
$line .= qq( <td><input type="text" name="min_msg" value="$bbs->{'min_msg'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�f���ЂƂ�����̍ő�L���� </td>\n);
$line .= qq( <td><input type="text" name="i_max" value="$bbs->{'i_max'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�L���ЂƂ�����̍ő僌�X�� </td>\n);
$line .= qq( <td><input type="text" name="m_max" value="$bbs->{'m_max'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�z�[���t�q�k </td>\n);
$line .= qq( <td><input type="text" name="home" value="$bbs->{'home'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>���{�b�g�悯 </td>\n);
$line .= qq( <td><input type="text" name="noindex_flag" value="$bbs->{'noindex_flag'}" class="text">);
$line .= qq( <span class="guide">��1 �c noindex,nofollow</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>���_�C���N�g </td>\n);
$line .= qq( <td><input type="text" name="bbs_redirect" value="$bbs->{'bbs_redirect'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�g���ߋ����O�̌� </td>\n);
$line .= qq( <td><input type="text" name="past_num" value="$bbs->{'past_num'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>���X�`���[�W���Ԃ̃{�[�i�X�b�� </td>\n);
$line .= qq( <td><input type="text" name="plus_bonus" value="$bbs->{'plus_bonus'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�L������ </td>\n);
$line .= qq( <td><input type="text" name="noads_mode" value="$bbs->{'noads_mode'}" class="text"></td><br$main::xclose><br$main::xclose>);

$line .= qq(<tr>\n);
$line .= qq(<td>���X�C�����[�h </td>\n);
$line .= qq( <td><input type="text" name="resedit_mode" value="$bbs->{'resedit_mode'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�T�u�L�������N���[�h </td>\n);
$line .= qq( <td><input type="text" name="subtopic_link" value="$bbs->{'subtopic_link'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>ID�̑f�i����j </td>\n);
$line .= qq( <td><input type="text" name="another_idsalt" value="$bbs->{'another_idsalt'}" class="text">);
$line .= qq( <span class="guide">���p�����Q����</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�폜�˗���̋L���i����j </td>\n);
$line .= qq( <td><input type="text" name="report_thread_number" value="$bbs->{'report_thread_number'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�L����̃��X�폜��</td>\n);
$line .= qq( <td><input type="text" name="allow_thread_master_delete" value="$bbs->{'allow_thread_master_delete'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr id="RULE">\n);
$line .= qq(<td>���[��</td>);
$line .= qq(<td><textarea name="rule_text" style="width:90%;height:200px;">$rule_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�L���{���̏�������</td>);
$line .= qq(<td><textarea name="textarea_first_input" style="width:90%;height:50px;">$textarea_first_input_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>�Ǘ��e���v��</td>);
$line .= qq(<td><textarea name="redcard" style="width:90%;height:50px;">$redcard_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td></td>\n);
$line .= qq(<td><input type="submit"  value="���̓��e�ŕύX����"></td>);
$line .= qq(</tr>\n);

$line .= qq(</form>);

$line .= qq(</table>);

return($line);


}

#-----------------------------------------------------------
# �J�e�S���ݒ��ύX
#-----------------------------------------------------------
sub EditCategory{

# �錾
my(%renew);

# �e��G���[
if($main::in{'report_number'} =~ /\D/){ main::error("�폜�˗��L���̃i���o�[�͔��p�����Ŏw�肵�Ă��������B"); }
if($main::in{'concept'} =~ /[^\w\s\-\.]/){ main::error("�J�e�S���R���Z�v�g�͉p����/���p�X�y�[�X/���p�n�C�t��/�s���I�h�݂̂ŋL�����Ă��������B"); }

# ��`
if($main::in{'title'}){ $renew{'title'} = $main::in{'title'}; } else { $renew{'title'} = ""; }
if($main::in{'report_number'}){ $renew{'report_number'} = $main::in{'report_number'}; } else { $renew{'report_number'} = ""; }
if($main::in{'rule'}){ $renew{'rule'} = $main::in{'rule'}; } else { $renew{'rule'} = ""; }
if($main::in{'refer_bbs'}){ $renew{'refer_bbs'} = $main::in{'refer_bbs'}; } else { $renew{'refer_bbs'} = ""; }
if($main::in{'concept'}){ $renew{'concept'} = $main::in{'concept'}; } else { $renew{'concept'} = ""; }

# �ϊ�
($renew{'rule'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'rule'});

# �댯�ȃ^�O��r��
Mebius::DangerTag("Error-view","$renew{'rule'}");

# �J�e�S���ݒ���X�V
Mebius::BBS::init_category("Renew",$main::in{'category'},%renew);

# ���_�C���N�g
Mebius::Redirect(undef,"./$main::script?mode=init_edit");

exit;

}

#-----------------------------------------------------------
# �f���ݒ��ύX
#-----------------------------------------------------------
sub EditBBS{

# �錾
my(%renew);

# �e��G���[
if($main::in{'concept'} =~ /[^0-9a-zA-Z\-_\s\.]/){ main::error("�R���Z�v�g�͉p�����L���œ��͂��Ă��������B ($main::in{'concept'})"); }


	# �X�V���e�̒�`
	if(defined($main::in{'title'})){ $renew{'title'} = $main::in{'title'}; } else { $renew{'title'} = ""; }
	if(defined($main::in{'head_title'})){ $renew{'head_title'} = $main::in{'head_title'}; } else { $renew{'head_title'} = ""; }
	if(defined($main::in{'concept'})){ $renew{'concept'} = $main::in{'concept'}; } else { $renew{'concept'} = ""; }
	if(defined($main::in{'category'})){ $renew{'category'} = $main::in{'category'}; } else { $renew{'category'} = ""; }
	if(defined($main::in{'style'})){ $renew{'style'} = $main::in{'style'}; } else { $renew{'style'} = ""; }
	if(defined($main::in{'setumei'})){ $renew{'setumei'} = $main::in{'setumei'}; } else { $renew{'setumei'} = ""; }
	if(defined($main::in{'rule_text'})){ $renew{'rule_text'} = $main::in{'rule_text'}; } else { $renew{'rule_text'} = ""; }
	if(defined($main::in{'textarea_first_input'})){ $renew{'textarea_first_input'} = $main::in{'textarea_first_input'}; } else { $renew{'textarea_first_input'} = ""; }
	if(defined($main::in{'redcard'})){ $renew{'redcard'} = $main::in{'redcard'}; } else { $renew{'redcard'} = ""; }
	if(defined($main::in{'noads_mode'})){ $renew{'noads_mode'} = $main::in{'noads_mode'}; } else { $renew{'noads_mode'} = ""; }
	if(defined($main::in{'resedit_mode'})){ $renew{'resedit_mode'} = $main::in{'resedit_mode'}; } else { $renew{'resedit_mode'} = ""; }
	if(defined($main::in{'subtopic_link'})){ $renew{'subtopic_link'} = $main::in{'subtopic_link'}; } else { $renew{'subtopic_link'} = ""; }
	if(defined($main::in{'noindex_flag'})){ $renew{'noindex_flag'} = $main::in{'noindex_flag'}; } else { $renew{'noindex_flag'} = ""; }
	if(defined($main::in{'secret_mode'})){ $renew{'secret_mode'} = $main::in{'secret_mode'}; } else { $renew{'secret_mode'} = ""; }
	if(defined($main::in{'past_num'})){ $renew{'past_num'} = $main::in{'past_num'}; } else { $renew{'past_num'} = ""; }
	if(defined($main::in{'plus_bonus'})){ $renew{'plus_bonus'} = $main::in{'plus_bonus'}; } else { $renew{'plus_bonus'} = ""; }
	if(defined($main::in{'bbs_redirect'})){ $renew{'bbs_redirect'} = $main::in{'bbs_redirect'}; } else { $renew{'bbs_redirect'} = ""; }
	if(defined($main::in{'another_idsalt'})){ $renew{'another_idsalt'} = $main::in{'another_idsalt'}; } else { $renew{'another_idsalt'} = ""; }
	if(defined($main::in{'report_thread_number'})){ $renew{'report_thread_number'} = $main::in{'report_thread_number'}; } else { $renew{'report_thread_number'} = ""; }
	if(defined($main::in{'new_wait'})){ $renew{'new_wait'} = $main::in{'new_wait'}; } else { $renew{'new_wait'} = ""; }
	if(defined($main::in{'norank_wait'})){ $renew{'norank_wait'} = $main::in{'norank_wait'}; } else { $renew{'norank_wait'} = ""; }
	if(defined($main::in{'i_max'})){ $renew{'i_max'} = $main::in{'i_max'}; } else { $renew{'i_max'} = ""; }
	if(defined($main::in{'m_max'})){ $renew{'m_max'} = $main::in{'m_max'}; } else { $renew{'m_max'} = ""; }
	if(defined($main::in{'max_msg'})){ $renew{'max_msg'} = $main::in{'max_msg'}; } else { $renew{'max_msg'} = ""; }
	if(defined($main::in{'min_msg'})){ $renew{'min_msg'} = $main::in{'min_msg'}; } else { $renew{'min_msg'} = ""; }
	if(defined($main::in{'home'})){ $renew{'home'} = $main::in{'home'}; } else { $renew{'home'} = ""; }
	if(exists $main::in{'allow_thread_master_delete'}){ $renew{'allow_thread_master_delete'} = $main::in{'allow_thread_master_delete'}; }

# �^�O��L���ɂ���ꍇ
($renew{'rule_text'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'rule_text'});
($renew{'textarea_first_input'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'textarea_first_input'});
($renew{'redcard'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'redcard'});
($renew{'setumei'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'setumei'});

# �댯�ȃ^�O��r��
Mebius::DangerTag("Error-view",$renew{'rule_text'});
Mebius::DangerTag("Error-view",$renew{'textarea_first_input'});
Mebius::DangerTag("Error-view",$renew{'redcard'});
Mebius::DangerTag("Error-view",$renew{'setumei'});


# �J�e�S���ݒ���X�V
Mebius::BBS::init_bbs("Renew",$main::in{'moto'},%renew);

# ���_�C���N�g
Mebius::Redirect(undef,"./$main::script?mode=init_edit");

exit;

}



1;
