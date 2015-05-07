
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# アイテムショップページ
#-----------------------------------------------------------
sub ViewItem{

# 宣言
my($init) = &Init();
my($init_login) = init_login();
my($head_title,$flag,$item_list);
our($advmy);

# CSS定義
$main::css_text .= qq(
div.sort1{word-spacing:0.50em;}
);

# アイテムを取得
($flag,$item_list) = &SelectItem("LIST Get-index","",$advmy);

# 倉庫のアイテムを取得
my($itemstock_list) = &ItemStock("Get-index Allow-edit",undef,$advmy);
if($itemstock_list){ $itemstock_list = qq(<h2 id="STORAGE">アイテム倉庫</h2>\n$itemstock_list); }

# ページタイトル
$head_title = qq(アイテムショップ);

# アイテムの並べ替えリンク
my($sort_link);
my @item_sort = ("=>普通","gold=>金額の低い順","atack=>威力の高い順");

	# 展開
	foreach(@item_sort){

		# 分解
		my($value,$text) = split(/=>/,$_);
		my($sort_href);

			# リンクの中身
			if($value){
				$sort_href = qq(&amp;sort=$value);
			}

			# 選択中のページ
			if($value eq $main::in{'sort'}){
					if($value){ $head_title .= qq( | $text | $init->{'title'}); }
					else{ $head_title .= qq( | $init->{'title'}); }
				$sort_link .= qq($text\n);
			}
			# 他のページ
			else{ $sort_link .= qq(<a href="$init->{'script'}?mode=item_shop$sort_href">$text</a>\n); }
	}


# HTML
my $print = qq(
<h1>アイテムショップ</h1>
$init_login->{'link_line'}
<div class="sort1">並べ替え：
$sort_link
</div>
<h2>購入する</h2>
<div class="line_height">
お客様へ。アイテムのお値段、品揃え、品質は時期によって変動する場合がございます。<br>
</div>
$item_list
$itemstock_list

);

Mebius::Template::gzip_and_print_all({ Title => $head_title , BCL => ["アイテム"] },$print);


exit;

}


