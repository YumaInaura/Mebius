
use strict;
package Mebius::Cookie;
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
sub param_to_set_cookie_main{

my $self = shift;
my $query = new Mebius::Query;
my $param_utf8 = $query->single_param_utf8_judged_device();
my(%set_cookie);

	if($param_utf8->{'name'}){
		$set_cookie{'name'} = $param_utf8->{'name'};
	}

	if( $param_utf8->{'font_color'} =~ /^\#?[a-f0-9]{3,6}$/ ){
		$set_cookie{'font_color'} = $param_utf8->{'font_color'};
	}

my $set_cookie_shift_jis = hash_to_shift_jis(\%set_cookie);
set_main($set_cookie_shift_jis,{ SaveToFile => 1 });

}


#-----------------------------------------------------------
# クッキーをハッシュでゲット
#-----------------------------------------------------------
sub get{

my($cookie_name) = @_;
my(%return);
my($cookie_body) = get_body_by_name($cookie_name);

	# 展開してハッシュに
	foreach(split(/,/,$cookie_body)){

		my($name,$value) = split(/:/);
		my($name_decoded) = Mebius::decode_text($name);
		my($value_decoded) = Mebius::decode_text($value);

		$return{$name_decoded} = $value_decoded;

	}

\%return;

}

#-----------------------------------------------------------
# 環境変数の中から、特定の Cookie のセットを返す
#-----------------------------------------------------------
sub get_body_by_name{

my($cookie_name) = @_;
my($return);

	# 複数のCookie を種類ごとに展開
	foreach( split(/;/,$ENV{'HTTP_COOKIE'}) ) {
	
		# クッキー名とボディに分解
		my($cookie_name2,$cookie_body2) = split(/=/);
		$cookie_name2 =~ s/\s//g; # なんだっけ？

			# 指定した Cookie がヒットした時
			if($cookie_name eq $cookie_name2){
				$return = $cookie_body2;
			}
		}

$return;

}

#-----------------------------------------------------------
# クッキーをハッシュでセット ( 新規作成 )
#-----------------------------------------------------------
sub set{

my($cookie_name,$set,$expires_localtime) = @_;
my(@cookie_body);

	if(!$expires_localtime){
		$expires_localtime = 365*24*60*60;
	}

	# ハッシュを展開
	foreach my $set_name ( keys %$set ){

		my($set_name_encoded) = Mebius::encode_text($set_name);
		my($set_value_encoded) = Mebius::encode_text($set->{$set_name});

		push(@cookie_body,"$set_name_encoded:$set_value_encoded");

	}

my $cookie_body = join(",",@cookie_body);

set_core($cookie_name,$cookie_body,$expires_localtime);


}


#-----------------------------------------------------------
# クッキーをハッシュでセット ( 新規作成、または上書き )
#-----------------------------------------------------------
sub update{

my($cookie_name,$update,$expires_localtime) = @_;

# 現在のCookieを取得
my($exsting_cookie) = get($cookie_name);
my %set = %$exsting_cookie;

	# 現行Cookieの値はそのままで、更新内容だけを上書きする
	foreach  ( keys %$update ){
		$set{$_} = $update->{$_};
	}

set($cookie_name,\%set,$expires_localtime);


}

#-----------------------------------------------------------
# クッキーをセット ( コア部分の処理 )
#-----------------------------------------------------------
sub set_core{

my($cookie_name,$cookie_body,$expires_localtime) = @_;
my($my_access) = Mebius::my_access();
my($set);

# 時刻定義
my($gmt) = Mebius::Cookie::localtime_to_gmt(time + $expires_localtime);


	# クッキーの内容を最終定義
	if($my_access->{'mobile_id'} eq "AU" || $my_access->{'mobile_id'} eq "SOFTBANK"){
		$set = "$cookie_name=$cookie_body; expires=$gmt; path=/;";
	}
	elsif(Mebius::alocal_judge()){
		$set = "$cookie_name=$cookie_body; expires=$gmt; path=/;";
	}
	else{
		$set = "$cookie_name=$cookie_body; domain=mb2.jp; expires=$gmt; path=/;";
	}

# クッキーをセット
print qq(Set-Cookie: $set\n);

}

