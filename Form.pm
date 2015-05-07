
package Mebius::Form;

use strict;

use Mebius::HTML;

use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub select_parts{

my $self = shift;
my $hash_group = shift || (warn && return());
my $input_name = shift || die;
my $selected = shift;
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("select",{ name => $input_name }) . "\n";

	foreach my $hash (@{$hash_group}){

		my $selected = 1 if($hash->{'name'} eq $selected);
		$print .= $html->start_tag("option",{ value => $hash->{'name'} , selected => $selected });
		$print .= e($hash->{'title'});
		$print .= $html->close_tag("option");
	}

$print .= $html->close_tag("select",{ name => $input_name }) . "\n";

$print;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub radio_parts{

my $self = shift;
my $hash_group = shift || (warn && return());
my $input_name = shift || die;
my $selected = shift;
my $html = new Mebius::HTML;
my($print);

	foreach my $hash (@{$hash_group}){

		my $checked = 1 if($hash->{'name'} eq $selected);
		$print .= $html->input("radio",$input_name,$hash->{'name'},{ text => $hash->{'title'} , checked => $checked});
	}

$print;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub checkbox_parts{

my $self = shift;
my $hash_group = shift || (warn && return());
my $input_name = shift || die;
my $selected = shift;
my $html = new Mebius::HTML;
my($print);

my @present_ivent_kind = split(/\s+/,$selected);

	foreach my $hash (@{$hash_group}){
	
		my($checked);

			foreach my $name (@present_ivent_kind){
					if($hash->{'name'} eq $name){
						$checked = 1;
					}
			}

		$print .= $html->input("checkbox",$input_name,$hash->{'name'},{ text => $hash->{'title'} , checked => $checked });
	}

$print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub simple_colors{

my $self = shift;

my $colors = [
{ color => "#000" , name => "黒" } , 
{ color => "#f00" , name => "赤" } , 
{ color => "#00f" , name => "青" } , 
{ color => "#090" , name => "緑" } , 
];

$colors;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub simple_colors_select_parts{

my $self = shift;
my($my_cookie) = Mebius::my_cookie_main();
my $colors = $self->simple_colors();
my $html = new Mebius::HTML;
my($print);

$print .= $html->start_tag("select",{ name => "font_color" });

	foreach my $data (@{$colors}){

		my($selected);

			if($my_cookie->{'font_color'} eq $data->{'color'}){
				$selected = 1;
			}

		$print .= $html->tag("option",$data->{'name'},{ value => $data->{'color'} , style => "color:$data->{'color'};" , selected => $selected });

	}

$print .= $html->close_tag("select");


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub color_select_box{

my $self = shift;
my($param) = Mebius::query_single_param();
my($print,$finput_color);
my($my_cookie) = Mebius::my_cookie_main_logined();
my(@color) = Mebius::Init::Color();

	if($ENV{'REQUEST_METHOD'} eq "POST" && $param->{'color'}){
		$finput_color = $param->{'color'};
	} else {
		$finput_color = $my_cookie->{'font_color'};
	}

$print .= qq(<select name="font_color" accesskey="9" id="color">);
	foreach(@color) {
		my($selected);
		my($col_name, $col_code) = split(/=/);
			if($col_code eq $finput_color) {
				$selected = " selected";
			}
		$print .= qq(<option value="$col_code" style="color:$col_code;"$selected>$col_name</option>\n);
	}

$print .= qq(</select>);

utf8($print);

$print;

}



1;
