
use strict;
use File::Copy;
use File::Path;
package Mebius::Adventure;

#-----------------------------------------------------------
# 処理スタート
#-----------------------------------------------------------
sub Trance{

	if($main::in{'type'} eq "do"){ &TranceAccount(); }
	else{ &TranceAccountView(); }

}

#-----------------------------------------------------------
# データ移行フォーム
#-----------------------------------------------------------
sub TranceAccountView{

# 宣言
my($use) = @_;
my($form,$guide_line);
my($init) = &Init();
my($init_login) = init_login();

# Cookieをゲット
my($cookie) = Mebius::get_cookie("MEBI_ADV");
my($cookie_id,$cookie_password) = @$cookie;

			# 説明部分
			if(!$use->{'TypePreview'}){
				$guide_line .= qq(<h2>説明</h2>);
				$guide_line .= qq(<ul>);
				$guide_line .= qq(<li>今までのメビアドのIDは、メビウスリングの総合アカウントと共通化しました。</li>);
				$guide_line .= qq(<li>以前のキャラデータは、<strong class="red">メビウスリングのアカウント</strong>に引き継ぐことが出来ます。</li>);
				$guide_line .= qq(<li>まずは総合アカウントに<a href="${main::auth_url}" target="_blank" class="blank">ログイン（または新規登録）</a>したまま、本ページを開いてください。</li>);
				$guide_line .= qq(<li>次に、<strong class="red">あなたが今まで使っていたキャラクターのIDとパスワード</strong>を入力すると、データの引継ぎが完了します。</li>);
				$guide_line .= qq(<li>データの引継ぎが完了すると、それ以降は<strong class="red">メビウスリングのアカウント</strong>にログインすることで、続けてゲームをお楽しみいただけます。</li>);
				$guide_line .= qq(<li>ひとつのキャラデータにつき、関連付けられるアカウントは一つだけですのでご注意ください。</li>);
				$guide_line .= qq(</ul>);
			}

# フォーム
$form .= qq(<h2>データの引継ぎ</h2>);

	# SNSへのログインチェック
	if(!$main::myaccount{'file'}){
		my($backurl) = Mebius::back_url({ TypeRequestURL => 1 });
		$form .= qq(データを移行する前に、総合アカウントに<a href="${main::auth_url}?backurl=$backurl->{'url_encoded'}">ログイン（またはアカウントを新規作成）</a>してください。);
	}
	# ログインしている場合
	else{

		$form .= qq(<form action="$init->{'script'}" method="post"><div>);
		$form .= qq(<input type="hidden" name="mode" value="trance"$main::xclose>);
		$form .= qq(<input type="hidden" name="type" value="do"$main::xclose>);


			# プレビュー
			if($use->{'TypePreview'}){

				$form .= qq(<h3>メビウスリング アカウント(新)</h3><a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a>);


				# 過去のキャラデータを取得
				require Mebius::Adventure::Charactor;
				my($old_adv) = &File(undef,{ FileType => "OldId" , id => $main::in{'id'} });
				my($status) = &CharaStatus({ TypeNotGetForm => 1 },$old_adv);
				$form .= qq(<h3>旧キャラデータ</h3>\n);
				$form .= qq($status);

				# アカウントが既に存在する場合
				my($new_adv) = &File("Allow-empty-id",{ FileType => "Account" , id => $main::myaccount{'file'} });
					if($new_adv->{'f'}){
						my($status) = &CharaStatus({ TypeNotGetForm => 1 },$new_adv);
						$form .= qq(<h3>既に存在するデータ (上書き削除されます)</h3>\n);
						$form .= qq($status);
					}

				$form .= qq(<p><span 	class="alert">※上記のキャラデータを、アカウントに引き継いでも良いですか？</span></p>);
		$form .= qq(<p><span class="alert">※いちどデータを引き継ぐと、他のアカウントや、他のキャラデータとの関連付けは出来なくなるため、ご注意ください。</span></p>);
				$form .= qq(<input type="hidden" name="id" value="$main::in{'id'}"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="hidden" name="pass" value="$main::in{'pass'}"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="submit" name="submit" value="データの引継ぎを実行する" class="isubmit"$main::xclose>);
			}
			# 普通
			else{

				$form .= qq(あなたのメビウスリング アカウント <a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a> ( このアカウントに、今までのキャラデータが引き継がれます )<br$main::xclose><br$main::xclose>);
				$form .= qq(ゲームで使っていたキャラID (旧) <input type="id" name="id" value="$cookie_id"$main::xclose><br$main::xclose>);
				$form .= qq(ゲームで使っていたパスワード (旧) <input type="password" name="pass" value="$cookie_password"$main::xclose><br$main::xclose>);
				$form .= qq(<input type="submit" name="preview" value="データの引継ぎを実行する(確認)" class="ipreview"$main::xclose>);
			}


		$form .= qq(</form></div>);
	}

my $print .= qq(<h1>旧データの引継ぎ</h1>);
$print .= qq($init_login->{'link_line'});
$print .= qq($guide_line$form);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# メビアドの古いデータを以降
#-----------------------------------------------------------
sub TranceAccount{

# 宣言
my($init) = &Init();
my(%renew_new,%renew_old,$trance_error_line,$bonused_flag,$print);

# アクセス制限
my($host) = main::axscheck("Post-only ACCOUNT");

	# SNSへのログインチェック
	if(!$main::myaccount{'file'}){
		main::error(qq(データを移行する前に、総合アカウントに<a href="${main::auth_url}?backurl=">ログイン（または新規登録）</a>してください。));
	}

# IDを定義
my $old_id = $main::in{'id'};
my $new_id = $main::myaccount{'file'};

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$new_id)){ main::error("アカウント名が変です。"); }
	if($old_id eq "" || $old_id =~ /[^0-9a-z]/){ main::error("キャラIDが変です。"); }