#-----------------------------------------------------------
# ローカル時刻を GMT に
#-----------------------------------------------------------
sub localtime_to_gmt{

my($localtime) = @_;

my @time = gmtime($localtime);
my @month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
my @week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

my $gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT", $week[$time[6]], $time[3], $month[$time[4]], $time[5]+1900, $time[2], $time[1], $time[0]);

}


#-----------------------------------------------------------
# メインクッキーの配列をハッシュに変換
#-----------------------------------------------------------
sub array_to_hash_main{

my(%cookie);

($cookie{'name'},$cookie{'refresh_second'},$cookie{'id_material'},$cookie{'font_color'},$cookie{'thread_up'},$cookie{'set_count'},$cookie{'last_post_time'},$cookie{'last_res_time'},$cookie{'gold'},$cookie{'regist_all_length'},$cookie{'regist_count'},$cookie{'font_size'},$cookie{'follow'},$cookie{'last_view_thread'},$cookie{'char'},$cookie{'use_history'},$cookie{'omit_text'},$cookie{'last_memo_time'},$cookie{'account'},$cookie{'hashed_password'},$cookie{'deleted_time'},$cookie{'bbs_news'},$cookie{'age'},$cookie{'email'},$cookie{'secret'},$cookie{'wait_second_res'},$cookie{'account_link'},$cookie{'last_set_time'},$cookie{'id_fillter'},$cookie{'account_fillter'},$cookie{'use_id_history'},$cookie{'device_type'},$cookie{'first_set_time'}) = @_;

%cookie;

}

#-----------------------------------------------------------
# メインクッキーの配列をハッシュに変換
#-----------------------------------------------------------
sub hash_to_array_main{

my(%cookie) = @_;

my @self = 
($cookie{'name'},$cookie{'refresh_second'},$cookie{'id_material'},$cookie{'font_color'},$cookie{'thread_up'},$cookie{'set_count'},$cookie{'last_post_time'},$cookie{'last_res_time'},$cookie{'gold'},$cookie{'regist_all_length'},$cookie{'regist_count'},$cookie{'font_size'},$cookie{'follow'},$cookie{'last_view_thread'},$cookie{'char'},$cookie{'use_history'},$cookie{'omit_text'},$cookie{'last_memo_time'},$cookie{'account'},$cookie{'hashed_password'},$cookie{'deleted_time'},$cookie{'bbs_news'},$cookie{'age'},$cookie{'email'},$cookie{'secret'},$cookie{'wait_second_res'},$cookie{'account_link'},$cookie{'last_set_time'},$cookie{'id_fillter'},$cookie{'account_fillter'},$cookie{'use_id_history'},$cookie{'device_type'},$cookie{'first_set_time'});

}

