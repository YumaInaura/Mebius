
package Mebius::BBS;
use strict;

use Mebius::BasicInit;
use Mebius::Basic;

use Mebius::BBS::Thread;
use Mebius::BBS::Res;
use Mebius::BBS::Status;
use Mebius::BBS::Wait;
use base qw(Mebius::Base::Basic);

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
sub main_limited_package_name{
"bbs";
}

#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub database_objects{

my(@object);

push @object , new Mebius::BBS::Wait;
push @object , new Mebius::BBS::Res;

@object;

}


#-----------------------------------------------------------
#
#-----------------------------------------------------------
sub limited_all_objects{

my $self = shift;
my(%object);

$object{'thread'} = new Mebius::BBS::Thread;

\%object;

}


#-----------------------------------------------------------
# 処理スタート - strict
#-----------------------------------------------------------
sub start{

# 宣言
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();

# 掲示板用の設定を取り込み
main::init_start_bbs();

	# 各種補足設定
	if($ENV{'CONTENT_TYPE'} =~ /^multipart\/form-data;/ && $main::bbs{'concept'} !~ /Upload-mode/){ &error("このコンテンツではアップロードできません。"); }

	# モード振り分け
	if($param->{'mode'} eq "view"){
		if($main::in{'r'} eq "support"){ require "$basic_init->{'init_directory'}part_crap.pl"; main::bbs_support(); }
		elsif($main::in{'r'} eq "data"){ require "$basic_init->{'init_directory'}part_data.pl"; main::bbs_view_data(); }
		elsif($main::in{'r'} eq "memo"){ require "$basic_init->{'init_directory'}part_memo.pl"; main::bbs_memo(); }
		else{ require "$basic_init->{'init_directory'}part_view.pl"; main::bbs_view_thread(); }
	}
	elsif($param->{'mode'} eq "kview" || $param->{'mode'} eq "kindex" || $param->{'mode'} eq "kfind" || $param->{'mode'} eq "kform" || $param->{'mode'} eq "krule" || $param->{'mode'} eq "kruleform") {

		# デスクトップ版のURLとまとめる ( リダイレクト )
		Mebius::BBS::UnifyMobileURL();

		#if($main::in{'r'} eq "support"){ require "$basic_init->{'init_directory'}part_support.pl"; &bbs_support(); }
		#elsif($main::in{'r'} eq "data"){ require "$basic_init->{'init_directory'}part_data.pl"; &bbs_view_data(); }
		#elsif($main::in{'r'} eq "memo"){ require "$basic_init->{'init_directory'}part_memo.pl"; &bbs_memo(); }
		#else{ require "$basic_init->{'init_directory'}k_view.pl"; &bbs_view_thread_mobile(); }
	}
	if($param->{'mode'} eq "support"){ require "$basic_init->{'init_directory'}part_crap.pl"; main::bbs_support(); }
	#elsif($param->{'mode'} eq "kindex") { require "$basic_init->{'init_directory'}k_indexview.pl"; &view_kindexview("VIEW"); }
	#elsif($param->{'mode'} eq "form" || $param->{'mode'} eq "ruleform") { require "$basic_init->{'init_directory'}part_newform.pl"; main::bbs_newform(); }
	elsif($param->{'mode'} eq "form") { require "$basic_init->{'init_directory'}part_newform.pl"; main::bbs_last_newform(); }
	elsif($param->{'mode'} eq "ruleform") { require "$basic_init->{'init_directory'}part_newform.pl"; main::bbs_newform(); }

	#elsif($param->{'mode'} eq "kfind") { require "$basic_init->{'init_directory'}k_find.pl"; main::bbs_find_mobile(); }
	elsif($main::submode1 eq "kpt"){ require "$basic_init->{'init_directory'}k_past.pl"; main::bbs_view_past_mobile(); }
	elsif($main::submode1 eq "feed"){ require "$basic_init->{'init_directory'}part_feed.pl"; main::bbs_view_feed(); }
	elsif($main::submode1 eq "ranking"){ require "$basic_init->{'init_directory'}part_handle_ranking.pl"; Mebius::BBS::HandleRankingIndex(); }
	elsif($param->{'mode'} eq "rule") { require "$basic_init->{'init_directory'}part_rule.pl"; main::bbs_rule_view(); }
	elsif($param->{'mode'} eq "tmove") { require "$basic_init->{'init_directory'}part_tmove.pl"; main::bbs_tmove(); }
	elsif($param->{'mode'} eq "cermail") { require "$basic_init->{'init_directory'}part_cermail.pl"; Mebius::Email::CermailStart(); }
	elsif($param->{'mode'} eq "Nojump") { require "$basic_init->{'init_directory'}part_Nojump.pl"; main::bbs_number_jump(); }
	elsif($param->{'mode'} eq "resedit") { require "$basic_init->{'init_directory'}part_resedit.pl"; main::thread_resedit(); }
	elsif($param->{'mode'} eq "mylist") { require "$basic_init->{'init_directory'}part_mylist.pl"; main::bbs_mylist(); }
	elsif($param->{'mode'} eq "resdelete") { require "$basic_init->{'init_directory'}part_resdelete.pl"; main::bbs_res_selfdelete(); }
	elsif($param->{'mode'} eq "member") { require "$basic_init->{'init_directory'}part_memberlist.pl"; main::bbs_memberlist(); }
	elsif($param->{'mode'} eq "scmail") { require "$basic_init->{'init_directory'}part_scmail.pl"; main::bbs_scmail(); }
	elsif($param->{'mode'} eq "find" || $param->{'mode'} eq "oldpast") { require "$basic_init->{'init_directory'}part_indexview.pl"; main::bbs_view_indexview(); }
	elsif($main::submode1 eq "past") { require "$basic_init->{'init_directory'}part_pastindex.pl"; Mebius::BBS::PastIndexView("Select-BBS-view"); }
	elsif($param->{'mode'} =~ /^(random|link|my)$/) { require "$basic_init->{'init_directory'}part_etcmode.pl"; main::etc_mode(); }
	elsif($param->{'mode'} eq "regist" || $param->{'mode'} eq "regist_resedit"){ require "$basic_init->{'init_directory'}part_regist.pl"; main::bbs_regist(); }
	#elsif($param->{'mode'} eq "regist_resedit"){ require "$basic_init->{'init_directory'}part_regist.pl"; main::bbs_regist(); }
	else{ require "$basic_init->{'init_directory'}part_indexview.pl"; main::bbs_view_indexview(); }

exit;

}

