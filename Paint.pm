use strict;
use File::Copy;
package Mebius::Paint;

#-----------------------------------------------------------
# お絵かき画像の処理
#-----------------------------------------------------------
sub Image{

# 宣言
my($type,$image_session,$image_id,$server_domain,$realmoto,$i_postnumber,$i_resnumber) = @_;
my(undef,undef,undef,%ex) = @_ if($type =~ /Image-post/);
my(undef,$image_data_from) = @_;
my($image_data,$image_tail,$logfile_open,$file_block);
my($image_file,$image_file_buffer,$samnale_file,$animation_file,$samnale_file_buffer,$animation_file_buffer);
my($logfile_handler,$logfile,$logfile_buffer);
my($image_url,$samnale_url,$animation_url,$html_url);
my($image_url_buffer,$samnale_url_buffer,$animation_url_buffer);
my($image_url_deleted,$samnale_url_deleted,$animation_url_deleted);
my($image_file_deleted,$samnale_file_deleted,$animation_file_deleted);
my($top_logfile1,%image,@buffer_line,@logfile_line,$successed_flag);
my($buffer_save_hour) = (7*24);
my($cookie_concept,$cookie_session,$cookie_password,@cookie_sessions,$cookie_sessions,$i_cookie,@timage_id_used,$logfile_redun);


	# ●クッキー取得処理
	if($type =~ /Get-cookie/){

		# クッキーを取得
		my($paint_cookie) = main::get_cookie("Paint");
		($cookie_concept,$cookie_session,$cookie_password) = @$paint_cookie;

		# クッキーのセッション名を展開
		foreach(split(/\s/,$cookie_session)){
			$i_cookie++;
				if($image_session eq $_){ next; }							# 同じセッション名は重複させない
				if($i_cookie > 10 - 1){ next; }								# 一定数以上のクッキーは削除
			push(@cookie_sessions,$_);
		}
		if($type =~ /(Delete-cookie|Rename-justy)/){}						# クッキーを削除するので、何もしない
		elsif($image_session){ unshift(@cookie_sessions,$image_session); }	# クッキーを追加するので、セッション名を足す
		$cookie_sessions = "@cookie_sessions";

	}

	# ●クッキーを削除してリターンする場合
	if($type =~ /Delete-cookie/){
		Mebius::set_cookie("Paint",[$cookie_concept,$cookie_sessions,$cookie_password]);
		return(1);
	}

	# ●クッキーにセッション名をセットしてリターンする場合
	if($type =~ /Set-cookie-session/){
		Mebius::set_cookie("Paint",[$cookie_concept,$cookie_sessions,$cookie_password]);
		return();
	}

# 汚染チェック
$i_postnumber =~ s/\D//;
$i_resnumber =~ s/\D//;
$realmoto =~ s/\W//g;
$image_session =~ s/\W//g;
$image_id =~ s/\D//g;

	# 共通リターン ??
	if($image_session eq "" && $type !~ /Justy/){ return(); }

	# 一部リターン
	if($type =~ /(Rename-justy|Delete-image|Revive-image|Justy)/){
		if($i_postnumber eq ""){ return(); }
		if($i_resnumber eq ""){ return(); }
		if($realmoto eq ""){ return(); }
	}


# ログファイルを定義
$logfile = "${main::int_dir}_paintdata/_${realmoto}_paintdata/${i_postnumber}/${i_resnumber}-paintdata.log";
$logfile_buffer = "${main::int_dir}_paintdata/_buffer/${image_session}-paintdata.log";

	# 開くログファイルを定義
	if($type =~ /Justy/){ $logfile_open = $logfile; }
	else{ $logfile_open = $logfile_buffer; }

	# 個別ログを開く
	open($logfile_handler,"<$logfile_open");
		if($type =~ /Renew-logfile/){ flock($logfile_handler,1); }
	chomp(my $top1 = <$logfile_handler>);
	chomp(my $top2 = <$logfile_handler>);
	chomp(my $top3 = <$logfile_handler>);
	chomp(my $top4 = <$logfile_handler>);
	chomp(my $top5 = <$logfile_handler>);
	close($logfile_handler);

	# 個別ログを分解
	my($timage_key,$timage_id,$timage_tail,$timage_title,$tsuper_id,$tlasttime,$tdate,$taddr,$thost,$tcnumber,$tagent,$taccount) = split(/<>/,$top1);
	my($timage_width,$timage_height,$tsamnale_width,$tsamnale_height,$timage_size,$tsamnale_size,$tanimation_size) = split(/<>/,$top2);
	my($tserver_domain,$trealmoto,$tpostnumber,$tresnumber,$tdelete_data) = split(/<>/,$top3);
	my($timage_id_used,$timage_steps,$timage_painttime,$timage_all_steps,$timage_all_painttime,$tcompress_level) = split(/<>/,$top4);
	my($tcount,$timage_session,$thandle,$ttrip,$tid,$tcomment) = split(/<>/,$top5);
	if($image_id eq ""){ $image_id = $timage_id; }
	$image_id =~ s/\W//g;
	$image_tail = $timage_tail;
	
	# データ整形
	if($image_session){ $timage_session = $image_session; }
	($image{'delete_person'},$image{'delete_date'},$image{'delete_time'}) = split(/=/,$tdelete_data);

	# イメージIDの利用ログを配列に代入
	foreach(split(/\s/,$timage_id_used)){
		push(@timage_id_used,$_);
	}

	# 画像ファイルを定義
	$image_file_buffer = "${main::paint_dir}buffer/${image_id}.$image_tail";
	$image_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_url = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_url_buffer = "${main::paint_url}buffer/$image_id.$image_tail";
	$image_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";

	# サムネイルファイルを定義
	$samnale_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";
	$samnale_file_buffer = "${main::paint_dir}buffer/${image_id}-samnale.jpg";
	$samnale_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";
	($samnale_url) = samnale_url($realmoto,$i_postnumber,$i_resnumber);
	$samnale_url_buffer = "${main::paint_url}buffer/$image_id-samnale.jpg";
	$samnale_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";

	# アニメーションファイルを定義
	$animation_file_buffer = "${main::paint_dir}buffer/${image_id}.spch";
	$animation_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_url = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_url_buffer = "${main::paint_url}buffer/$image_id.spch";
	$animation_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}.spch";

	# 重複禁止用のファイルを定義
	$logfile_redun = "${main::int_dir}_paintdata/_buffer_id/${image_id}-redun.log";

	# 素を定義
	$file_block = "$realmoto-${i_postnumber}-${i_resnumber}-${image_tail}";

	# HTMLファイルを定義
	($html_url) = html_url($realmoto,${i_postnumber},${i_resnumber});

	# ●画像他データを削除する（管理ディレクトリへ移動）
	if($type =~ /Delete-image/){
		
		# エラー
		if($timage_key =~ /Deleted/){ return(); main::error("この画像は既に削除済みです。"); }

		# ディレクトリ作成
		Mebius::Mkdir("","${main::jak_dir}paint/$realmoto");
		Mebius::Mkdir("","${main::jak_dir}paint/$realmoto/$i_postnumber");

		# 画像他をリネーム
		rename($image_file,$image_file_deleted);
		rename($animation_file,$animation_file_deleted);
		rename($samnale_file,$samnale_file_deleted);

	}

	# ●画像他データを復活する（一般ディレクトリへ移動）
	if($type =~ /Revive-image/){

		# エラー
		if($timage_key !~ /Deleted/){ return(); main::error("この画像は削除されていません。"); }

		# 画像他をリネーム
		rename($image_file_deleted,$image_file);
		rename($animation_file_deleted,$animation_file);
		rename($samnale_file_deleted,$samnale_file);
	}

	# ●バッファファイルを削除する ( 新着リストで溢れた場合 )
	if($type =~ /Delete-buffer/){
		Mebius::Mkdir("","${main::paint_dir}$realmoto");
		Mebius::Mkdir("","${main::paint_dir}$realmoto/$i_postnumber");
		unlink($image_file_buffer);
		unlink($animation_file_buffer);
		unlink($samnale_file_buffer);
		unlink($logfile_redun);
		if($type !~ /Not-delete-logfile/){ unlink($logfile_buffer); }
		return();
	}

	# ●ログファイルのデータ等をハッシュとしてリターンする場合
	if($type =~ /Get-hash/){

		$image{'key'} = $timage_key;
		$image{'id'} = $image_id;
		$image{'tail'} = $image_tail;
		$image{'lasttime'} = $tlasttime;
		$image{'session'} = $image_session;
		$image{'savehour'} = $buffer_save_hour;
		$image{'lefthour'} = $buffer_save_hour - int(($main::time - $tlasttime)/(60*60));
		$image{'logfile_redun'} = $logfile_redun;
		$image{'image_file'} = $image_file;
		$image{'samnale_file'} = $samnale_file;
		$image{'animation_file'} = $animation_file;
		$image{'image_file_buffer'} = $image_file_buffer;
		$image{'samnale_file_buffer'} = $samnale_file_buffer;
		$image{'animation_file_buffer'} = $animation_file_buffer;
		$image{'image_url'} = $image_url;
		$image{'samnale_url'} = $samnale_url;
		$image{'animation_url'} = $animation_url;
		$image{'html_url'} = $html_url;
		$image{'image_url_buffer'} = $image_url_buffer;
		$image{'samnale_url_buffer'} = $samnale_url_buffer;
		$image{'animation_url_buffer'} = $animation_url_buffer;
		$image{'image_url_deleted'} = $image_url_deleted;
		$image{'samnale_url_deleted'} = $samnale_url_deleted;
		$image{'animation_url_deleted'} = $animation_url_deleted;
		$image{'super_id'} = $tsuper_id;
		$image{'session_file'} = $logfile;
		$image{'session_file_buffer'} = $logfile_buffer;
		$image{'painttime'} = $timage_painttime;
		$image{'all_painttime'} = $timage_all_painttime;
		$image{'steps'} = $timage_steps;
		$image{'all_steps'} = $timage_all_steps;
		$image{'image_size'} = $timage_size;
		$image{'samnale_size'} = $tsamnale_size;
		$image{'animation_size'} = $tanimation_size;
		$image{'comment'} = $tcomment;
		$image{'compress_level'} = $tcompress_level;

		# 作者情報
		$image{'handle'} = $thandle;
		$image{'trip'} = $ttrip;
		$image{'id'} = $tid;
		$image{'host'} = $thost;
		$image{'cnumber'} = $tcnumber;
		$image{'agent'} = $tagent;
		$image{'account'} = $taccount;

		# イメージサイズ
		$image{'width'} = $timage_width;
		$image{'height'} = $timage_height;
		$image{'samnale_width'} = $tsamnale_width;
		$image{'samnale_height'} = $tsamnale_height;
		if($image{'samnale_width'} && $image{'samnale_height'}){ $image{'samnale_style'} = qq( style="width:$image{'samnale_width'}px;height:$image{'samnale_height'}px;"); }
		else{ $image{'samnale_style'} = qq( style="width:120px;height:120px;"); }

		# 元記事のURLなど
		$image{'realmoto'} = $trealmoto;
		$image{'postnumber'} = $tpostnumber;
		$image{'resnumber'} = $tresnumber;

		# メインモード？
		if($trealmoto =~ /^(mpaint)$/){ $image{'main_type'} = 1; }

		# メインモードでない場合は、記事URLなどを定義
		else{
				if($trealmoto){ $image{'bbs_url'} = "/_$trealmoto/"; }
				if($trealmoto && $tpostnumber){ $image{'thread_url'} = "/_$trealmoto/$tpostnumber.html"; }
				if($trealmoto && $tpostnumber && $tresnumber){ $image{'res_url'} = "/_$image{'realmoto'}/$tpostnumber.html-$tresnumber#S$tresnumber"; }
		}

		# 【確定後画像】の表示可能状態
		if($image{'tail'} && $image{'key'} !~ /Deleted/){ $image{'image_ok'} = 1; }

		# クッキー
		$image{'cookie_concept'} = $cookie_concept;
		$image{'cookie_session'} = $cookie_session;
		$image{'cookie_password'} = $cookie_password;

			# 画像タイトル
			$image{'title'} = $timage_title;
			if($image{'title'}){
					$image{'title_and_id'} = qq($image{'session'} ( $image{'title'} ));
			}
			else{
				#$image{'title'} = $image{'session'};
				$image{'title_and_id'} = $image{'session'};
			}

			# 画像のタイトルタグ
			$image{'title_tag'} .= qq($image{'title'});
			$image{'title_tag'} .= qq( $image{'width'}x$image{'height'});
			if($image{'image_size'}){ $image{'image_size_kbyte'} = int($image{'image_size'} / 1000); }
			#if($image{'image_size_kbyte'}){ $image{'title_tag'} .= qq( $image{'image_size_kbyte'}KB); }
	
			if($image{'key'} =~ /Animation/){ $image{'title_tag'} .= qq( アニメあり); }
			$image{'title_tag'} = qq( title="$image{'title_tag'}");

			# キー判定
			if($image{'key'} =~ /Deny-sasikae/){ $image{'deny_sasikae'} = 1; }
			if($image{'key'} =~ /Animation/){ $image{'animation_flag'} = 1; }
			if($image{'key'} =~ /Deleted/){ $image{'deleted'} = 1; }

			# 表示可能か、投稿可能か
			if($type =~ /Post-check/){

				# 必須ステップ数、ペイントタイム
				$image{'must_steps'} = 80;
				$image{'must_painttime'} = 60*5;
					if($main::alocal_mode || $main::myadmin_flag >= 5){
						$image{'must_steps'} = 1;
						$image{'must_painttime'} = 3;
					}

				# 必須ペイントタイム、ステップ数を満たしているかどうか
				if($image{'all_steps'} >= $image{'must_steps'} && $image{'all_painttime'} >= $image{'must_painttime'}
				&& $image{'key'} =~ /Edited/ && $image{'key'} !~ /Posted/
				&& $image{'lefthour'} >= 1 && !-f $image{'logfile_redun'} && -f $image{'image_file_buffer'}){
					$image{'post_ok'} = 1;
				}
				if(-f $image{'image_file_buffer'} && $image{'lefthour'} >= 1){ $image{'continue_ok'} = 1; }
				if(-f $image{'logfile_redun'}){ $image{'image_posted'} = 1; }
			}

	}

	# ●掲示板への投稿に成功
	if($type =~ /Rename-justy/){

		# ディレクトリ作成
		Mebius::Mkdir("","${main::paint_dir}$realmoto");
		Mebius::Mkdir("","${main::paint_dir}$realmoto/$i_postnumber");

			# 正画像がすでに存在する場合
			if(-f $image_file){ main::error("この画像は既に存在します。"); }
			if(-f $samnale_file){ main::error("このサムネイルは既に存在します。"); }
			if(-f $animation_file){ main::error("このアニメーションデータは既に存在します。"); }
			if(-f $logfile){ main::error("この画像は既に存在します。（２）"); }

			# バッファから本画像へ
			if(-f $image_file_buffer){
					&File::Copy::copy($image_file_buffer,$image_file) || main::error("画像の正規化に失敗しました。");
			}
			else{ main::error("一時保存用の画像が存在しません。"); }

			# バッファから本サムネイルへ
			if(-f $samnale_file_buffer){
					&File::Copy::copy($samnale_file_buffer,$samnale_file) || main::error("サムネイルの正規化に失敗しました。");
			}
			else{ main::error("一時保存用のサムネイルが存在しません。$samnale_file_buffer"); }

			# バッファから本アニメデータへ
			if(-f $animation_file_buffer){
					&File::Copy::copy($animation_file_buffer,$animation_file) || main::error("アニメーションデータの正規化に失敗しました。");
			}
			else{ main::error("一時保存用のアニメーションデータが存在しません。"); }

			# サイト全体の「新着お絵かきリスト」の更新
			if(!$main::secret_mode){
				require "${main::int_dir}part_newlist.pl";
				Mebius::Newlist::Paint("Renew New Justy",$image_session,$image_id,$file_block,$tsuper_id);
			}

		# クッキーのセッションを削除
		#Mebius::set_cookie("Paint",$cookie_concept,$cookie_sessions,$cookie_password);

	}

	# ★★個別ログファイルを作成/更新
	if($type =~ /Renew-logfile/){

		# 局所化
		my($logfile_renew);

			# 書き込むログファイルの定義
			if($type =~ /Renew-logfile-buffer/){
				$logfile_renew = $logfile_buffer;
					if($type =~ /Posted/){ $timage_key .= qq( Posted); }
			}
			elsif($type =~ /Renew-logfile-justy/){
				$logfile_renew = $logfile;
				Mebius::Mkdir("","${main::int_dir}_paintdata/_${realmoto}_paintdata/");
				Mebius::Mkdir("","${main::int_dir}_paintdata/_${realmoto}_paintdata/$i_postnumber");
			}

			# ●データを編集する場合
			if($type =~ /Edit-data/){
				$tcomment = $main::in{'comment'};
				$timage_title = $main::in{'image_title'};
				$timage_key =~ s/ Edited//g;
				$timage_key .= qq( Edited);
					($ttrip,$thandle) = main::trip($main::in{'name'});
					($tid) = main::id();
			}

			# ●JAVAからデータを受け取った場合
			if($type =~ /Image-post/){

				# 引継ぎEXヘッダの汚染チェック、反映
				$timage_title = $ex{'image_title'};

				# イメージサイズ
				$timage_width = $ex{'width'};
				$timage_height = $ex{'height'};
				$tsamnale_width = $ex{'samnale_width'};
				$tsamnale_height = $ex{'samnale_height'};
				$timage_size = $ex{'image_size'};
				$tsamnale_size = $ex{'samnale_size'};
				$tanimation_size = $ex{'animation_size'};
				$tcompress_level = $ex{'compress_level'};
				$timage_steps = $ex{'count'} - $timage_all_steps;
				$timage_all_steps = $ex{'count'};
				$timage_painttime = int ($ex{'timer'} / 1000);
				$timage_all_painttime += $timage_painttime;
				$tcount++;

				# スーパーIDの処理
				if($tsuper_id eq ""){ $tsuper_id = $ex{'super_id'}; }
				($tsuper_id) = &Super_id("Image-post Renew Brand-new",$tsuper_id,$image_session,$image_id);
				$image{'super_id'} = $tsuper_id;

				# 汚染チェック
				$timage_width =~ s/\D//g;
				$timage_height =~ s/\D//g;
				$tsamnale_width =~ s/\D//g;
				$tsamnale_height =~ s/\D//g;
				$timage_size =~ s/\D//g;
				$tsamnale_size =~ s/\D//g;
				$tanimation_size =~ s/\D//g;
				$timage_steps =~ s/\D//g;
				$timage_painttime =~ s/\D//g;
				$tcompress_level =~ s/\D//g;
				$timage_key =~ s/(\s)?Posted//g;

				# サムネイルのサイズが本画像より大きい場合、サイズを合わせる
				if($tsamnale_width > $timage_width){ $tsamnale_width = $timage_width; }
				if($tsamnale_height > $timage_height){ $tsamnale_height = $timage_height; }

					# 拡張子
					if($ex{'image_type'} =~ /^(jpg|jpeg)$/){ $timage_tail = "jpg"; }
					elsif($ex{'image_type'} =~ /^(png)$/){ $timage_tail = "png"; }
					else{ return(); }

					# ログファイルに書き込む値の定義
					if($ex{'animation_on'} && $timage_key !~ /Animation/){ $timage_key .= qq( Animation); }
					if($ex{'deny_sasikae'} && $timage_key !~ /Deny-sasikae/){ $timage_key .= qq( Deny-sasikae); }
					push(@timage_id_used,$image_id);

			}

			# ●画像を【投稿確定】した場合
			if($type =~ /Rename-justy/){

				$tserver_domain = $server_domain;
				$trealmoto = $realmoto;
				$tpostnumber = $i_postnumber;
				$tresnumber = $i_resnumber;

				# スーパーIDファイルを更新
				&Super_id("Rename-justy Renew",$tsuper_id,$image_session,$file_block);

				# 重複禁止用ファイルを削除
				Mebius::Fileout("New-file",$logfile_redun);

			}

			# 管理者による画像の削除と復活
			if($type =~ /Delete-image/){
				$timage_key .= qq( Deleted);
				$tdelete_data = qq($main::admy_name=$main::date=$main::time);
			}
			elsif($type =~ /Revive-image/){
				$timage_key =~ s/Deleted//g;
			}

			# 投稿者データを更新する場合（管理者削除の場合は更新しない）
			if(!$main::admin_mode){
				$tlasttime= $main::time;
				$tdate = $main::date;
				$taddr = $main::addr;
				$thost = $main::host;
				$tcnumber = $main::cnumber;
				$tagent = $main::agent;
				$taccount = $main::pmfile;
			}

		# ファイルの書き込み
push(@logfile_line,"$timage_key<>$image_id<>$timage_tail<>$timage_title<>$tsuper_id<>$tlasttime<>$tdate<>$taddr<>$thost<>$tcnumber<>$tagent<>$taccount<>\n");
		push(@logfile_line,"$timage_width<>$timage_height<>$tsamnale_width<>$tsamnale_height<>$timage_size<>$tsamnale_size<>$tanimation_size<>\n");
		push(@logfile_line,"$tserver_domain<>$trealmoto<>$tpostnumber<>$tresnumber<>$tdelete_data<>\n");
		push(@logfile_line,"@timage_id_used<>$timage_steps<>$timage_painttime<>$timage_all_steps<>$timage_all_painttime<>$tcompress_level<>\n");
		push(@logfile_line,"$tcount<>$timage_session<>$thandle<>$ttrip<>$tid<>$tcomment<>\n");

		Mebius::Fileout("",$logfile_renew,@logfile_line);

	}

	# ハッシュを返す
	if($type =~ /Get-hash/){ return(%image); }

}