#-----------------------------------------------------------
# メインクッキーをセット
#-----------------------------------------------------------
sub set_main{

# Cookieセット
my($set_cookie,$use) = @_;
my($my_account) = Mebius::my_account();
my($my_access) = Mebius::my_access();
my($my_real_device) = Mebius::my_real_device();
my($init_directory) = Mebius::BaseInitDirectory();
my(%set_cookie,$renew_cookie_logined);

	if($use->{'source'} eq "utf8"){
		$set_cookie = hash_to_shift_jis($set_cookie);
	}

# クッキー名
my $cookie_name = "love_me_aura";

# 現存の自然なCookieを取得
my($cookie) = Mebius::my_cookie_main();

# カウントを増やす
$set_cookie->{'+'}{'set_count'} = 1;
	# 管理番号がない場合はセットする
	if($cookie->{'char'} eq ""){ ($set_cookie->{'char'}) = Mebius::Crypt::char(undef,20); }
	# 初めてのセットの場合は、その時刻を記録する
	if(!$cookie->{'first_set_time'}){ $set_cookie->{'first_set_time'} = time; }
	# IDの素がない場合はセットする ( Cookie がセットできない環境でのハッシュ化は負荷がかかる? かもしれないので、Cookie有効無効を判定する )
	if(!$cookie->{'id_material'} && $ENV{'HTTP_COOKIE'}){ ($set_cookie->{'id_material'}) = Mebius::my_id_material(); }
	# 最終セット時刻（現在時刻）を記録する
	$set_cookie->{'last_set_time'} = time;

# Cookieを任意の値に書き換え
my($renew_natural_cookie) = Mebius::Hash::control($cookie,$set_cookie);

	# ●Cookieのセーブ機能
	if($use->{'SaveToFile'}){

		# 自然なCookieの変更内容を記憶しておく 
		my %renew_natural_cookie = %$renew_natural_cookie;

		# ログインCookieを取得
		my($cookie_logined) = Mebius::my_cookie_main_logined();

		# 任意の値に書き換え
		($renew_cookie_logined) = Mebius::Hash::control($cookie_logined,$set_cookie);


			# ▼個体識別番号ファイルへのセーブ
			if($my_access->{'mobile_uid'}){

					my %renew_save_mobile;

					# 値が最終決定されたCookieのハッシュを、セーブデータ用のハッシュに変換
					foreach(keys %$renew_cookie_logined){
							$renew_save_mobile{"cookie_$_"} = $renew_cookie_logined->{$_};
					}
					$renew_save_mobile{'+'}{'set_cookie_count'} = 1;
		
				# ファイルを更新
				my($renewed_save_data) = Mebius::save_data({ FileType => "Mobile" , Renew => 1 , select_renew => \%renew_save_mobile },$my_access->{'multi_user_agent'});

					# ファイルに記録した値では、元のCookieを変更しない (元々のCookie値で上書きする)
					#foreach(keys %$renewed_save_data){
					#			if($_ =~ /^cookie_(\w+)$/){ $renew_natural_cookie{$1} = $cookie->{$1}; }
					#}

			}

			# ▼ アカウントへのセーブ
			elsif($my_account->{'login_flag'}){

					my %renew_account;

					# 値が最終決定されたCookieのハッシュを、アカウント用のハッシュに変換
					foreach(keys %$renew_cookie_logined){
							$renew_account{"cookie_$_"} = $renew_cookie_logined->{$_};
					}
					$renew_account{'+'}{'set_cookie_count'} = 1;

				# ファイルを更新
				my(%renewed_account) =  Mebius::Auth::File("Renew",$my_account->{'file'},\%renew_account);

					# ファイルに記録した値では、元のCookieを変更しない (元々のCookie値で上書きする)
					foreach(keys %renewed_account){
								if($_ =~ /^cookie_(\w+)$/){ $renew_natural_cookie{$1} = $cookie->{$1}; }
					}

			}

		# リファレンスを再定義
		$renew_natural_cookie = \%renew_natural_cookie;

	}

# 最終定義されたSet Cookieのハッシュを配列に変換
my(@set_cookie) = Mebius::Cookie::hash_to_array_main(%$renew_natural_cookie);

# 実際の Cookie を配列でセット
my($setted_cookie) = Mebius::set_cookie($cookie_name,\@set_cookie);

	# Sum Cookie をセット
	if($my_real_device->{'ds_flag'}){
		0;
	}
	else{
		Mebius::Cookie::set_sum("love_me_aura",$setted_cookie->{'body'});
	}

if($renew_cookie_logined){ return $renew_cookie_logined; }
else{ return $renew_natural_cookie; }

}


#-----------------------------------------------------------
# Sumをセット
#-----------------------------------------------------------
sub set_sum{

my($cookie_name,$cookie_body) = @_;
my($hashed_cookie_body) = Mebius::Cookie::hash_sum($cookie_body);
my $time = time;

Mebius::set_cookie("Sum",["$cookie_name:$hashed_cookie_body:$time"]);

}