#-----------------------------------------------------------
# 掲示板関係の基本ディレクトリ名
#-----------------------------------------------------------
sub directory_path{

my(%self);
my($init_directory) = Mebius::BaseInitDirectory();

$self{'init_bbs'} = "${init_directory}_init_bbs/";
$self{'init_category'} = "${init_directory}_init_category/";

\%self;

}


#-----------------------------------------------------------
# ファイル名を取得
#-----------------------------------------------------------
sub InitFileName{

# 宣言
my($type,$moto,$thread_number) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($directory_path) = Mebius::BBS::directory_path();
my($path) = Mebius::BBS::path($moto);
my(%self);

	# 汚染チェック
	if($moto =~ /\W/){ return(); }

	# 設定ファイル
	if($directory_path->{'init_bbs'}){
		$self{'file'} = "$directory_path->{'init_bbs'}$moto.ini";
	} else{
		die("Perl Die! Can't get BBS Directory path.");
	}

# データディレクトリ
my($bbs_path) = Mebius::BBS::path($moto);
$self{'data_directory'} = $bbs_path->{'base_directory'};

# スレッドのログディレクトリ ( まだ BBS特有の data_directory 内には移動していない )
($self{'thread_log_directory'}) = Mebius::BBS::thread_directory_path($moto);

	# スレッドファイル
	if($thread_number && $thread_number =~ /^\d+$/){ $self{'thread_file'} = "$self{'thread_log_directory'}/$thread_number.cgi"; }

%self = (%$path,%self);

return(\%self);

}


#-----------------------------------------------------------
# 簡易フィルタの判定
#-----------------------------------------------------------
sub Fillter_id{

# 宣言
my($type,$fillter,$target_id) = @_;
my($filled_flag);

	# フィルタ設定を展開
	foreach(split(/\s/,$fillter)){
			if($target_id =~ /^([A-Z]+(=|-))?${_}(_[0-9a-zA-Z]{2,3})?$/){ $filled_flag = 1; }
	}

return($filled_flag);

}
#-----------------------------------------------------------
# 簡易フィルタの判定
#-----------------------------------------------------------
sub Fillter_account{

# 宣言
my($type,$fillter,$target_account) = @_;
my($filled_flag);

	# フィルタ設定を展開
	foreach(split(/\s/,$fillter)){
		if($target_account eq $_){ $filled_flag = 1; }
	}

return($filled_flag);

}

