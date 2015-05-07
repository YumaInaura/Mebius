
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# 値段
#-----------------------------------------------------------
sub PriceRoom{

# 宣言
my($use,$adv) = @_;
my(%data);

$data{'sex_change_price'} = (10000000 + ($adv->{'level'}*2500)) * $adv->{'sex_change_count'};
$data{'name_change_price'} = (10000000 + ($adv->{'level'}*2500)) * $adv->{'name_change_count'};

return($data{'sex_change_price'},$data{'name_change_price'});

#return(\%data);

}


#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub Room{
$main::sub_title = "市役所 | $main::title";
		if($main::in{'type'} eq "changename" || $main::in{'type'} eq "changesex"){ &ChangeStatus(); }
		elsif($main::in{'type'} eq ""){ &ViewRoom(); }
		else{ main::error("ページが存在しません。"); }
}


#-----------------------------------------------------------
# 市役所ページ表示
#-----------------------------------------------------------
sub ViewRoom{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($message,$form,$charge_gold,$charity_line,$i,$message2,$submit1,$submit2,$change_name_line,$change_sex_line);
our($advmy);

# CSS定義
$main::css_text .= qq(
form{margin:1em 0em;}
table{width:100%;}
.now_gold{width:17em;display:inline;width:200px;}
.keep_gold{width:30em;display:inline;width:200px;}
);

# キャラデータを読み込む
my($adv) = &File("Mydata Allow-empty-id",{ FileType => $advmy->{'FileType'} , id => $advmy->{'id'} } );

# 市役所の設定を読み込み
my($changesex_gold,$changename_gold) = &PriceRoom({},$adv);

# カンマを付ける
my($changesex_gold_comma,$changename_gold_comma,$kgold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$changesex_gold,$changename_gold,$adv->{'gold'}]);

	# 所持金の表示
	if($adv->{'gold'}){ 
		$form .= qq(あなたの所持金： <strong class="goldcolor">$kgold_comma G</strong>);
	}


	# 名前変更フォーム
	$change_name_line .= qq(<h2>名前の変更</h2>);
	if($advmy->{'login_flag'}){
		$change_name_line .= qq(
		<span class="goldcolor">$changename_gold_comma\G </span>であなたの名前を変更します。
		<form action="$init->{'script'}" method="post"$main::sikibetu>
		<div>
		現在の名前： $adv->{'name'}<br><br>
		新しい名前： <input type="text" name="name" value="">
		<input type="hidden" name="mode" value="room">
		<input type="hidden" name="type" value="changename">
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="submit" value="名前を変更する">
		</div>
		</form>
		);
	}
	else{
		$change_name_line .= qq($init->{'please_login_text'});
	}

	# 性別変更フォーム
	$change_sex_line .= qq(<h2>性別の変更</h2>);
	if($advmy->{'login_flag'}){
		$change_sex_line .= qq(
		<span class="goldcolor">$changesex_gold_comma\G</span> であなたの性別を登記上、変更します。
		<form action="$init->{'script'}" method="post"$main::sikibetu>
		<div>
		<input type="hidden" name="mode" value="room">
		<input type="hidden" name="type" value="changesex">
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="submit" value="性別を変更する">
		</div>
		</form>
		);
	}
	else{
		$change_sex_line .= qq($init->{'please_login_text'});
	}

my $print = qq(
<h1>市役所</h1>
$init_login->{'link_line'}
$message
$form
$change_name_line
$change_sex_line
);

Mebius::Template::gzip_and_print_all({ BCL => ["市役所"] },$print);

exit;

}

#-----------------------------------------------------------
# 登録の変更
#-----------------------------------------------------------
sub ChangeStatus{

# 局所化
my($init) = &Init();
my($init_login) = init_login();
my($deposit_gold,%renew);
our($advmy);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

# キャラデータを読み込む
my($adv) = &File("Mydata Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

# 市役所の設定を読み込み
my($changesex_gold,$changename_gold) = &PriceRoom({},$adv);

	# 名前の変更
	if($main::in{'type'} eq "changename"){
		my($base_directory) = Mebius::BaseInitDirectory();
		require "${base_directory}regist_allcheck.pl";
		my($new_name) = shift_jis(Mebius::Regist::name_check($main::in{'name'}));
		main::error_view();
			if($adv->{'gold'} < $changename_gold){ main::error("お金が足りません。 $adv->{'gold'}\G / $changename_gold\G"); }
		$renew{'name'} = $new_name;
		$renew{'-'}{'gold'} = $changename_gold;
		$renew{'+'}{'name_change_count'} = 1;
	}

	# 性別の変更
	if($main::in{'type'} eq "changesex"){
			if($adv->{'gold'} < $changesex_gold){ main::error("お金が足りません。 $adv->{'gold'}\G / $changename_gold\G"); }
			if($adv->{'sex'} == 1){ $renew{'sex'} = 0; }
			else{ $renew{'sex'} = 1; }
		$renew{'-'}{'gold'} = $changesex_gold;
		$renew{'+'}{'sex_change_count'} = 1;
	}

# キャラデータを更新
my($renewed) = &File("Mydata Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

# ジャンプ
$main::jump_url = $init->{'login_url'};
$main::jump_sec = 1;

my $print = qq(
<h1>市役所</h1>
$init_login->{'link_line'}
登録を変更しました！<br>
$init->{'continue_button'}
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




1;