#-----------------------------------------------------------
# 武器を買う / 交換する
#-----------------------------------------------------------
sub BuyWepon{

# 局所化
my($type) = @_;
my($init) = &Init();
my($init_login) = init_login();
my($hit,$item_id,$item_pass,$message1,$message2);
my($select_item,$item_damage);
my($flag,$list,%renew,$item,$stock,$new_item);
our($advmy);

	# 処理タイプを定義
	if($main::in{'type'} eq "change_item"){ $type .= qq( Change-item); }
	else{ $type .= qq( Buy-item); }

	# 各種エラー
	if($type =~ /Buy-item/ && $main::in{'select_item'} eq ""){ main::error("アイテムを選んでください。"); }
	if($type =~ /Change-item/ && $main::in{'item_session'} eq ""){ main::error("アイテムを選んでください。"); }

# キャラファイルを開く
my($adv) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

	# ●新しくアイテムを購入する場合
	if($type =~ /Buy-item/){

		# アイテムを取得
		($flag,$list,$new_item) = &SelectItem("BUY_ACTION",$main::in{'select_item'},$adv);

		# 各種エラー
		if(!$flag) { main::error("存在しないアイテムです。"); }
		if($new_item->{'item_price'} >= 1 && $adv->{'gold'} < $new_item->{'item_price'}) {
			main::error("お金が足りません $new_item->{'item_price'} G / $adv->{'gold'} G");
		}

		# 職業専門武器のレベル制限
		my $need_level = int($new_item->{'item_damage'} / 1);
			if($new_item->{'item_job'} && $new_item->{'item_damage'} >= 100 && $need_level > $adv->{'level'} && !$main::alocal_mode){
				main::error("$need_levelまでレベルを上げないとこの武器は買えません。");
			}

			# 装備している武器がある場合、以前の武器を倉庫へ
			if($adv->{'item_name'}){ ItemStock("Renew Add-stock Buy-item",undef,$adv); }

		# 各種調整
		$renew{'-'}{'gold'} = $new_item->{'item_price'};
		$new_item->{'item_damage_plus'} = "";		# 新品なので強化値はゼロに

		# メッセージ
		if($new_item->{'item_number'} eq "0000"){
			$message1 = qq(武器を外しました。);
				if($adv->{'item_name'}){ $message2 = qq(「$adv->{'item_name'}」は倉庫に保管しました。); }
			$new_item->{'item_number'} = $new_item->{'item_name'} = $new_item->{'item_damage'} = $new_item->{'item_concept'} = "";
		}
		else{
			$message1 = qq(”$new_item->{'item_name'}”を$new_item->{'item_price'}\G で購入しました！);
				if($adv->{'item_name'}){ $message2 = qq(「$adv->{'item_name'}」は倉庫に保管しました。); }
		}


	}

	# ●アイテムを交換する/売る場合
	elsif($type =~ /Change-item/){

			# ▼アイテムを売る場合
			if($main::in{'drop_stock'}){

				# チェックがカラの場合
				if(!$main::in{'sell_item_check'}){
					main::error("お売りいただけるのでしょうか？");
				}

				# 倉庫のアイテムIDをゲット、そのまま該当アイテムを捨てる
				($stock) = &ItemStock("Drop-stock Renew Get-hash",$main::in{'item_session'},$adv);

				# アイテムを取得
				($item) = &SelectItem("Get-hash",$stock->{'item_number'});

				# 売却する
				my $sell_price = ($item->{'item_price'}/3);
					# 武器強化値によって売却値を上げる
					if($stock->{'item_damage_plus'} >= 1 && $item->{'item_damage'} >= 1){
						$sell_price += int($sell_price * (($stock->{'item_damage'}+($stock->{'item_damage_plus'}*3*1.7)) / $item->{'item_damage'}));
					}
				$sell_price = int $sell_price;
				my($sell_price_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$sell_price]);
				$renew{'+'}{'gold'} = $sell_price;
				$message1 = qq(倉庫の”$stock->{'item_name'}”を ${sell_price_comma}Gで 売却しました。);

			}

			# ▼アイテムを交換する場合
			else{

				# 倉庫から、新しく装備する武器のIDを取得する
				($stock) = &ItemStock("ItemStock Get-hash",$main::in{'item_session'},$adv);
					if($stock->{'item_number'} eq ""){ main::error("このアイテム は倉庫に存在しません。"); }

				# 倉庫から出したアイテムの最新データを取得、反映させる ( item_damage_plus 以外 )
				($new_item) = &SelectItem("Get-hash",$stock->{'item_number'});
				$new_item->{'item_damage_plus'} = $stock->{'item_damage_plus'};

				# 今の武器を倉庫へ / 取り出した武器を倉庫から消す
				&ItemStock("Renew Add-stock",$main::in{'item_session'},$adv);

				# メッセージ定義
				$message1 = qq(”$new_item->{'item_name'}”を装備しました。);
				if($adv->{'item_name'}){ $message2 = qq(「$adv->{'item_name'}」は倉庫に保管しました。); }

			}

	}

# 新しい武器を装備する (キャラデータへの反映)
$renew{'item_number'} = $new_item->{'item_number'};
$renew{'item_name'} = $new_item->{'item_name'};
$renew{'item_damage'} = $new_item->{'item_damage'};
$renew{'item_job'} = $new_item->{'item_job'};
$renew{'item_damage_plus'} = $new_item->{'item_damage_plus'};
$renew{'item_concept'} = $new_item->{'item_concept'};

# キャラファイルを更新
&File("Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

	# ジャンプ
	if(Mebius::alocal_judge()){
		#Mebius::Redirect(undef,"$init->{'script'}?mode=item_shop");
	}


# HTML
my $print = qq(
<h1>$message1</h1>
$init_login->{'link_line'}
<div class="adv_message">
$message2
<div>
<a href="$init->{'script'}?mode=item_shop">→アイテムショップへ戻る</a>
</div>
</div>
$init->{'continue_button'}
</div>
);

# フッタ
Mebius::Template::gzip_and_print_all({ RefreshURL => "$init->{'script'}?mode=item_shop" , RefreshSecond => 2 },$print);

exit;

}


