
use strict;
package Mebius;

#-----------------------------------------------------------
# 広告表示の有無を判定
#----------------------------------------------------------
sub Adscheck{

# 宣言
my($type,$com,$sub) = @_;
my($flag);
our($nocview_flag,$noads_mode,$subtopic_mode,$alocal_mode);

# 題名判定
if($sub eq "" && !$subtopic_mode){ $flag = 1; }
if($sub){
if($sub =~ /(グロ|性|暴\|殺|死|ギャンブル)/){ $flag = 1; }
if($sub =~ /(むか|ムカ)(つく|ツク)/){ $flag = 1; }
}

# 本文判定
if(length($com) < 2*10 && !$subtopic_mode){ $flag = 1; }
if($com){
if($com =~ /(性器|精子|セックス|オナ|妊娠|エッチ|生理|自慰|ペニス|エロ|ホモ|ゲイ|性的|レイプ)/){ $flag = 1; }
if($com =~ /(卑怯)/){ $flag = 1; }
if(index($com,'マスターベーション') >= 0){ $flag = 1; }
if(index($com,'コンドーム') >= 0){ $flag = 1; }

if($com =~ /(リストカット|リスカ|アムカ|カッティング|自殺|事件|殺人|暴\行)/){ $flag = 1; }
if(index($com,'アームカット') >= 0){ $flag = 1; }
}

if($flag && !$alocal_mode){ $nocview_flag = 1; $noads_mode = 1; }

}

1;