#-----------------------------------------------------------
# 本文のコンセプト
#-----------------------------------------------------------
sub CommentStyle{

# 宣言
my($type,$res_concept,$color) = @_;
my($comment_style,$comment_style_in);

	if($res_concept =~ /Fontfamily<(.+)>/){ $comment_style_in .= qq(font-family:$1;); }
	if($color =~ /\#?([0-9a-f]{3,6})/){ $comment_style_in .= qq(color:#$1;); 	}
	if($comment_style_in){ $comment_style = qq( style="$comment_style_in"); }

return($comment_style,$comment_style_in);

}




#-----------------------------------------------------------
# 掲示板名の配列
#-----------------------------------------------------------
sub BBSNameAray{

# 宣言
my($type,$select_category,$aray_type_foreach_category,$bbs_data_from_dbi) = @_;
my($get_all_category_flag,%category);

	# トップページ用
	if($type =~ /Get-top-page-link/){
			my($index_line) = ForeachIndexCategory($aray_type_foreach_category,$select_category,$bbs_data_from_dbi);
			return($index_line);
	}

	# 特定カテゴリの配列を返す
	if($type =~ /Get-array/){
		my($category) = all_bbs_hash_per_category();
			if(ref $category->{$select_category} eq "ARRAY"){
				return(@{$category->{$select_category}});
			} else {
				return([]);
			}
	}


}



#-----------------------------------------------------------
# 掲示板が設定に存在するかどうかを確認
#-----------------------------------------------------------
sub bbs_exists_check{

my($bbs_kind) = @_;
my($exists_flag);
my $bbs_status = new Mebius::BBS::Status;

	if($bbs_kind eq ""){ return(); }

my($all_bbs_hash) = Mebius::BBS::all_bbs_hash();

my $bbs_exists_on_dbi = $bbs_status->fetchrow_on_hash_main_table($bbs_kind);

	if($all_bbs_hash->{$bbs_kind} || $bbs_exists_on_dbi->{$bbs_kind}){
		$exists_flag = 1;
	}

$exists_flag;

}



#-----------------------------------------------------------
# カテゴリを展開するコア処理
#-----------------------------------------------------------
sub ForeachIndexCategory{

# 宣言
my($type,$select_category,$bbs_data_on_dbi) = @_;
my(%type);
my($my_use_device) = Mebius::my_use_device();
foreach(split(/\s/,$type)){	$type{$_} = 1; } # 処理タイプを展開
my($line,%hash);
my($param) = Mebius::query_single_param();
my($category_data) = all_bbs_hash_per_category();
my $html = new Mebius::HTML;

	# カテゴリ展開
	foreach(@{$category_data->{$select_category}}){

			# ●インデックス取得用
			if($type{'Get-index'}){

				my($style_inline,$class,$font_size,$souko_flag);
				my $bbs_data = $bbs_data_on_dbi->{$_->{'kind'}};

					# 最近書き込まれた時刻を元に、各掲示板リンクの文字サイズを変更する ( ホットな掲示板ほど、フォントを大きく )
					if($_->{'Close'}){
						next;
					} elsif($_->{'Hidden'}){
						$souko_flag = 1;
					} elsif($bbs_data->{'regist_time'} >= time - 5*60){
						$font_size = 150;
					} elsif($bbs_data->{'regist_time'} >= time - 30*60){
						$font_size = 135;
					} elsif($bbs_data->{'regist_time'} >= time - 1*60*60){
						$font_size = 120;
					} elsif($bbs_data->{'regist_time'} >= time - 1*24*60*60){
						0;
					} elsif($bbs_data->{'regist_time'} >= time - 2*24*60*60){
						$font_size = 80;
					} elsif($bbs_data->{'regist_time'} >= time - 7*24*60*60){
						$font_size = 50;
					} elsif($select_category !~ /^(mebi|aura)$/) {
						$souko_flag = 1;
						$font_size = 50;
					}

					if($font_size){
						$style_inline = "font-size:${font_size}%;"
					}

					if($souko_flag){
						$class = "green";
					}

				my($link) = $html->href("/_$_->{'kind'}/",$_->{'title'},{ style => $style_inline , class => $class });

					if($souko_flag){
							if($param->{'all_view'}){
								$line .= $link;
							} else {
								next;
							}
					} else {
						$line .= $link;
					}

			}

		$line .= qq(\n);

	}

	# インデックス取得用 ( 整形 )
	if($type{'Get-index'}){
			if($line){
					if($my_use_device->{'smart_flag'}){
						$line = qq(<span>$line</span>);
					}
					else {
						$line = qq(<div class="indent3">$line</div>);
					}
			}
		return($line);
	}

}


#-----------------------------------------------------------
# 掲示板の投稿順位等
#-----------------------------------------------------------
sub AllBBSSortFile{

# 宣言
my($type) = @_;
my($i,@renew_line,%data,$file_handler);
my($init_directory) = Mebius::BaseInitDirectory();

# ファイル定義
my $directory1 = "${init_directory}_bbs_data_all/";
my $file1 = "${directory1}all_sort_bbs.log";

# 最大行を定義
my $max_line = 50;

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"+<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"+<$file1") && ($data{'f'} = 1);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,2); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$moto2,$title2,$last_res_time2,$last_post_time2,$all_res2) = split(/<>/);

			# 更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$key2<>$moto2<>$title2<>$last_res_time2<>$last_post_time2<>$all_res2<>\n");

			}

	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>$main::time<>\n");

		# ファイル更新
		seek($file_handler,0,0);
		truncate($file_handler,tell($file_handler));
		print $file_handler @renew_line;
		close($file_handler);
		Mebius::Chmod(undef,$file1);

	}


close($file_handler);


	# 新しい行を追加
	if($type =~ /New-line/){

		unshift(@renew_line,"<><><><><><>\n");

	}

return(%data);

}