#-----------------------------------------------------------
# アイテムリストを取得
#-----------------------------------------------------------
sub SelectItem{

# 局所化
my($myaccount) = Mebius::my_account();
my($type,$select_item,$adv) = @_;
my($init) = &Init();
my($flag,$list,@item_list,%return,%item_kind,$FILE1);

# CSS定義
$main::css_text .= qq(
td.gold{text-align:right;}
td.damage{text-align:right;}
td.item_guide{padding-left:0.5em;}
table.itemlist{margin:1em 0em;}
);


# ファイル定義
my $file  = "$init->{'adv_dir'}_item_data_adventure/item1.dat";

# アイテムファイルを開く
open($FILE1,"<",$file) || die("Perl Die! Can't open item list file");
	while(<$FILE1>){
		chomp $_;
		my($item_number2,$item_name,$item_damage,$item_price,$item_guide,$item_job,$item_concept2,$salled_num2) = split(/<>/,$_);

			# アイテムの二重登録を防ぐ
			if($item_kind{$item_number2}++){
				close($FILE1);
				main::error("アイテムが二重設定されています。");
			}

		( my $item_price_escape_comma = $item_price) =~ s/,//g;
		push(@item_list,"$item_number2<>$item_name<>$item_damage<>$item_price<>$item_guide<>$item_job<>$item_concept2<>$item_price_escape_comma<>$salled_num2<>\n");

	}
close($FILE1);

	# アイテムの並び替え
	if($type =~ /LIST/){
			if($main::in{'sort'} eq "gold"){ @item_list = sort { (split(/<>/,$a))[7] <=> (split(/<>/,$b))[7] } @item_list; }
			if($main::in{'sort'} eq "atack"){ @item_list = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @item_list; }
	}

	# アイテムファイルを開く
	foreach(@item_list){

		# 局所化
		chomp;
		my($item_number2,$item_name,$item_damage,$item_price,$item_guide,$item_job,$item_concept2,$item_price_escape_comma2) = split(/<>/);
		my($disabled1,$class1,$myitem_mark);


		# 値段の整形 ( カンマが入っている場合あり )
		$item_price =~ s/\D//g;

			# 職業によっては値段を安く
			if($adv->{'jobname'} eq '超能力者' && $adv->{'level'} >= 500){ $item_price = int $item_price * 0.85; }
			if($adv->{'jobname'} eq 'レンジャー' && $adv->{'level'} >= 1000){ $item_price = int $item_price * 0.75; }

			# 特定のアイテム
			if($item_number2 eq $select_item){
				$return{'item_number'} = $item_number2;
				$return{'item_name'} = $item_name;
				$return{'item_damage'} = $item_damage;
				$return{'item_price'} = $item_price;
				$return{'item_guide'} = $item_guide;
				$return{'item_job'} = $item_job;


				$return{'item_concept'} = $item_concept2;

				$flag = 1;
			}

			# 金額チェック
			if($item_price >= 1 && $item_price > $adv->{'gold'}){ $class1 = qq( class="disable"); $disabled1 = $main::disabled; }

			# 職業限定アイテム
			if($item_job ne ""){
				my($hit);
				foreach(split(/,/,$item_job)){
					if($_ eq $adv->{'jobname'}){ $hit = 1; }
				}
				if(!$hit && $type =~/BUY_ACTION/ && $item_number2 eq $select_item){ main::error("「$item_name」を買えるのは $item_job だけです。"); }
				if($hit){ $class1 = qq( class="fit"); }
				else{ $class1 = qq( class="def"); $disabled1 = $main::disabled; }
			}

			# 現在、この武器を装備している場合
			if($item_number2 eq $adv->{'item_number'}){
				$class1 = qq( class="self");
				$disabled1 = $main::disabled;
					# その上さらに、同じ武器を買おうとした場合
					if($type =~/BUY_ACTION/ && $adv->{'item_number'} eq $select_item){ main::error("このアイテム ( $item_name ) は既に持っています。"); }
			}

		# 自分の所持アイテム
		#if($item_number2 eq $advitem){
			#if($type =~/BUY_ACTION/ && $item_number2 eq $select_item){ main::error("このアイテムは既に持っています。"); }
			#$class1 = qq( class="self"); $disabled1 = $disabled;
		#}

			# ◯インデックスを取得
			if($type =~ /Get-index/){

				# 値段にカンマを付ける
				my($item_price_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$item_price]);

					# アイテムコンセプトを元に、説明文の追加
					if($item_concept2 =~ /Getgold-boost-([0-9\.]+)/){ $item_guide .= qq(戦闘時の獲得ゴールドが$1倍になります。); }
					if($item_concept2 =~ /Getexp-boost-([0-9\.]+)/){ $item_guide .= qq(戦闘時の獲得経験値が$1倍になります。); }
					if($item_concept2 =~ /Anti-assassin/){ $item_guide .= qq(敵の暗殺を防ぎます。); }

				$list .= qq(<tr$class1><td><label for="item_$item_number2">);
					if($adv->{'f'}){
						$list .= qq(<input type="radio" name="select_item" value="$item_number2" id="item_$item_number2"$disabled1> );
					}
					if($main::in{'check'}){
						$list .= qq($item_concept2);
					}
				$list .= qq($item_name$myitem_mark</label></td><td class="gold"> $item_price_comma G</td><td class="damage">$item_damage</td><td>$item_job</td><td class="item_guide">$item_guide</td></tr>\n);
			}

	}


