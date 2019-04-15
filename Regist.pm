
package Mebius::Regist;

use strict;
use Encode::Guess;

use Mebius::Fillter;
use Mebius::Echeck;
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
sub param_to_font_color{

my($param) = Mebius::query_single_param();
my($font_color);

	if( $param->{'font_color'} =~ /^\#?[a-f0-9]{3,6}$/ ){
		$font_color = $param->{'font_color'};
	}

$font_color;


}

#-----------------------------------------------------------
# URLを禁止する
#-----------------------------------------------------------
sub deny_url{

my $self = shift;
my $text = shift;
my($error_flag);

$text =~ s/[\s\n\r　]//gi;

	if($text =~ m!ttp://|www\.|\.(com|jp|net)!i){
		$error_flag = 1;
	}

$error_flag;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub name_to_handle_or_regist_error{

my $self = shift;
my $param_name = shift;
my $query = new Mebius::Query;
my $regist = new Mebius::Regist;
my $param_utf8_judged = $query->single_param_utf8_judged_device();

	if($param_name !~ /^[0-9a-z]+$/){
		die("Don't hand direct parameter.");
	}

	if( my $error = $regist->name_error_message($param_utf8_judged->{$param_name})){
		$self->regist_error($error);
	}

my $handle = $regist->name_to_handle($param_utf8_judged->{$param_name});

$handle;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub name_error_message{

my $self = shift;
my(undef,$error_messages) = name_check({ source => "utf8" },@_);

my $error = join / / , @{$error_messages};

$error;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub name_to_handle{

my $self = shift;
my $name = shift;

my $adjusted_name = $self->delete_trip($name);

($adjusted_name) = name_check({ source => "utf8" },$adjusted_name);

$adjusted_name;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub delete_trip{

my $self = shift;
my $name = shift;

$name =~ s/#(.+)//g;

$name;

}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub url_check{

# 宣言
my $self = shift;
my $check = my $check_url = shift;
my $use = @_ if(ref $_[0] eq "HASH");
my $type = @_ if(ref $_[0] eq "");
my($basic_init) = Mebius::basic_init();
my($i,$allowurl_list,$flag,$mail_flag,@deny_words1,@deny_words2,$error_message,$other_website_url_num,$alert_flag,@error);
my($my_account) = Mebius::my_account();

# 自由なURL投稿を許可する日数 ( アカウント登録日から計算 )
my $allow_free_post_url_days = 31;

# フック
my $check_pure = $check;
# ローカル

# 禁止ワードを定義
my @deny_words1 = ('://','：／／','ttp','ｔｔｐ','www\.','Feeling\+Lucky','btnI','\[url','\[a href');

	# 秘密板を制限
	if(!$main::secret_mode && $check =~ /\/_sc([a-z0-9]+)\//){ $flag = 1; }


	# 許可ＵＲＬを展開、判定から除外
	foreach my $foreach (@{$basic_init->{'allow_url'}}){

		# 分解
		#my($sitedomain,$sitename,$type2) = split(/=>/,$_);
		my($sitedomain,$sitename,$type2) = (${foreach}->{'url'},${foreach}->{'title'});
		utf8($sitename);

		# 限定的
		if($type =~ /Limited/ && $type2 !~ /Free/){ next; }

		$i++;

			# 許可URLを判定本文から削除
			foreach(split(/<br>/,$check)){

					if($sitedomain){
						my $deleted_num = ($check =~ s!http(s)?://(www\.)?([a-z0-9]+\.)?$sitedomain/([\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\\%\*#]{1,1000})?!!eg);
							if(!${foreach}->{'MyWebsite'}){ $other_website_url_num += $deleted_num; }

						# サブドメインも許可する場合
						#$check =~ s/http:\/\/(([a-z0-9]+)\.)?$sitedomain\///g;
						$check =~ s/$sitedomain//g;
					}
			}

			# サイト名がある場合
			if($sitename){
				my $site_url = $sitedomain;
				$site_url =~ s/([^\w\.])//g;
					if($i >= 2){ $allowurl_list .= qq( | ); }
					#if($sitedomain =~ /^http/){ $allowurl_list .= qq(<a href="$sitedomain">$sitename</a>); }
					#else{ $allowurl_list .= qq(<a href="http://$site_url/">$sitename</a>); }
					$allowurl_list .= "$site_url";
			}

	}


	# ▼特定条件下で、外部サイトの貼り付けを許可する
	if($my_account->{'justy_days'} >= $allow_free_post_url_days && !$alert_flag){
		$check =~ s!http(s)?://(www\.)?([a-z0-9\.]+?)\.(jp|com)/([\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\\%\*#]{1,1000})?!!;
	}

$allowurl_list = qq(　( 許可サイト： $allowurl_list ) );

# 判定用に本文を整形
$check =~ s/( |　|☆|★|www\.)//g;;
$check =~ s/(<br>)|\n|\r//g; # => 許可URLを除外前に処理してしまうと、許可ＵＲＬ＋改行＋他サイトでURLが書き込めるようになってしまう

	# 共通の禁止記述
	foreach(@{$basic_init->{'deny_words'}}){
			if($check_pure =~ /$_/) { $flag = 1; }
	}

	# ＵＲＬを禁止 - 基本
	if(!$main::allowurl_mode){
			foreach(@deny_words1){

					if($check =~ /$_/) { $flag = 1; }
			}
	}

	# ＵＲＬを禁止 - メールアドレスと重複する部分
	if(!$main::allowaddress_mode && !$main::allowurl_mode){
			if($check =~ /(\.net|\.com|\.biz|\.info|\.jp([^g]|$))/) { $flag = 1; }
	}


	# 外部URLを禁止
	if($flag && !$mail_flag){
		#push @error , qq(▼<a href="$basic_init->{'guide_url'}%B3%B0%C9%F4%A4%CE%A3%D5%A3%D2%A3%CC">外部のＵＲＬや、メールアドレスは書き込めません。</a><br>$allowurl_list);
		push @error , qq(▼外部のＵＲＬや、メールアドレスは書き込めません。 $allowurl_list);

			if($my_account->{'login_flag'}){

					# アカウント登録日から規定日数が経過して”いる”場合
					if($my_account->{'justy_days'} >= $allow_free_post_url_days){
						push @error , qq(　→外部のURLを書き込めるのは .jp .com ドメインのURLを、1回1個ずつに限ります。);
					# アカウント登録日から規定日数が経過して”いない”場合
					} else {
						my $left_days = $allow_free_post_url_days - $my_account->{'justy_days'};
						push @error , qq(　→アカウント登録から${allow_free_post_url_days}日経過すれば、.jp .com ドメインのURLが、1回に1個だけ投稿可能\になります。);
							push @error , qq(( 現在 $my_account->{'justy_days'}日目 ));
					}
			}

	}

	# ●ステータスコードをチェックする
	if($type =~ /Status/ && @error <= 0){
		if($check_url !~ /^(http\:\/\/[\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\\%\*#]+)$/){
			push @error , qq(▼対象ＵＲＬの文法が間違っています。正しい書式で書いてください。 ( $check_url ) ); 
		}
		elsif(length($check_url) >= 200){
			push @error , qq(▼対象ＵＲＬが長すぎます。 ( $check_url ) ); 
		}
		else{
			my($code) = Mebius::Getstatus("",$check_url);
			if($code ne "200"){ push @error , qq(▼対象ＵＲＬにアクセスできません。 ( $check_url ) ); }
		}
	}


	# お絵かき城のURL
	if($check_pure =~ /(relm|paint)\.cgi\?mode=/ && $main::realmoto ne "delete"){
		push @error , qq(▼お絵かき城の絵には保存期限があり、URLを貼\りつけても、後から閲覧できなくなります。　\URLを貼り付けるには、保存期限のない <a href="${main::main_url}pallet.html">新お絵かき機\能\</a> をご利用ください。);
	}
	
	# バッファ絵のURL
	if($check_pure =~ m!http://(.+?)?mb2\.jp/paint/buffer/! && $main::moto ne "delete"){
		push @error , qq(▼一時絵のURLは投稿できません。);
	}

	# 他サイトのURLが多すぎる場合
	if($other_website_url_num > 3){
			push @error , qq(▼許可サイトの中でも、外部サイトのURLが多すぎます。外部サイトのURLを減らしてください。 (${other_website_url_num}個/3個) );
	}

	# URLが無い場合
	if($main::bbs{'concept'} =~ /Recommend-regist-url/){
			my($url_number) = Mebius::url({ ReturnLinkedNum => 1 },$check_pure);
				if($url_number <= 0){
						push @error , qq(▼URLが記入されていないか、URLの書式が間違っています。このコンテンツでは、必要な<a href="$basic_init->{'guide_url'}%A3%D5%A3%D2%A3%CC">URL</a>を書きこんでください。);
						push(@main::alert_type,"URL未記入");
				}
	}

my $error_message = join " " , @error;

$error_message;

}



#-----------------------------------------------------------
# 筆名のチェック
#-----------------------------------------------------------
sub name_check{

# 宣言
my $use = shift if(ref $_[0] eq "HASH");
my($check,$maxlength) = @_;
my $query = new Mebius::Query;
my($error_flag,$length,$denyname_flag1,$echeck_only_flag,@error,$type);
my $fillter = new Mebius::Fillter;
my $text = new Mebius::Text;

	if(!$query->selected_encode_is_utf8() && $use->{'source'} ne "utf8"){
		utf8($check);
	}

	# 改行を禁止
	if($check =~ /<br>|\r|\n/){ push(@error,"筆名では改行できません。"); }

	# 異常な長さの名前を即刻禁止
	if(length($check) > 1000){ push(@error,"筆名が長すぎます。"); }

	# 筆名の最大文字数
	if(!$maxlength){ $maxlength = 60; }

# トリップが紛れ込んでいる場合は分離
my($handle,$trip) = split(/#/,$check);

# チェックのためにスペースを排他
my $handle_deleted_space = $text->delete_marks($handle);

# 同じ文字の連続使用を禁止
my($same_pattern_flag);
my($first_1byte)  = substr($handle_deleted_space,0,1);
my($first_2byte) = substr($handle_deleted_space,0,2);
		if($handle_deleted_space =~ /((\Q$first_1byte\E){5})/){ $same_pattern_flag = $1; }
		#if($handle_deleted_space =~ /^((\Q$first_2byte\E){3})/){ $same_pattern_flag = $1; }
		if($handle_deleted_space =~ /((\Q$first_2byte\E){4})/){ $same_pattern_flag = $1; }
		if($same_pattern_flag){
			push(@error,qq(筆名に同じ文字の連続 \( ).e($same_pattern_flag).qq( \) は使えません。));
			Mebius::AccessLog(undef,"Handle-name-same-patterun","筆名 ： $handle");
		}

# 筆名の基本変換
$handle =~ s/&amp;([#a-zA-Z0-9]+);/□/g;
$handle =~ s/\Qリーダー\E/りいだあ/g;	# 管理者名
$handle =~ s/\Qマスター\E/ますたあ/g;	# 管理者名
$handle =~ s/\Qルーキー\E/るうきい/g;	# 管理者名
$handle =~ s/\Qマーキー\E/まあきい/g;	# 管理者名
$handle =~ s/管((\s|　)+)?理/かんり/g;	# 管理者名

$handle =~ s/&amp;([#a-zA-Z0-9]+);//g;	# 特殊文字
$handle =~ s/<br>//g;					# 改行
$handle =~ s/★/？/g;					# ＩＤ
$handle =~ s/☆/？/g;					# トリップ
my $check_buf1 = $check;
$handle =~ s/(　| )+/ /g;			# 行頭/行末の全角スペース
$handle =~ s/(\s{2,})/ /g;				# 連続半角スペース

# 筆名の長さを計算
$length = int( (length($handle)) / 2 );
my $byte = length $handle;

	# 基本エラー
	# 空白の連続 (最後の空白は麻雀牌みたいな記号)
	#if(($type ne "allow_noname" || $type =~ /EMPTY/) && ($handle =~ /^(\x81\x40|\s|)+$/ || $handle eq "") ) {
	#	push(@error,"名前がありません。何か考えてください。");
	#	$error_flag = "Nothing";
	#}

	if(length($handle) < 1*2) {
		push(@error,"名前が短すぎます。（ 現在 0.5文字 / 最小 1文字 ）");
		$error_flag = "短";
	}

	if(length $handle > $maxlength) {
		push(@error,"名前が長すぎます。（ 現在 ${byte}バイト / 最大 ${maxlength}バイト ）");
		$error_flag = "長";
	}

	# 匿名判定 
	if($handle_deleted_space =~ /(名(無|な)し|匿名|通りすがり|通行人|傍観者|未定|Anony)/i) {
		push(@error,"匿名 ( $1 ) は利用出来ません。");
		$error_flag = "匿名";
	}

	# 不適切な筆名判定
	if($handle_deleted_space =~ /
			 (あいうえお|荒(ら)?し)
			|(死|氏|志)ね|(\Qタ\E|ﾀ)(ヒ|ﾋ)(ね|れ)
			|(う|ぅ)(ん|●|○)(こ|ち)
			|(ウ|ゥ)(ン|●|○)(コ|チ)
			|(マ|チ)(ン|●|○)(コ)
			|(ま|ち)(ん|●|○|n|ｎ)(こ|子|娘)
			|(お|オ)(め|メ|◯|●)(こ|コ)
			|(ペニス|ちんぽ|チンポ)
			|(オナニ|レイプ|痴漢|チカン|ちかん)
			|(包茎|金玉|性器|精子)
			|(幼女|ようじょ|ペド|ロリコン|つるぺた)
			|(パイズリ|フェラチオ|ク(ン|●|○)ニ)
			|(エッチ|セックス|精液|変態)
			|(おっぱい|アナル)
			|((しょん|しょう|小)|(だい|大))(べん|便)
			|(殺人)
			|(削除済)
			|(池沼|エロい)
			|^(ちん|チン)(ちん|チン)$
	/x){ $denyname_flag1 = 1; }
	if($handle_deleted_space =~ /(Sex)/xi){ $denyname_flag1 = 1; }

	if($fillter->heavy_sexual_fillter($handle_deleted_space)){
		$denyname_flag1 = 1; 
	}

	# 羅列判定
	if($handle_deleted_space =~ /^(あ|い|う|え|お)$/){ $denyname_flag1 = 1; }

	# データ収集用
	if($handle_deleted_space =~ /(SEX|ＳＥＸ|出会い|ロリ)/){ $echeck_only_flag = 1; }
	if($handle_deleted_space =~ /(うざい|ウザイ)/){ $echeck_only_flag = 1; }
	#if($echeck_only_flag){ Mebius::Echeck::Record("","Handle-hidden",$check); }

	# 禁止名最終判定
	if($denyname_flag1){
		push(@error,"この筆名 ( $handle ) は使えません。");
		$error_flag = "禁止"; 
	}

	# ＵＲＬを禁止
	if($handle_deleted_space =~ /(http|:\/\/|\.jp|\.com|\.net)/){
		push(@error,"名前にＵＲＬは使えません。");
		$error_flag = "URL";
	}

	# すぐにエラーを出す場合
	foreach my $error (@error){
		my $line = qq(▼$error<br>);
		shift_jis($line);
		($main::e_com) .= $line;
	}


# リターン
return($handle,\@error);

}

#-------------------------------------------------
# 性的投稿のチェック
#-------------------------------------------------
sub sex_check{

# 宣言
my($type,$check,$category,$concept) = @_;
my($error_sexnum,$error_flag,$sexnum,$alert_flag,@badword,$comment_split,$badword,$sex_word,$sex_alert_flag);
my($virtual_num,$virtual_word,$badword,$error_message,$alert_message);
my $comment = $check;

my $utf8_length = 3;

	if($type =~ /(Shift_jis|Sjis)-to-utf8/){
		Mebius::Encoding::sjis_to_utf8($check);
	}

	# リターンする場合
	if($concept =~ /NOT-ECHECK/){ return(); }

	# エラー最大数を設定
	if($type =~ /Sousaku/){
		$error_sexnum = 20;
	}
	else{
			if(length $check >= 500*$utf8_length){ $error_sexnum = 4; }
			elsif(length $check >= 100*$utf8_length){ $error_sexnum = 3; }
			else{ $error_sexnum = 2; }
	}

# 整形
(my $check_space_deleted = $check) =~ s/(\s|　|、|<br>)//g;

	# ▼キーワード数判定 ( +1 )
	{
			if(my $buf = ($check_space_deleted =~ s/(
				(エッチ)|
				(セックス|精子|乳首|全裸|おっぱい|幼女|ペニス|クンニ|SEX|ＳＥＸ|アナル|勃起|射精|体位)|
				(マスターベーション|フェラ)|
				(性交)|
				(う|ウ)(ん|●|○|〇|０)(こ|コ)|
				(クチュ)|
				(犯され)|
				(レ)(●|◯)(プ)|(レ)(イ)(●|◯)|
				(服)(を)?(脱がされ)|
				(エッチ|えっち)(したい)
			)
			/$&/xg)){
				$sexnum += $buf;
				push(@badword,$&);
			}

	}

	# ▼キーワード数判定 ( +2 )
	{
			if(my $buf = ($check_space_deleted =~ s/(
			(オ)(ナ|●|○|〇|０)(ニ)(ー)
			|(オ)(ナ)(ニ|●|○|〇|０)(ー)
			|(●|○|〇|０)(ナ)(ニ)(ー)
			|(潮吹|ピストン)
		)
			/$&/xg)){
				$sexnum += ($buf*2);
				push(@badword,$&);
			}

	}

	# ▼一括”アラート”キーワード
	{
			if(my $buf = ($check_space_deleted =~ s/(
				(イッちゃう)
				|(おっぱい|オッパイ)(.{1,30})?(揉)(む|み|んで)
				|(パイズリ|オナホ|肉棒|性奴隷)
				|((一緒|いっしょ)に)(イク)
				|(巨乳|貧乳|美乳|爆乳)
				|(首|性器|乳|体|胸)(.{0,30})((な|ナ|舐)(め|メ)|(ペ|ぺ)(ロ|ろ))
				|(胸|乳)(.{0,30})(さわ|触|(揉(む|み|んで)))
				|(まんまん)(.{1,30})?(ペロペロ)
				|(えっち|エッチ|SEX|ＳＥＸ|セックス)(.{0,40})(したい|する)
				|(愛液)
				|(ちんこ|チンコ|ちんちん)(.{0,150})(射精|挿入)
				# 話系
				|(エロい|エッチな)(はなし|話|こと)(.{0,15})(しよう)
				# 伏字系
				|(●|○|〇|０)(ん|ン)(こ|コ)
				|(ペ)(ニ)(●|○|〇|０)
				|(ちんかす|チンカス)
				# 単語系
				|(クリトリス)
			)/$&/xg)){
					$sexnum += $buf;
					$sex_alert_flag++;
					push(@badword,$&);
			}
	}

	# ▼一括”エラー”キーワード
	{
			if(my $buf = $check_space_deleted =~ s/
				((レ)(●|○|〇|０)(プ)|(レ)(イ)(●|○|〇|０)|レイプ)(したい|してやる)
				|(ま|マ)(ん|ン|●|○|〇|０)(こ|コ)|(ﾏﾝｺ)
				|((レ)(●|◯)(プ)|(レ)(イ)(●|◯)|レイプ|エッチ|セックス)(したい|してやる)
				|(チ|ち)(●|○|〇|０)(こ|コ)
				|(チ|ち)(ん|ン)(●|○|〇|０)
				|(ア)(ナ)(●|○|〇|０)
				|(ア)(●|○|〇|０)(ル)
				|(●|○|〇|０)(ニ)(ス)
				|(ペ)(●|○|〇|０)(ス)
				|(俺|僕|オレ)(の)(チ|ち)(ん|ン)(こ|コ)
				|(ク)(ン|●|◯)(ニ)
				|(オナ)(る|ってる|ニスト)
				|(つるぺた)
				|(ザーメン)
				|(足コキ|手コキ)
				|(ウンコ|SEX|ＳＥＸ){2}
			/$&/xg){
				$sexnum += 10;
				push(@badword,$&);
			}
	}

	# 組み合わせチェック
	foreach $comment_split (split(/<br>/,$check)){

			$comment_split =~ s/(\s|　|、)//g;

			# バーチャルデート判定 (第一段)
			if($comment_split =~ /(\/\/|／／|＼＼)$/){ $virtual_num += 0.5; }
			if($comment_split =~ /ひゃ(ぁ)(う|ぅ)/){ $virtual_num += 1; $virtual_word .= qq( $&); }
			if($comment_split =~ /耳(かぷ|カプ|ﾍﾟﾛ|ｶﾌﾟ|ﾊﾑ)/){ $virtual_num += 3; $virtual_word .= qq( $&); }
			if($comment_split =~ /(耳|首)(.{1,15})?(なめ|舐め)/){ $virtual_num += 3; $virtual_word .= qq( $&); }
			if($comment_split =~ /(恥ずかし|ちゅっ|チュッ)(.{1,30})?(\/\/|／／|＼＼)/){ $virtual_num += 3; $virtual_word .= qq( $&); }
			if($comment_split =~ /(すりすり)(.{1,30})?(\/\/|／／|＼＼)/){ $virtual_num += 0.5; $virtual_word .= qq( $&); }
			if($comment_split =~ /(ひゃう)(.{1,30})?(\/\/|／／|＼＼)/){ $virtual_num += 5; $virtual_word .= qq( $&); }

	}


	# 組み合わせで禁止フラグを立てる
	if($sexnum >= $error_sexnum){
			foreach(@badword){ $badword .= qq( $_); }
		$error_flag = qq(組み合わせ ($badword)); 
	}

# バッドワードを展開	
	foreach(@badword){
		if($badword){ $badword .= qq( / $_ ); }
		else{ $badword = qq($_); }
	}
	if($badword){ $badword = qq( ( $badword ) ); }

	# エラー定義
	if($error_flag){

		$error_message .= qq(▼不適切なキーワード${badword}が多すぎます。 ( $sexnum pt / $error_sexnum pt )<br>　隠語、性的表現などを減らしてください。<br>);
		Mebius::Echeck::Record("","Sex","$comment");
		Mebius::Echeck::Record("","All-error","$comment");

	}

	# バーチャルデート判定
	elsif($virtual_num >= 3 && $type !~ /Sousaku/){
			if($virtual_word){ $virtual_word = qq( ( $virtual_word ) ); }
		$alert_message .= qq(▼「バーチャルデート」「恋愛利用」をしていませんか？　出会い系のご利用は原則禁止です。$virtual_word<br>);
		$alert_flag = qq(バーチャルデート $virtual_word);
		my $alert_type = "出会い/デート";
		shift_jis($alert_type);
		push(@main::alert_type,$alert_type);
		Mebius::Echeck::Record("","Virtual-date","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}


	# アラート定義
	elsif($sex_alert_flag){

		my($view_word) = qq( ( $sex_word ) ) if($sex_word);
		$alert_message .= qq(▼相談/議論以外での性的な書き込みしていませんか？ $view_word　他の方の不快にならないよう、サイトをご利用ください。<br>);
		my $alert_type = "性的な表現";
		shift_jis($alert_type);
		push(@main::alert_type,$alert_type);
		Mebius::Echeck::Record("","Sex","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
		$alert_flag = qq(性的 $badword);
	}

	# エンコード
	if($type =~ /(Shift_jis|Sjis)-to-utf8/){
		shift_jis(undef,$alert_message,$error_message,$error_flag,$alert_flag);
	}

	# エラー
	if($error_message){	$main::e_com .= $error_message; }
	# 警告
	if($alert_message){ $main::a_com .= $alert_message; }


# リターン
return($error_flag,$alert_flag,$sexnum,$error_sexnum);

}


#-------------------------------------------------
# 個人情報のチェック
#-------------------------------------------------
sub private_check{

# 宣言
my($type,$check,$category,$concept) = @_;
my($error_message,$alert_message);
my($hearing_error_flag,$todoufuken_split);
my($error_flag,@todoufukenn,@city,$split_error_flag,$private_error_flag,$private_alert_flag,$check_flag,$address_error_flag,$alert_flag,$deai_alert_flag);
my($private_word,$hearing_word,$alert_level,$deai_word,$alert_type);

	# リターンする場合
	if($type =~ /Sousaku/){ return(); }
	if($concept =~ /NOT-ECHECK/){ return(); }

	if($type =~ /(Shift_jis|Sjis)-to-utf8/){
		Mebius::Encoding::sjis_to_utf8($check);
	}

# フック
my $check_pure = my $comment = $check;

	# チェック用にスペース等を除外
	($check) = Mebius::escape("Space",$check);
	($check) = Mebius::url({ EraseURL => 1 },$check);
	$check =~ s/No\.([0-9,\-]+)//g;


# 都道府県名を定義
@todoufukenn = ('北海道','青森','岩手','宮城','秋田','山形',
'福島','茨城','栃木','群馬',
'埼玉','千葉','東京都','神奈川',
'山梨','長野','新潟','富山',
'石川','福井','岐阜','静岡','愛知','三重',
'滋賀','京都','大阪','兵庫',
'奈良','和歌山','鳥取','島根',
'岡山','広島','山口','徳島',
'香川','愛媛','高知','福岡','佐賀','長崎','熊本','大分','宮崎','鹿児島','沖縄');

	# 電話番号判定１
	if($check !~ /(フレコ|コード)/){
			if($check =~ /(080|090|０８０|０９０)([-0-9０１２３４５６７８９─ー－]{8,30})/){
				$check_flag = qq($1-$2);
				$private_error_flag = "電話1 - $&";
				$alert_flag = 1;
				$alert_level += 10;
			}
	}

	# 電話番号判定２
	if(!$alert_flag && $check =~ /(電話|Tel|TEL|tel|℡)/ && $check !~ /(フレコ|コード)/ && $category ne "game"){
			if($check =~ /(0|０)([0-9]{1,2}|[０１２３４５６７８９]{2,4})(-|─|ー|－)([0-9]{3,10}|[０１２３４５６７８９]{6,30})/){
				$check_flag = qq($&);
				$private_word .= qq( $&);
				$private_error_flag = "電話1 - $&";
				$alert_flag = 1;
				$alert_level += 10;
			}
	}

	# ●１行ずつ判定
	foreach my $comment_split (split(/<br>/,$check_pure)){

			# 住所
			if($comment_split =~ /(市|町|村|区|駅|中学|高校|高等学校|住所)/){
					my($flag2) = $&;

					# 都道府県を展開
					foreach $todoufuken_split (@todoufukenn){
							if($comment_split =~ /($todoufuken_split)/){
								$private_error_flag = "住所-$flag2-$&";
								$check_flag = qq($&-$flag2);
							} 
					}

			}

			# 学校名
			if($comment_split =~ /(市立|私立|都立|付属|附属)(.{1,60})(中学|小学校|高校|高等学校)/){
				$private_word .= qq( $&);
				$private_error_flag = "住所";
			}

			# 伏字系
			if($comment_split =~ /(●|◯)?(●|○)(先生|子|太)/){
				$private_word .= qq( $&);
				$private_error_flag = qq(本名);
			}

			# 学校名系
			if($comment_split =~ /
				(僕|ぼく|ボク|俺|おれ|オレ|私|わたし|あたし|アタシ|ワタシ|うち|ウチ)(の)(学校)(.+)(高校|中学|小学校|大学)
			/x){
				$private_word .= qq( $&);
				$private_error_flag = qq(学校名);
			}

			# 本名系
			if($comment_split =~ /
				(僕|ぼく|ボク|俺|おれ|オレ|私|わたし|あたし|アタシ|ワタシ|うち|ウチ)(.{1,15})?(の)(本名|ほんみょう)
				|((本名|実名)(は|わ|が)?)(.{1,30})(です|だ(よ|ょ)|だから|だけど|やけん|同じ|(と|って)(言|い)(います|う))
				|(^|って|は|わ|が|って|←|これ)(.{1,30})?(本名|ほんみょう|実名)(ね|だ(よ|ょ)|です|だから|やけん|だけど|だね|なの|なんだ|と同じ)
				|(名前)(.{0,30})(本名|ほんみょう|実名)(です)
			/x){
				$private_word .= qq( $&);
				$private_error_flag = qq(本名);
			}

			# 住所系
			if($comment_split =~ /
			(区|市|町)(に)((住|す)んで)((い)?ます|(い)?るよ)
			|(平|西|北|東|南|浜|岡|丘|星|宮|風|前|園|明|山|陽|田|寺|院|付属|附属|剛|光|津|徳|一|ニ|三|四|五|六|七|八|九|十|●|◯)(中学|小学)
			|(○|●)(区|市|町)

			/x){
				$private_word .= qq( $&);
				$private_error_flag = qq(住所);
			}


			# 個人情報の聞き出し系
			if($comment_split =~ /
				(何市|何区|の(何処|どこ))(.*)(住|す)(み|んでる)(の|？|\?)
				|(本名|ほんみょう|実名|住所)(.{1,15})(お願いします|(書|か)いて(くだ|下)さい)
				|(住所|電話番号|小学校|本名)(.{1,15})?((教|おし)え(て|る|ろ)|(書|か)いて)
			/x){
				$hearing_error_flag = 1;
				$hearing_word .= qq( $&);
			}

			# ▼出会い系判定
			if($comment_split =~ /
				(メール|メル)(とか|を)?((でき|出来)る人|(下|くだ)さい)
				|(電話)(交換)
				|(な)(やつ|奴|人)(メール|メル)(しよ)
				|(メール)(待って(る|ます)|しませんか)
				|(アド)(レス)?(交換|こうかん)(しよ|したい)
				|(直メ)(しよ|したい)
				|(携帯)(.{1,15})?(番号)(.{1,15})?((の|載|乗)せる)
			/x){
				$deai_alert_flag = qq(出会い);
				$deai_word .= qq( $&);
			}
			if($comment_split =~ /((メ)?アド|ケー番)(.{0,30}) (((教|おし)え(て|ろ|る(よ|ね))|載せ((ら)?れ|て)|聞きたい)|書(いて|く))/x){
					if($comment_split !~ /(て)(もら)|(メビアド)/){
						$deai_alert_flag = qq(出会い);
						$deai_word .= qq( $&);
					}
			}

			if($comment_split =~ /(オフ(会)?)(とか|で)?((でき|出来)る人|会(えない|いたい|おう))/){ $deai_alert_flag = qq(聞き出し); $deai_word .= qq( $&); }
			if($comment_split =~ /(文通)(しよう)/){ $deai_alert_flag = qq(聞き出し); $deai_word .= qq( $&); }

	}

	# 情報の聞き出しエラー
	if($hearing_error_flag){
		$alert_flag = "聞き出し - $hearing_word ";
		$alert_message .= qq(▼他の人に住所などを聞こうとしていませんか？ ( $hearing_word ) <br$main::xclose>　個人情報の聞き出しはご遠慮ください。<br>);
		$alert_type = qq(個人情報);
	}

	# エラー文を定義
	if($private_error_flag){
		$alert_message .= qq(<a href="${main::guide_url}%B8%C4%BF%CD%BE%F0%CA%F3%A4%F2%BC%E9%A4%ED%A4%A6%A1%AA">▼本名、電話番号、住所（都道府県より詳しいもの）などの個人情報 ( $private_word ) を書き込もうとしていませんか？　個人情報は絶対に掲載しないでください。　後で大変な問題になることがあります。</a><br>);
		$alert_flag = qq($private_error_flag - $private_word);
		$alert_type = qq(個人情報);
	}


	# ●出会い系投稿を禁止
	if($deai_alert_flag){
			if($deai_word){ $deai_word = qq( ($deai_word ) ); }
		$alert_message .= qq(▼「メールアドレスを求める」「会う約束をする」「オフ会を開く」など、出会い系利用をしていませんか？$deai_word<br>);
		$alert_flag = qq(出会い);
		$alert_type = qq(出会い);
	}

	# ●メールアドレスの直接書き込みを禁止 ( 改行されることもあるので、文章全体から判定 )
	if(!$main::allowaddress_mode){

			# 有名プロバイダ
			if($check =~ /
				([\w\.]{5}|\@|☆|★|＠|あっと(まーく)?|(アット|ｱｯﾄ)(マーク)?)
					(
							(ezweb|ｅｚｗｅｂ)|
							(softbank|ソフトバンク|そふとばんく|そふばん|ソフバン)|
							(ヤフー|ＹＡＨＯＯ|やふー)|
							(エーユー|えーゆー|ＡＵ)|
							(ドコモ|どこも|ﾄﾞｺﾓ|docomo|ｄｏｃｏｍｏ)|
							(.{1,15})((メ|ﾒ|め)(ー|ｰ|い|え)(ル|ﾙ|る))
					)
			/xi){
				$address_error_flag = 1;
			}

			# 一般キーワード
			if($check =~ /
				([\w\-\.]{5})(\@|☆|★|＠|(アット|あっと)(マーク|まーく)?)
				([a-zA-Z0-9_\-\.]{3,50})
				(どっと|ドット|ﾄﾞｯﾄ|\.|\.)
			/x){
				$address_error_flag = 1;
			}

			# エラー定義
			if($address_error_flag){
				$error_message .= qq(▼メールアドレスの書き込みは禁止です。<br>);
				$error_flag = qq(メールアドレス);
				Mebius::Echeck::Record("","Address","$comment");
			}

	}


	# エンコード
	if($type =~ /(Shift_jis|Sjis)-to-utf8/){
		Mebius::Encoding::utf8_to_sjis(undef,$alert_message,$error_message,$error_flag,$alert_flag,$comment,$check_flag,$alert_type);
	}

	# Echeck記録用
	if($check_flag){ $main::echeck_oneline = $check_flag; }

	# エラー
	if($error_message){	$main::e_com .= $error_message; }
	# 警告
	if($alert_message){	$main::a_com .= $alert_message; }

	# Echeck記録用
	if($alert_flag){
		push(@main::alert_type,$alert_type);
		Mebius::Echeck::Record("","Private","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}



# リターン
return($error_flag,$alert_flag);


}

#-----------------------------------------------------------
# 文字色のチェック
#-----------------------------------------------------------
sub color_check{

# 宣言
my($use,$color) = @_;

	if($color !~ /^(#)?([0-9a-f]{3})$/) { $color = "#000"; }

	if(!Mebius::Init::Color({ JustyCheck => 1 } , $color  )){
		$color = "#000";
	}

return($color);

}



1;
