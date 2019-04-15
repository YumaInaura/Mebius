
use strict;
package Mebius::Image;

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
sub use_image_magick{

my($flag);

	if(Mebius::alocal_judge()){
		$flag = 0;
	} else {
		require Image::Magick;
		$flag = 1;
	}

$flag;


}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub image_magick_object{

my $self = shift;
my($image);

	if($self->use_image_magick()){
		$image = new Image::Magick;
	} else {
		return();
	}

$image;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub strip{

my $self = shift;
my $file_name = shift || return();
my $image = $self->image_magick_object() || return();

$image->Read($file_name);
$image->Strip();
$image->Write($file_name);


}


#-----------------------------------------------------------
# 画像サイズの処理
#-----------------------------------------------------------
sub fix_max_size{

# 局所化
my $self = shift;
my $original_file_name = shift;
my $print_file_name = shift || $original_file_name;
my $maxwidth = shift || 300;
my $maxheight = shift || 300;
my($scale);

	if(!$self->use_image_magick()){
		return();
	}

my $image = new Image::Magick;

# ファイル定義
my $imgfile = $original_file_name;

#-- 画像を読込む --#
$image->Read("$imgfile");


# 画像サイズ取得
my($upload_width, $upload_height) = $image->Get('width', 'height');

	# 縮尺を計算（幅）
	if($upload_width > $maxwidth) { $scale = $maxwidth / $upload_width; }

	# 縮尺を計算（高さ）
	if($upload_height > $maxheight) {
		my $scale2 = $maxheight / $upload_height;
			if(!$scale || ($scale2 < $scale) ){ $scale = $scale2; }
	}

#-- 縮小／拡大 --#
$image->Resize(
width  => int($upload_width  * $scale),
height => int($upload_height * $scale),
blur   => 0.8
);

#$image->Strip();

#-- 画像を保存する(JPEG) --#
$image->Write($print_file_name);
#chmod(0604,$print_file_name);

undef $image;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub auto_orient{

my $self = shift;
my $original_file_name = shift;
my $print_file_name = shift || $original_file_name;

	if(!$self->use_image_magick()){
		return();
	}

my $magick = new Image::Magick;
$magick->Read($original_file_name);
$magick-> AutoOrient(); # ここで回転対応
$magick->Write($print_file_name);

}


package Mebius::Paint;

#-----------------------------------------------------------
# お絵かき画像の処理
#-----------------------------------------------------------
sub Imageid{

# 宣言
my($type) = @_;
my(undef,$imageid,$server_domain,$realmoto,$i_postnumber,$i_resnumber) = @_ if($type =~ /Get-image-data/);
my($image_data);
our($paint_dir,$tail);

# 汚染チェック
$imageid =~ s/\W//g;
$i_postnumber =~ s/\D//;
$i_resnumber =~ s/\D//;

# リターン
if($imageid eq ""){ return(); }
if($i_postnumber eq ""){ return(); }
if($i_resnumber eq ""){ return(); }

	# 画像の有無、拡張子を識別
	if(-e "${paint_dir}buffer/$imageid.jpg"){ $tail = "jpg"; }
	if(-e "${paint_dir}buffer/$imageid.png"){ $tail = "png"; }
	else{ return(); }

	$image_data = qq($realmoto/$i_postnumber-$i_resnumber=$tail=$server_domain);

return($image_data);

}

1;