# 旧データを開く
my($old_adv) = &File("",{ FileType => "OldId" , id => $old_id });

	# データ移行済みかどうかをチェック
	if($old_adv->{'trance_to_account'}){
		my $message = qq(既にこのキャラデータ ( $old_id ) は、アカウント ( $old_adv->{'trance_to_account'} ) にデータが引き継がれています。);
			if(Mebius::alocal_judge() || $init->{'mente_mode'}){
				$trance_error_line .= qq(<p class="red">$message</p>);
			}
			else{
				main::error($message);
			}
	}

# 新しいデータを開く
my($new_adv) = &File("",{ FileType => "Account" , id => $new_id });

	# データ移行済みかどうかをチェック
	if($new_adv->{'trance_from_account'}){
		my $message = qq(既にこのアカウント ( $new_id ) は、古いキャラデータ ( $new_adv->{'trance_from_account'} ) を引継ぎ終わっています。);
			if(Mebius::alocal_judge() || $init->{'mente_mode'}){
				$trance_error_line .= qq(<p class="red">$message</p>);
			}
			else{
				main::error($message);
			}
	}


	# ログイン失敗回数を取得
	my(%login_missed) = Mebius::Login::TryFile("Adventure-file By-form Get-hash",$main::xip);

			# 今日のログイン失敗が多すぎる場合はエラーに
			if($login_missed{'error_flag'}){
				main::error($login_missed{'error_flag'});
			}

	# 旧データのパスワードチェック
	if($old_adv->{'pass'} eq $main::in{'pass'} && $old_adv->{'pass'} && $old_adv->{'f'}){}
	# パスワード認証に失敗した場合
	else{
		Mebius::Login::TryFile("Adventure-file Login-missed By-form Renew",$main::xip,$old_id,$main::in{'pass'});
		main::error("メビアドのIDとパスワードが一致しません。");
	}

	# プレビュー
	if($main::in{'preview'}){
		&TranceAccountView({ TypePreview => 1 });
	}

	# ●ここからファイル更新処理を追加

	# 既に移行先のアカウントが存在する場合
	if($new_adv->{'f'}){
		# バックアップを作成
		my $copy_success_flag = File::Copy::copy($new_adv->{'file'},$new_adv->{'overwrite_file'});
	}

	# 新しいデータを更新
	if($new_adv->{'directory'}){ File::Path::rmtree($new_adv->{'directory'}); }
	else{ main::error("ディテクトリが定義できません。"); }


%renew_new = %$old_adv;
$renew_new{'trance_from_account'} = $old_id;
$renew_new{'trance_from_time'} = time;
my $bonus_per = 1.5;
	if($old_adv->{'gold'} + $old_adv->{'bank'} >= 1){
		$renew_new{'gold'} = int($renew_new{'gold'} * $bonus_per);
		$renew_new{'bank'} = int($renew_new{'bank'} * $bonus_per);
		$bonused_flag = 1;
	}
$renew_new{'pass'} = "";
$renew_new{'salt'} = "";
$renew_new{'first_host'} = $host;
$renew_new{'first_agent'} = $main::agent;
$renew_new{'first_time'} = time;
$renew_new{'id'} = $new_id; # ランキングに反映用
my($renewed_new_adv) = &File("Renew",{ FileType => "Account" , id => $new_id , TypeTrance => 1 },\%renew_new);

# 古いデータを更新
$renew_old{'trance_to_account'} = $new_id;
$renew_old{'trance_to_time'} = time;
&File("Renew",{ FileType => "OldId" , id => $old_id },\%renew_old);

# アイテム倉庫のデータをコピー
require Mebius::Adventure::Item;
my($new_adv_for_item) = &File(undef,{ FileType => "Account" , id => $new_id  });
my($item_old) = &ItemStock("Old-file Get-hash",undef,$old_adv);
my($item_new) = &ItemStock("Get-hash Test",undef,$new_adv_for_item);
my $copy_success_flag = &File::Copy::copy($item_old->{'file'},$item_new->{'file'});

# CCC
#Mebius::AccessLog(undef,"Adventure-trance",qq($item_old->{'file'} => $item_new->{'file'}));

# 記録
Mebius::AccessLog("Not-unlink-file","Adventure-trance-character-data","$old_id → $new_id");

$print .= qq(<p> メビアドの旧ID ( $old_id ) を メビウスリングアカウント ( $new_id ) に反映させました。</p>);

	if($copy_success_flag){
		$print .= qq(<p>アイテム倉庫の内容を引き継ぎました。</p>);
	}

	if($bonused_flag){
		$print .= qq(<p> 引継ぎボーナスとして 所持金、貯金額が $bonus_per 倍に増えました。 </p>);
	}

	# エラー (管理者確認用)
	if($trance_error_line){
		$print .= qq($trance_error_line);
	}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

