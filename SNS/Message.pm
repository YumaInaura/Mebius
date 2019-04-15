
use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# 共通の設定
#-----------------------------------------------------------
sub InitMessage{

my(%init);

# メッセージ１通あたりの最大文字数
$init{'max_length_message'} = 5000;

# メッセージ１通あたりの最大文字数 ( 題名 )
$init{'max_length_subject'} = 50;

# １日あたりのメッセージ最大送信数
$init{'max_message_perday'} = 50;

# 送信 / 受信別の帯の色
$init{'send_color_style'} = "background:#fee;border-color:#f99;";
$init{'catch_color_style'} = "background:#eef;border-color:#99f;";

# 管理者として認識するレベル
if($main::myadmin_flag >= 5){ $init{'admin_flag'} = 1; }


return(%init);

}

#-----------------------------------------------------------
# アカウント状態のチェック
#-----------------------------------------------------------
sub LevelCheckMessage{

# 宣言
my($type,%account,$enemy_account) = @_;
my($error_message);

	# 相手と自分のキーチェック
	if(!$account{'justy_flag'}){ $error_message = qq($account{'name_link'} さんには現在、メッセージを送信できません。); }

	# 送信/受信権限がない場合
	elsif(!$account{'allow_message_flag'}){ $error_message = qq($account{'name_link'} さんには現在、メッセージフォームを使える権限がありません。); }

	# エラーをすぐ表示する場合	
	if($type =~ /Error-view/ && $error_message && !$main::myadmin_flag){
		main::error("$error_message");
	}

return($error_message);

}

#-------------------------------------------------
# 処理をスタート
#-------------------------------------------------
sub MessageFormStart{

	# モバイル判定
	if($main::device_type eq "mobile"){
		main::kget_items();
	}

	# タイトル定義
	$main::sub_title = qq(メッセージ | $main::title);
		if($main::myaccount{'file'}){
			$main::head_link3 = qq(&gt; <a href="${main::auth_url}$main::in{'account'}/?mode=message">メッセージ</a>);
		}


	# モード振り分け
	if($main::in{'account'} eq ""){ &MessageHistoryAllMemberView(undef); }
	elsif($main::in{'type'} eq "send_message"){ &SendMessage(undef,$main::in{'to'}); }
	elsif($main::in{'type'} eq "control_message"){ &ControlMessage(undef,$main::in{'account'}); }
	elsif($main::in{'type'} eq "view"){ &MessageView("Message-view",$main::in{'account'},$main::in{'message_id'}); }
	elsif($main::in{'type'} eq "history"){ &MessageHistoryAccountView(undef,$main::in{'account'},$main::in{'account2'}); }
	elsif($main::in{'type'} eq "" && $main::in{'to'}){ &MessageView("Brand-new-form",$main::in{'account'}); }
	elsif($main::in{'type'} eq "box" || $main::in{'type'} eq ""){ &MessageBoxView(undef,$main::in{'account'}); }
	else{ main::error("このモードは存在しません。"); }

exit;

}