#-----------------------------------------------------------
# スーパーIDのログ
#-----------------------------------------------------------
sub Super_id{

# 宣言
my($type,$super_id,$image_session,$image_file) = @_;
my($super_id_handler,@renewline,$logfile,$super_id_main,$super_id_key);

# スーパーIDを分解
my($yearf,$monthf,$super_id_main) = split(/-/,$super_id);

# 汚染チェック
$image_session =~ s/\W//g;

# スーパーIDの定義
$super_id_main =~ s/\W//g;
if($super_id_main eq "" && $type =~ /Brand-new/){ ($super_id_main) = Mebius::Crypt::char("",12); }
if($super_id_main eq ""){ return(); }

# 年IDの定義
$yearf =~ s/\D//g;
if($yearf eq "" && $type =~ /Brand-new/){ $yearf = $main::thisyearf; }
if($yearf eq ""){ return(); }

# 月IDの定義
$monthf =~ s/\D//g;
if($monthf eq "" && $type =~ /Brand-new/){ $monthf = $main::thismonthf; }
if($monthf eq ""){ return(); }


# スーパーID全体の再定義
$super_id = "$yearf-$monthf-$super_id_main";

# ファイル定義
$logfile = "${main::int_dir}_paintdata/_super_id/$yearf/$monthf/${super_id_main}_superid.log";

	# ファイルを削除する場合
	if($type =~ /Delete-file/){
		unlink($logfile);
		return();
	}

# ログファイルを開く
open($super_id_handler,$logfile);

	# ファイルロック
	if($type =~ /Renew/){ flock($super_id_handler,1); }

# トップデータを分解
chomp(my $top1 = <$super_id_handler>);
my($tkey,$tlasttime) = split(/<>/,$top1);

	# ファイルを展開
	while(<$super_id_handler>){
		
		# この行を分解
		chomp;
		my($key2,$image_session2,$image_file2) = split(/<>/);
		
			# ファイル更新用
			if($type =~ /Renew/){

				# この行を追加
				push(@renewline,"$key2<>$image_session2<>$image_file2<>\n");				

			}

	}

close($super_id_handler);

	# ファイル更新用
	if($type =~ /Renew/){

		# トップデータがない場合
		if($tkey eq ""){ $tkey = 1; }

		# ディレクトリ作成
		Mebius::Mkdir("","${main::int_dir}_paintdata/_super_id/$yearf");
		Mebius::Mkdir("","${main::int_dir}_paintdata/_super_id/$yearf/$monthf");

		# 新しい行を追加
		if($type =~ /Image-post/){ $super_id_key .= qq( Buffer); }
		elsif($type =~ /Rename-justy/){ $super_id_key .= qq( BBS); }
		unshift(@renewline,"$super_id_key<>$image_session<>$image_file<>\n");

		# トップデータを追加
		unshift(@renewline,"$tkey<>$main::time<>\n");

		# ログファイルを更新
		Mebius::Fileout("",$logfile,@renewline);

		# リターン
		return($super_id);

	}

}


