
use strict;
use Encode;
use Mebius::Encoding;
use Mebius::SNS;
package Mebius::Fillter;
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
sub delete_marks{

my $self = shift;
my $text = shift;

$text =~ s/(\s|　|☆|★|・|＼|／|、|，|。|\.|,|:|;)//g;

$text;


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub each_comment_fillter_on_shift_jis{

my $self = shift;
my $comment = shift;
my($message);

my $comment_utf8 = utf8_return($comment);

	if( $message = $self->each_comment_fillter($comment_utf8)){
		shift_jis($message);
	}

$message;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub each_comment_fillter_judge{

my $self = shift;
my $comment = shift;
my $text = new Mebius::Text;
my($fillter_flag);

my $comment_for_judge = $text->adjust_for_judge($comment);

	if($self->heavy_sexual_fillter($comment_for_judge)){
		$fillter_flag = 1;
	}


$fillter_flag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub each_comment_fillter{

my $self = shift;
my $comment = shift;
my $text = new Mebius::Text;
my($my_account) = Mebius::my_account();
my($fillter);

my $comment_for_judge = $text->adjust_for_judge($comment);

	if($my_account->{'login_flag'}){
		return();

	} else {
			if($self->heavy_sexual_fillter($comment_for_judge)){
				$fillter = qq(<span style="font-style:italic;" class="gray size90">この投稿はフィルタされています。表示するにはアカウントにログインして下さい。</span>);
			} else {

			}
	}

$fillter;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub each_handle_fillter_on_shift_jis{

my $self = shift;
my $handle = shift;

my $handle_utf8 = utf8_return($handle);

my $message = $self->each_handle_fillter($handle_utf8);

$message;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub each_handle_fillter{

my $self = shift;
my $return;

	if($self->each_comment_fillter(@_)){
		$return = "-";
	}

$return;

}


#-----------------------------------------------------------
# 本文とタイトルを一斉判定
#-----------------------------------------------------------
sub ads {

# 宣言
my($use,$subject,$comment) = @_;
my($fillter_flag);

	# 題名フィルタ
	if(Mebius::Fillter::subject_fillter({ FromEncoding => $use->{'FromEncoding'} },$subject)){ $fillter_flag = 1; }

	# コメントフィルタ
	if(Mebius::Fillter::comment_fillter({ FromEncoding => $use->{'FromEncoding'} },$comment)){ $fillter_flag = 1; }


return($fillter_flag);

}


#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub basic{

my($subject,$comment) = @_;
my($return);

	# 題名フィルタ
	if(Mebius::Fillter::subject_fillter({ },$subject)){ $return = 1; }

	# コメントフィルタ
	if(Mebius::Fillter::comment_fillter({ },$comment)){ $return = 1; }

$return;

}


#-----------------------------------------------------------
# 複数のフィルタを一斉に適用
#-----------------------------------------------------------
sub Ads{

my($flag) = ads(@_);

$flag;

}

#-----------------------------------------------------------
# レス本文を隠すかどうか決める
#-----------------------------------------------------------
sub check_per_res{



}

#-----------------------------------------------------------
# フィルタ判定してエラーを表示する
#-----------------------------------------------------------
sub fillter_and_error{

my($subject,$comment) = @_;
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($return);


	if(heavy_fillter($subject,$comment)){
		$return = q(このページにはデリケートな内容が含まれているため、表示できません \( <a href=").e($basic_init->{'guide_url'}).q(/%A5%C7%A5%EA%A5%B1%A1%BC%A5%C8%A4%CA%C6%E2%CD%C6">詳しく</a> \));
			if(!$my_account->{'admin_flag'} && !Mebius::Admin::admin_mode_judge()){
				main::error($return);
			}

	} elsif(middle_fillter($subject,$comment)){
		
		$return = q(このページにはデリケートな内容が含まれています。表示するには) . Mebius::SNS->please_login_link();
			if(!$my_account->{'login_flag'} && !$my_account->{'admin_flag'} && !Mebius::Admin::admin_mode_judge()){
				main::error($return,"401");
			}
	}

$return;

}


#-----------------------------------------------------------
# 重度のフィルタ
#-----------------------------------------------------------
sub heavy_fillter{

my($subject) = @_;
my($return);
my $fillter = new Mebius::Fillter;

#,$comment

	# 病
	if($subject =~ /(自殺)(.{0,20})(したい|します|方法)/s){ $return = 1; }
	if($subject =~ /(オナニ|自慰|自殺|自傷)/s){ $return = 1; }
	if($subject =~ /(手首)(.{0,30})(傷|赤|血)/s){ $return = 1; }
	if($subject =~ /(セクハラ|ｾｸﾊﾗ|レイプ|ﾚｲﾌﾟ|強姦|性犯罪)/s){ $return = 1; }
	if($subject =~ /(殺人)/s){ $return = 1; }
	if(common_heavy_fillter($subject)){ $return = 1; }

	if($fillter->heavy_sexual_fillter($subject)){ $return = 1; }


$return;

}

#-----------------------------------------------------------
# 重度のフィルタ ( 題名と本文共通 ) 
#-----------------------------------------------------------
sub common_heavy_fillter{

my($text) = @_;
my($fillter_flag);

	if($text =~ /(リスカ|ﾘｽｶ|アムカ|ｱﾑｶ|レグカ|ﾚｸﾞｶ|リストカッ(ト|タ)|ﾘｽﾄｶｯ(ﾄ|ﾀ)|アームカッ(ト|タ)|ｱｰﾑｶｯ(ﾄ|ﾀ)|レッグカッ(ト|タ)|ﾚｯｸﾞｶｯ(ﾄ|ﾀ))/s){ $fillter_flag = 1; }

$fillter_flag;


}


#-----------------------------------------------------------
# 中程度のフィルタ
#-----------------------------------------------------------

sub middle_fillter{

my($subject,$comment) = @_;
my($return);

	if($subject =~ /(いじめ|イジメ|虐め|死にたい|殺意)/s){ $return = 1; }
	if($subject =~ /(虐待|暴力)/s){ $return = 1; }

	if(common_heavy_fillter($comment)){ $return = 1; }

	# コメント
	#if(heavy_fillter($comment)){ $return = 1; }

$return;

}



#-----------------------------------------------------------
# 題名フィルタ
#-----------------------------------------------------------
sub subject_fillter{

# 宣言
my $select = shift;
my $subject = shift;
my($fillter_flag,$use);
my $fillter = new Mebius::Fillter;

	if(ref $select eq "HASH"){
		$use = $select;
	} else  {
		$use = shift;
	}

	# エンコード調整
	if($use->{'FromEncoding'}){
		Mebius::Encoding::from_to($use->{'FromEncoding'},"utf8",$subject);
	}


	# 題名がない場合
	if($subject eq ""){ return(); }

# 空白を削除
$subject = $fillter->delete_marks($subject);

	if(heavy_fillter($subject)){ $fillter_flag = 1; }
	if(middle_fillter($subject)){ $fillter_flag = 1; }
	if(subject_and_comment_common_fillter($subject)){ $fillter_flag = 1; }


	# 攻撃的
	if($subject =~ /(グロ|ｸﾞﾛ|性|暴|殺|死|氏ね|タヒ|ギャンブル|馬鹿|虐待|嫌い|畜生|反対|アンチ|厨|糞|カス|ｶｽ|荒らし|クソ|くそ|ｸｿ|クズ|ｸｽﾞ|爆発し|(腹)(.{0,10})(立))/s){ $fillter_flag = 1; }
	if($subject =~ /(う|ウ|ｳ)((ざ|ザ|ｻﾞ)(い|イ|ｲ|っ|ッ|かった|すぎ)|(ぜ|ゼ)(え|ぇ|エ|ェ|ー))/s){ $fillter_flag = 1; }
	if($subject =~ /((き|キ|ｷ)(も|モ|ﾓ)(い|イ|ィ|ぃ)|キモ)/s){ $fillter_flag = 1; }
	if($subject =~ /(グチ|愚痴|最悪|恨み|アホ|喧嘩|(目|め)(障|ざわ)り|ケンカ|いい(加減|かげん)に)/s){ $fillter_flag = 1; }
	if($subject =~ /(むか|ムカ|イラ|苛)(つく|つい|ツク)|(イライラ|いらいら|苛々|苛苛|憎い|調子(.{0,20})(の|ノ|乗))/s){ $fillter_flag = 1; }
	if($subject =~ /(ワロタ|ワロス|わろた|(\(|（)(笑|怒))/s){ $fillter_flag = 1; }
	if($subject =~ /(マジキチ|ﾏｼﾞｷﾁ|炎上|ビッチ|(晒)(さ|し|す|せ|そ))/s){ $fillter_flag = 1; }
	if($subject =~ /(リンチ)/s){ $fillter_flag = 1; }
	if($subject =~ /(DQN|ＤＱＮ)/s){ $fillter_flag = 1; }
	if($subject =~ /(反対|汚|穢|姦|谷間|被害|襲(わ|う|い|え|お)|刺(し|す|せ))/s){ $fillter_flag = 1; }
	if($subject =~ /(ﾌﾟｷﾞｬ|プギャ|ファック|これは(ひど|酷)い)/s){ $fillter_flag = 1; }

	# 荒れやすい
	if($subject =~ /(不良)/s){ $fillter_flag = 1; }

	# 性的
	if($subject =~ /(胸)(.{0,20})(大|小)/s){ $fillter_flag = 1; }
	if($subject =~ /(ヌード|ムラムラ|すけべ|スケベ|助平|股間|(喘|あえ)ぎ声|押し倒)/s){ $fillter_flag = 1; }
	if($subject =~ m!(//$)!){ $fillter_flag = 1; }


	if($subject =~ /(フェチ|アダルト|(エ(ロ|口)い|えろ|ｴﾛ)(い|イ|ィ|ぃ)|パンツ|ぱんつ|下半身|ちんちん|チンチン|性的|風俗|下ネタ|裸|(M|Ｍ)字)/s){ $fillter_flag = 1; }

	if($subject =~ /(奴隷|変人|変態|変質者|卵子|受精|チカン|拉致|hs|ｈｓ|女児|興奮)/s){ $fillter_flag = 1; }
	if($subject =~ /(生理|おりもの)/s){ $fillter_flag = 1; }
	if($subject =~ /(ロリ|ﾛﾘ|ショタ|ホモ|レズ|ペド|サド|マゾ|SM|ＳＭ|犯(さ|し|す|せ|そ))/s){ $fillter_flag = 1; }
	if($subject =~ /(20|18|15|２０|１８|１５)(.{0,10})(禁|R|Ｒ|以上|未満)/s){ $fillter_flag = 1; }
	if($subject =~ /(R|Ｒ)(-)?(20|18|15|２０|１８|１５)/s){ $fillter_flag = 1; }
	if($subject =~ /(成人)(向)/s){ $fillter_flag = 1; }


	# 自己警告
	if($subject =~ /((閲覧|観覧|えつらん)(.{0,30})(ちゅうい|注意|禁止))/s){ $fillter_flag = 1; }
	if($subject =~ /(体)(.{0,10})(悩み)/s){ $fillter_flag = 1; }


	# 犯罪
	if($subject =~ /(犯罪|違法|事件|死体|臓器)/s){ $fillter_flag = 1; }
	if($subject =~ /(トラウマ|復讐)/s){ $fillter_flag = 1; }

	# 自然災害
	if($subject =~ /(地震|震災|火事|火災|津波|事故|危険|手首)/s){ $fillter_flag = 1; }

	# 規約
	if($subject =~ /(広告|アフィ|クリック|ｸﾘｯｸ|くりっく)/s){ $fillter_flag = 1; }

	# 問題が起こりやすいスレッド	
	if($subject =~ /(宗教|党|ストレス|批判)/s){ $fillter_flag = 1; }

	# その他
	if($subject =~ /(兵器|爆弾|戦争)/s){ $fillter_flag = 1; }
	if($subject =~ /(創価)/s){ $fillter_flag = 1; }
	if($subject =~ /(差別)/s){ $fillter_flag = 1; }
	if($subject =~ /(覚(せい|醒)剤)/s){ $fillter_flag = 1; }
	if($subject =~ /((ちゃ|ては)いけない)/s){ $fillter_flag = 1; }

	# 予備
	if($subject =~ /(ハッキング|クラッキング)/s){ $fillter_flag = 1; }



return($fillter_flag);

}

#-----------------------------------------------------------
# ペアスレなどのフィルタ
#-----------------------------------------------------------
sub light_fillter{

my($subject) = @_;
my($fillter);

	if($subject =~ m!(//|ド(S|M|Ｓ|Ｍ)|ペア|嬢様|執事)!){
		$fillter = 1;
	}

$fillter;


}

#-----------------------------------------------------------
# 本文フィルタ
#-----------------------------------------------------------
sub comment_fillter{

# 宣言
my($use,$comment) = @_;
my($fillter_flag);

	# エンコード調整
	if($use->{'FromEncoding'}){
		Mebius::Encoding::from_to($use->{'FromEncoding'},"utf8",$comment);
	}

	if(!$comment){ return(); }

	# 本文判定
	if(heavy_fillter(undef,$comment)){ $fillter_flag = 1; }
	if(middle_fillter(undef,$comment)){ $fillter_flag = 1; }
	if(subject_and_comment_common_fillter($comment)){ $fillter_flag = 1; }

	if($comment =~ /(エッチ)/s){ $fillter_flag = 1; }
	if($comment =~ /(マスターベーション)|(コンドーム)|(アームカット)/s){ $fillter_flag = 1; }
	if($comment =~ /(リストカット|りすとかっと|リスカ|ﾘｽｶ|アムカ|ｱﾑｶ|カッティング|事件|殺(したい))/s){ $fillter_flag = 1; }
	if($comment =~ /(むか|ムカ)(つく|ツク)/s){ $fillter_flag = 1; }

return($fillter_flag);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub heavy_sexual_fillter{

my $self = shift;
my $text_body = shift;
my $text = new Mebius::Text;
my($fillter_flag);

my $text_for_judge = $text->adjust_for_judge($text_body);

# 空白を削除
$text_for_judge = $self->delete_marks($text_for_judge);


	if($text_for_judge =~ /(ドピュ|どぴゅ|性器|精子|射精|膣|陰茎|夢精|幼女|ようじょ|自慰|勃起|ぼっき|ボッキ|乳首|巨乳|貧乳|勃起|処女|童貞|性器|陰毛|お(っ)?ぱい|オ(ッ)?パイ)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(セフレ|ｾﾌﾚ|(ヴァ|バ)ージン|セックス|せっくす|ｾｯｸｽ|(S|ｓ|Ｓ)(E|ｅ|Ｅ)(X|ｘ|Ｘ|×)|セクロス|ｾｸﾛｽ|(オナ|ｵﾅ)(禁|ニ|ヌ)?|えっち|(工|エ)ッチ|ｴｯﾁ|ペニス|ﾍﾟﾆｽ|ロリコン|ﾛﾘｺﾝ|コンドーム|ポルノ|クリトリス|ｸﾘﾄﾘｽ|性交|交尾|アナル|ｱﾅﾙ|クンニ|フェラ|ﾌｪﾗ|イマラチオ|ヤリマン|ヤリチン|エクスタシ|ｴｸｽﾀｼ|マスターベーション|ちんちん|チンチン|ﾁﾝﾁﾝ)/i){ $fillter_flag = 1; }

	if($text_for_judge =~ /(淫乱|乱交|スケベ|ワレメ|欲求不満|ツルペタ|子宮|卑猥|性欲|露出|監禁|金玉|睾丸|手淫|大便|精液|中出し|生出し|立(ち)?バック|騎乗位|愛液)/s){ $fillter_flag = 1; }


	if($text_for_judge =~ /(((工|エ|ｴ)(ロ|口|□|ﾛ))|えろ)(い|ぃ)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(^|([^a-zA-Z0-9]))(H|Ｈ)((な|の|に)|(.*?)(経験|写真))/s){ $fillter_flag = 1; }



	if($text_for_judge =~ /(ホモ)(動画|写真|サイト)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(う|ウ|ｳ)(ん|ン|ﾝ|ｎ|n|N|○|●|□|※|＊)(ち|チ|こ|コ|ｺ)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(?<!(パ|ぱ|ガ|が))(ち|チ|ﾁ)(ん|ン|ﾝ|ｎ|n|N|○|●|※|＊)((こ|コ|ｺ|ぽ|ポ|ﾎﾟ)|(ち|チ|ﾁ)(ん|ン|ﾝ|ｎ|n|N|○|●|※|＊))/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(ま|マ|ﾏ|ma)(ん|ン|ﾝ|(ｎ)+|(n)+|(N)+|○|●|□|※|＊)(こ|コ|ｺ|ko)/si){ $fillter_flag = 1; }
	if($text_for_judge =~ /(ま|マ|ﾏ|ma)(ん|ン|ﾝ|(ｎ)+|(n)+|(N)+)(○|●|□|※|＊)/si){ $fillter_flag = 1; }
	if($text_for_judge =~ /(ク|ｸ|く)(リ|ﾘ|り)(ト|ﾄ|と)(リ|ﾘ|り)(ス|ｽ|す)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(セ|ｾ|せ)(ッ|ｯ|つ|ツ|っ|○|●|□|※|＊)(ク|ｸ|く|○|●|□|※)(ス|ｽ|す)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(オ|ｵ|お)(ナ|ﾅ|な|○|●|□|※|＊)(に|二|ﾆ)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(ク|ｸ|く)(リ|ﾘ|リ|○|●|□|※|＊)(ト|ﾄ|と|○|●|□|※)(リ|ﾘ|リ|○|●|□|※)(ス|ｽ|す)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(レ|ﾚ|れ)(イ|ｲ|い|○|●|□|※|＊)(プ|ﾌﾟ|ぷ)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(^|[^A-Za-z])(H|Ｈ)(する|すれ|した|しま|しよ|して|しな)/s){ $fillter_flag = 1; }
	if($text_for_judge =~ /(アソコ)(.*)(毛)/s){ $fillter_flag = 1; }




$fillter_flag;

}

#-----------------------------------------------------------
# 題名と本文、共通のフィルタ
#-----------------------------------------------------------
sub subject_and_comment_common_fillter{

my($text) = @_;
my($fillter_flag);
my $self = __PACKAGE__;

	if($self->heavy_sexual_fillter($text)){
		$fillter_flag = 1;
	}

	if($text =~ /(性的|痴漢|慰安婦|売春|猥褻|わいせつ|ワイセツ|子作り|エロ(画像))/s){ $fillter_flag = 1; }
	if($text =~ /(自殺|殺人|暴行|処刑)/s){ $fillter_flag = 1; }

	if($text =~ /(キ(チ|ティ)ガイ|ｷ(ﾁ|ﾃｨ)ｶﾞｲ|基地(外|街)|気(狂|違)い)/s){ $fillter_flag = 1; }
	if($text =~ /(低脳|売国|(メス|雌)豚)/s){ $fillter_flag = 1; }

	if($text =~ /(麻薬|薬物|大麻|マリファナ|コカイン)/s){ $fillter_flag = 1; }

$fillter_flag;


}


1;