#-----------------------------------------------------------
# Sumを照合
#-----------------------------------------------------------
sub collation_sum{

my($cookie_name,$cookie_body) = @_;
my($collect_flag,$hashed_sum_hit,$set_time_hit,$cookie_name_hit);
my($my_real_device) = Mebius::my_real_device();

		my($hashed_cookie_body) = Mebius::Cookie::hash_sum($cookie_body);

		# サムを取得
		my($sum_cookie,$sum_cookie_body) = main::get_cookie("Sum");

			foreach(@$sum_cookie){

				# 行を分解
				my($cookie_name2,$hashed_sum2,$set_time2) = split(/\:/,$_);

						# 該当の Cookie 名がヒットした倍
						if($cookie_name2 eq $cookie_name){

								$hashed_sum_hit = $hashed_sum2;
								$set_time_hit = $set_time2;
								$cookie_name_hit = $cookie_name2;
						}
			}

	# 照合
	if($hashed_cookie_body eq $hashed_sum_hit){ $collect_flag = 1; }

	# DSの場合は何もしない
	if($my_real_device->{'ds_flag'}){
		0;
	}
	elsif(!$collect_flag){
			Mebius::AccessLog(undef,"Cookie-sum-not-collect","Now-hashed-sum $hashed_cookie_body / Recorded-sum $hashed_sum_hit / Sum-set-time $set_time_hit / Target-cookie-name $cookie_name_hit \nNatural-cookie $ENV{'HTTP_COOKIE'}");
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq(Now-hashed-sum $hashed_cookie_body / Recorded-sum $hashed_sum)); }

$collect_flag;

}


#-----------------------------------------------------------
# Cookie の sum をハッシュ化
#-----------------------------------------------------------
sub hash_sum{

my($cookie_all_text) = @_;

my($sum) = Mebius::Crypt::crypt_text($cookie_all_text,"Fdglda9856y5AGHHGt4gdajfsdagj48fgahsdf4ytgjad5agh7hDdagg8");

$sum;

}

#-----------------------------------------------------------
# Cookie の sum を認証
#-----------------------------------------------------------
sub collation_sum_cookie{

my($cookie_all_text);
my($my_cookie) = Mebius::my_cookie_main();

my($sum_hashed) = sum_cookie($cookie_all_text);

if($my_cookie->{'sum'} eq $sum_hashed){

}


}



package Mebius;

#-----------------------------------------------------------
# クッキーをゲット
#-----------------------------------------------------------
sub get_cookie{

# 宣言
my($cookie_name) = @_;
my(@cook,%cook);

	# 取得するクッキーを選ぶ（全体←→カテゴリ）
	if(!$cookie_name) { die("Perl Die! Cookie name is empty.") }

	# Cookie全体を分解して、任意のIDを取り出す
	foreach( split(/;/,$ENV{'HTTP_COOKIE'}) ) {
		my($key,$val) = split(/=/);
		$key =~ s/\s//g;
		$cook{$key} = $val;
	}

	# データをURLデコードして復元
	foreach ( split(/<>/, $cook{$cookie_name}) ) {
		s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;
		($_) = Mebius::escape(undef,$_);
		push(@cook,$_);
	}


# リターンする
return(\@cook,$cook{$cookie_name});


}

#-----------------------------------------------------------
# ログインしている場合に Cookieを上書き
#-----------------------------------------------------------
sub my_cookie_main_logined{

my($use) = @_;
my(%self,$colect_flag);
my($init_directory) = Mebius::BaseInitDirectory();

# Near State （呼び出し） 2.10
my $HereName1 = "my_cookie_main_logined";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }


# データを取得
my($my_access) = Mebius::my_access();
my($my_account) = Mebius::my_account();

# Cookieを普通にゲット
my($my_cookie_main) = Mebius::my_cookie_main();

# 値をコピーしておく
%self = %$my_cookie_main;

	# ▼携帯個体識別番号のセーブデータを呼び出し
	if($my_access->{'mobile_uid'}){
		my($save_mobile) = Mebius::save_data({ FileType => "Mobile" },$my_access->{'multi_user_agent'});
			if($save_mobile->{'f'}){
					foreach(%$save_mobile){
						if($_ =~ /^cookie_(\w+)$/){ $self{$1} = $save_mobile->{$_}; }
					}
				$self{'call_save_data_flag'} = 1;
			}

	}

	# ▼アカウントデータを取得して、値を上書きする
	elsif($my_account->{'login_flag'}){
			foreach(keys %$my_account){
					if($_ =~ /^cookie_(\w+)$/){ $self{$1} = $my_account->{$_}; }
			}
		$self{'call_save_data_flag'} = 1;
	}

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	# Near State （保存） 2.10
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,\%self); }

