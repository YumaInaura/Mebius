
use strict;
package Mebius;

#-----------------------------------------------------------
# �L���\���̗L���𔻒�
#----------------------------------------------------------
sub Adscheck{

# �錾
my($type,$com,$sub) = @_;
my($flag);
our($nocview_flag,$noads_mode,$subtopic_mode,$alocal_mode);

# �薼����
if($sub eq "" && !$subtopic_mode){ $flag = 1; }
if($sub){
if($sub =~ /(�O��|��|�\\|�E|��|�M�����u��)/){ $flag = 1; }
if($sub =~ /(�ނ�|���J)(��|�c�N)/){ $flag = 1; }
}

# �{������
if(length($com) < 2*10 && !$subtopic_mode){ $flag = 1; }
if($com){
if($com =~ /(����|���q|�Z�b�N�X|�I�i|�D�P|�G�b�`|����|����|�y�j�X|�G��|�z��|�Q�C|���I|���C�v)/){ $flag = 1; }
if($com =~ /(�ڋ�)/){ $flag = 1; }
if(index($com,'�}�X�^�[�x�[�V����') >= 0){ $flag = 1; }
if(index($com,'�R���h�[��') >= 0){ $flag = 1; }

if($com =~ /(���X�g�J�b�g|���X�J|�A���J|�J�b�e�B���O|���E|����|�E�l|�\\�s)/){ $flag = 1; }
if(index($com,'�A�[���J�b�g') >= 0){ $flag = 1; }
}

if($flag && !$alocal_mode){ $nocview_flag = 1; $noads_mode = 1; }

}

1;
