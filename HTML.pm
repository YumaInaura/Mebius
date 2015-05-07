
use strict;
use Mebius::Device;
package Mebius;
use Mebius::Query;
use Mebius::Encoding;
package Mebius::HTML;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{
my $class = shift;
bless { href => undef } , $class;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub simple_print{

# 宣言
my $self = shift;
my $body = shift;
my $encoding = new Mebius::Encoding;
my $mebius = new Mebius;
my($use) = shift if(ref $_[0] eq "HASH");
my($print,$charset);

	if($use->{'charset'} eq "euc-jp"){
		$charset = "euc-jp";
	} else {
		$charset = "utf-8";
	}

$print .= qq(<!DOCTYPE html>\n);
$print .= qq(<html lang="ja">\n);
$print .= qq(<head>\n);
$print .= $use->{'html_head'};
$print .= qq(<meta http-equiv="content-type" content="text/html; charset=).e($charset).qq(">\n);
$print .= qq(<title>).e($use->{'Title'} || $use->{'title'}).qq(</title>\n);

$print .= $self->use_to_inline_css($use);
#$print .= $self->use_to_css_files_line($use);

$print .= qq(</head>\n);
$print .= qq(<body>\n);
$print .= qq(\n);
$print .= qq($body\n);
$print .= qq(</body>\n);
$print .= qq(</html>\n);

	#if($use->{'encode_source'} eq "euc-jp"){
	#	$print = $encoding->eucjp_to_utf8($print);
	#}

# コンテンツタイプ
print "Content-type:text/html;charset=$charset;\n\n";
print $print;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub use_to_inline_css{

my $self = shift;
my $use = shift || return();
my($print);

my $style = $use->{'inline_css'} || return();

$print .= qq(<style type="text/css"><!--\n);
$print .= e($style,{ NotValue => 1 }) . "\n";
$print .= qq(--></style>\n);

$print;

}


#-----------------------------------------------------------
# 好きな要素で囲む ( 未使用 )
#-----------------------------------------------------------
sub around_tag{

my $use = shift if(ref $_[0] eq "HASH");
my($text,$ellement) = @_;
my($self);

	if(!$text){ return(); } 
	if(!$ellement){ return($text); }
	if($ellement =~ /[^a-z]/){ return($text); }

$self .= q(<).e($ellement).q(>);
$self .= q(<).e($ellement).q(>);

$text;

}

#-----------------------------------------------------------
# a href タグを作成する
#-----------------------------------------------------------
sub href{

my $self = shift;
my $link = shift;
my $text = shift;
my $use = shift if(ref $_[0] eq "HASH");
my($return,%element);

# テキストがない場合は、URLをそのままテキストとして扱う
$text ||= $link;

	if($use->{'no_follow_flag'}){
		$element{'rel'} = "nofollow";
	}

$element{'href'} = $link;

my $relay_use = Mebius::Operate->overwrite_hash($use,\%element);

$return = $self->tag("a",$text,$relay_use);

$return;

}

#-----------------------------------------------------------
# span タグを生成する
#-----------------------------------------------------------
sub div{

my $self = shift;
$self->tag("div",@_);

}

#-----------------------------------------------------------
# span タグを生成する
#-----------------------------------------------------------
sub span{

my $self = shift;
$self->tag("span",@_);

}


#-----------------------------------------------------------
# span タグを生成する
#-----------------------------------------------------------
sub strong{

my $self = shift;
$self->tag("strong",@_);

}

#-----------------------------------------------------------
# ラジオ
#-----------------------------------------------------------
sub radio{

my $operate = Mebius::Operate->new();

my $self = shift;
my $name = shift;
my $value = shift;
my $text = shift;

my $relay_use = $operate->overwrite_hash(shift,{ text => $text});
my $return = $self->input("radio",$name,$value,$relay_use);

$return;

}

#-----------------------------------------------------------
# input タグを生成する
#-----------------------------------------------------------
sub input{

my $self = shift;
my $type = shift;
my $name = shift;
my $value = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $query = new Mebius::Query;
my $device = new Mebius::Device;
my($parts) = Mebius::Parts::HTML();
my($param) = Mebius::query_single_param();

	if($query->default_encode_is_shift_jis()){
		$param = hash_to_utf8($param);
	}

my($input,$checked);
	if($use->{'text'}){
		$input .= qq(<label);
		$input .= $self->various_element($use->{'label'});
		$input .= qq(>);
	}



	if(($ENV{'REQUEST_METHOD'} eq "POST" || $use->{'QUERY_INPUTED'} ) && $type =~ /^(text|url|password|search|hidden)$/ && (!$use->{'NotOverwrite'} && !$use->{'NotOverWrite'}) && exists $param->{$name}){
		$value = $param->{$name};
	}

	if($use->{'checked'}){
		$checked = 1;
	} elsif($use->{'default_checked'} && $query->get_method()){
		$checked = 1;
	}	elsif($type eq "radio" && ($param->{$name} eq $value && $query->post_method()) || ($value eq "" && $query->get_method())){
		$checked = 1;
	} elsif($type eq "checkbox" && $query->post_method() && exists $param->{$name}){
		$checked = 1;
	}


my $relay_use = Mebius::Operate->overwrite_hash($use,{ type => $type , name => $name , value => $value ,checked => $checked  });
delete $relay_use->{'label'};
delete $relay_use->{'text'};

$input .= $self->start_tag("input",$relay_use);


	if($use->{'text'}){
		$input .= $self->span($use->{'text'},$use->{'span'});
		$input .= qq(</label>);
	}

$input .= "\n";

$input;

}

#-----------------------------------------------------------
# テキストエリア
#-----------------------------------------------------------
sub textarea{

my $self = shift;
my $name = shift;
my $value = shift;
my $use = shift if(ref $_[0] eq "HASH");

	if($ENV{'REQUEST_METHOD'} eq "POST" && !$use->{'NotOverwrite'}){
		my($param) = Mebius::query_single_param();
		$value = $param->{$name};
	}

my $relay_use = Mebius::Operate->overwrite_hash($use,{ name => $name  });
my $textarea = $self->tag("textarea",$value,$relay_use);

$textarea;

}

#-----------------------------------------------------------
# span タグを生成する
#-----------------------------------------------------------
sub tag{

my $self = shift;
my $tag = shift;
my $text = shift;
my $element = shift;
my $use = shift;
my($return);

	if($tag =~ /[^a-z0-9]|^$/){ return(); }

$return .= $self->start_tag($tag,$element);

	if( my $href = $use->{'href'}){
		$return .= q(<a href=").e($href).qq(">).e($text).q(</a>);
	} elsif($element->{'NotEscape'} || $use->{'NotEscape'}){
		$return .= $text;
	} else {
		$return .= e($text);
	}

	#if($use->{'Debug'}){
	#		if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($return ?)); }
	#}

$return .= $self->close_tag($tag);

$return;

}

#-----------------------------------------------------------
# 開始タグ
#-----------------------------------------------------------
sub start_tag{

my $self = shift;
my $tag = shift || die;
my $use = shift if(ref $_[0] eq "HASH");
my($return);

	if($tag =~ /[^a-z0-9]|^$/){ return(); }

$return .= q(<);
	if($use->{'AllowTag'}){
		$return .= $tag;
	} else {
		$return .= ($tag);
	}
$return .= $self->various_element($use);
$return .= q(>);

$return;

}

#-----------------------------------------------------------
# 終了タグ
#-----------------------------------------------------------
sub close_tag{

my $self = shift;
my $tag = shift || die;

	if($tag =~ /[^a-z0-9]|^$/){ return(); }

$tag = "</" . e($tag) . ">";

$tag;

}


#-----------------------------------------------------------
# 様々な要素
#-----------------------------------------------------------
sub various_element{

my $self = shift;
my $use = shift;
my $return;

# 許可する属性
#my $allow = {
#style => 1 ,
#class => 1 ,
#id => 1 , 
#title => 1 ,
#size => 1 ,
#accesskey => 1 ,
#placeholder => 1 ,
#pattern => 1 ,
#maxlength => 1, 
#rows => 1,
#cols => 1 ,
#onclick => 1 ,
#onkeyup => 1 ,
#};


# 許可する属性
my $single = {
utn => 1 ,
autofocus => 1 ,
disabled => 1 , 
checked => 1 ,
selected => 1 ,
};

	# 入力値のチェック
	if(ref $use ne "HASH"){ return(); }

	# 展開
	foreach my $element ( keys %{$use} ){

			if(!exists $use->{$element}){ next; }
			if(!defined $use->{$element}){ next; }

			if($element !~ /^[0-9a-z]+$/){ next; }

			# 単一属性
			if($single->{$element}){

					if($use->{$element}){
						$return .= qq( ).e($element);
					}

			# 引用符で囲む属性
			} else {
					if($element =~ /^on([a-z]+)$/i){
						$return .= qq( ).e($element).qq(=").e($use->{$element},{ Javascript => 1 }).q(");
					} else {
						$return .= qq( ).e($element).qq(=").e($use->{$element}).q(");
					}
				#die("$element is not allowed element.");
			}
	}

$return;

}


package Mebius;

#-----------------------------------------------------------
# シンプルなHTML
#-----------------------------------------------------------
sub SimpleHTML{

# 宣言
my($use) = shift if(ref $_[0] eq "HASH");
my($message) = @_;
my($view_line);

	# 必須項目
	if(exists $use->{'Message'}){ $message = $use->{'Message'}; }

	# 文字コード変換
	if($use->{'FromEncoding'}){ Mebius::Encoding::from_to($use->{'FromEncoding'},"utf8",$message); }

#die('Perl Die! Message is empty'); }

$view_line .= qq(<html lang="ja">\n);
$view_line .= qq(<head>\n);
$view_line .= qq(<meta http-equiv="content-type" content="text/html; charset=utf-8">\n);
$view_line .= qq(<title></title>\n);
$view_line .= qq(<meta name="robots" content="noindex,nofollow,noarchive">\n);
$view_line .= qq(</head>\n);
$view_line .= qq(<body>\n);
$view_line .= qq(\n);
#$view_line .= &Escape::HTML([$use->{'Message'}]);
$view_line .= qq($message\n);
$view_line .= qq(</body>\n);
$view_line .= qq(</html>\n);


# コンテンツタイプ
print "Content-type:text/html;charset=utf-8;\n\n";
print $view_line;

exit;


}

#-----------------------------------------------------------
# メンテナンス
#-----------------------------------------------------------

sub maintenance{

my($finish_time) = @_;
my($finish_time_text);

	if($finish_time){
		my($how_long) = Mebius::second_to_howlong({ TopUnit => 1 }  , $finish_time - time);
		$finish_time_text = qq(<p>終了予定時刻： ${how_long}以内 <span style="color:#f00;">※状況によっては前後する場合があります。</span></p>);
	}

print "Status: 503 Service Temporarily Unavailable\n";
Mebius::SimpleHTML(qq(<h2><p>503 Service Temporarily Unavailable</h2>  現在メンテナンス中です。再開までお待ちください。</p>$finish_time_text<p><a href="http://mb2.jp/">mb2.jp</a> / <a href="http://sns.mb2.jp/">sns.mb2.jp</a></p>));

}

#-----------------------------------------------------------
# スタイルをスタイルタグに
#-----------------------------------------------------------
sub to_style_element{

my($inline_style) = @_;

	if(!$inline_style){ return(); }

my $self = qq( style="$inline_style");

}




1;