#-----------------------------------------------------------
# メッセージ単体の閲覧 ＆ 送信フォーム
#-----------------------------------------------------------
sub MessageView{

# 宣言
my($type,$message_account,$message_id,$error_message) = @_;
my(%init) = &InitMessage();
my($line,%to_account,%message_account,%message,$first_input_subject,$first_input_textarea);
my($first_input_to_account,$form,$not_useform_message,%box,$plustype_check_friend_to,$plustype_check_friend_from);

# CSS定義
$main::css_text .= qq(
textarea.message{width:100%;height:200px;}
td.message{vertical-align:top;}
div.not_useform{padding:1em;margin:1em 0em;background:#dee;}
div.error_message{padding:0.5em 1em;background:#fee;margin:1.0em;}
div.alert_box{padding:1em;border:solid 1px #f00;margin:1em 5%;}
div.message_handle{margin-bottom:2em;}
);

	# 自分の権限チェック
	my($error_mylevel) = &LevelCheckMessage(undef,%main::myaccount);
	$not_useform_message .= $error_mylevel;

	# 最大送信数の制限
	if($main::myaccount{'today_send_message_num'} > $main::myaccount{'maxsend_message'}){
		$not_useform_message .= qq(今日の最大送信数を超えています、明日まで待ってください。);
	}

	# 自分宛のメッセージではない場合
	# ★★注意！★★ ( 他人にメッセージを閲覧されないように 【必ずこの時点でエラーにすること】)
	if($message_account ne $main::myaccount{'file'}){
			if($init{'admin_flag'}){ $not_useform_message .= qq(あなたのメッセージボックスではありません。); }
			else{ main::error("あなたのメッセージボックスではありません。"); }
	}

	# 送信者のアカウントを開く
	(%message_account) = Mebius::Auth::File("File-check-error Option",$message_account);

	# すべてのボックスのリンクを取得
	my($select_box_links) = &MessageBoxAllLinks("",$message_account);

	# ●新規送信フィーム
	if($type =~ /Brand-new-form/){

		# アクセス制限
		main::axscheck("Login-check");

		# 宛先を定義
		(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$main::in{'to'});

		# ヘッダリンクを定義
		$main::head_link4 .= qq(&gt; 新規送信);

	}

	# ● メッセージを閲覧する場合
	if($type =~ /Message-view/){

			# 自分のメッセージボックスではない場合
			if($main::myaccount{'file'} ne $message_account){
					if($init{'admin_flag'}){ }
					else{ main::error("あなたのメッセージではありません。"); }
			}

		# メッセージデータを取得
		(%message) = &MessageFile("Get-hash File-check-error Open-message",$message_account,$message_id);

		# 所属するメッセージボックスを取得
		(%box) = &MessageBox("Get-hash-only",$message_account,$message{'boxtype'});

		# ヘッダリンクを定義
		$main::head_link4 .= qq(&gt; <a href="./?mode=message&amp;boxtype=$message{'boxtype'}">$box{'title'}</a>);
		$main::head_link5 .= qq(&gt; $message{'subject'});

			# 各種エラー
			if($message{'deleted_flag'}){
					if($init{'admin_flag'}){ $not_useform_message .= qq(このメッセージは削除済みです。); }
					else{ main::error("このメッセージは削除済みです。"); }
			}

		# 自分に送信したメッセージの場合は、送信フォームを表示しない
		if($message{'from_account'} eq $main::in{'account'}){ 
			$not_useform_message .= qq(自分が送信したメッセージです。);
		}

		# 相手のアカウントを取得
		(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$message{'from_account'});

	}

	# 自分がマイメビのみに送信を許可している場合
	if($main::myaccount{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_from .= qq( Friend-check);
	}
	# 相手がマイメビのみに送信を許可している場合
	if($to_account{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_to .= qq( Friend-check);
	}


# お互いの禁止設定をチェック
my($deny_flag1,$deny_message1) = Mebius::Auth::FriendStatus("Check-status Deny-check $plustype_check_friend_from",$message_account,$to_account{'file'});
$not_useform_message .= $deny_message1;
my($deny_flag2,$deny_message2) = Mebius::Auth::FriendStatus("Check-status Deny-check $plustype_check_friend_to",$to_account{'file'},$message_account);
$not_useform_message .= $deny_message2;

# 年齢差チェック
#my($error_age_gyap) = Mebius::Auth::AgeGyap("Allow-together-adult",$to_account{'age'},$main::myaccount{'age'},1);
#$not_useform_message .= $error_age_gyap;

# 相手の権限チェック
my($error_enemy_level) = &LevelCheckMessage(undef,%to_account);
$not_useform_message .= $error_enemy_level;

	# 自分がログインしていない場合 ( エラーメッセージ書き換え )
	if(!$main::myaccount{'file'}){
		$not_useform_message = qq(メッセージ機\能\を使うには<a href="${main::auth_url}?backurl=$main::selfurl_enc">ログイン</a>してください。);
	}

	# フォームの初期入力
	# 題名
	if($main::ch{'subject'}){ $first_input_subject = $main::in{'subject'}; }
	elsif($type =~ /Message-view/){
			if($message{'subject'} =~ /^Re:/){
				$first_input_subject = qq($message{'subject'});
			}
			else{
				$first_input_subject = qq(Re: $message{'subject'});
			}
	}
	if($first_input_subject eq "" && $main::postflag){ $first_input_subject = "(無題)"; }
	# 宛先
	if($main::in{'to'}){ $first_input_to_account = $main::in{'to'}; }
	elsif($type =~ /Message-view/){ $first_input_to_account = qq($message{'from_account'}); }

	# 本文
	if($main::postflag){
		$first_input_textarea = $main::in{'comment'};
		$first_input_textarea =~ s/<br>/\n/g;
	}

	# HTMLの定義
	if($type =~ /Message-view/){

		# 自動リンク
		my($view_message) = Mebius::auto_link($message{'message'});

		$line .= qq(<h1$main::kstyle_h1>$message{'subject'}</h1>\n);
		$line .= qq($select_box_links);
		#$line .= qq(<h2$main::kstyle_h2>宛先</h2>\n);
			if($message{'boxtype'} eq "send"){ $line .= qq(<h2 style="$init{'send_color_style'}$main::kstyle_h2_in">送信</h2>\n); }
			else{ $line .= qq(<h2 style="$init{'catch_color_style'}$main::kstyle_h2_in">受信</h2>\n); }

		$line .= qq(<div class="message_handle">);
		$line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
		#$line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);

			if($message{'from_account'} eq $message_account){ $line .= qq( ( <a href="./?mode=message&amp;type=history&amp;account2=$message{'to_account'}">履歴</a> ) ); }
			else{ $line .= qq( ( <a href="./?mode=message&amp;type=history&amp;account2=$message{'from_account'}">履歴</a> ) ); }

		$line .= qq(</div>\n);
		$line .= qq(<div class="line-height">$view_message</div>\n);
		$line .= qq(<div class="right">$message{'senddate'}</div>\n);

	}
	elsif($type =~ /Brand-new-form/){
		$line .= qq(<h1$main::kstyle_h1>メッセージの送信</h1>\n);
		$line .= qq($select_box_links);
		$line .= qq(<h2$main::kstyle_h2>新規送信</h2>\n);
		$line .= qq($to_account{'name_link'} さんに非公開のメッセージを送ります。\n);
	}


	# プレビュー暫定処置
	if($ENV{'REQUEST_METHOD'} eq "POST" && $main::in{'comment'}){
		$form .= qq(<h2$main::kstyle_h2>プレビュー</h2>);
		$form .= qq(<section>);
		my($preview) = Mebius::auto_link($main::in{'comment'});
		$form .= qq($preview);
		$form .= qq(</section>);
	}

# フォーム始まり
$form .= qq(<h2$main::kstyle_h2>送信フォーム</h2>\n);

	# エラーメッセージ
	if($error_message){
		$form .= qq(<div style="color:#f00;" class="error_message">エラー： $error_message</div>\n);
	}


$form .= qq(<form action="./" method="post"$main::sikibetu>\n);
$form .= qq(<div>\n);
$form .= qq(<div class="right">今日はあと $message_account{'today_left_message_num'}通 送信できます。</div>\n);
$form .= qq(<input type="hidden" name="mode" value="message"$main::xclose>\n);
$form .= qq(<input type="hidden" name="type" value="send_message"$main::xclose>\n);
$form .= qq(<input type="hidden" name="message_id" value="$main::in{'message_id'}"$main::xclose>\n);
$form .= qq(<input type="hidden" name="to" value="$first_input_to_account"$main::xclose>\n);
$form .= qq(<input type="hidden" name="account" value="$message_account"$main::xclose>\n);
$form .= qq(<input type="hidden" name="return_message_id" value="$message_id"$main::xclose>\n);
$form .= qq(<table summary="送信フォーム">\n);

# 宛先の表示
$form .= qq(<tr>\n);
$form .= qq(<td class="message">宛先</td>\n);
$form .= qq(<td>$to_account{'name'} - $to_account{'file'}</td>\n);
$form .= qq(</tr>\n);

# 件名入力欄
$form .= qq(<tr>\n);
$form .= qq(<td class="message">件名</td>\n);
$form .= qq(<td><input type="text" name="subject" value="$first_input_subject"$main::xclose></td>\n);
$form .= qq(</tr>\n);

# 本文入力欄
$form .= qq(<tr>\n);
$form .= qq(<td class="message">本文</td>\n);
$form .= qq(<td><textarea name="comment" class="message">$first_input_textarea</textarea></td>\n);
$form .= qq(</tr>\n);

# 注意欄
$form .= qq(<tr>\n);
$form .= qq(<td></td>\n);
$form .= qq(<td class="line-height">\n);
$form .= qq(<span style="color:#080;" class="size90">※全角$init{'max_length_message'}文字まで送信できます。　内容は非公開ですが、<a href="${main::auth_url}message.html" target="_blank" class="blank">送信履歴</a>のみ公開されます。</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">※商用利用、出会い目的での利用、他迷惑な利用はご遠慮下さい。管理上必要だと判断した場合、メッセージ内容は<strong>管理者が調査</strong>させていただく場合があります。</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">※送信内容は暗号化されません。クレジットカードなど、重要な情報を送らないでください。</span>\n);
$form .= qq(</td>\n);
$form .= qq(</tr>\n);


# 送信ボタン
$form .= qq(<tr>\n);
$form .= qq(<td></td>\n);
$form .= qq(<td>\n);
$form .= qq(<input type="submit" name="preview" value="この内容でプレビューする" class="ipreview"$main::xclose>\n);
$form .= qq(<input type="submit" value="この内容で送信する" class="isubmit"$main::xclose>\n);
$form .= qq(</td>\n);
$form .= qq(</tr>\n);

$form .= qq(</table>\n);

# ほかの注意
$form .= qq(<div class="line-height alert_box">\n);
#$form .= qq(<span style="color:#f00;" class="size90">※年齢登録を偽ってのご利用は、絶対にご遠慮下さい。アカウントロック、利用停止などの処置を取らせていただく場合があります。</span><br$main::xclose>\n);
$form .= qq(<span style="color:#f00;" class="size90">※メッセージフォームは一定の条件でオープンします。条件は予\告\なしに変更となり、メッセージフォームが使えなくなる場合があります。</span><br$main::xclose>\n);
$form .= qq(</div>\n);


$form .= qq(</div>\n);
$form .= qq(</form>\n);

	# ストップモード
	if($main::stop_mode =~ /SNS/){
		$form = qq(SNSは現在、更新停止中です。);
	}



# HTML之書き出し
my $print = qq($line);

	if($not_useform_message){ $print .=  qq(<div class="not_useform">$not_useform_message</div>); }
	if(!$not_useform_message || $init{'admin_flag'}){ $print .=  qq($form); }

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# メッセージを送信する
#-----------------------------------------------------------
sub SendMessage{

# 宣言
my($type,$to_account) = @_;
my(%init) = &InitMessage();
my(%to_renew,%from_renew,$view_line,$plustype_message_view,$plustype_check_friend_from,$plustype_check_friend_to,%renew_option,%renew_account,%renew_target_account);

# アクセス制限
main::axscheck("Post-only Login-check ACCOUNT");

	# ストップモード
	if($main::stop_mode =~ /SNS/){
		main::error("SNSは現在、更新停止中です。");
	}

# 相手のアカウントを開く
my(%to_account) = Mebius::Auth::File("File-check-error Key-check-error Option",$to_account);

# 権限チェック
&LevelCheckMessage("Error-view",%main::myaccount,$to_account{'file'});
&LevelCheckMessage("Error-view",%to_account,$main::myaccount{'file'});



	# 今日の最大送信数を越えている場合
	if(!$main::myadmin_flag && $main::myaccount{'today_send_message_num'} > $main::myaccount{'maxsend_message'}){
		main::error("今日の最大送信数を超えています。明日まで待ってください。");
	}

	# 自分がマイメビのみに送信を許可している場合
	if(!$main::myadmin_flag && $main::myaccount{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_from .= qq( Friend-check-error);
	}
	# 相手がマイメビのみに送信を許可している場合
	if(!$main::myadmin_flag && $to_account{'allow_message'} eq "Friend-only"){
		$plustype_check_friend_to .= qq( Friend-check-error);
	}

# お互いの禁止設定をチェック
Mebius::Auth::FriendStatus("Check-status Deny-check-error $plustype_check_friend_from",$main::myaccount{'file'},$to_account{'file'});
Mebius::Auth::FriendStatus("Check-status Deny-check-error $plustype_check_friend_to",$to_account{'file'},$main::myaccount{'file'});

	# 年齢差チェック
	#Mebius::Auth::AgeGyap("Allow-together-adult Error-view",$to_account{'age'},$main::myaccount{'age'},1);

	# エラー/プレビュー時のモード定義
	if($main::in{'message_id'}){
		$plustype_message_view .= qq( Message-view);
	}
	else{
		$plustype_message_view .= qq( Brand-new-form);
	}

	# 各種エラー
	if(length($main::in{'comment'})/2 > $init{'max_length_message'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"本文が文字数超過です。");
	}
	if($main::in{'comment'} =~ /^$|^([\s　]+)$/){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"本文を入力してください。");
	}
	if(length($main::in{'subject'})/2 > $init{'max_length_subject'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'},"題名が文字数超過です。");
	}
	if($main::in{'subject'} =~ /^$|^([\s　]+)$/){
		$main::in{'subject'} = "(無題)";
	}

	# プレビュー
	if($main::in{'preview'}){
		MessageView(" $plustype_message_view",$main::in{'account'},$main::in{'message_id'});
	}

	# ●メッセージに返信した場合、旧メッセージに返信マークを付ける
	if($main::in{'return_message_id'}){
		MessageFile("Return-message Renew",$main::myaccount{'file'},$main::in{'return_message_id'});
	}

# メッセージファイルに記録する内容を定義
$to_renew{'message'} = $main::in{'comment'};
$to_renew{'subject'} = $main::in{'subject'};
$to_renew{'to_handle'} = $to_account{'name'};
$to_renew{'from_handle'} = $main::myaccount{'name'};
$to_renew{'to_account'} = $to_account{'file'};
$to_renew{'from_account'} = $main::myaccount{'file'};
$to_renew{'boxtype'} = "catch";

# メッセージファイルに記録する内容を定義
$from_renew{'message'} = $main::in{'comment'};
$from_renew{'subject'} = $main::in{'subject'};
$from_renew{'to_handle'} = $to_account{'name'};
$from_renew{'from_handle'} = $main::myaccount{'name'};
$from_renew{'to_account'} = $to_account{'file'};
$from_renew{'from_account'} = $main::myaccount{'file'};
$from_renew{'boxtype'} = "send";

# 新しいメッセージIDを定義
my($to_message_id) = Mebius::Crypt::char(undef,30);

# 新しいメッセージIDを定義
my($from_message_id) = Mebius::Crypt::char(undef,30);

# 相手のメッセージボックスにメッセージを作成
MessageFile("New-message Renew",$to_account,$to_message_id,%to_renew);

# 相手のメッセージボックス ( 受信箱 ) を更新
MessageBox("Renew New-message",$to_account,"catch",$to_message_id);

# 相手のアカウントごとの送受信履歴を更新
MessageHistoryAccount("Renew New-message",$to_account,$main::myaccount{'file'},$to_message_id);

# 自分のメッセージボックスにメッセージを作成
MessageFile("New-message Renew",$main::myaccount{'file'},$from_message_id,%from_renew);

# 自分のメッセージボックス ( 送信箱 )を更新
MessageBox("Renew New-message",$main::myaccount{'file'},"send",$from_message_id);

# 自分のアカウントごとの送受信履歴を更新
MessageHistoryAccount("Renew New-message",$main::myaccount{'file'},$to_account,$from_message_id);

# 前メンバーの送信履歴を更新
MessageHistoryAllMember("Renew New-message",$to_account,$to_message_id);

# 自分のオプションファイルを更新
#$renew_option{'plus->today_send_message_num'} = 1;
#$renew_option{'last_send_message_yearmonthday'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_option);

# 自分 ( 送信者 )のファイルを更新
$renew_account{'+'}{'today_send_message_num'} = 1;
$renew_account{'last_send_message_yearmonthday'} = qq($main::thisyearf-$main::thismonthf-$main::todayf);
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_account);

# 相手ファイルを更新
$renew_target_account{'+'}{'unread_message_num'} = 1;
Mebius::Auth::File("Renew",$to_account,\%renew_target_account);

# 受信相手に、実メールを送信
my %mail;
$mail{'url'} = "$to_account{'file'}/?mode=message&type=view&message_id=$to_message_id";
$mail{'comment'} = $to_renew{'message'};
$mail{'subject'} = qq($main::myaccount{'name'}さんからメッセージが届きました。);
Mebius::Auth::SendEmail(" Type-message",\%to_account,\%main::myaccount,\%mail);

# クッキーをセット
#Mebius::set_cookie();

# 表示内容を定義
Mebius::Redirect(undef,"${main::auth_url}$main::myaccount{'file'}/?mode=message");
$view_line .= qq(送信しました。(<a href="${main::auth_url}$to_account/">→戻る</a>));

# タイトル定義
$main::sub_title = qq(メッセージの送信);
$main::head_link4 = qq(&gt; 送信);

my $print = $view_line;

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# メッセージ単体ファイル
#-----------------------------------------------------------
sub MessageFile{

# 宣言
my($type,$account,$message_id,%renew) = @_;
my(%message,@renew_line,$message_handler);

	# 汚染チェック
	if($account =~ /^$|\W/){ main::error("相手のアカウント名が変です。"); }

	# 汚染チェックすること
	if($message_id =~ /^$|\W/){ main::error("メッセージIDを指定してください。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ディレクトリ / ファイル定義
my $directory1 = "${account_directory}message/";
my $directory2 = "${directory1}_log_message/";
my $file = "${directory2}${message_id}_message.dat";

	# 更新フラグ
	if($type =~ /Renew/){
		$message{'renew_flag'} = 1;
	}

	# ファイルを開く
	if($type =~ /File-check-error/){ open($message_handler,"<$file") || main::error("メッセージが存在しません。"); }
	else{ open($message_handler,"<$file"); }

		if($type =~ /Renew/){ flock($message_handler,1); }
	chomp(my $top1 = <$message_handler>);
	chomp(my $top2 = <$message_handler>);
	chomp(my $top3 = <$message_handler>);
	chomp(my $top4 = <$message_handler>);
	close($message_handler);

	# トップデータを分解
	($message{'concept'},$message{'to_account'},$message{'from_account'},$message{'to_handle'},$message{'from_handle'}) = split(/<>/,$top1);
	($message{'subject'},$message{'message'},$message{'boxtype'}) = split(/<>/,$top2);
	($message{'sendtime'},$message{'lasttime'},$message{'open_time'},$message{'senddate'}) = split(/<>/,$top3);
	($message{'addr'},$message{'host'},$message{'agent'},$message{'cnumber'},$message{'encid'}) = split(/<>/,$top4);

	# ●ハッシュの調整

	# 削除済みの場合
	if($message{'concept'} =~ /Deleted/){
		$message{'deleted_flag'} = 1;
	}

	# 開封も削除もされていない場合
	if($message{'concept'} !~ /Deleted/ && !$message{'open_time'}){
		$message{'natural_flag'} = 1;
	}

	if(time < $message{'sendtime'} + 3*24*60*60){
		$message{'new_flag'} = 1;
	}

	# 任意の更新
	if($type =~ /Renew/){
			foreach(keys %renew){
					if(defined($renew{$_})){ $message{$_} = $renew{$_}; }
			}
	}

	# 新規送信
	if($type =~ /New-message/){
		$message{'encid'} = main::id();
		$message{'addr'} = $main::addr;
		$message{'host'} = $main::host;
		$message{'agent'} = $main::agent;
		$message{'cnumber'} = $main::cnumber;
		$message{'sendtime'} = $main::time;
		$message{'senddate'} = $main::date;
	}

	# 返信した場合
	if($type =~ /Return-message/){
			if($message{'concept'} =~ /Return-message/){
				$message{'renew_flag'} = 0;
			}
			else{
				$message{'concept'} .= qq( Return-message);
			}
	}

	# メッセージを削除する場合
	if($type =~ /Delete-message/){
			# 既に削除済みの場合
			if($message{'concept'} =~ /Deleted/){
				$message{'renew_flag'} = 0;
			}
			# 削除する
			else{
				$message{'success_flag'} = 1;
				$message{'concept'} .= qq( Deleted);
			}
	}

	# メッセージを復活する場合
	if($type =~ /Revive-message/){
			# 既に削除済みの場合
			if($message{'concept'} =~ /Deleted/){
				$message{'concept'} =~ s/(\s?)Deleted//g;
				$message{'success_flag'} = 1;
			}
			# 削除済みで無い場合
			else{
				$message{'renew_flag'} = 0;
			}
	}

	# ▼開封する場合 ???
	if($type =~ /Open-message/ && $message{'to_account'} eq $main::myaccount{'file'} && !$message{'open_time'} && !$message{'deleted_flag'}){

		my(%renew_box);
		$message{'renew_flag'} = 1;
		$message{'open_time'} = time;
		$type .= qq( Renew);
			$renew_box{'point->opened_message'} = 1;
			MessageBox("Renew",$account,$message{'boxtype'},undef,%renew_box);

			# アカウント本体の新着メッセージ数を減らす
			my($renewed_account) = Mebius::Auth::File("Renew ReturnRef",$account,{ '-' => { unread_message_num => 1 } });

				# SSS マイナスの件数を修正 2013/1/22 (火)
				if($renewed_account->{'unread_message_num'} <= -1){
					Mebius::Auth::File("Renew",$account,{ 'unread_message_num' => 0 });
				}

	}


	# ファイル更新
	if($type =~ /Renew/ && $message{'renew_flag'}){

		# 共通の更新を定義
		$message{'lasttime'} = time;

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);

		# 更新行を体着
		push(@renew_line,"$message{'concept'}<>$message{'to_account'}<>$message{'from_account'}<>$message{'to_handle'}<>$message{'from_handle'}<>\n");
		push(@renew_line,"$message{'subject'}<>$message{'message'}<>$message{'boxtype'}<>\n");
		push(@renew_line,"$message{'sendtime'}<>$message{'lasttime'}<>$message{'open_time'}<>$message{'senddate'}<>\n");
		push(@renew_line,"$message{'addr'}<>$message{'host'}<>$message{'agent'}<>$message{'cnumber'}<>$message{'encid'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}


return(%message);

}

#-----------------------------------------------------------
# メッセージボックスを閲覧する
#-----------------------------------------------------------
sub MessageBoxView{

# 宣言
my($type,$account) = @_;
my(%init) = &InitMessage();
my($plustype_box,$select_box_links,%box,$index_line);

	# 対象アカウントを開く
	my(%account) = Mebius::Auth::File(undef,$account);

	# ログインチェック
	if(!$main::myaccount{'file'}){ main::error(qq(この機\能\を使うには<a href="${main::auth_url}?backurl=$main::selfurl_enc">ログイン</a>してください。)); }

	# 権限チェック
	#&LevelCheckMessage(undef,%main::myaccount);

	# 自分のメッセージボックスではない場合 ★★★必ずこの時点でエラーを表示すること★★★
	if(!$account{'myprof_flag'} && !$init{'admin_flag'}){ main::error("あなたのメッセージボックスではありません。"); }

	# すべてのボックスのリンクを取得
	my($select_box_links) = &MessageBoxAllLinks("Box-view",$account);

	# メッセージボックスを取得
	if($main::in{'boxtype'} eq ""){
		(%box) = &MessageBox("Get-index",$account,"catch",10); 
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});
		(%box) = &MessageBox("Get-index",$account,"send",10); 
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});

	}
	else{
		(%box) = &MessageBox("Get-index",$account,$main::in{'boxtype'},undef,$main::in{'page'});
		$main::head_link4 = qq(&gt; $box{'title'});
		$index_line .= qq($box{'index_line'});
		$index_line .= qq($box{'page_links'});
	}

# リンク
my($sns_multi_link) = main::footer_link();

my $print .= qq(
$sns_multi_link
<h1$main::kstyle_h1>メッセージボックス</h1>
$select_box_links
$index_line
$sns_multi_link
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

#-----------------------------------------------------------
# 全メッセージボックスの選択リンク
#-----------------------------------------------------------
sub MessageBoxAllLinks{

# 宣言
my($type,$account,$relay_type) = @_;
my($select_box_links);

# 全ボックスの種類を定義
my(@message_box) = ("catch","send");

	# メッセージボックスを展開
	foreach(@message_box){
		my($line2);
		my(%box2) = &MessageBox("Get-hash-only",$account,$_);
			$line2 .= qq($box2{'title'});
				if($_ eq "send"){ $line2 .= qq(($box2{'all_message'})); }
				else{ $line2 .= qq(($box2{'natural_message'}/$box2{'all_message'})); }
				if($_ ne $main::in{'boxtype'}){ $line2 = qq(<a href="./?mode=message&amp;boxtype=$_">$line2</a>); }
			$select_box_links .= qq($line2\n);
	}

	# リンク定義
	if($main::in{'boxtype'} eq "" && $type =~ /Box-view/){
		$select_box_links = qq(全て $select_box_links\n);
		$main::head_link3 = qq(&gt; メッセージ);
	}
	else{
		$select_box_links = qq(<a href="./?mode=message">全て</a> $select_box_links\n);
	}
	$select_box_links = qq(<div class="word-spacing">$select_box_links</div>);

return($select_box_links);

}

#-----------------------------------------------------------
# メッセージボックス
#-----------------------------------------------------------
sub MessageBox{

# 宣言
my($type,$account,$boxtype) = @_;
my(%init) = &InitMessage();
my(undef,undef,undef,$maxview_index,$page_number) = @_ if($type =~ /Get-index/);
my(undef,undef,undef,$message_id,%renew) = @_ if($type =~ /Renew/);
my(%box,@renew_line,$message_handler,$file,$hit_index,$index_line,$i_index);

	# 最大表示行数
	if(!$maxview_index){
			if($main::kflag){ $maxview_index = 10; }
			else{ $maxview_index = 20; }
	}
	if(!$page_number){ $page_number = 1; }

#if($main::alocal_mode){ $maxview_index = 3; }

	# 汚染チェック
	if($type =~ /Delete-message|New-message/){
			if($message_id =~ /^$|\W/){ main::error("メッセージIDを指定してください。"); }
	}

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ main::error("アカウント名 ( $account ) が変です。"); }
	if($boxtype =~ /^$|\W/){ main::error("メッセージボックス ( $boxtype) の指定が変です。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ディレクトリ定義
my $directory = "${account_directory}message/";

	# ファイルの定義
	$file = "${directory}${account}_message-box_$boxtype.log";

	# ファイルを開く
	open($message_handler,"<",$file);

		# ファイルロック
		if($type =~ /Renew/){ flock($message_handler,1); }

	# トップデータを分解
	chomp(my $top1 = <$message_handler>);
	($box{'concept'},$box{'title'},$box{'all_message'},$box{'opened_message'},$box{'deleted_message'},$box{'lastcatch_time'},$box{'last_time'}) = split(/<>/,$top1);

	# ハッシュを調整
	if($boxtype eq "catch"){ $box{'title'} = "受信箱"; }
	elsif($boxtype eq "send"){ $box{'title'} = "送信済み"; }

	# 変なデータを修正
	if($box{'opened_message'} > $box{'all_message'}){
		$box{'opened_message'} = $box{'all_message'};
	}

	$box{'natural_message'} = $box{'all_message'} - $box{'opened_message'};
	if(!$box{'all_message'}){ $box{'all_message'} = 0; }
	if(!$box{'natural_message'}){ $box{'natural_message'} = 0; }
	if(!$box{'opened_message'}){ $box{'opened_message'} = 0; }
	if(!$box{'deleted_message'}){ $box{'deleted_message'} = 0; }


	$box{'new_message'} = 0;


		# 最後の受信からしばらく経過している場合は、ファイルを展開しての新着チェックをおこなわない
		if($type =~ /Get-new-status/ && time >= $box{'lastcatch_time'} + 3*24*60*60){
			$type .= qq( Get-hash-only);
		}

		# ハッシュのみを取得する場合
		if($type =~ /Get-hash-only/){
			close($message_handler);
			return(%box);
		}

	# ファイルを展開
	while(<$message_handler>){

		# 局所化
		my($mark2);

		# ラウンドカウンタ
		$i_index++;
			if($init{'admin_flag'}){ $mark2 .= qq( $i_index); }

		# 行を分解
		chomp;
		my($message_id2) = split(/<>/);

		# 更新取得用 ( 2012.08.21 のフィード仕様変更に関係して、未使用? )
		if($type =~ /Get-new-status/){

			# メッセージデータを取得
			my(%message) = MessageFile("Get-hash",$account,$message_id2);

				# 各種ネクスト/ラスト
				if(!$message{'new_flag'}){ last; }

				# 新着メッセージ数
				if($message{'new_flag'} && $message{'natural_flag'}){ $box{'new_message'}++; }

		}

		# インデックス取得用
		if($type =~ /Get-index/){

			# 局所化
			my($style_subject);
	
			# メッセージデータを取得
			my(%message) = MessageFile("Get-hash",$account,$message_id2);

			# 返信済みの場合
			if($message{'concept'} =~ /Return-message/ && $boxtype ne "send"){
				$style_subject = qq( style="color:#080;");
			}

			# 開封済みの場合
			elsif($message{'open_time'} && $boxtype ne "send"){
				#$mark2 .= qq( <span style="color:#66f;" class="size80";>[ 開封済み ]</span>); 
				$style_subject = qq( style="color:#999;");
			}

			# 削除済みの場合
			if($message{'concept'} =~ /Deleted/){
				if($init{'admin_flag'}){ $mark2 .= qq( <span style="color:#f00;" class="size80";>[ 削除済み ]</span>); }
				else{ next; }
			}
			
			# ヒットカウンタ
			else{
				$hit_index++;
			}

				# 最大表示行数に達した場合
				if($hit_index > 0 && $hit_index < $page_number){ next; }
				if($hit_index >= $maxview_index + $page_number){ last; }

			$index_line .= qq(<tr>\n);

			# 削除チェックボックス
			$index_line .= qq(<td>\n);
			$index_line .= qq(<input type="checkbox" name="message_id_$message_id2" value="1"$main::xclose>\n);
			$index_line .= qq(</td>\n);

			# メッセージ件名
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="./?mode=message&amp;type=view&amp;message_id=$message_id2"$style_subject>$message{'subject'}</a>\n);
			$index_line .= qq(</td>\n);

			# 送信元のアカウント
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
			$index_line .= qq(</td>\n);

			# 宛先のアカウント
			$index_line .= qq(<td>\n);
			$index_line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);
			$index_line .= qq(</td>\n);

			# 送信 / 受信日時
			$index_line .= qq(<td>\n);
			$index_line .= qq($message{'senddate'}\n);
			$index_line .= qq(</td>\n);

			# マーク
			$index_line .= qq(<td>\n);
			$index_line .= qq($mark2\n);
			$index_line .= qq(</td>\n);
			$index_line .= qq(</tr>\n);

		}

			# ファイル更新用
			if($type =~ /Renew/){
				push(@renew_line,"$message_id2<>\n");
			}

	}

	close($message_handler);

	# 新規送信の場合
	if($type =~ /New-message/){

			# 最後の受信時間
			if($boxtype ne "send"){ $box{'lastcatch_time'} = $main::time; }

		# 全メッセージ数
		$box{'all_message'}++;

		# 新しい行を追加
		unshift(@renew_line,"$message_id<>\n");

	}

	# インデックス取得用
	if($type =~ /Get-index/){

		# 局所化
		my($h2_style);

		# 帯の色
		if($boxtype eq "send"){ $h2_style = "$init{'send_color_style'}$main::kstyle_h2_in"; }
		else{ $h2_style = "$init{'catch_color_style'}$main::kstyle_h2_in"; }

			if($boxtype eq $main::in{'boxtype'}){
				$box{'index_line'} .= qq(<h2 style="$h2_style">$box{'title'}($box{'all_message'})</h2>);
			}
			else{
				$box{'index_line'} .= qq(<h2 style="$h2_style"><a href="./?mode=message&amp;boxtype=$boxtype">$box{'title'}($box{'all_message'})</a></h2>);
			}

			if($index_line){
					$box{'index_line'} .= qq(<form action="./" method="post"$main::sikibetu>);
					$box{'index_line'} .= qq(<div>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="mode" value="message"$main::xclose>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="type" value="control_message"$main::xclose>\n);
					$box{'index_line'} .= qq(<input type="hidden" name="account" value="$account"$main::xclose>\n);
					$box{'index_line'} .= qq(<table summary="メール一覧">\n);
					$box{'index_line'} .= qq(<th></th><th>件名</th><th>送信者</th><th>宛先</th><th>日付</th><th></th>\n);
					$box{'index_line'} .= qq($index_line\n);
					$box{'index_line'} .= qq(</table>\n);
					$box{'index_line'} .= qq(<div class="right">\n);
					$box{'index_line'} .= qq(<input type="submit" name="delete" value="メッセージ削除"$main::xclose>\n);
						if($init{'admin_flag'}){
							$box{'index_line'} .= qq(<input type="submit" name="revive" style="color:#00f;" value="メッセージ復活"$main::xclose>\n);
						}

					$box{'index_line'} .= qq(</div>\n);
					$box{'index_line'} .= qq(</div>\n);
					$box{'index_line'} .= qq(</form>\n);
			}
			else{
				$box{'index_line'} .= qq(<div class="margin">今は何もありません。</div>);
			}


			# ページめくりリンクを取得
			if($box{'all_message'} >= $maxview_index){
				my $prev = $page_number - $maxview_index;
				my $next = $page_number + $maxview_index;
				$box{'page_links'} .= qq(ページ： );
					if($prev >= 1){ $box{'page_links'} .= qq(<a href="./?mode=message&amp;boxtype=$boxtype&amp;page=$prev">←</a>\n); }
					else{  $box{'page_links'} .= qq(←\n); }
					if($next <= $box{'all_message'}){ $box{'page_links'} .= qq(<a href="./?mode=message&amp;boxtype=$boxtype&amp;page=$next">→</a>\n); }
					else{ $box{'page_links'} .= qq(→\n); }
			}

	}

	# ファイル更新
	if($type =~ /Renew/){

			# 最終更新時刻
			$box{'last_time'} = time;

			# ハッシュの一斉変更
			foreach(keys %renew){
					if(defined($renew{$_})){ $box{$_} = $renew{$_}; }
					if($_ =~ /^point->(\w+)$/){ $box{$1} += $renew{$_}; }
					if($_ =~ /^text->(\w+)$/){ $box{$1} .= $renew{$_}; }
			}

		# ディレクトリを作成
		Mebius::Mkdir(undef,$directory);

		# トップデータを追加
	unshift(@renew_line,"$box{'concept'}<>$box{'title'}<>$box{'all_message'}<>$box{'opened_message'}<>$box{'deleted_message'}<>$box{'lastcatch_time'}<>$box{'last_time'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}

return(%box);


}

#-----------------------------------------------------------
# メッセージ状態の変更
#-----------------------------------------------------------
sub ControlMessage{

# 宣言
my($type,$account) = @_;
my(%init) = &InitMessage();
my($selected_flag,$delete_message_num,%boxtype,%boxtype_opened_message,$unread_num);

	# 自分のメッセージボックスでない場合
	if($account ne $main::myaccount{'file'} && !$init{'admin_flag'}){
		main::error("自分のメッセージではないため、削除できません。");
	}

	# タイプが指定されていない場合
	if($type !~ /Revive-message|Delete-message/){
			if($main::in{'delete'}){ $type .= qq( Delete-message); }
			elsif($main::in{'revive'} && $init{'admin_flag'}){ $type .= qq( Revive-message); }
			else{ main::error("実行タイプを指定してください。"); }
	}

	# ログインしていない場合
	if(!$main::myaccount{'file'}){ main::error("メッセージを削除するには、ログインしてください。"); }

	# 分解
	foreach(split(/&/,$main::postbuf)){

		# データ分解
		my($key2,$value2) = split(/=/,$_);

			# メッセージIDがヒットした場合
			if($key2 =~ /^message_id_(\w+)$/){
				my $message_id2 = $1;
				$selected_flag = 1;
					# メッセージの状態を変更 (削除)
					if($type =~ /Delete-message/){
						my(%message) = MessageFile("Delete-message Renew",$account,$message_id2);
							if($message{'success_flag'}){

									# 未開封であれば、削除によって既読数を減らす
									if(!$message{'open_time'} && $account ne $message{'from_account'}){
										$unread_num--;
									}
								$boxtype{"$message{'boxtype'}"}--;
									if($message{'open_time'}){ $boxtype_opened_message{"$message{'boxtype'}"}--; }
							}
					}

					# メッセージの状態を変更 (復活)
					elsif($type =~ /Revive-message/){
						my(%message) = MessageFile("Revive-message Renew",$account,$message_id2);
							if($message{'success_flag'}){
									# 未開封であれば、削除によって既読数を増やす
									if(!$message{'open_time'} && $account ne $message{'from_account'}){
										$unread_num++;
									}
								$boxtype{"$message{'boxtype'}"}++;
									if($message{'open_time'}){ $boxtype_opened_message{"$message{'boxtype'}"}++; }
							}
					}
			}
	}

	# アカウント本体ファイルを更新 (メッセージ既読数の変更）
	if($unread_num){
		my(%renew_account);
		$renew_account{'+'}{'unread_message_num'} = $unread_num;
		Mebius::Auth::File("Renew",$account,\%renew_account);
	}

	# 全メッセージ数を変更
	foreach(keys %boxtype){
		my(%renew_box);
		$renew_box{"point->all_message"} = $boxtype{$_};
		$renew_box{"point->opened_message"} = $boxtype_opened_message{$_};
		$renew_box{"point->deleted_message"} = - $boxtype{$_};
		MessageBox("Renew",$account,$_,undef,%renew_box);
	}

# 何も選ばれていない場合
#if(!$selected_flag){ main::error("メッセージを選択してください。"); }

# リダイレクト
Mebius::Redirect(undef,"${main::auth_url}$account/?mode=message");

return();


}
#-----------------------------------------------------------
# アカウントあたりの送受信履歴ページを表示する
#-----------------------------------------------------------
sub MessageHistoryAccountView{

# 宣言
my($type,$account1,$account2) = @_;
my(%init) = &InitMessage();

# CSS定義
$main::css_text .= qq(
div.message{}
div.message_handle{margin-bottom:1.5em;margin-top:1.0em;}
);


	# 自分のメッセージボックスでない場合はエラーに
	if($account1 ne $main::myaccount{'file'} && !$init{'admin_flag'}){
		main::error("あなたのメッセージではありません。");
	}


# すべてのボックスのリンクを取得
my($select_box_links) = MessageBoxAllLinks("",$account1);

# 相手のアカウントを開く
my(%account2) = Mebius::Auth::File("File-check-error",$account2);

# インデックスを取得
my(%history) = MessageHistoryAccount("Get-index",$account1,$account2);

my $print = qq(
<h1$main::kstyle_h1>送受信履歴</h1>
$select_box_links
$history{'index_line'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# アカウントあたりの送受信履歴
#-----------------------------------------------------------
sub MessageHistoryAccount{

# 宣言
my($type,$account,$account2,$message_id) = @_;
my(%init) = &InitMessage();
my($view_line,$history_handler,%history,$i,@renew_line,$index_line,$hit_index);

	# 汚染チェック
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }
	if(Mebius::Auth::AccountName(undef,$account2)){ return(); }
	if($type =~ /New-message/ && $message_id =~ /^$|\W/){ return(); }
	if($account eq $account2){ return(); }

# 最大記録行数
my $maxline_index = 50;

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

#my($account2_directory) = Mebius::Auth::account_directory($account2);

# ファイル定義
my $directory1 = "${account_directory}message/_account_message/";
my $file = "${directory1}${account2}_account_message.log";

# ファイルを開く
open($history_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($history_handler,1); }

# トップデータを分解
chomp(my $top1 = <$history_handler>);
($history{'key'}) = split(/<>/,$top1);

	# ファイルを展開する
	while(<$history_handler>){
		
		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($message_id2) = split(/<>/);

			# インデックス取得用
			if($type =~ /Get-index/){

				# 局所化
				my($mark2,$h2_style,$h2);

				# 最大表示数を超えた場合、終了
				if($i >= 10){ last; }

				# メッセージデータを取得
				my(%message) = Mebius::Auth::MessageFile("Get-hash",$account,$message_id2);

				# 削除済みの場合
				if($message{'deleted_flag'}){
					next;
				}

				# ヒットカウンタ
				$hit_index++;

					# マーク定義
					if($message{'boxtype'} eq "send"){
						$mark2 .= qq( <span style="color:#f00;">( 送信 )</span>);
						$h2_style = qq( style="$init{'send_color_style'}$main::kstyle_h2_in");
						$h2 = qq(<h2$h2_style>$message{'subject'}</h2>);
					}
					else{
						$h2_style = qq( style="$init{'catch_color_style'}$main::kstyle_h2_in");
						$h2 = qq(<h2$h2_style><a href="./?mode=message&amp;type=view&amp;message_id=$message_id2">$message{'subject'}</a></h2>);
					}

				# 表示行を定義
				$index_line .= qq(<div>);
				$index_line .= qq($h2);
				$index_line .= qq(<div class="message_handle"><a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>$mark2</div>);
				$index_line .= qq(<div class="line-height">$message{'message'}</div>);
				$index_line .= qq(<div class="right">$message{'senddate'}</div>);

					# 返信リンク
					#if($message{'from_accodunt'} ne $account){
					#	$index_line .= qq(<div class="right"><a href="">返信する</a></div>\n);
					#}

				$index_line .= qq(</div>\n);

			}

			# ファイル更新用
			if($type =~ /Renew/){

					# 最大登録行数に達した場合
					if($i >= $maxline_index){ last; }

				# 更新行を追加
				push(@renew_line,"$message_id2<>\n");

			}

	}

close($history_handler);

	# インデクス取得用
	if($index_line){
		$history{'index_line'} = $index_line;
	}

	# 新しい行を追加する場合
	if($type =~ /New-message/){
		unshift(@renew_line,"$message_id<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリを作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$history{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}

# リターン
return(%history);

}

#-----------------------------------------------------------
# メッセージの送信履歴を閲覧
#-----------------------------------------------------------
sub MessageHistoryAllMemberView{

# 宣言
my($type) = @_;
my($view_line);

# 送信履歴を取得
my(%send_history) = MessageHistoryAllMember("Get-index");

# タイトル定義
$main::sub_title = qq(メッセージの送信履歴 | $main::title );
	if($main::myaccount{'file'}){ $main::head_link3 = qq(&gt; <a href="${main::auth_url}$main::myaccount{'file'}/?mode=message">メッセージ</a>); }
	else{ $main::head_link3 = qq(&gt; メッセージ); }
$main::head_link4 = qq(&gt; 送信履歴(全メンバー));

# 表示内容を手小木
$view_line .= qq(<h1$main::kstyle_h1>メッセージの送信履歴 (全メンバー)</h1>);
#$view_line .= qq(<span style="color:#f00;">※年齢を偽っての利用を発見された場合は、違反が明確に分かる箇所（URL、レス番など）をご提示の上、お手数ですが<a href="http://aurasoul.mb2.jp/_delete/">削除依頼掲示板</a>までご報告ください。</span><br$main::xclose><br$main::xclose>);
$view_line .= qq($send_history{'index_line'});


my $print = qq($view_line);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




#-----------------------------------------------------------
# メッセージの送信履歴 ( 全メンバー )
#-----------------------------------------------------------
sub MessageHistoryAllMember{

# 宣言
my($type,$to_account,$message_id) = @_;
my(%init) = &InitMessage();
my(@renew_line,$history_handler,%send_history);
my($i_index,$index_line);

# ディレクトリ / ファイル定義
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $file = "${auth_log_directory}message_history.log";

# 最大登録行数
my $maxline_index = 50;

	# ファイルを開く
	open($history_handler,"<$file");

		# ファイルロック
		if($type =~ /Renew/){ flock($history_handler,1); }

	# トップデータを分解
	chomp(my $top1 = <$history_handler>);
	($send_history{'concept'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$history_handler>){

		# ラウンドカウンタ
		$i_index++;

		# 行を分解
		chomp;
		my($to_account2,$message_id2) = split(/<>/);

			# インデックス取得用
			if($type =~ /Get-index/){

				# 局所化
				my(%account2);

				# メッセージを開く
				my(%message) = MessageFile("Get-hash",$to_account2,$message_id2);

				$index_line .= qq(<tr>\n);

					# 送信者のアカウントを開く
					if($init{'admin_flag'}){
						(%account2) = Mebius::Auth::File("Option",$message{'from_account'});
					}

					# メッセージ件名
					if($init{'admin_flag'}){
						$index_line .= qq(<td>\n);
						#$index_line .= qq(<a href="./$message{'to_account'}/?mode=message&amp;type=view&amp;message_id=$message_id2">$message{'subject'}</a>\n);
						$index_line .= qq($message{'subject'}\n);
						$index_line .= qq(</td>\n);
					}

				# 送信者のアカウント
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$message{'from_account'}/">$message{'from_handle'} - $message{'from_account'}</a>\n);
					if($init{'admin_flag'}){ $index_line .= qq( ($account2{'today_left_message_num'} / $account2{'maxsend_message'}) ); }
				$index_line .= qq(</td>\n);

				# 宛先のアカウント
				$index_line .= qq(<td>\n);
				$index_line .= qq(<a href="${main::auth_url}$message{'to_account'}/">$message{'to_handle'} - $message{'to_account'}</a>\n);
				$index_line .= qq(</td>\n);

				# 送信 / 受信日時
				$index_line .= qq(<td>\n);
				$index_line .= qq($message{'senddate'}\n);
				$index_line .= qq(</td>\n);

				$index_line .= qq(</tr>\n);
			}

			# 更新行を追加
			if($type =~ /Renew/){
					if($i_index >= $maxline_index){ last; }
				push(@renew_line,"$to_account2<>$message_id2<>\n");
			}
	}
	
	close($history_handler);

	# インデックス取得用
	if($type =~ /Get-index/){
		$send_history{'index_line'} .= qq(<table summary="送信履歴">\n);
			if($init{'admin_flag'}){ $send_history{'index_line'} .= qq(<th>件名</th>\n); }
		$send_history{'index_line'} .= qq(<th>送信者</th><th>宛先</th><th>日付</th>\n);
		$send_history{'index_line'} .= qq($index_line\n);
		$send_history{'index_line'} .= qq(</table>\n);

	}

	# 新規送信した場合
	if($type =~ /New-message/){
		unshift(@renew_line,"$to_account<>$message_id<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		#Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$send_history{'concept'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}


return(%send_history);


}



1;
