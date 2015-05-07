
use strict;
use Mebius::Echeck;
use Mebius::Regist;
use Mebius::Auth;
package Mebius::Regist;
use Mebius::Export;

#-----------------------------------------------------------
# IDとパスワードの新規登録チェック
#-----------------------------------------------------------
sub PasswordCheck{

# 局所化
my($type,$id,$pass,$pass2,$id_minlength,$pass_minlength,$id_maxlength,$pass_maxlength) = @_;

$id = e($id);
$pass = e($pass);
$pass2 = e($pass2);


	# IDの最小/最大文字数
	if(!$id_minlength){ $id_minlength = 3; }
	if(!$id_maxlength){ $id_maxlength = 10; }

	# パスワードの最小/最大文字数
	if(!$pass_minlength){ $pass_minlength = 6; }
	if(!$pass_maxlength){ $pass_maxlength = 20; }

	# IDチェック
	if($type !~ /Not-check-(id|account)/){
		my($id_error_flag) = Mebius::Auth::AccountName(undef,$id);
			if($id_error_flag){ $main::e_com .= $id_error_flag; }
	}

	# パスワードチェックのための処理
	my ($first_word_password) = substr($pass,0,1);
	my ($two_word_password) = substr($pass,0,2);

	# パスワードチェック
	if($pass eq ""){
		$main::e_com .= qq(パスワードを入力してください。<br>);
	}
	elsif(length($pass) < $pass_minlength || length($pass) > $pass_maxlength){
		$main::e_com .= qq(パスワードは半角 $pass_minlength - $pass_maxlength文字 で入力してください。<br>);
	}
	elsif($pass =~ /^(123|abc)/i){
		$main::e_com .= qq(パスワードに [ 123 ] [ abc ] など、単純な組み合わせを使わないでください。<br>);
	}
	elsif($pass =~ /^(\Q$first_word_password\E)+$/){
		$main::e_com .= qq(パスワードに [ 1111 ] など、単純な組み合わせを使わないでください。<br>);
	}
	elsif($pass =~ /^(\Q$two_word_password\E)+$|(\Qtwo_word_password\E){3,}/){
		$main::e_com .= qq(パスワードに [ 1212 ] など、単純な組み合わせを使わないでください。<br>);
	}
	elsif($pass =~ /(pass)/i){
		$main::e_com .= qq(パスワードにこのフレーズ \( $1 \) は使えません。<br>);
	}
	elsif($pass =~ /^(\d{1,6})$/){
		$main::e_com .= qq(数字だけの短い羅列は、パスワードには出来ません。アルファベットや記号を織りまぜてください。<br>);
	}

	# 確認用パスワードのチェック
	if($type !~ /Not-confirm-password/){
			if($pass && $pass2 eq ""){
				$main::e_com .= qq(確認用のパスワードを入力してください。<br>);
			}
			elsif($pass ne $pass2){
				$main::e_com .= qq(パスワードと確認用のパスワードが一致しません。<br>);
			}
	}

	# IDとパスワードが似ている場合
	if($id && $pass && (index($pass,$id) >= 0 || index($id,$pass) >= 0)){
		$main::e_com .= qq(アカウント名とパスワードが似すぎています。<br>); 
	}

	# アカウント名とIDが似ている場合
	my($encid) = main::id();
	if($encid && $pass && (index($pass,$encid) >= 0 || index($encid,$pass) >= 0)){
		$main::e_com .= qq(アカウント名 とID <i>$encid</i> が似すぎています。$encid,$pass<br>); 
	}

	# エラー
	if($type =~ /Error-view/ && $main::e_com){
		main::error("$main::e_com");
	}

return();

}

#-----------------------------------------------------------
# 掲示板の題名チェック
#-----------------------------------------------------------
sub SubjectCheckBBS {

# 宣言
my($type,$subject,$comment,$bbs_concept) = @_;
my($zatudan_flag,$sometime_flag,$alert_flag,$deai_flag);

# 題名エンコード
my($subject_encoded) = Mebius::Encode(undef,$subject);

# 確認先の記事
my $please_find_url = "./?mode=find&amp;word=$subject_encoded";

	# ●出会い系
	if($subject =~ /(彼氏|彼女)(.*)(募集|ほしい|欲しい)/x){ $deai_flag = 1; }
	if($deai_flag){
		$alert_flag = "出会い系";
		$main::a_com .= qq(▼題名チェック - 出会い系として使われやすい記事ではありませんか？　出会い系利用が起こらないよう、十\分にご注意ください。<br>);
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}

	# ●よくある記事
	if($subject =~ /((恋愛)(相談)|恋バナ)/x){
		$sometime_flag = 1;
	}
	if($sometime_flag){
		$alert_flag = "よくある記事";
		$main::a_com .= qq(▼題名チェック - よくある記事 ( $subject ) は重複記事として削除されやすくなります。　既に同じテーマの記事がないかどうか、<a href="$please_find_url">ご確認</a>ください。<br>);
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}

	# ●よくある雑談記事
	if($bbs_concept !~ /ZATUDANN-OK1/){
			if($subject =~ /
				(暇な(人|子|仔))
				|((何)でも)(.*)(話そ|喋ろ)
				|(仲仔)
				|(雑談|ざつだん)
				|(暇人)
				|(おしゃべり)
			/x){ $zatudan_flag = 1; }
	}

	if($zatudan_flag){
		$main::a_com .= qq(▼題名チェック - テーマのない雑談記事 ( $subject ) は、重複記事として削除されやすくなります。　既に「総合雑談系」の記事がないか、<a href="$please_find_url">ご確認</a>ください。<br>);
		$alert_flag = "よくある雑談";
		Mebius::Echeck::Record(undef,"BBS-Subject");
	}


return(undef,$alert_flag);

}




#-------------------------------------------------
# 悪意投稿のチェック
#-------------------------------------------------
	# ★調整のコツ ：
	# １．【よくある言い回し】は文章を１行ずつチェックして一括判定。
	# ２．【無差別荒らし、単純暴言系】はバッドキーワードの量をチェック。
	# ３．【それ以外の投稿】は、文章全体から【キーワード組み合わせ】をチェック。（チェーン投稿判定の時のように）
	# ４．【良い投稿】【仲間内でも使いそうな表現】はポイントを低くするか例外設定を。
	# ５．【多くのサンプル】を集めて改善に努めること。