\%self;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_cookie_main_utf8{

my($my_cookie) = Mebius::my_cookie_main();

my $my_cookie_utf8 = hash_to_utf8($my_cookie);

$my_cookie_utf8;

}

#-----------------------------------------------------------
# メインのクッキーをハッシュとして取得
#-----------------------------------------------------------
sub my_cookie_main{

my($use) = @_;
my($colect_flag);

# Near State （呼び出し） 2.10
my $HereName1 = "my_cookie_main";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# クッキーゲット（メイン)
my($main_cookie,$main_cookie_body) = Mebius::get_cookie("love_me_aura");
my(%self) = Mebius::Cookie::array_to_hash_main(@$main_cookie);

	# Cookieが存在する場合
	if($main_cookie_body){
			# SUMを照合 2012/3/15 (木) 以降
			if($self{'last_set_time'} >= 1331798291){
				my($collect_flag) = Mebius::Cookie::collation_sum("love_me_aura",$main_cookie_body);
			}
	}

# 特定の値のエスケープ
($self{'char_escaped'} = $self{'char'}) =~ s/[^0-9a-zA-Z]//g;

	# Near State （保存） 2.10
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,\%self); }

\%self;

}

#-----------------------------------------------------------
# Cookieをセット
#-----------------------------------------------------------
sub set_cookie{

# 宣言
my($use) = shift if(ref $_[0] eq "HASH");
my($cookie_name,$set_cookie) = @_;
my(@savecook,@savemobile,$set_cnumber);
my($i,$gmt,$cook,$setdomain,$onset_flag,@saveaccount,$cookie_body,$set_cfirst_set_time,%self);
my($my_access) = Mebius::my_access();

# 名前定義
my $HereName1 = "set_cookie";
my $HereKey1 = $cookie_name;

# 二回以上の同一名での Set-cookie を禁止 ( 二回目以降は無視する )
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ 
		#Mebius::AccessLog(undef,"SET-2COOKIES");
		return();
	}
	else{
		Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1);
	}

	# クッキー名を定義
	if($cookie_name eq "") { die("Perl Die! Cookie name is empty.") }

	# 二重セットを回避 
	#if($done{"cookie=>$cookie_name"}){
	#	$done{"cookie=>$cookie_name"}++;
	#	Mebius::AccessLog(undef,"SET-2COOKIES",qq(セット回数 \$done{"cookie=>$cookie_name"} == $done{"cookie=>$cookie_name"}));
	#}
	#else{ $done{"cookie=>$cookie_name"}++; }

	# 記録用データをエンコード
	foreach(@$set_cookie){
		$i++;
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
		push(@{$self{'setted'}},$_); # 外部受け継ぎ用
	}

# クッキーをセット
Mebius::Cookie::set_core($cookie_name,$cook,365*24*60*60);

	# 二重クッキーの削除
	#if($dobcookienum >= 2){
	#print "Set-Cookie: ${cookie_setname}=$cook; max-age=0; expires=Fri, 5-Oct-1979 08:10:00 GMT; path=/;\n";
	#}


$self{'body'} = $cook;

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereName1); }


\%self;


}


#-----------------------------------------------------------
# Cnumber のハッシュ化
#-----------------------------------------------------------
sub hashed_cookie_char{

# 宣言
my($type,$cnumber) = @_;
my($hashed_cnumber);

	# リターン
	if($cnumber eq "" || $cnumber =~ /[^a-zA-Z0-9]/){ return(); }

	# 暗号化
	my $salt = "WYlMqu6Ow1QffJNKVpVT2qgyeeySJ0,kvwzqwHRvNCmd4UywmZUbkrBI5B2HN,TWTV4L3p62XoOMg0SsXPsn4kVj5ed7";
	($hashed_cnumber) = Mebius::Crypt::crypt_text("Digest-base64 Not-special-charactor",$cnumber,$salt);


return($hashed_cnumber);


}

#-----------------------------------------------------------
# Cnumber 
#-----------------------------------------------------------
sub my_hashed_cookie_char{

my($cookie) = Mebius::my_cookie_main();

my($hashed) = Mebius::hashed_cookie_char(undef,$cookie->{'char'});

$hashed;

}


1;