# アイテムリスト
$list = qq(
<table class="itemlist adventure" summary="アイテム一覧" class="adventure">
<tr><th>名前</th><th>価格</th><th>威力</th><th>職業限定</th><th>効果</th></tr>
$list
</table>
);

	# ログイン中の場合、購入ボタンを表示
	if($adv->{'f'}){

			# 所持金表示
			my($adv_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$adv->{'gold'}]);

			# アイテムダメージ表示
			my($item_damage_all);
			if(!$adv->{'item_number'}){}
			elsif($adv->{'item_damage_plus'}){ $item_damage_all = qq($adv->{'item_damage'} + $adv->{'item_damage_plus'}); }
			else{ $item_damage_all = qq($adv->{'item_damage'}); }

		$list = qq(
		<form action="$init->{'script'}" method="post" class="buy_item"$main::sikibetu>
		<div>
		ご購入の際は、お求めのアイテムにチェックを入れて <input type="submit" value="このアイテムを買う"> を押してください。
		<br$main::xclose>
		<br$main::xclose>

		<span class="goldcolor"> あなたの所持金： $adv_gold_comma G</span> / あなたの武器： $adv->{'item_name'} ($item_damage_all)
		$list
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="hidden" name="mode" value="item_buy">
		<input type="submit" value="このアイテムを買う" class="isubmit">
		</div>
		</form>
		);
	}

	# ハッシュのみを返す場合
	if($type =~ /Get-hash/){
		return(\%return);
	}

	# リターン
	else{
		return($flag,$list,\%return);
	}

}

