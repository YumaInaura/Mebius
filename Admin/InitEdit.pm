
use Mebius::BBS;
use strict;
package Mebius::Admin::InitEdit;

#-----------------------------------------------------------
# 設定変更フォーム
#-----------------------------------------------------------
sub Start{

if($main::in{'type'} eq "edit_category"){ &EditCategory(); } 
if($main::in{'type'} eq "edit_bbs"){ &EditBBS(); } 
else{ &View(); }

exit;

}

#-----------------------------------------------------------
# 設定画面
#-----------------------------------------------------------
sub View{

# 宣言
my($line,$category_rule_textarea);
our($category,$moto);
my $bbs = Mebius::BBS->new();
my $bbs_kind = $bbs->root_bbs_kind();

# 権限チェック
if($main::admy_rank < $main::master_rank){ main::error("権限がありません。"); }

# CSS 定義
$main::css_text .= qq(
input.text{width:20%;}
input.on-off{width:5em;}
table,th,tr,td{border-style:none;}
table{}
);


# カテゴリ設定を読み込む
my($init_bbs) = Mebius::BBS::init_bbs(undef,$main::moto);
my($init_category) = Mebius::BBS::init_category(undef,$init_bbs->{'category'});

# テキストエリア整形
$category_rule_textarea = $init_category->{'rule'};
$category_rule_textarea =~ s/<br>/\n/g;
$category_rule_textarea = Mebius::escape("Not-br",$category_rule_textarea);

$line .= qq( <a href="$main::home?allcord=1">ＴＯＰに戻る</a>);
$line .= qq(　<a href="./$main::script">掲示板に戻る</a>);
$line .= qq(　<a href="/_${main::realmoto}/rule.html">ルールを表\示 [通常モード]</a>);

($line) .= &BBSForm();

$line .= qq(<h1>カテゴリ設定 ( $init_category->{'title'} カテゴリ - $main::bbs{'category'} )</h1>);
$line .= qq(<form action="$main::script" method="post">\n);
$line .= qq(<input type="hidden" name="mode" value="init_edit">\n);
$line .= qq(<input type="hidden" name="moto" value="$bbs_kind">\n);
$line .= qq(<input type="hidden" name="type" value="edit_category">\n);
$line .= qq(<input type="hidden" name="category" value="$main::category">\n);
$line .= qq(カテゴリ名<br$main::xclose><input type="text" name="title" value="$init_category->{'title'}"><br$main::xclose><br$main::xclose>);
$line .= qq(カテゴリコンセプト<br$main::xclose><input type="text" name="concept" value="$init_category->{'concept'}"><br$main::xclose><br$main::xclose>);
$line .= qq(削除依頼記事<br$main::xclose><input type="text" name="report_number" value="$init_category->{'report_number'}"><br$main::xclose><br$main::xclose>);
$line .= qq(参照する掲示板<br$main::xclose><input type="text" name="refer_bbs" value="$init_category->{'refer_bbs'}"><br$main::xclose><br$main::xclose>);
$line .= qq(ルール<br$main::xclose> <textarea name="rule" style="width:70%;height:200px;">$category_rule_textarea</textarea><br$main::xclose>);
$line .= qq(<input type="submit"  value="この内容で変更する"><br$main::xclose>);

$line .= qq(</form>);




my $print = qq($line);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# 掲示板の設定フォーム
#-----------------------------------------------------------
sub BBSForm{

# 宣言
my($line,$rule_textarea,$redcard_textarea);
my($textarea_first_input_textarea);

# 掲示板設定を取得
my($bbs) = Mebius::BBS::init_bbs("Get-hash",$main::realmoto);

# テキストエリア整形
$rule_textarea = $bbs->{'rule_text'};
$rule_textarea =~ s/<br>/\n/g;
$rule_textarea = Mebius::escape("Not-br",$rule_textarea);

# テキストエリア整形
$redcard_textarea = $bbs->{'redcard'};
$redcard_textarea =~ s/<br>/\n/g;
$redcard_textarea = Mebius::escape("Not-br",$redcard_textarea);

# テキストエリア整形
$textarea_first_input_textarea = $bbs->{'textarea_first_input'};
$textarea_first_input_textarea =~ s/<br>/\n/g;
$textarea_first_input_textarea = Mebius::escape("Not-br",$textarea_first_input_textarea);

# 説明文整形
my($bbs_setumei) = Mebius::escape("Not-br",$bbs->{'setumei'});

$line .= qq(<h1>掲示板設定 ( $bbs->{'title'} )</h1>);

$line .= qq(<table>);

$line .= qq(<form action="$main::script" method="post">\n);
$line .= qq(<input type="hidden" name="mode" value="init_edit">\n);
$line .= qq(<input type="hidden" name="type" value="edit_bbs">\n);
$line .= qq(<input type="hidden" name="moto" value="$main::realmoto">\n);

$line .= qq(<tr>\n);
$line .= qq(<td>掲示板名</td>);
$line .= qq(<td><input type="text" name="title" value="$bbs->{'title'}" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>掲示板名(ヘッダ)</td>\n);
$line .= qq(<td><input type="text" name="head_title" value="$bbs->{'head_title'}" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>CSS </td>\n);
$line .= qq(<td><input type="text" name="style" value="$bbs->{'style'}" class="text">);
$line .= qq( <span class="guide">※例 /style/blue1.css </span>);
$line .= qq(</td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>秘密 </td>\n);
$line .= qq(<td><input type="text" name="secret_mode" value="$bbs->{'secret_mode'}" class="text">);
$line .= qq( <span class="guide"> ※例： aura など文字列を設定。</span></td>\n);
$line .= qq(</tr\n);

$line .= qq(<tr>\n);
$line .= qq(<td>説明文</td>\n);
$line .= qq(<td><input type="text" name="setumei" value="$bbs_setumei" class="text"></td>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>コンセプト</td>\n);
$line .= qq(<td><input type="text" name="concept" value="$bbs->{'concept'}" class="text" style="width:60%;"><br$main::xclose>\n);
$line .= qq(<span class="guide">);
$line .= qq(Upload-mode アップロード許可);
$line .= qq( / Local-mode ローカルモード);
$line .= qq( / Chat-mode チャットモード);
$line .= qq( / Sousaku-mode 創作 / Noads-mode 広告なし );
$line .= qq( / Strong-penalty 強ペナルティ );
$line .= qq(</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>カテゴリ</td>\n);
$line .= qq( <td><input type="text" name="category" value="$bbs->{'category'}" class="text">);
$line .= qq( <span class="guide"> ※半角英数字で設定。</span></td>\n);
$line .= qq(</tr>\n);


$line .= qq(<tr>\n);
$line .= qq(<td>一律チャージ時間（レス） </td>\n);
$line .= qq( <td><input type="text" name="norank_wait" value="$bbs->{'norank_wait'}" class="text">);
$line .= qq( <span class="guide">※1 … noindex,nofollow</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>新規投稿の待ち時間（特殊） </td>\n);
$line .= qq( <td><input type="text" name="new_wait" value="$bbs->{'new_wait'}" class="text">);
$line .= qq( <span class="guide">※半角数字、時間で設定。</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>最大文字数(レス) </td>\n);
$line .= qq( <td><input type="text" name="max_msg" value="$bbs->{'max_msg'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>最小文字数(レス) </td>\n);
$line .= qq( <td><input type="text" name="min_msg" value="$bbs->{'min_msg'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>掲示板ひとつあたりの最大記事数 </td>\n);
$line .= qq( <td><input type="text" name="i_max" value="$bbs->{'i_max'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>記事ひとつあたりの最大レス数 </td>\n);
$line .= qq( <td><input type="text" name="m_max" value="$bbs->{'m_max'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>ホームＵＲＬ </td>\n);
$line .= qq( <td><input type="text" name="home" value="$bbs->{'home'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>ロボットよけ </td>\n);
$line .= qq( <td><input type="text" name="noindex_flag" value="$bbs->{'noindex_flag'}" class="text">);
$line .= qq( <span class="guide">※1 … noindex,nofollow</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>リダイレクト </td>\n);
$line .= qq( <td><input type="text" name="bbs_redirect" value="$bbs->{'bbs_redirect'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>拡張過去ログの個数 </td>\n);
$line .= qq( <td><input type="text" name="past_num" value="$bbs->{'past_num'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>レスチャージ時間のボーナス秒数 </td>\n);
$line .= qq( <td><input type="text" name="plus_bonus" value="$bbs->{'plus_bonus'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>広告消去 </td>\n);
$line .= qq( <td><input type="text" name="noads_mode" value="$bbs->{'noads_mode'}" class="text"></td><br$main::xclose><br$main::xclose>);

$line .= qq(<tr>\n);
$line .= qq(<td>レス修正モード </td>\n);
$line .= qq( <td><input type="text" name="resedit_mode" value="$bbs->{'resedit_mode'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>サブ記事リンクモード </td>\n);
$line .= qq( <td><input type="text" name="subtopic_link" value="$bbs->{'subtopic_link'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>IDの素（特殊） </td>\n);
$line .= qq( <td><input type="text" name="another_idsalt" value="$bbs->{'another_idsalt'}" class="text">);
$line .= qq( <span class="guide">※英数字２文字</span></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>削除依頼先の記事（特殊） </td>\n);
$line .= qq( <td><input type="text" name="report_thread_number" value="$bbs->{'report_thread_number'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>記事主のレス削除権</td>\n);
$line .= qq( <td><input type="text" name="allow_thread_master_delete" value="$bbs->{'allow_thread_master_delete'}" class="text"></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr id="RULE">\n);
$line .= qq(<td>ルール</td>);
$line .= qq(<td><textarea name="rule_text" style="width:90%;height:200px;">$rule_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>記事本文の初期入力</td>);
$line .= qq(<td><textarea name="textarea_first_input" style="width:90%;height:50px;">$textarea_first_input_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td>管理テンプレ</td>);
$line .= qq(<td><textarea name="redcard" style="width:90%;height:50px;">$redcard_textarea</textarea></td>);
$line .= qq(</tr>\n);

$line .= qq(<tr>\n);
$line .= qq(<td></td>\n);
$line .= qq(<td><input type="submit"  value="この内容で変更する"></td>);
$line .= qq(</tr>\n);

$line .= qq(</form>);

$line .= qq(</table>);

return($line);


}

#-----------------------------------------------------------
# カテゴリ設定を変更
#-----------------------------------------------------------
sub EditCategory{

# 宣言
my(%renew);

# 各種エラー
if($main::in{'report_number'} =~ /\D/){ main::error("削除依頼記事のナンバーは半角数字で指定してください。"); }
if($main::in{'concept'} =~ /[^\w\s\-\.]/){ main::error("カテゴリコンセプトは英数字/半角スペース/半角ハイフン/ピリオドのみで記入してください。"); }

# 定義
if($main::in{'title'}){ $renew{'title'} = $main::in{'title'}; } else { $renew{'title'} = ""; }
if($main::in{'report_number'}){ $renew{'report_number'} = $main::in{'report_number'}; } else { $renew{'report_number'} = ""; }
if($main::in{'rule'}){ $renew{'rule'} = $main::in{'rule'}; } else { $renew{'rule'} = ""; }
if($main::in{'refer_bbs'}){ $renew{'refer_bbs'} = $main::in{'refer_bbs'}; } else { $renew{'refer_bbs'} = ""; }
if($main::in{'concept'}){ $renew{'concept'} = $main::in{'concept'}; } else { $renew{'concept'} = ""; }

# 変換
($renew{'rule'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'rule'});

# 危険なタグを排除
Mebius::DangerTag("Error-view","$renew{'rule'}");

# カテゴリ設定を更新
Mebius::BBS::init_category("Renew",$main::in{'category'},%renew);

# リダイレクト
Mebius::Redirect(undef,"./$main::script?mode=init_edit");

exit;

}

#-----------------------------------------------------------
# 掲示板設定を変更
#-----------------------------------------------------------
sub EditBBS{

# 宣言
my(%renew);

# 各種エラー
if($main::in{'concept'} =~ /[^0-9a-zA-Z\-_\s\.]/){ main::error("コンセプトは英数字記号で入力してください。 ($main::in{'concept'})"); }


	# 更新内容の定義
	if(defined($main::in{'title'})){ $renew{'title'} = $main::in{'title'}; } else { $renew{'title'} = ""; }
	if(defined($main::in{'head_title'})){ $renew{'head_title'} = $main::in{'head_title'}; } else { $renew{'head_title'} = ""; }
	if(defined($main::in{'concept'})){ $renew{'concept'} = $main::in{'concept'}; } else { $renew{'concept'} = ""; }
	if(defined($main::in{'category'})){ $renew{'category'} = $main::in{'category'}; } else { $renew{'category'} = ""; }
	if(defined($main::in{'style'})){ $renew{'style'} = $main::in{'style'}; } else { $renew{'style'} = ""; }
	if(defined($main::in{'setumei'})){ $renew{'setumei'} = $main::in{'setumei'}; } else { $renew{'setumei'} = ""; }
	if(defined($main::in{'rule_text'})){ $renew{'rule_text'} = $main::in{'rule_text'}; } else { $renew{'rule_text'} = ""; }
	if(defined($main::in{'textarea_first_input'})){ $renew{'textarea_first_input'} = $main::in{'textarea_first_input'}; } else { $renew{'textarea_first_input'} = ""; }
	if(defined($main::in{'redcard'})){ $renew{'redcard'} = $main::in{'redcard'}; } else { $renew{'redcard'} = ""; }
	if(defined($main::in{'noads_mode'})){ $renew{'noads_mode'} = $main::in{'noads_mode'}; } else { $renew{'noads_mode'} = ""; }
	if(defined($main::in{'resedit_mode'})){ $renew{'resedit_mode'} = $main::in{'resedit_mode'}; } else { $renew{'resedit_mode'} = ""; }
	if(defined($main::in{'subtopic_link'})){ $renew{'subtopic_link'} = $main::in{'subtopic_link'}; } else { $renew{'subtopic_link'} = ""; }
	if(defined($main::in{'noindex_flag'})){ $renew{'noindex_flag'} = $main::in{'noindex_flag'}; } else { $renew{'noindex_flag'} = ""; }
	if(defined($main::in{'secret_mode'})){ $renew{'secret_mode'} = $main::in{'secret_mode'}; } else { $renew{'secret_mode'} = ""; }
	if(defined($main::in{'past_num'})){ $renew{'past_num'} = $main::in{'past_num'}; } else { $renew{'past_num'} = ""; }
	if(defined($main::in{'plus_bonus'})){ $renew{'plus_bonus'} = $main::in{'plus_bonus'}; } else { $renew{'plus_bonus'} = ""; }
	if(defined($main::in{'bbs_redirect'})){ $renew{'bbs_redirect'} = $main::in{'bbs_redirect'}; } else { $renew{'bbs_redirect'} = ""; }
	if(defined($main::in{'another_idsalt'})){ $renew{'another_idsalt'} = $main::in{'another_idsalt'}; } else { $renew{'another_idsalt'} = ""; }
	if(defined($main::in{'report_thread_number'})){ $renew{'report_thread_number'} = $main::in{'report_thread_number'}; } else { $renew{'report_thread_number'} = ""; }
	if(defined($main::in{'new_wait'})){ $renew{'new_wait'} = $main::in{'new_wait'}; } else { $renew{'new_wait'} = ""; }
	if(defined($main::in{'norank_wait'})){ $renew{'norank_wait'} = $main::in{'norank_wait'}; } else { $renew{'norank_wait'} = ""; }
	if(defined($main::in{'i_max'})){ $renew{'i_max'} = $main::in{'i_max'}; } else { $renew{'i_max'} = ""; }
	if(defined($main::in{'m_max'})){ $renew{'m_max'} = $main::in{'m_max'}; } else { $renew{'m_max'} = ""; }
	if(defined($main::in{'max_msg'})){ $renew{'max_msg'} = $main::in{'max_msg'}; } else { $renew{'max_msg'} = ""; }
	if(defined($main::in{'min_msg'})){ $renew{'min_msg'} = $main::in{'min_msg'}; } else { $renew{'min_msg'} = ""; }
	if(defined($main::in{'home'})){ $renew{'home'} = $main::in{'home'}; } else { $renew{'home'} = ""; }
	if(exists $main::in{'allow_thread_master_delete'}){ $renew{'allow_thread_master_delete'} = $main::in{'allow_thread_master_delete'}; }

# タグを有効にする場合
($renew{'rule_text'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'rule_text'});
($renew{'textarea_first_input'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'textarea_first_input'});
($renew{'redcard'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'redcard'});
($renew{'setumei'}) = Mebius::Descape("Not-br Deny-diamond",$renew{'setumei'});

# 危険なタグを排他
Mebius::DangerTag("Error-view",$renew{'rule_text'});
Mebius::DangerTag("Error-view",$renew{'textarea_first_input'});
Mebius::DangerTag("Error-view",$renew{'redcard'});
Mebius::DangerTag("Error-view",$renew{'setumei'});


# カテゴリ設定を更新
Mebius::BBS::init_bbs("Renew",$main::in{'moto'},%renew);

# リダイレクト
Mebius::Redirect(undef,"./$main::script?mode=init_edit");

exit;

}



1;
