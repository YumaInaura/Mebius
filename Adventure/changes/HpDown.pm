
sub do_adv_hp_down{

# �Ǐ���
my($down_hp,$down_hp_poin);

# �o�r�o����̏ꍇ
if($psp_access || $device_type eq "mobile"){ main::error("�A���s���͂ł��܂���B"); }

#$down_hp_point = 1;

# HP��������
#&File(undef,$kid);
#if($advmaxhp > 6) { $advmaxhp = $advhp = int( $advmaxhp * (1-($down_hp_point*0.01)) ); } else { $advmaxhp = 1; }
#&renew_charadata(undef,$kid);

# �G���[
main::error("�A���s���͋֎~�ł��BHP��$down_hp_point��������܂����B");

}


1;