#-------------------------------------------------
sub EvilCheck{

# 宣言
my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($check2) = ($check);
my($error_flag,$error_border_keyword,$evilnum,$alert_flag,$comment_split,$evilnum_fraze,$evilflag_kajou,$check_oneline,$good_flag);
my($error_type,$error_subject,$alert_subject,$point_view,$check_flag_buf,$alert_border_keyword,$evilnum_light,$evil_word);
my($fraze_check_flag);
my($error_border_fraze,@kajou_word,$alert_border_fraze);
my($badword_keyword,@badword_keyword,@badword_fraze,$badword_fraze,$check_line,$keyword_check_flag,$alert_type);
my($period_num,$i,$error_odds,@delreport_word,$guchi_flag);

	# リターンする場合
	if($concept =~ /NOT-ECHECK/){ return(); }

# チェック用にスペース、改行等を削除
$check =~ s/(\s|　|、|・)//g;

	# 文章量に応じてボーダーラインを上下させる
	if($type =~ /Sousaku/){ $error_odds = 5.0; }
	elsif($category eq "narikiri"){ $error_odds = 3.0; }
	elsif(length($check) <= 25*2){ $error_odds = 0.25; }
	elsif(length($check) <= 50*2){ $error_odds = 0.5; }
	elsif(length($check) >= 500*2){ $error_odds = 1.5; }
	elsif(length($check) >= 1000*2){ $error_odds = 2.0; }
	else{ $error_odds = 1.0; }

	# 最大数を設定 - 一般系
	$error_border_keyword = 5*$error_odds;
	$alert_border_keyword = 3*$error_odds;
	$error_border_fraze = 2*$error_odds;
	$alert_border_fraze = 1*$error_odds;

	# 改行を無視してチェック
	if($check2 =~ /
			(チョン)(.{0,100})(韓国|在日)
			|(韓国|在日)(.{0,100})(チョン)
		/x){

		$evilnum_fraze++;
		$check_oneline = $&;
		$error_subject = " フレーズ（改行無視）";
	}


	# 一定の条件（相談など）では、キーワードの組み合わせチェックをおこなわない
	if($check =~ /相談(でき|出来|したら|したい|させて)|聞いて(ください|下さい)/){ $good_flag = 1; }

	# ●文章を１行ずつ展開してチェック
	if(!$good_flag){

			# 本文を展開
			foreach $comment_split (split(/<br>/,$check2)){

				# 局所化
				my($evil_buf,$warai_flag,$comment_split_omitted);
				my $comment_split_pure = $comment_split;
		
					# ラウンドカウンタ
					if(length($comment_split) >= 2*5){ $i++; }

					# 除外
					if($comment_split =~ /(私|俺|僕)(は|も|なんか)/x){
						next;
					}

					# 引用文は除外
					if($comment_split =~ /^(&gt;|＞)/x){
						next;
					}

				# カッコの中身を除外する
				$comment_split =~ s/(「)(.+?)(」)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(｢)(.+?)(｣)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(『)(.+?)(』)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(“)(.+?)(”)//g;
				$comment_split_omitted .= qq($&);
				$comment_split =~ s/(\s|　|、)//g;


					# 笑いチェック
					if($comment_split =~ /(ぶｗ|ｗｗｗ|www|ﾌﾟｯ|プッ)|(\(|（)(藁|ワラ|ﾜﾗ|笑)|(藁|ワラ|ﾜﾗ|笑)$/){
						$warai_flag = 1;
						$evilnum_fraze += 0.1;
						push(@badword_fraze,$&);
					}


					# ▼キーワード量判定 ( エラーあり )
					if(!$good_flag){
						$evilnum += ($comment_split =~ s/((死|氏|志)(ね|ネ)|クズ|\Q糞\E|クソ|(アホ|阿呆|阿保)|(う|ウ)((ざ|ザ)(い|イ)|(ぜ|\Qゼ\E)(え|ぇ|エ|ェ))([^(なんて)]|$))/$&/g);
						$evilnum += ($comment_split =~ s/((きも|キモ|肝)(い|ぃ|イ|ィ|す|ス)|(ｷﾓｲ)|(き(っ)?め|キメ)(え|ぇ|エ|ェ)(し)?)/$&/g);
						$evilnum += ($comment_split =~ s/(消防|\Q厨房\E|(^|[^星])屑|下種)/$&/g);
						$evilnum += (($comment_split =~ s/(www|ｗｗｗ)/$&/g) * 0.2);
						$evilnum += (($comment_split =~ s/(	\(笑	|	（笑	|	笑$	)/$&/xg) * 0.2);
						$evilnum += (($comment_split =~ s/(	\(怒	|	（怒	|	怒$	)/$&/xg) * 0.5);
						$evil_word .= qq( $1);

					}


					# 愚痴判定
					if($comment_split =~ /※愚痴/x){
						$guchi_flag = 1;
					}

					# お決まりのフレーズ - ( 大ポイント加算 )
					if($comment_split =~ /(
							 (ぶ(っ|ち)殺(す|してや(る|っ)))
							|((いう|言う)(奴|やつ)|かなり) (う|ウ) ((ざ|ザ)(い|イ|っ|ッ)|(ぜ|\Qゼ\E) (え|ぇ|エ|ェ))
							|((そいつ|全員)(死|氏|志)(ね|ネ))
							# マジ◯◯系
							|
								# キーワード１
								(
								(\Qちょー\E|\Qチョー\E|超)|(まじ|まぢ|マジ|マヂ|馬路)(で)?|ほん(っ)?と|めちゃ|メチャ|お(前|まえ)(ら|等)|男子|女子
								|(お((ま|め)(え|ぇ)|前)|あんた|アンタ|貴方|あなた|あんた)
								|((本当|ほんと(う)?|ホント)に|正直)
								|(失せろ)
								|(糞|クソ\)
								
								)
								# キーワード2
								(.{0,15})
								# キーワード3
								(
									(むか|ムカ)(つく|ツク)
									|(きも|キモ|肝)(い|ぃ|イ|ィ|す|ス|くね|w|ｗ)|(ｷﾓｲ)|(き(っ)?め|キメ)(え|ぇ|エ|ェ)
									|(う|ウ)((ざ|ザ)(い|イ|っ|ッ|かった)|(ぜ|\Qゼ\E)(え|ぇ|エ|ェ|\Qー\E))
									|死ね
									|カス|クズ|くず
									|クソ\
									|\Q糞\E
									|(ks|ｋｓ)
									|((気持|きも)ち)((悪|わる)い)
									|(殺した)(い|かった)
									|(ふざけ(ん|る)な)
									|(うける|ウケル)
									|(意味|いみ|イミ)(不|ふ|フ|ぷ)
									|(迷惑|殺す)
								)
							|(\Q糞\E|クソ\)(う|ウ)((ざ|ザ)(い|イ|っ|ッ)|(ぜ|\Qゼ\E)(え|ぇ|エ|ェ))
							|(うける|\Qウケル\E)(んですけど)
							|(る|の)((方|ほう)が)(.{1,5})?(ばか|馬鹿|((気持|きも)ち)((悪|わる)い)|ガキ|餓鬼)
							|(調子|(チョ|ちょ)(\Qー\E|う|ウ)(シ|し))(こくなよ|((乗|の)ってんじゃ)|こいて(る)?んじゃ)
							|(いきがっ(てんじゃ|ちゃっ))
							|(や)(腰抜け)
							|(なめ(て)?(る)?んじゃ)(ね(え|ぇ|\Qー\E))
							|(\Q糞\E|クソ\)(管理|弱い|ばかり|ばっか|男|女)
							# 排他系
							|(さんは|お前は|ガキ|餓鬼)(.{1,20})(来るな|来ないで)
							# ウゼーーーーーー系
							|(UZEEEEEEEEEEE)
							|(^|[^おこそとのほもよろ])(う(っ)?ぜ|\Qウ\E(ッ)?\Qゼ\E)(\Qーー\E|～～|(エ|ェ|え|ぇ){2,})
							|(き(ん)?め|キ(ン)?メ)(エ|ェ|え|ぇ|\Qー\E){2,}
							|((死|氏|志)(ね|ネ)(カス|かす))
							#|(死んでくれ)
							|(^|[^(（])(\Qﾀﾋ\E|\Qタヒ\E)(ね|れ)
							|(頭|あたま|アタマ|脳(味噌)?)(が)?
								((大丈夫|だいじょうぶ)((.{1,20})?(？|\?)|か|ですか|$)|(おかしい|可笑しい|イカレて|いかれて|沸いて|どうかし(て|と)る))
							|(害児)
							|(むか|ムカ)(つく|ツク)(し)?(!|！|(.{0,20})怒)
							# お前～＋系
							|(お前|おまえ|あんた|アンタ|貴方|あなた)(.{1,10})?((邪魔|ジャマ|じゃま)|(頭(おかしい|狂って)))
							|(頭)(おかし(い|ん)|悪すぎ)
							|(あなた|貴方|(お(前|まえ)|てめ(ぇ|え)))(は)(それ以下|アホ|阿呆|阿保)
							|(ゴミ|ごみ|馬鹿|バカ)(は)((お(前|まえ)(ら|等)?)だ)
							|(こそ)((死|氏|し)ね)
							# 同じ単語の、◯回以上の繰り返し
							|((死|し)ね|阿保|阿呆|あほ|キモ|きも|笑|ザコ|雑魚){3}
							|((今|いま)すぐ|そっち(.{1,4})|さっさと|お(めえ|まえ|前)(が)?|まじ)((死|氏|志|し)ね|(消|き)え(ろ|て))
							|((厨|中)二(病)?|ゆとり|知ったか|偽善者|釣り|厨|言い訳)(乙)([^女]|$)
							|(乙)(.{1,5})?(\^\^)
							|(\Q厨房\E)(ども|\Q共\E)(が|め)
							|(クソ\|くそ|糞|クズ)(.{1,10})?(ども|\Q共\E)
							|(人間の)(クズ)
							|(ビッチ)
							|(ばか|馬鹿|雑魚|ザコ)
								(
									(の)(くせ|癖)(に)|
									じゃ(ない|ね(え|ぇ)|ネ(エ|ェ))の(\?|？|！|!|(か)?お(前|まえ|め(ぇ|え)))
								)
							|(自治|削除|粘着)(厨)
							|(キモ|きも)((い|ぃ|イ|ィ)(よ|んだよ|んだけど)|すぎ|過ぎ|杉|w|ｗ)
							# 対象限定系
							|(むか|ムカ)(つく|ツク)(.{1,20})(先生|教師|担任|顧問|邪魔|婆|ばば(あ|ぁ)|ババ(ア|ァ))
							|(先生|教師|担任|顧問|邪魔|婆|ばば(あ|ぁ)|ババ(ア|ァ))(.{1,20})((むか|ムカ)(つく|ツク)|(消えて)|(消えろ)|(死ね))
							# ビックリマーク系
							|(むか|ムカ)(つく|ツク)(!|！)
							# 単語ひとつ系
							|(クソ\|くそ|糞)(じじい|ジジイ|ばばあ|ババア)
							|(きみ|君|お前|おまえ|あなた)(が|は|の(方|ほう)が)(.{1,20})?(ぶす|ブス)
							#
							|(低能\|低脳|低レベル)(な|の|が|だ)
							|(能\|脳)(なし|無し)(な|の|が|だ)
							# あだ名 - 蔑称系
							|(脳((な|無)し|足りん))
							|(うんこ|ウンコ|うんち|ウンチ)(ちゃん|君|クン|くん)
							|(弱虫)(.{1,10})(君|クン)
							|(ザコ|雑魚)(さん)
							|(ババ(ア|ァ)|ばば(あ|ぁ))(が|の|!|！)
							|(生理的に)(無理|ムリ|むり)
							|(激|超)(ザコ|雑魚)
							|(ザコ|雑魚)(が)(!|！)
							|((死|し)にたい(の)?なら)(.{1,10})?((死|し)ね(よ|ば(いい|良い)))
							|(ふざけ(る|ん)な)(.{1,10})?(!|！)
							|(所詮(は|わ)?|(て|み)ろ|ホント|どうせ|ただの)(クズ|カス|ガキ|クソ\)
							|(ゴミ|糞)(.{2,10})?(野郎)
							|(人として)(最低)
							|(正義|ヒロイン|\Qヒーロー\E)(ぶっ(ちゃっ)?て|気取り)
							|(マスゴミ|(ウジ|蛆	)テレビ)	
						# 売り言葉に買い言葉
							|(友達)(いない)(だろ|くせに)
							# 笑いプラス
							|(哀れ|ｋｓ|死ねば(？|\?)?|幼稚だ(ね)?|うける|氏ね|消えろ|ガイジ|カス)(.{1,10})?(ww|ｗｗ)
							|((いき|粋)が(ってんじゃ|っちゃっ|るな))
							|ほざ(いてろ|け(!|！))
							|(黙れ)(こら|コラ)
							|(マジキチ|気違い|基地(外|街)|キチガイ)
							|(先公)
							|(害虫)(だ)
							|((構\|かま)って)(ちゃん)
							|(二度と)((出て)?(く|来)(る|ん)な)
							|(出てけ(よ|や)?)(!|！|ww|ｗｗ)
							|(うざ|ウザ)((過|す)ぎる)
							|(うざ|ウザ)(い|イ)(.{0,20})(!|！|消えろ)
							# 2ちゃんねる用語系
							|(プギャ|ﾌﾟｷﾞｬ)(\Qー\E|-)
							|(テラワロス|\Qクソワロタ\E|\Qﾃﾗﾜﾛｽ\E)
							|(これは(酷|ひど)い)
							|((氏|死|志)(ね)|ググ(れ|レ))(ＫＳ|ｋｓ|カス)
							|(氏ね)(!|！)
							|(釣り)(だろ)
							|(クソ\)(記事|スレ)
							|(ざま(ぁ|あ)|ざっま|ゆとりが)(ww|ｗｗ)
							|(\Qスイーツ\E)(.{1,20})?(笑)
							# 来るな系
							|(スレ|掲示板|ここ)(に)?((来|く)(る|ん)な)
							|(スレ|掲示板|ここ)(から)(消えろ|消えて(く(れ|ん)ない|$)|(出て|でて)(行|い|ゆ)?(け))
							# ギャル系
							|(イミフ|意味不(明)?)(.{1,10})?(なん(で)?すけど)
							# べらんめい系
							|(は|奴(.{1,10})?)((すっこん|引っ込ん)(どけ|でろ))
							|(ぼけ|ボケ)(!!|！！)
							|(笑わ)(せ(る|ん)な)
							|(とっとと)(失せろ|消えろ)
							# 笑い系
							|(幼稚)(.{1,20})?(ww|ｗｗ|笑)
							# いにしえのフレーズ系 ( 議論系？ )
							|(同じ)(穴の)(むじな|狢|貉|ムジナ)
							|(茶番(劇)?)(は)
							|(ご愁傷)(さま|様)
							|(理解)(すれば(\?|？)|出来ませんか)
							|(バカ|馬鹿)(は)(ほっといて|放っといて)
							|(の)(分際で)
							|(小学生|幼稚園(児|生)|幼児)	(でも(分|わ)かる|じゃあるまいし)
							|(あんた|あなた|アナタ|貴方|お前|おまえ|てめ(え|ぇ))(に)(言われる)(筋合)(い)?(は)?(な|無)(い|え)
							|(見苦しい|無知)(にも)((程|ほど)が)(ある|あります)
							|((社会|人間)のゴミ)
							|((幼稚|稚拙)な)(考え|意見)
							|(あまりに)(幼稚|稚拙)
							|(幼稚園で|小学校で|中学校で)(習)(いませんで|わなかった)
							|(幼稚園(児)?|小学生)(レベル)
							|(寝言は)(寝て)(言え|言いなさい)	
							#|(病院)(行|い)(け)
							|(精神科|精神病院)	(.{1,10})?	(	(見|診)てもら | (行|い)(け|こう(ぜ|よ))	)
							|(精神年齢)(.{0,20})(低)
							|(鏡)(見ろ(よ|や))
							|((反吐|ヘド|へど)が)((出|で)(る|そう))
							|(吐き気)(が)?(する)
							|(日本語|句読点|字)(も)(まともに)?((使え|読め)(ない|ね(え|ぇ)))
							|(日本語)(.{1,10})?(勉強したら|読めない)(.{1,10})?(\?|？)
							|(ごきぶり|ゴキブリ|ゆとり|馬鹿)(以下)
							|(ここまで来ると|見て(い)?て)(哀れ)
							|(テメ(エ|ェ)|てめ(え|ぇ)|お(前|まえ|め(え|ぇ)))(が)(.+)(だろうが)
							|(卑怯者|一生(.+)して(な|ろ))(.*)(笑|ww|ｗｗ|藁|ﾜﾗ|ワラ)
							|((屑|クズ)が)([!！。]+)?$
					)/x){
						$evilnum_fraze++;
						$evil_buf = 1;
							push(@badword_fraze,$&);
					}

					# 自虐は除外
					if($comment_split !~ /(僕|ぼく|ボク|俺|おれ|オレ|私|わたし|あたし|(う|ぅ)ち|自分)(さ|って|は)/){
							if($comment_split =~ /
							(ゴミ|ザコ(い|イ)?|雑魚(い|イ)?|(低能\|低脳|最低|最悪|低レベル)(の|な)?|救いよう(の|が)?ない|クソ\)
								(馬鹿|バカ|デブ|野郎|教師|女|男|ヤツ|やつ|奴|人間|アニメ|猿|サル|すぎ|\Q厨房\E)
							/x){
								$evilnum_fraze++;
								$evil_buf = 1;
								push(@badword_fraze,$&);
							}
					}

					# お決まりのフレーズ - ( 中ポイント加算 )
					if($comment_split =~ /(見て(い)?て)(同情する)
						|(ば(～){3,}かっ)
						|(親が)(可哀想|かわいそう)
						|(可哀想|かわいそう)(な)(人|奴|やつ)
						|(きらい|嫌い)(!!|！！)
						|(痛い)(人|奴)
						|((す|過)ぎて)(うける)
					/gx){
						$evilnum_fraze += 0.5;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}


					# お決まりのフレーズ - ( 低ポイント加算 )
					if($comment_split =~ /
						(は(あ|ぁ)(\?|？))
					/x){
						$evilnum_fraze += 0.2;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}


					# 犯罪フレーズ
					if($comment_split =~ /(レイプ)(してやる)/){
						$evilnum_fraze += 2;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# 空白ありのキーワード
					if($comment_split_pure =~ /(ふ　ざ　け　る　な)/){
						$evilnum_fraze++;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# １行の中で【このフレーズだけ】が使われている場合
					if($comment_split =~ /^
						(
							((し|死|氏|志)ね)
							|((きも|キモ|肝)(い|ぃ|イ|ィ|す|ス)|(ｷﾓｲ)|(き(っ)?め|キメ)(え|ぇ|エ|ェ)(し)?)
							|((う|ウ) ((ざ|ザ)(い|イ|っ|ッ)|(ぜ|\Qゼ\E) (え|ぇ|エ|ェ)))
						)
						([。|!|！]+)?$/x){
						$evilnum_fraze++;
						$evil_buf = 1;
						push(@badword_fraze,$&);
					}

					# ★過剰反応
					if($comment_split =~ /
						(荒(ら)?(し|す))	(.{0,10})	(帰(って|れ)|お帰り(くだ|下)さい|最低|[^出]来るな|(来|こ)ないで|(や|辞|止)め(て|ろ|なさい))
						|(荒(ら)?(し|す)) (.{0,10})? (来ないで)
						|(お前|君|あなた|貴方)(が|も|は)(荒らし)
						|(荒らしは)		(	(お前|君|あなた|貴方)	|	(	(.{1,10})(かま)(って)((ほ|欲)しいだけ)	)	)
						|(.+)(は)(荒らし(だ|です))
						|(自演)(.{1,10})?(ばれ|バレ)
					/x){
						$evilflag_kajou = $evil_buf = 1;
						push(@kajou_word,"$&");

					}

					# ★「削除依頼出しました」の判定
					if($comment_split =~ /(削除依頼)	(.{1,4})?	((出|だ)?(し)(ておき|とき)?(ます|ました|とく))/x){
						push(@delreport_word,$&);
					}

					# 該当行を記憶
					if($evil_buf){
							$check_oneline = $comment_split;
							$error_subject = " フレーズ（１行毎）";
					}

			}

	}


	# Echeck記録用
	if($check_oneline){ $main::echeck_oneline = $check_oneline; }

	# バッドワードを展開
	foreach(@badword_keyword){
		if($badword_keyword){ $badword_keyword .= qq( / $_); }
		else{ $badword_keyword .= qq($_); }
	}

	# バッドワードを展開
	foreach(@badword_fraze){
		if($badword_fraze){ $badword_fraze .= qq( / $_); }
		else{ $badword_fraze .= qq($_); }
	}
	if($badword_fraze){ $badword_fraze = qq( ( <em>$badword_fraze</em> ) ); }

	# ●キーワード量で判定 (エラー)
	if($evilnum >= $error_border_keyword && !$error_flag){
		$main::e_com .= qq(▼不適切な単語が多いため書き込めません。<strong>表\現方法</strong>には十\分ご配慮ください。 ( 現在 $evilnum_light pt / 最大 $alert_border_keyword pt )<br>);
		$error_flag = 1;
		$error_subject = qq(不適切-キーワード量);
		$keyword_check_flag = "error";
	}

	# ●フレーズでのエラー判定
	if($type !~ /Sousaku/ && $evilnum_fraze >= $error_border_fraze && !$error_flag){
		$main::e_com .= qq(▼不適切な表\現が多いため、書き込めません。<br>);
		$error_flag = 1;
		$fraze_check_flag = "error";
	}

	# キーワード量でのアラート判定
	if($evilnum >= $alert_border_keyword && !$error_flag && !$alert_flag){
		$main::a_com .= qq(▼不適切な表\現$evil_wordが多くありませんか？　投稿マナーには十\分ご配慮ください。 ( 現在 $evilnum_light pt )<br>);
		$alert_flag = 1;
		$keyword_check_flag = "alert";
		$alert_subject = qq(不適切-キーワード量);
	}


	# ●フレーズでのアラート判定
	if($type !~ /Sousaku/ && $evilnum_fraze >= $alert_border_fraze && !$error_flag && !$alert_flag){
		$main::a_com .= qq(▼文章中に、マナーを欠いた表\現$badword_frazeはありませんか？<br$main::xclose>　　<span style="color:#f00;">発言内容には\十\分ご配慮ください。 </span> ( $evilnum_fraze / $alert_border_fraze )<br>);
		$alert_flag = 1;
		$alert_subject = qq(不適切-フレーズ);
		$fraze_check_flag = "alert";
	}

	# ●過剰反応へのアラート判定
	if($evilflag_kajou){
		my($kajou_word);
			foreach(@kajou_word){
				if($kajou_word){ $kajou_word .= qq( / $_); }
				else{ $kajou_word .= qq($_); }
			}
			if($kajou_word){ $kajou_word = qq( ( $kajou_word ) ); }
		$main::a_com .= qq(▼「荒らし」や「ルール違反」に、反応を返していませんか？　 $kajou_word <br$main::xclose>　荒らしには<strong>一切反応せず</strong>、<a href="$main::delete_url">削除依頼</a>をしたり、普段どおりの書き込みを続けてください。<br>);
		$alert_subject = qq(過剰反応);
		$alert_flag = 1;
	}

	# 削除依頼出しました～へのアラート判定
	if(@delreport_word >= 1 && $category ne "mebi"){
		my($delreport_word);
			foreach(@delreport_word){
				if($delreport_word){ $delreport_word .= qq( / $_); }
				else{ $delreport_word .= qq($_); }
			}
			if($delreport_word){ $delreport_word = qq( ( $delreport_word ) ); }
		$main::a_com .= qq(▼ここで$delreport_wordと書き込むことは、本当に適切ですか？　<strong>煽り/逆効果</strong>になりそうな場合はご遠慮ください。<br$main::xclose>);
		$alert_subject = qq(削除依頼);
		$alert_flag = 1;
	}

	# 愚痴へのアラート判定
	if($guchi_flag){
		$main::a_com .= qq(▼愚痴(グチ)を書きたい場合は、普段より投稿マナーに注意してください。　たとえば<strong>「うざい」「死ね」</strong>などの\暴\言はご遠慮ください。<br>);
		$alert_subject = qq(愚痴注意);
		$alert_flag = 1;
	}

	# Echeck確認用の表示 ( 未使用 )
	if($type =~ /Check-mode/){

		# 局所化
		my($badword_error,$badword_alert);
		my $badword_all = $badword_fraze;

		# 整数に整形
		($evilnum,$evilnum_light,$evilnum_fraze)
			= Mebius::DefineNumber(undef,$evilnum,$evilnum_light,$evilnum_fraze);

			# ▼キーワード量
			if($keyword_check_flag eq "error"){
				$check_line .= qq(<strong class="red">$evilnum</strong>);
			}
			elsif($keyword_check_flag eq "alert"){
				$check_line .= qq(<strong class="green">$evilnum_light</strong>);
			}
			else{
				$check_line .= qq($evilnum);
			}
		$check_line .= qq( / $alert_border_keyword / $error_border_keyword ( num )<br$main::xclose>\n);


			# ▼フレーズ
			if($fraze_check_flag eq "error"){
				$check_line .= qq(<strong class="red">$evilnum_fraze</strong>);
			}
			elsif($fraze_check_flag eq "alert"){
				$check_line .= qq(<strong class="green">$evilnum_fraze</strong>);
			}
			else{
				$check_line .= qq($evilnum_fraze);
			}
		$check_line .= qq( / $alert_border_fraze / $error_border_fraze ( fraze )<br$main::xclose>\n);

			# エラー題名の整形
			if($error_flag){
				$error_flag = qq(<div><strong style="color:#f00;">●$error_subject<br$main::xclose><br$main::xclose>$check_oneline</strong><br$main::xclose><br$main::xclose>$badword_all</div><br$main::xclose><br$main::xclose>\n);

			}

			# アラート題名の整形
			elsif($alert_flag){
				$alert_flag = qq(<div><strong style="color:#080;">◯$alert_subject<br$main::xclose><br$main::xclose>$check_oneline<br$main::xclose><br$main::xclose>$badword_all</strong></div>\n);
			}

	}

	# 印用
	if($alert_flag){
		push(@main::alert_type,"マナー/リアクション");
	}

	# ●Echeckの記録
	if($error_flag){
		Mebius::Echeck::Record("","Evil","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}
	elsif($alert_flag){
		Mebius::Echeck::Record("","Evil","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}

# リターン
return($error_flag,$alert_flag,$check_line);

}


#-----------------------------------------------------------
# 雑談化チェック
#-----------------------------------------------------------
sub ConvesationCheck{

# 宣言
my($type,$comment) = @_;
my($error_flag,$alert_flag,$bad_word,$alert_border);

# コメントの全長を取得
my $comment_length = Mebius::GetLength(undef,$comment);

	# ボーダー設定
	if($comment_length >= 250){ $alert_border = 3; }
	elsif($comment_length >= 75){ $alert_border = 2; }
	elsif($comment_length >= 25){ $alert_border = 1; }
	else{ $alert_border = 0.5; }

	# 本文を展開
	foreach(split(/<br>/,$comment)){

			# 雑談化判定
			if($comment_length < 1000){

					if($_ =~ /
						(自己紹介)(.{1,10})?(です|します)
						|(いま|今)(暇|ひま|いる)
						|(ご飯|ごはん)(だった|食べてた)
						|(暇|一緒に|いっしょに)(.{1,20})?((話|はな)そ)
						|(友達|仲子)(に)(なって)
						|(何て|なんて|どんな(風|ふう)に)(呼(べば|んだら))
						|(って)((呼|よ)んでも)((ｏ|o|O|Ｏ|お)(\.|．)?(k|K|Ｋ|ｋ)| (良い|いい)(.{1,10})?(\?|？))
						|(って|気軽に|好きな(よう|風)に)(.{1,20})?((呼|よ)んで)(下さい|ください)
						# 勉強系
						|(テスト)(.{1,20})?(勉強)
						|(国語|算数|数学|理科|社会|歴史|体育|家庭科|英語)(.{1,20})?(問題|テスト|得意|苦手|最悪|問題|科目)
						|(苦手|得意)(.{1,10})?(科目)

						|(昨日|今日|明日|先週|今週|来週|もう少しで|(月|火|水|木|金|土|日)曜)(.{1,20})?
							(入学式|始業式|終業式|試験|身体測定|席替え|修学旅行|\Q運動会\E|学校)

						|(入学式|始業式|終業式|試験|身体測定|席替え|修学旅行|運動会|学校)(.{1,20})?
							(帰って|昨日|今日|明日|先週|今週|来週|(月|火|水|木|金|土|日)曜)

						|(勉強|受験|部活|テスト)(.{1,20})?(頑張って|がんばって|大変|点数|忙し)
						|(入って|はいって)(ええ|良い|いい)(.{1,20})?(\?|？)
						|(これから|(今|いま)(から)?)(.{1,10})?(御飯|ご飯|ごはん|ゴハン|(お)?風呂|用事|部活|塾|学校)
						|(ご飯|ごはん|ゴハン|(お)?風呂|用事|部活|塾)(.{1,20})?((行|い)ってきま(\Qー\E|～)+?す|落ち)
						# 日常の用事系
						|(ご飯|ごはん|ゴハン|(お)?風呂|宿題)(.{1,20})?(落ち)
						|(お風呂)(.{1,20})?((入|はい)って)((く|来)る|(き|来)ます)
						|(時|分)((く|ぐ)(ら)(い|ぃ)|位)(.{1,20})?(落ち)
						|(時)(になったら)(落ち)
						|(もう|早く)(寝)(る|よ|ま(\Qー\E|～)?す)
						|(いつ)(寝る|ねる)(.{1,10})?(\?|？)
						|(塾)(が)?(ある)
						# 住所など聞き出し系
						|(何県に|(何処|どこ)に)()(.{1,20})?(住んで)
							(ますか|(る)(.{1,10})?(\?|？))
						|(受験)(.{1,10})?(です|終わっ(て|た))
						|(パソ\コン|PC|ＰＣ)(の)(調子)
						|(小(一|ニ|三|四|五|六|１|２|３|４|５|６)|(中|高)(一|ニ|三|１|２|３))(に)(なる)
						|(僕|ぼく|ボク|俺|おれ|オレ|私|わたし|あたし|アタシ|ワタシ|うち|ウチ)
							(
								 (も|は|わ|ゎ)(.{1,20})?(塾|卒業)
								|(も|は|わ|ゎ)(.{1,20})?(小(学)? (一|ニ|三|四|五|六|１|２|３|４|５|６|1|2|3|4|5|6) |(中(学)?|高(校)?)(一|ニ|三|１|２|３|1|2|3)|(月生まれ))
								|(も)(入れて)
								|(の(こと|事))((覚|おぼ)えて)
								|(の)(学校)
								|(.{1,20})?(住み|(に)(住んで))
								|(.{1,10})?(歳|才)
							)
						|(春から|まだ)(小(学)? (一|ニ|三|四|五|六|１|２|３|４|５|６) |(中(学)?|高(校)?)(一|ニ|三|１|２|３))
						|(って)(何歳|何才|中学生|小学生)
						|(友達|仲子)(.{1,10})?(なりませんか)
						|(もう(すぐ)?|いったん|一旦)(落ち)
						/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}

			}
#				|(受験|入学式)

			# 短文の場合 ( A )
			if($comment_length < 1000){
					if($_ =~ /
						# 自己紹介系
						(自己紹介)
						|(呼び(\Qタメ\E|ため|捨て))
						|(\Qタメ\E|ﾀﾒ|ため)(.{1,10})?((ｏ|o|O|Ｏ|お)(\.|．)?(k|K|Ｋ|ｋ)| (良い|いい)(.{1,10})?(\?|？))
						|(\Qタメ\E)(語|あり)
						|((友|とも)(達|だち)|友に)(なり(ませんか|たい)|なろ(う|ぅ|ぉ))
						|(僕|ぼく|ボク|俺|おれ|オレ|私|わたし|あたし|アタシ|ワタシ|うち|ウチ)(.{1,10})?(年上|年下)
						# 待ち合わせ系
						|(午後|午前|((.{1,4})時(.{1,4})分) ) (.{1,20})? (に) (.{1,20})? (来ます|来る(ね|って))
						|(また)(明日|あした|(来|き)(ます))
						|(はやく|早く)(きて|来て)
						# 勉強
						|(そろそろ|次)(.{1,20})?((中間|期末|実力)テスト)
						# チャット語系
						|(落ち)(ま(\Qー\E|～)?す|(る(ね|ネ))|ww|ｗｗ|$)
						|(落ち)(了解)
						|((誰|だれ)か)(.{1,10})?(相手して|話そ|はなそ| (い|居)(ますか|ませんか|ないの|ないか) | (いる)(.{1,10})?(\?|？) )
						|(いたら|いろいろ|色々)(話そ|絡も|はなそ)
						|((い|居)(たら|るなら))(.{1,10})?(書き込み|返事)
						|(いってら)
						|(暇|ひま)(なん|だ|～)
						|(夜)(来(ら)?れる)(.{1,10})?(\?|？)
						|((何|なん)の)(話)(する)
						|(何|なに)((話|はな)す)
						#|(いるよ)(～)
						
						|(タメ口|呼び捨て)
						|(ばいばい|バイバイ)
						|(また)(.{1,10})?((はな|話)そ(う|お|ぅ|ぉ))
						|^(いるよ)
						|(うつの|打つの)(.{1,10})?(遅)(い|くて)
						# 呼び系
						|(って) (呼) (んでね|びます|ぶ(事|こと)に)
						# 他
						|(金貨)(.{1,20})?(プラス|マイナス|じゃま|邪魔)
							/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}
			}

			# 超短文の場合 ( B )
			if($comment_length < 100){
					# 1.0ポイント加算
					if($_ =~ /(

						 ((い|居)る？)(.{1,20})?((い|居)たら)

						|(ALL)
						|(おやすみ)
						|(はな|話)(そ)
						|(仲良く)(しましょ|しよ)
						|(話)(しましょ|しよう)
						|(喋|しゃべ|語|かた)(ろう|ろぉ|りましょ)

						|(誰か)(来て)
						|(何歳|何才)(ですか|っすか)
						|(会いたかった)
							)/x){
							$alert_flag++;
							$bad_word .= qq( $&);
					}
					# 0.5ポイント加算
					if($_ =~ /(
						 (久|ひさ)しぶり
						#|(よろ|宜)(しく)
						|(こんばん(は|わ|ゎ))
						|(こんにち(は|わ|ゎ))
						|((はじめ|はぢめ|初め|始め)まして)
							)/x){
							$alert_flag += 0.5;
							$bad_word .= qq( $&);
					}
			}



	}

	# ●Echeckの記録
	#if($error_flag){
	#	$main::e_com .= qq();
	#	Mebius::Echeck::Record("","Convesation","$comment");
	#	Mebius::Echeck::Record("","All-error","$comment");
	#}
	#els

	# アラート判定
	if($alert_flag >= $alert_border){
		push(@main::alert_type,"チャット化/雑談化");
		$alert_flag = qq(チャット化/雑談化 \($bad_word\));
		# ( $bad_word )
		$main::a_com .= qq(▼書き込みが雑談化/チャット化していませんか？<br>\n);
		$main::a_com .= qq(　掲示板/記事のテーマに合った投稿をしてください。<br>\n);
		$main::a_com .= qq(　違反が多い記事は削除/ロックさせていただく場合があります。<br>\n);
		$main::a_com .= qq(　雑談をする場合は<a href="http://mb2.jp/_ztd/">自由掲示板</a>など、雑談系のコンテンツをご利用ください。<br>\n);
		Mebius::Echeck::Record("","Convesation","$comment");
		Mebius::Echeck::Record("","All-alert","$comment");
	}
	else{
		$alert_flag = 0;
	}



return($error_flag,$alert_flag);

}


#-------------------------------------------------
#  チェーン投稿の判定
#-------------------------------------------------
sub ChainCheck{

# 宣言
my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($chain,$kasho_flag,$hari,$error_flag);
my($bad_word,$chain_flag);

# チェックのために空白を削除 
$check =~ s/( |　|<br>)//g;

#り付け(たら|ると|て(くだ|下)さい) | 

	# 判定
	if($check =~ /
	(
		 (箇|ヶ|ヵ|ケ|か|カ|個)所
		|((違う|別の|他の|ほかの|どこかの)|([0-9]|１|２|３|４|５|６|７|８|９|１０|二|三|四|五|六|七|八|九|十\|？) (つの|回|個の))
			(板|掲示板|スレ|ｽﾚに|レスに|ところ)
	)
	(.{1,20})?
	(
		 (張|貼\|は) (り(つ|付)け |ると|らないと|らなければ|れば|るだけ|ってね|ってみ|ったら|る(こと|事)) | 写(したら|せば)

		|((書き(こ|込)(んで|む))|(書いて(くだ|下))|(置(くと|いたら)))
				(.{1,100})?
					(告白され|告られ|両(想|思)い|キセキが)

		|(書き込まなかった)
				(.{1,100})?
					(死に)


	)
	/x){
		$chain_flag = 1;
		$bad_word .= qq( $&); 
	}

	# 判定
	if($check =~ /
		 (紙と(、)?ペンを(、)?(用意して|ご用意ください))
		|(ペンと(、)?紙を(、)?(用意して|ご用意ください))
		|(この)(文|書き込み|レス)(を)(見た)(人|あなた|貴方)(.{1,20})?(幸せ|\Q幸運\E)
		|(これを)(見た)(人|あなた|貴方)(.{1,20})?(幸せ)(.{1,20})?(以内に)
		|(\Qコピー\E|コピペ)
			(
				 (したら)(.{1,20})?(アドレス)(.{1,10})?((出|で)て)((き|来)(ます)|(く|来)(るよ))
				|(して)((回|まわ)して)
			)

		|(\Qコピー\E|コピペ|コピって)(.{1,10})?(は|張|貼\)(ると|って)(.{1,40})?(動画|画像|願い|アドレス)
		| (張|貼\|は) (り(つ|付)け)(.{1,20})?((まわ|回)して)((くだ|下)さい)
		|((箇|ヶ|ヵ|ケ|か|カ)所)(.{1,20})?(\Qコピー\E|コピペ)(したら)(.{1,10})?((出|で)て((き|来)(ます)|(く|来)(るよ)))
		|((箇|ヶ|ヵ|ケ|か|カ)所)(.{1,20})?(心理(テスト|ﾃｽﾄ))(.{1,20})?(は|張|貼\)(る|って)
		|(心理(テスト|ﾃｽﾄ))(.{1,20})?((箇|ヶ|ヵ|ケ|か|カ)所)(.{1,20})?(は|張|貼\)(る|って)

		|(\d)(回)((は|張|貼\)ると)(.{1,20})?(両思い|両想い)
		|(\Qアメリカのゲームです\E)
		|(３番に書いた人は貴方の)
		|(クリック|ｸﾘｯｸ)(できる|出来る)(ように)(.{1,20})?(【|】|\[|\])
		|(【|】|\[|\])(.{1,20})?(クリック|ｸﾘｯｸ)(できる|出来る)(ように)
	/x){
		$chain_flag = 1;
		$bad_word .= qq( $&); 
	}

	# ▼一段チェック（～箇所に）
	#if($comment_split =~ /(時間|日|週間)(以内)に/){ $bad_word .= qq( $&); }
	#elsif($comment_split =~ /(コピペ|\Qコピー\E)(して|したら|って)/){ $bad_word .= qq( $&); }


	# チェックＢ
	#if($comment_split =~ /(まわして|回して)ください/){ $chain_flag = 1; $bad_word .= qq( $&); }
	#if($comment_split =~ /(アドレス)(.{1,20})?(出て)(きます|来ます)/){ $chain_flag = 1; $bad_word .= qq( $&); }


			# 「コピー」のキーワードを二重判定しない

	# エラー定義
	if($chain_flag){
		$main::e_com .= qq(▼<a href="$main::guide_url%A5%C1%A5%A7%A1%BC%A5%F3%C5%EA%B9%C6">チェーン投稿は書き込めません。</a><br>
		　次々とコピーされる書き込みは、迷惑となりますのでご遠慮ください。<br>); 
		$error_flag = qq($bad_word);
		Mebius::Echeck::Record("","Chain");
		Mebius::Echeck::Record("","All-error");
	}

# リターン
return($error_flag);

}




#-----------------------------------------------------------
# オーバーフローチェック
#-----------------------------------------------------------
sub OverFlowCheck{

# 宣言
my($type,$text) = @_;
my($comment_split,$i_comment);

	# 容量オーバー
	my $max_length = 2*10000;
	my($text_length) = length($text);
	if($text_length > $max_length){
			if($type !~ /Echeck-view/){
				Mebius::AccessLog(undef,"Regist-over-flow","大きすぎる投稿データ: $text_lengthバイト / $text");
				Mebius::Echeck::Record("","Over-flow");
			}
		main::error("投稿データが大きすぎます。$text_lengthバイト / $max_lengthバイト");
	}

	# 長すぎる１行がある場合、ここですぐエラーに
	my $max_length_split = 2*2000;
	foreach $comment_split (split(/<br>/,$text)){
		$i_comment++;
		my($comment_split_length) = length($comment_split);
			if($comment_split_length > $max_length_split){
					if($type =~ /Echeck-view/){
					}
					else{
						Mebius::AccessLog(undef,"Regist-over-flow-line","１行が長すぎる投稿: $comment_split_lengthバイト / $comment_split");
						Mebius::Echeck::Record("","Over-flow");
						main::error("１行が長すぎます。適度に改行してください。 ( $i_comment行目 ： $comment_split_lengthバイト / $max_length_splitバイト )");
					}
			}
	}

return();

}


1;
