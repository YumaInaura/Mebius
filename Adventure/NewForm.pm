
use Mebius::RegistCheck;
use strict;
package Mebius::Adventure;
use Mebius::Export;

#-----------------------------------------------------------
# 新規登録フォーム
#-----------------------------------------------------------
sub NewForm{

# 宣言
my($init) = &Init();
my($randid,$randpass,$randname,$point);
our($advmy);

# CSS定義
$main::css_text .= qq(
table.select_skill{border-style:none;}
td.select_skill_sub{border-style:none;width:70px;background:#8bf;}
td.select_skill{border-style:none;width:70px;}
table.newmake,td.newmake{border-style:none;}
);

# タイトル定義
$main::sub_title = qq(新規登録 | $main::title);
$main::head_link3 = qq(&gt; 新規登録);

	# アカウントにログインしていない場合
	if(!$main::myaccount{'file'}){ main::error("キャラクタを新規作成するには、アカウントにログイン（または新規登録）してください。","401"); }

# キャラクタファイルを取得
my($adv) = &File("",{ FileType => "Account" , id => $main::myaccount{'file'} });

	# 既にキャラクターが存在する場合
	if($adv->{'f'}) {
			if(Mebius::alocal_judge() && 1 == 0){ unlink($adv->{'file'}); }
			else{ 
				Mebius::Redirect(undef,$init->{'base_url'});
				main::error(qq(あなたは既にキャラクタを作成しています。<a href="$init->{'script'}?mode=login">マイキャラクターへ</a>));
		}
	}

# 職業リストを取得
require Mebius::Adventure::Job;
my($jobflag,$jobline,$job_select,$job_list) = &SelectJob("");


	# パス初期入力
	if($main::alocal_mode){
		$randname = qq(テスター) . int(rand(9999))
	}


my $print .= <<"EOM";
<h1>キャラクタ作成</h1>
<form action="$init->{'script'}" method="post"$main::sikibetu>
<input type="hidden" name="mode" value="make_end">
<table class="newmake">

<tr>
<td class="newmake">アカウント</td>
<td class="newmake"><a href="${main::auth_url}$main::myaccount{'file'}/" target="_blank" class="blank">$main::myaccount{'file'}</a> </td>
</tr>

<tr>
<td class="newmake">キャラクターの名前</td>
<td class="newmake"><input type="text" name="c_name" size="30" value="$randname"></td>
</tr>


<tr>
<td class="newmake">キャラクターの性別</td>
<td class="newmake">
<label><input type="radio" name="sex" value="1"$main::parts{'checked'}>男</label>
<label><input type="radio" name="sex" value="0">女</label>
</td>
</tr>
EOM


$print .= <<"EOM";
<tr>
<td>職業</td>
<td>
<label><input type="radio" name="new_job" value="0"$main::parts{'checked'}$main::xclose>戦士</label>
<label><input type="radio" name="new_job" value="1"$main::xclose>魔法使い</label>
<label><input type="radio" name="new_job" value="2"$main::xclose>僧侶</label>
<label><input type="radio" name="new_job" value="3"$main::xclose>盗賊</label>
</td>
</tr>
<tr>
<td colspan="2" class="newmake"><input type="submit" value="この内容でキャラクターを作成"></td>
</tr>
</table>
<input type="hidden" name=point value="$point">
</form>
EOM

# 職業リスト
#print qq(
#<h2>職業リスト</h2>
#$job_list
#);



# フッター
Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# キャラクタ作成、登録完了 
#-----------------------------------------------------------
sub NewCharaMake{

# 宣言
my($init) = &Init();
my($jobflag,%adv);

# アクセス制限
main::axscheck("Post-only ACCOUNT");

# 各種エラー
require "${main::int_dir}regist_allcheck.pl";
($main::in{'c_name'}) = shift_jis(Mebius::Regist::name_check($main::in{'c_name'}));
	if($main::in{'c_name'} eq "") { main::error("キャラクターの名前が未記入です"); }

$main::in{'c_name'} =~ s/(★|☆)//g;
($main::in{'c_name'}) = split(/#/,$main::in{'c_name'});

# キャラクタファイルを作成
&NewCharacterMake(undef,{ FileType => "Account" , id => $main::myaccount{'file'} , sex => $main::in{'sex'} , job => $main::in{'new_job'} , name => $main::in{'c_name'}  });


my $print = <<"EOM";
<h1>登録完了画面</h1>
<div>新規登録が完了しました！</div>
$init->{'continue_button'}
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;
}


1;