#-----------------------------------------------------------
# アイテム倉庫
#-----------------------------------------------------------
sub ItemStock{

# 宣言
my($type,$item_session,$adv) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($init) = &Init();
my($stock_handler,@renewline,$index_line,$i,$directory,%data);
our($advmy);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$adv->{'id'})){ return(); }

	# ファイルを開く (新)
	if($type{'Old-file'}){
		$data{'file'} = "$init->{'adv_dir'}_charadata_itemstock/$adv->{'id'}_itemstock.log";
	}
	# ファイルを開く (旧)
	else{
		$data{'file'} = "$adv->{'directory'}$adv->{'id'}_itemstock.log";
	}

	# ファイルを開く
	if($type{'File-check-error'}){
		$data{'f'} = open($stock_handler,"+<$data{'file'}") || main::error("ファイルが存在しません。");
	}
	else{
		$data{'f'} = open($stock_handler,"+<$data{'file'}");

			# ファイルが存在しない場合は新規作成
			if(!$data{'f'} && $type{'Renew'}){
				Mebius::Fileout("Allow-empty",$data{'file'});
				$data{'f'} = open($stock_handler,"+<$data{'file'}");
			}

	}

	# ファイルロック
	if($type =~ /Renew/){ flock($stock_handler,2); }

	# トップデータを分解
	chomp(my $top1 = <$stock_handler>);
	my($tkey) = split(/<>/,$top1);

	# ファイルを展開
	while(<$stock_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($item_session2,$item_number2,$item_name2,$item_damage2,$item_job2,$item_damage_plus2,$item_concept2) = split(/<>/);

			# 倉庫がいっぱいの場合
			if($type =~ /Buy-item/ && $i >= 200){
				close($stock_handler);
				main::error("倉庫がいっぱいでもう増やせません。どれかを捨ててください。");
			}

			# 武器を付け替える場合
			if($type =~ /Get-hash/){
					if($item_session eq $item_session2){
						$data{'item_number'} = $item_number2;
						$data{'item_name'} = $item_name2;
						$data{'item_damage'} = $item_damage2;
						$data{'item_job'} = $item_job2;
						$data{'item_damage_plus'} = $item_damage_plus2;
						$data{'item_concept'} = $item_concept2;
					}
			}

			# アイテムを交換する場合
			if($type =~ /Add-stock/){
					if($item_session eq $item_session2){ next; }
					#if("$adv->{'item_number'}>$adv->{'item_name'}>$adv->{'item_damage'}" eq "$item_number2>$item_name2>$item_damage2"){ next; }	# 同じ武器は増やさない
			}

			# アイテムを売る場合
			if($type =~ /Drop-stock/ && $item_session2 eq $item_session){
				next;
			}

			# 更新行を追加
			if($type =~ /Renew/){
				push(@renewline,"$item_session2<>$item_number2<>$item_name2<>$item_damage2<>$item_job2<>$item_damage_plus2<>$item_concept2<>\n");
			}

			# インデックス表示を取得
			if($type =~ /Get-index/){

				my($edit_input) = qq(<input type="radio" name="item_session" value="$item_session2" id="stock_$item_session2">) if($type =~ /Allow-edit/);
				$index_line .= qq(<tr><td>$edit_input);
				$index_line .= qq(<label for="stock_$item_session2"> $i．$item_name2);
				$index_line .= qq(</label></td>);
				$index_line .= qq(<td>威力 $item_damage2);
					if($item_damage_plus2){ $index_line .= qq( + $item_damage_plus2); }
				$index_line .= qq(</td></tr>\n);
			}

	}

		# ●ファイル更新
		if($type =~ /Renew/){

				# アイテムを倉庫に追加する場合
				if($type =~ /Add-stock/ && $adv->{'item_name'}){

					my($item_session) = Mebius::Crypt::char(undef,30);

					# 新しく追加する行
	unshift(@renewline,"$item_session<>$adv->{'item_number'}<>$adv->{'item_name'}<>$adv->{'item_damage'}<>$adv->{'item_job'}<>$adv->{'item_damage_plus'}<>$adv->{'item_concept'}<>\n");
				}

				# トップデータを追加
				if($tkey eq ""){ $tkey = 1; }
			unshift(@renewline,"$tkey<>\n");

			# 更新
			seek($stock_handler,0,0);
			truncate($stock_handler,tell($stock_handler));
			print $stock_handler @renewline;

		}

# ファイルを閉じる
close($stock_handler);

	# パーミッション変更
	if($type{'Renew'}){
		Mebius::Chmod(undef,$data{'file'});
	}


	# インデックスを返す
	if($type =~ /Get-index/){

		if($index_line){ $index_line = qq(<table summary="倉庫のアイテム" class="adventure">$index_line</table>); }
	
		if($index_line && $type =~ /Allow-edit/){
			$index_line = qq(
				<form action="$init->{'script'}" method="post"$main::sikibetu>
				<div>
				<input type="hidden" name="mode" value="item_buy"$main::xclose>
				<input type="hidden" name="type" value="change_item"$main::xclose>
				<input type="hidden" name="id" value="$advmy->{'id'}"$main::xclose>
				<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
				<input type="hidden" name="char" value="$advmy->{'char'}">
				$index_line
				<input type="submit" value="アイテムを交換する" class="isubmit"$main::xclose>
				　
				<input type="submit" name="drop_stock" value="アイテムを売る" class="isubmit"$main::xclose>
				<label>
				<input type="checkbox" name="sell_item_check" value="1"$main::xclose>
				私は、売却価格等には一切の異議を唱えないことに同意し、貴店に本アイテムを売却いたします。
			</label>
				</div>
				</form>
				);
		}

		return($index_line);
	}


	# ハッシュを返す
	if($type =~ /Get-hash/){
		return(\%data);
	}

}

1;
