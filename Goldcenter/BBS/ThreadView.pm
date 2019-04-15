
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# フォームで囲む ( 携帯版と共通 )
#-----------------------------------------------------------
sub res_area_around_report_mode{

my($res_area) = @_;

	if(Mebius::Report::report_mode_judge_for_res()){
		utf8($res_area);
		($res_area) = shift_jis(Mebius::Report::report_mode_around_form({ ResMode => 1 } , $res_area));
	} elsif(Mebius::Report::report_mode_judge_for_thread()){
		utf8($res_area);
		($res_area) = shift_jis(Mebius::Report::report_mode_around_form({ ThreadMode => 1 } , $res_area));
	} else {
		0;
	}



$res_area;

}


1;

