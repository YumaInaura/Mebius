
use strict;
use Mebius::BBS::Admin::Parts;
package Mebius::Control;

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
sub user_control_link_series{

my $self = shift;
my $links = Mebius::Admin::user_control_link_multi(@_);
my(@line);

push @line , $links->{'host'} if($links->{'host'});
push @line , $links->{'isp'} if($links->{'isp'});
push @line , $links->{'addr'} if($links->{'addr'});
push @line , $links->{'cookie'} if($links->{'cookie'});
push @line , $links->{'account'} if($links->{'account'});
push @line , $links->{'user_agent'} if($links->{'user_agent'});

my $line = join " ┃ " , @line; 

$line;

}

#-----------------------------------------------------------
# 汎用 操作パーツ
#-----------------------------------------------------------
sub radio_parts{

my $self = shift;
my $radio_name = shift;
my $data = shift;
my $use = shift || {};
my $html = new Mebius::HTML;
my($form,$disabled_delete,$disabled_revive,$label_style_delete,$label_style_revive,$disabled_full_delete,$label_style_full_delete);
	
	if($data->{'full_deleted_flag'}){
		$disabled_full_delete = 1;
		$label_style_full_delete = "text-decoration:line-through;";
	}

	if($data->{'deleted_flag'}){
		$disabled_delete = 1;
		$label_style_delete = "text-decoration:line-through;";
	} else {
		$disabled_revive = 1;
		$label_style_revive = "text-decoration:line-through;";
	}

$form .= $html->radio($radio_name,"","未選択");

	if(!$use->{'Simple'}){
		$form .= $html->radio($radio_name,"no-reaction","対応しない");
	}

$form .= $html->radio($radio_name,"delete","削除", { disabled => $disabled_delete , label => { style => $label_style_delete } });

	if($use->{'use_full_delete'}){
		$form .= $html->radio($radio_name,"full_delete","完全削除", { disabled => $disabled_full_delete , label => { style => $label_style_full_delete } });
	}

	if(!$use->{'Simple'}){
		$form .= $html->radio($radio_name,"penalty","罰削除", { disabled => $disabled_delete , label => { class => "red" , style => $label_style_delete } });
	}

	if(!$use->{'Simple'} || !$disabled_revive){
		$form .= $html->radio($radio_name,"revive","復活", { disabled => $disabled_revive , label => { class => "blue" , style => $label_style_revive } });
	}
$form .= " " . $html->input("submit","","操作する",{ style => "margin-left:1em;" });


$form;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub deleted_mark{

my $self = shift;
my $html = new Mebius::HTML;

my $mark = $html->tag("span"," [削除済み] ",{ class => "red" });

}


1;
