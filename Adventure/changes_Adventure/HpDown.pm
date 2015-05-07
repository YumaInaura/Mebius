
sub do_adv_hp_down{

# 局所化
my($down_hp,$down_hp_poin);

# ＰＳＰからの場合
if($psp_access || $device_type eq "mobile"){ main::error("連続行動はできません。"); }

#$down_hp_point = 1;

# HPを下げる
#&File(undef,$kid);
#if($advmaxhp > 6) { $advmaxhp = $advhp = int( $advmaxhp * (1-($down_hp_point*0.01)) ); } else { $advmaxhp = 1; }
#&renew_charadata(undef,$kid);

# エラー
main::error("連続行動は禁止です。HPが$down_hp_point％下がりました。");

}


1;