#-----------------------------------------------------------
# キャンバスサイズ
#-----------------------------------------------------------
sub Canvas_size{

# 局所化
my($type,$canvas_width,$canvas_height) = @_;
my(@canvas_size,$allow_width_flag,$allow_height_flag,$error_flag);

# キャンバスサイズの種類を定義
@canvas_size = (
"500",
"450",
"400",
"350",
"300",
"250",
"200",
"150",
"100"
);


	# 違反をチェック
	if($type =~ /Violation-check/){

		# 汚染チェック
		if($canvas_width =~ /\D/){ $error_flag = qq(キャンバスサイズ（横）は半角数字で指定してください。); }
		if($canvas_height =~ /\D/){ $error_flag = qq(キャンバスサイズ（縦）は半角数字で指定してください。); }

		# 配列を展開
		foreach(@canvas_size){
			if($canvas_width == $_){ $allow_width_flag = 1; }
			if($canvas_height == $_){ $allow_height_flag = 1; }
		}

		# 違反している場合
		if(!$allow_width_flag){ $error_flag = qq(キャンバスサイズ（縦）の指定が不正です); }
		if(!$allow_height_flag){ $error_flag = qq(キャンバスサイズ（縦）の指定が不正です。); }

		return($error_flag);
	}

# リターン

return(@canvas_size);

}


#-----------------------------------------------------------
# サムネイルのURL
#-----------------------------------------------------------
sub samnale_url{

my($realmoto,$i_postnumber,$i_resnumber) = @_;

my $self = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";

}

#-----------------------------------------------------------
# HTMLページのURL
#-----------------------------------------------------------
sub html_url{

my($realmoto,$i_postnumber,$i_resnumber) = @_;

my	$self = "${main::main_url}pallet-viewer-$realmoto-${i_postnumber}-${i_resnumber}.html";

}



1;