#-----------------------------------------------------------
# 携帯のURLをデスクトップ版にリダイレクトしてまとめる
#-----------------------------------------------------------
sub UnifyMobileURL{

# 宣言
my($use) = @_;
my($redirect_url);

# REQUEST_URI を定義
my $request = $ENV{'REQUEST_URI'};

	# URLを整形

	# 掲示板メニュー
	if($request =~ s! /_([0-9a-z]+)/km([0-9]+)\.html$ !/_$1/m$2.html!x){
			# ページ数が 0 の場合は、掲示板TOPのURLにリダイレクト
			if($2 eq "0"){ $request =~ s/m([0-9])(\.html)$//g; }
	}

	# スレッド
	$request =~ s! ^/_([0-9a-z]+)/k([0-9a-z_\-]+)\.html(\-[0-9,\-]+)? !/_$1/$2.html$3!x;

	# 各種モード
	$request =~ s! /_([0-9a-z]+)/k(find|form|rule|ruleform)\.html !/_$1/$2.html!x;

	# スレッド内検索など
	$request =~ s! mode=k(view|find) !mode=$1!x;

# 現在のURLを取得
my($server_url) = Mebius::server_url();
my $redirect_url = "$server_url$request";


# リダイレクト先
Mebius::Redirect(301,$redirect_url);


}

#-----------------------------------------------------------
# $moto から $realmoto を定義
#-----------------------------------------------------------
sub RealMoto{

my($use,$moto) = @_;

(my $realmoto = $moto) =~ s/^sub//g;

$realmoto;

}



#-----------------------------------------------------------
# 同一の処理
#-----------------------------------------------------------
sub real_bbs_kind{
	if(ref $_[0] eq __PACKAGE__){ die("This sub routin is not for object. Please use object named 'root_bbs_kind'. "); }
my($self) = RealMoto(undef,$_[0]);
$self;
}


#-----------------------------------------------------------
# サブ掲示板かどうかを判定 ( オート )
#-----------------------------------------------------------
sub sub_bbs_judge_auto{

my($param) = Mebius::query_single_param();
my($flag) = Mebius::BBS::sub_bbs_judge($param->{'moto'});

$flag;

}

#-----------------------------------------------------------
# サブ掲示板かどうかを判定
#-----------------------------------------------------------
sub sub_bbs_judge{

if($_[0] =~ /^sub(\w+)$/){ return 1; }

}


#-----------------------------------------------------------
# 掲示板用のスクリプトであることを判定する
#-----------------------------------------------------------
sub bbs_script_judge{

my($flag);

	if($ENV{'SCRIPT_NAME'} =~ m!/bbs.cgi$!){
		$flag = 1;
	}

$flag;

}


#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new{
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 掲示板の種類を取得する
#-----------------------------------------------------------
sub root_bbs_kind{

my $self = shift;
my $root_bbs_kind = $self->true_bbs_kind();

$root_bbs_kind =~ s/^sub//g;

$root_bbs_kind;

}

#-----------------------------------------------------------
# 掲示板の種類を取得する
#-----------------------------------------------------------
sub true_bbs_kind{

my $self = shift;
my $bbs_kind;
my($param) = Mebius::query_single_param();

	if($param->{'moto'} =~ /^([0-9a-z]+)$/){
		$bbs_kind = $param->{'moto'};
	} else {
		0;
	}

$bbs_kind;

}

#-----------------------------------------------------------
# bbs_kind から掲示板のカテゴリ設定を取得
#-----------------------------------------------------------
sub init_category_parmanent_auto{

my $self = shift;
my $bbs_kind = $self->root_bbs_kind();

	if(!$bbs_kind){ return(); }

# カテゴリデータを取得
my($category_data) = init_category_parmanent_from_bbs_kind($bbs_kind);
$category_data;

}


#-----------------------------------------------------------
# HTMLを出力する
#-----------------------------------------------------------
sub print_html_all{

my $self = shift;
my $print = shift;
my $use = shift if(ref $_[0] eq "HASH");
my $operate = Mebius::Operate->new();
my(@BCL);

# カテゴリ設定を取得して、パンくずリストのリンクを定義する
my $init_category = $self->init_category_parmanent_auto();
my $category_title = $init_category->{'title'};

# 掲示板の設定を取得
my $init_bbs = init_bbs_parmanent_auto();

# 掲示板のURLを取得
my $bbs_path = Mebius::BBS::Path->new($init_bbs->{'kind'});
my $bbs_url = $bbs_path->bbs_url_adjusted();
my $title = $init_bbs->{'title'};

	# 文字コード
	if($use->{'source'} eq "utf8"){
		utf8($title,$category_title);
	}

push @BCL , { url => "/_category/$init_category->{'name'}/" , title => $category_title };

	if($use->{'bbs_top_flag'}){
		push @BCL , $title;
	} else {
		push @BCL , { url => $bbs_url , title => $title };
	}

	# 元からのBCL設定を追加
	if(ref $use->{'BCL'} eq "ARRAY"){ push @BCL , @{$use->{'BCL'}}; }

# ハッシュを上書き
my $overwrited_use = $operate->overwrite_hash($use,{ BCL => \@BCL , NotDefaultBCL => 1 });

# HTMLを出力
Mebius::Template::gzip_and_print_all($overwrited_use,$print);

}


#-----------------------------------------------------------
# 全掲示板のメニュー設定
#-----------------------------------------------------------
sub all_bbs_hash_per_category{

my %category;
my $self = shift;

$category{'aura'} =
[
{ kind => 'ams' , title => 'あうら歌' },
{ kind => 'asd' , title => '歌2' },
{ kind => 'asx' , title => '依' },
{ kind => 'acm' , title => '４コマ漫画' },
{ kind => 'amb' , title => 'メビ日記' },
{ kind => 'aal' , title => '作1' },
];

$category{'poemer'} = [
{ kind => 'toukoujou' , title => '詩1' },
{ kind => 'doudoujou' , title => '詩2' },
{ kind => 'saikoujou' , title => '詩(隠)' },
{ kind => 'rouroujou' , title => '詩(思)' , option => 'Souko' },

{ kind => 'prs' , title => 'プロ詩' },
{ kind => 'ska' , title => '感想詩' },
{ kind => 'ssh' , title => '詩集' },
{ kind => 'aria' , title => '主題' },
{ kind => 'gsk' , title => 'リレー詩' },

{ kind => 'pss' , title => '詩小説' },
{ kind => 'sks' , title => '作詞' },
{ kind => 'kdp' , title => '感動詩' },
{ kind => 'rtk' , title => '恋詩' },

{ kind => 'poem' , title => '詩人' }
];


$category{'novel'} = [
{ kind => 'shousetu' , title => '小説１' },
{ kind => 'shousetu2' , title => '小説２' },

{ kind => 'ste' , title => '書捨て' },
{ kind => 'tog' , title => 'ト書き' , Souko => 1 },
{ kind => 'sst' , title => '初心者' },
{ kind => 'css' , title => '中級者' },
{ kind => 'st3' , title => 'プロ小説' },

{ kind => 'ss' , title => 'ＳＳ' },
{ kind => 'sss' , title => '短編集' },
{ kind => 'gss' , title => 'リレー' },
{ kind => 'rs' , title => '恋小説' },
{ kind => 'rsp' , title => '真恋' , Souko => 1 },
{ kind => 'cms' , title => 'コメディ' },
{ kind => 'fs' , title => 'ラノベ' },
{ kind => 'kds' , title => '感動' , Souko => 1 },
{ kind => 'sfs' , title => 'ＳＦ' , Souko => 1 },
{ kind => 'hs' , title => '推理' },
{ kind => 'hor' , title => 'ホラー' },
{ kind => 'skb' , title => '作文' , Souko => 1 },
{ kind => 'kya' , title => '脚本' , Souko => 1 },

{ kind => 'sts' , title => '設定' },
{ kind => 'gsd' , title => '募集' },
{ kind => 'kakikata' , title => '小説家' },
{ kind => 'hon' , title => '本' }
];


$category{'diary'} = [

{ kind => 'nikki' , title => '日記' },
{ kind => 'da2' , title => '日記２' },
{ kind => 'rni' , title => '恋日記' },
{ kind => 'ini' , title => '育児記' } ,
{ kind => 'esy' , title => 'エッセイ' },
{ kind => 'cmd' , title => 'お笑い' }
];


$category{'soudann'} = [
{ kind => 'sdn' , title => '相談' },
{ kind => 'men' , title => 'メンタル' },

{ kind => 'jos' , title => '女性' },
{ kind => 'dns' , title => '男性' },
{ kind => 'rennai' , title => '恋愛' },
{ kind => 'gya' , title => '虐待' , Hidden => 1 },
];



$category{'shakai'} = [
{ kind => 'grn' , title => '議論' },
{ kind => 'tetsugaku' , title => '哲学' },
{ kind => 'shk' , title => '社会' },

{ kind => 'sgw' , title => '障がい' },
{ kind => 'sbt' , title => '差別' }
];


$category{'nenndai'} = [
{ kind => 'swn' , title => '中高年' },
{ kind => 'skj' , title => '社会人' },
{ kind => 'shf' , title => '主婦' } ,
{ kind => 'koukou' , title => '大高生' },

{ kind => 'zt2' , title => '雑談' },
{ kind => 'sdr' , title => '質問' },
{ kind => 'pcp' , title => 'ＰＣ' },
{ kind => 'gks' , title => '勉強' },
{ kind => 'bunngaku' , title => '文学' } ,
{ kind => 'buk' , title => '文系' } ,
{ kind => 'suk' , title => '理数系' } ,
{ kind => 'rks' , title => '歴史' } ,

];


$category{'mebi'} = [
{ kind => 'qst' , title => 'メビ質問' },
{ kind => 'delete' , title => '削除依頼' }
];


$category{'anicomi'} = [
{ kind => 'anime' , title => 'アニメ総合' },
{ kind => 'comic' , title => 'コミック' },
{ kind => 'cha' , title => 'キャラ総合' },
{ kind => 'csj' , title => '少女漫画' },
{ kind => 'cco' , title => 'ちゃお' , Souko => 1 } ,

{ kind => 'onepiece' , title => 'ワンピース' },
{ kind => 'cdg' , title => 'Dグレ' },
{ kind => 'cbr' , title => 'BLEACH' , Souko => 1 },
{ kind => 'crb' , title => 'REBORN!' },
{ kind => 'cgt' , title => '銀魂' },
{ kind => 'gan' , title => 'ガンダム' },
{ kind => 'kei' , title => 'けいおん!!' , Souko => 1 },
{ kind => 'fairytail' , title => 'FAIRY TAIL' },

{ kind => 'cjp' , title => 'ジャンプ' } ,
{ kind => 'csd' , title => 'サンデー' , Souko => 1 } ,
{ kind => 'cmg' , title => 'マガジン' , Souko => 1 } ,

{ kind => 'chg' , title => 'ひぐらし' , Souko => 1 },
{ kind => 'moe' , title => '萌え' , Souko => 1 }
];

$category{'game'} = [

{ kind => 'gms' , title => 'ゲーム総合' },
{ kind => 'gko' , title => '通信,待合' },
{ kind => 'gpd' , title => 'プレイ日記' },
{ kind => 'gcd' , title => 'カードゲーム' },
{ kind => 'grp' , title => 'RPG' , Souko => 1 } ,
{ kind => 'gpz' , title => 'パズル' , Souko => 1 } ,
{ kind => 'gft' , title => '格ゲー' , Souko => 1 } ,
{ kind => 'gac' , title => 'アクション' , Souko => 1 } ,
{ kind => 'gst' , title => 'シューティング' , Souko => 1 } ,
{ kind => 'gne' , title => 'ネトゲ' , Souko => 1 } ,
{ kind => 'oreca' , title => 'オレカ' },
{ kind => 'gmh' , title => 'モンハン' },
{ kind => 'gpo' , title => 'ポケモン' },
{ kind => 'gdo' , title => 'ドラクエ' },
{ kind => 'gff' , title => 'FF' } ,
{ kind => 'g11' , title => 'イナイレ' },
{ kind => 'dbm' , title => 'どう森' } ,
{ kind => 'pzd' , title => 'パズドラ' },
{ kind => 'gmt' , title => 'メタルギア' , Souko => 1 } ,
{ kind => 'gme' , title => 'メガテン' , Souko => 1 } ,
{ kind => 'glk' , title => 'ロックマン' , Souko => 1 } ,
{ kind => 'gbj' , title => '牧場物語' , Souko => 1 }
];

$category{'narikiri'} = [
{ kind => 'ni2' , title => 'なりきり' },
{ kind => 'nrk' , title => 'ストーリー' },
{ kind => 'nro' , title => 'オリジナル' },
{ kind => 'npr' , title => 'なりプロ' , Souko => 1 },
{ kind => 'ngm' , title => 'ゲーム' },


{ kind => 'nrb' , title => 'なりREBORN' , Souko => 1 },
{ kind => 'ngt' , title => 'なり銀魂' },
{ kind => 'n11' , title => 'なりイナイレ' },
{ kind => 'nhr' , title => 'なりハルヒ' , Souko => 1 } ,
{ kind => 'nrb' , title => 'なりREBORN!' , Souko => 1 } ,
{ kind => 'ndg' , title => 'なりDグレ' , Souko => 1 } ,
{ kind => 'nmn' , title => 'なりマナー' , Souko => 1 } ,

{ kind => 'nrs' , title => '募集/設定' },
{ kind => 'nzz' , title => 'リアル雑談' },
];


$category{'gokko'} = [
{ kind => 'aso' , title => 'ごっこ' },
{ kind => 'gsh' , title => 'お店ごっこ' },
{ kind => 'gad' , title => 'オーディごっこ' },
{ kind => 'gsc' , title => '学園ごっこ' },

{ kind => 'sir' , title => 'しりとり' },
{ kind => 'kao' , title => '顔文字' },
{ kind => 'qiz' , title => 'クイズ' , Souko => 1 }
];

$category{'etc'} = [
{ kind => 'pet' , title => 'ペット' },
{ kind => 'gnj' , title => '芸能' },
{ kind => 'fsn' , title => '流行' },
{ kind => 'owa' , title => 'お笑い' , Souko => 1 },
{ kind => 'tks' , title => '特撮' , Souko => 1 },
{ kind => 'tvs' , title => 'テレビ' },
{ kind => 'mve' , title => '映画' , Souko => 1 },
{ kind => 'rad' , title => 'ラジオ' , Souko => 1 },
{ kind => 'ura' , title => '占い' },
{ kind => 'kyo' , title => '恐怖' },

{ kind => 'car' , title => '自動車' , Souko => 1 } ,
{ kind => 'den' , title => '電車' , Souko => 1 } ,
{ kind => 'bwk' , title => 'バイク' , Souko => 1 } ,

{ kind => 'kdn' , title => '家電' , Souko => 1 } ,
{ kind => 'knk' , title => '観光' , Souko => 1 } ,
{ kind => 'kag' , title => '家具' , Souko => 1 } ,
{ kind => 'psc' , title => 'パソコン' , Souko => 1 } ,
{ kind => 'mbl' , title => '携帯' , Souko => 1 } ,


{ kind => 'spt' , title => '運動' },
{ kind => 'sbs' , title => 'バスケ' , Souko => 1 } ,
{ kind => 'ssc' , title => 'サッカー' , Souko => 1 } ,
{ kind => 'sbb' , title => '野球' , Souko => 1 } ,
{ kind => 'sfg' , title => 'ゴルフ' , Souko => 1 } ,
{ kind => 'str' , title => '釣り' , Souko => 1 } ,

{ kind => 'beyblade' , title => 'ベイブレード' , Souko => 1 },

{ kind => 'ryo' , title => '料理' , Souko => 1 },

];

$category{'music'} = [
{ kind => 'onngaku' , title => '音楽総合' },
{ kind => 'ogk' , title => '楽器' },
{ kind => 'akb' , title => 'AKB系' },
{ kind => 'jan' , title => 'ジャニーズ' } ,
{ kind => 'voc' , title => 'ボカロ' } ,
{ kind => 'ovs' , title => 'ビジュアル' , Souko => 1 } ,
{ kind => 'ofr' , title => '洋楽' , Souko => 1 } ,
{ kind => 'ork' , title => 'ロック' , Souko => 1 } ,
{ kind => 'opp' , title => 'ポップス' , Souko => 1 } ,
{ kind => 'oaq' , title => 'AquaTimez' , Souko => 1 } ,
];


$category{'zatudann2'} = [
{ kind => 'chuugaku' , title => '中学生' } ,
{ kind => 'shougaku' , title => '小学生' } ,

{ kind => 'ztd' , title => '自由' } ,
{ kind => 'keijiban' , title => '雑談' } ,
{ kind => 'mei' , title => '同盟' } ,
{ kind => 'ztg' , title => '雑学' } ,
{ kind => 'shm' , title => '趣味' } ,
{ kind => 'enq' , title => 'アンケ' } ,
{ kind => 'btn' , title => 'バトン' } ,
{ kind => 'yme' , title => '夢' } ,

];


$category{'chiiki'} = [
{ kind => 'cth' , title => '東北' },
{ kind => 'ckt' , title => '関東' },
{ kind => 'cks' , title => '関西' },
{ kind => 'ccb' , title => '中部' },
{ kind => 'ccg' , title => '中四国' },
{ kind => 'cky' , title => '九州' },
{ kind => 'gai' , title => '外国' , Souko => 1 }
];

$category{'test'} = [
{ kind => 'test' , title => 'テスト' },
{ kind => 'test2' , title => 'テスト2' },
{ kind => 'test4' , title => 'テスト3' }
];

$category{'chat'} = [];
$category{'secret'} = [];
$category{'nocate'} = [];
$category{'sports'} = [];

$category{'contact'} = [
{ kind => 'twitter' , title => 'Twitter' } ,
{ kind => 'skype' , title => 'Skype' } ,
{ kind => 'fcode' , title => 'フレコ' } ,
];

#{ kind => 'line' , title => 'LINE' } ,


$category{'souko'} = [
{ kind => 'moe' , title => '萌え' } ,
{ kind => 'iys' , title => '癒し' } ,
{ kind => 'skw' , title => '詩会話' } ,
{ kind => 'aristotle' , title => '他創作' } ,
{ kind => 'sen' , title => '告知' } ,
{ kind => 'knk' , title => '環境' } ,
{ kind => 'psi' , title => '言葉遊び' } ,
{ kind => 'prg' , title => 'プログラム' } ,
{ kind => 'kjn' , title => '個人' , Close => 1 } ,
{ kind => 'tnp' , title => '単発' } ,
{ kind => 'shk' , title => '政治' } ,
{ kind => 'mns' , title => 'マンション' } ,
{ kind => 'ocd' , title => 'DVD' } ,
{ kind => 'uam' , title => '運営' } ,
{ kind => 'mra' , title => 'マナー' } ,
{ kind => 'ive' , title => 'イベント' } ,
{ kind => 'bqz' , title => 'バカクイズ' } ,
{ kind => 'kgm' , title => 'テキゲー' } ,
{ kind => 'ojp' , title => '邦楽' } ,
];

\%category;

}


#-----------------------------------------------------------
# 掲示板種類に対応したカテゴリを定義 ( 未使用 )
#-----------------------------------------------------------
sub all_bbs_hash_with_category{

my $self = shift;
my($all_bbs_hash) = all_bbs_hash_per_category();
my(%new_bbs_init);

	foreach my $category_name ( keys %{$all_bbs_hash} ){
			foreach my $bbs_init (@{$all_bbs_hash->{$category_name}}){
				$new_bbs_init{$bbs_init->{'kind'}} = $bbs_init;
				$new_bbs_init{$bbs_init->{'kind'}}{'category'} = $category_name;
			}
	}

\%new_bbs_init;

}

#-----------------------------------------------------------
# 全掲示板のハッシュ
#-----------------------------------------------------------
sub all_bbs_hash{

my $self = shift;
my($hash_per_category) = all_bbs_hash_per_category();
my(%all_bbs_hash);

	# 全てのカテゴリを展開
	foreach my $category_name ( keys %{$hash_per_category} ){

			# カテゴリ毎の掲示板設定を展開
			foreach my $bbs_init (@{$hash_per_category->{$category_name}}){
				$all_bbs_hash{$bbs_init->{'kind'}} = $bbs_init;
				$all_bbs_hash{$bbs_init->{'kind'}}{'category'} = $category_name;
			}

	}

\%all_bbs_hash;

}


#-----------------------------------------------------------
# 掲示板種類と掲示板名のセット
#-----------------------------------------------------------
sub bbs_names{

my $self = shift;
my(%bbs_name);

my($all_bbs_hash) = all_bbs_hash();

	foreach my $bbs_kind (keys %{$all_bbs_hash}){
		$bbs_name{$bbs_kind} = $all_bbs_hash->{$bbs_kind}->{'title'};
		#$bbs_name{$bbs->{'kind'}} = $bbs->{'title'};
	}

# リターン
\%bbs_name;

}

package main;

#-------------------------------------------------
#  基本調整 - strict
#-------------------------------------------------
sub init_start_bbs{

# 宣言
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($server_domain) = Mebius::server_domain();
my($my_account) = Mebius::my_account();
my($type) = @_;
my($eval);
our(@color,$menu1,$menu2,$p_page,$pfirst_page,$kfirst_page,$m_max,$i_max,$kpage,$new_wait);
our($upload_url,$upload_dir,$realmoto,$moto,$category,$nowfile,$pastfile,$home,$hometitle,$concept);
our($backup_dir,$alocal_mode,$secret_mode,$bbs_redirect,%in,%bbs);

# 文字色
(@color) = Mebius::Init::Color();

# 各種設定
$menu1 = 30;		# 現行ログ、１メニューあたりの最大記事表示数
$menu2 = 100;		# 過去ログ、１メニューあたりの最大記事表示数
$i_max = 300;		# 掲示板１個あたりの、最大記事数
($p_page,$pfirst_page) = Mebius::Page::InitPageNumber("Desktop-view"); # ページ分割設定を取得
($kpage,$kfirst_page) = Mebius::Page::InitPageNumber("Mobile-view"); # ページ分割設定を取得
$m_max = 2000;		# 記事１個あたりの、最大レス登録個数
$new_wait = 24;		# 新規投稿の待ち時間（～時間）

# 投稿の基本設定
our $wait = 4;				# レスの基本待ち時間
our $max_msg = 6000;		# レスの最大文字数
our $min_msg = 5;			# レスの最小文字数
our $new_max_msg = 9000;	# 新規投稿の最大文字数
our $new_min_msg = 50;		# 新規投稿の最小文字数
our $ngbr = 300;			# 投稿時の最大改行個数

	my $bbs_object = Mebius::BBS->new();
	($moto) = $bbs_object->root_bbs_kind() || &error("掲示板の指定が変です。");;
	($realmoto) = $bbs_object->true_bbs_kind() || &error("掲示板の指定が変です。");;


# 新設定ファイル(個別設定)を読み込み
my($bbs) = Mebius::BBS::init_bbs_parmanent($moto);
	if(ref $bbs eq "HASH"){ %bbs = %$bbs; }

main::bbs_init_to_global(undef,$bbs);

	# 掲示板が設定されていない場合
	if(!$bbs->{'alive'}){
			# BBS.pm の中に配列がある場合は、掲示板を自動作成
			#if($my_account->{'admin_flag'}){
			#		if(Mebius::BBS::bbs_exists_check($moto)){
			#			Mebius::BBS::make_new_bbs($moto,$bbs);
			#		}	else {
			#			main::error("この掲示板は設定されていません。");
			#		}
			#}
			# 設定されていない掲示板のエラーを出す
			#else{
				main::error("この掲示板は設定されていません。");
			#}
	}

	# 閉鎖中の掲示板
	if($concept =~ /Admin-only/ && $type !~ /Admin-mode/){ main::error("この掲示板は設定されていません。"); }
	if($concept =~ /BBS-CLOSE/){ main::error("この掲示板は閉鎖中です。","410 Gone"); }

	# ログインモード
	if($concept =~ /Mode-login/){
		require "${init_directory}part_login.pl";
		Mebius::Login::Logincheck("",$realmoto);
	}

	# 秘密板
	if($secret_mode){

			if($moto !~ /^sc([a-z0-9]+)$/ && !$alocal_mode){ &error("この掲示板は存在しません。"); }
			if($type =~ /Admin-mode/ && $main::admy{'rank'} < $main::master_rank && $moto ne "sc$main::admy{'second_id'}"){ main::error("この掲示板は管理できません。"); }

		require "${init_directory}def_secret.pl";
		&scbase();
	}

	# アップロード可能な場合
	if($main::bbs{'concept'} =~ /Upload-mode/){
		require "${init_directory}part_upload.pl";
		($upload_url,$upload_dir) = init_upload("",$realmoto);
	}

	# 掲示板の移転
	if($bbs_redirect =~ /http:/){ require "${init_directory}part_movebbs.pl"; &movebbs_redirect("",$bbs_redirect); }

	# サブ記事モードの場合、設定を追加
	if($realmoto =~ /^sub/){ require "${init_directory}part_subview.pl"; &init_option_bbs_subbase(); }

	# 掲示板独自の設定 ( 2 )
	if($type !~ /Admin-mode/){
			if(!$home){ $home = "http://$server_domain/"; }
			#if($server_domain eq "mb2.jp" || $home eq "http://mb2.jp/"){ $hometitle = "メビウスリング娯楽版"; }
			if($server_domain eq "mb2.jp"){ $home = "http://mb2.jp/"; }
	}


	# 現行ログなど設定
	if($init_directory && $moto){
			#if($logdir eq ""){ $logdir = $bbs{'thread_log_directory'}; }
			if($nowfile eq ""){ $nowfile = "$bbs{'data_directory'}_index_${moto}/index_${moto}.log"; }
			#if($nowfile eq ""){ $nowfile = "${init_directory}${moto}_idx.log"; }
			if($pastfile eq ""){ $pastfile = $bbs{'old_past_file'}; }
			if($main::newpastfile eq ""){ $main::newpastfile = "${init_directory}_bbs_index/_${main::moto}_index/${main::moto}_allindex.log"; }
			if($category eq ""){ $category = "nocate"; }
	}

	# CSS追加
	push(@main::css_files,"bbs_all");

# 著作権表示
our $original_maker = qq(<a href="http://www.kent-web.com/" rel="nofollow" target="_blank" class="blank">配布-WebPatio</a>);
$original_maker .= qq(┃<a href="http://aurasoul.mb2.jp/">改造-$basic_init->{'top_level_domain'}</a>);


}

1;
