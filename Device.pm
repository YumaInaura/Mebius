
use strict;
package Mebius::Device;

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_user_target_on_hash{

my $self = shift;
my $relay_hash = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%where);

	if( my $target = $my_account->{'id'}){
		$where{'account'} = $target;
	}

	if( my $target = $my_cookie->{'char'}){
		$where{'cnumber'} = $target;
	} elsif( my $target = $ENV{'REMOTE_ADDR'} ){
		$where{'addr'} = $target;
	}

%where;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_myself_check{

my $self = shift;
my $data = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($hit);

	if($data->{'account'} && $data->{'account'} eq $my_account->{'id'}){
		$hit++;
	}



	if($data->{'cnumber'} && $data->{'cnumber'} eq $my_cookie->{'char'}){
		$hit++;
	}

$hit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub data_to_myself_check_strong{

my $self = shift;
my $data = shift;
my($hit);

my $hit = $self->data_to_myself_check($data);

	if($data->{'addr'} && $data->{'addr'} eq $ENV{'REMOTE_ADDR'}){
		$hit++;
	}

$hit;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_user_target_on_hash_only{

my $self = shift;
my $relay_hash = shift;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my(%where);

	if( my $target = $my_account->{'id'}){
		$where{'account'} = $target;
	} elsif( my $target = $my_cookie->{'char'}){
		$where{'cnumber'} = $target;
	}

%where;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub add_hash_with_access_target{

my $self = shift;
my $relay_hash = shift || die;
my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();

my %where = %{$relay_hash};

	if( my $target = $my_account->{'id'}){
		$where{'access_target'} = $target;
		$where{'access_target_type'} = "account";
	} elsif ( my $target = $my_cookie->{'char'}){
		$where{'access_target'} = $target;
		$where{'access_target_type'} = "cnumber";

	} else {
		return();
	}


%where;

}


#-----------------------------------------------------------
# ボット判定
#-----------------------------------------------------------
sub bot_judge{

# 宣言
my($use) = @_;
my($bot_flag,$real_user_agent);

	# 自分のアクセスの場合
	if(exists $use->{'UserAgent'}){
		$real_user_agent = $use->{'UserAgent'};
	}
	else{
		$real_user_agent = $ENV{'HTTP_USER_AGENT'};
	}
	# UAがない場合はリターン
	if(!$real_user_agent){ return(); }

	# 判定
	if($real_user_agent =~ m!
		(Bot|bot|Slurp|slurp|Spider|spider|Crawl|crawl|search|mobile goo|Mediapartners-Google)
		|(\+https?://(.+?)\.([a-zA-Z]{2,4})/)
		!x){
		$bot_flag = 1;
	}

return($bot_flag);

}

#-----------------------------------------------------------
# 別名
#-----------------------------------------------------------
sub use_device_mobile_judge{ use_device_is_mobile(__PACKAGE__,@_); }

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}

#-----------------------------------------------------------
# 端末が GZIP 圧縮に対応しているかを判定
#-----------------------------------------------------------
sub accept_gzip_type{

my $self = shift;
my($usegzip);

	# バグのあるブラウザ
	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE [1-6]\.|rv:11\.|Macintosh(.+)Safari/){ return(); }

	# 圧縮可能な端末かどうかを判定
	foreach my $enc ( split( /\s*,\s*/, $ENV{'HTTP_ACCEPT_ENCODING'} )) {
		$enc =~ s/;.*$//s;      # ; qs= 等は無視する
		$usegzip = $enc if ( $enc =~ /^(x-)?gzip$/ );
	}

$usegzip;

}


#-----------------------------------------------------------
# 接続情報をいちどに取得する
#-----------------------------------------------------------
sub my_connection{

my $self = shift;
my(%data);

my($my_account) = Mebius::my_account();
my($my_cookie) = Mebius::my_cookie_main();
my($my_access) = Mebius::my_access();
($data{'id'}) = Mebius::my_id();
$data{'user_id'} = $data{'id'};

$data{'account'} = $my_account->{'id'};
$data{'cnumber'} = $data{'cookie'} = $my_cookie->{'char_escaped'};
$data{'user_agent'} = $my_access->{'multi_user_agent'};
$data{'host'} = Mebius::get_host_state();
($data{'addr'}) = Mebius::my_addr();

	if($my_access->{'mobile_uid'}){ $data{'mobile_uid'} = $data{'mobile_full_uid'} = $my_access->{'multi_user_agent'}; }

\%data;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub add_hash_with_my_connection{

my $self = shift;
my $hash = shift;

my $connection = $self->my_connection();

my %added_hash = (%{$hash},%{$connection});

\%added_hash;

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub my_connection_add_hash{

my $self = shift;
my $hash = shift;
my(%added_hash);

my %hash = %{$hash};

%added_hash = (%hash,%{$self->my_connection()});

\%added_hash;

}



#-----------------------------------------------------------
# スマフォ判定
#-----------------------------------------------------------
sub use_device_is_smart_phone{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();

$my_use_device->{'smart_phone_flag'};

}

#-----------------------------------------------------------
# ガラケー判定
#-----------------------------------------------------------
sub use_device_is_mobile{

my $self = shift;
my($my_use_device) = Mebius::my_use_device();

$my_use_device->{'mobile_flag'};

}

#-----------------------------------------------------------
# ガラケー判定
#-----------------------------------------------------------
sub use_device_is_smart_phone_or_mobile{

my $self = shift;
my $flag = $self->use_device_is_mobile() || $self->use_device_is_smart_phone();
$flag;
}
package Mebius;

#-----------------------------------------------------------
# 接続情報をいちどに取得する
#-----------------------------------------------------------
sub my_connection{

my $device = new Mebius::Device;
$device->my_connection(@_);

}




#-----------------------------------------------------------
# 自分のアクセスから各種のデバイス情報を一斉に取得
#  => 書き方少し煩雑なので、整理したい
#-----------------------------------------------------------
sub my_access{

# 宣言
my($basic_init) = Mebius::basic_init();
my(%access);

# 名前を定義
my $HereName1 = "my_access";
my $HereKey1 = "normal";

# Near State （呼び出し）
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

# 二種類のデバイスタイプを取得
my($use_device) = Mebius::my_use_device();
my($real_device) = Mebius::my_real_device();

# UAを定義
$access{'multi_user_agent'} = $ENV{'HTTP_USER_AGENT'};

	# ユーザーエージェント等によっては、ここでホスト名を取得 )A-1
	# => $ENV{'REQUEST_METHOD'} eq "POST" は必要 (今のところ A-2 と連動 )
	if(($real_device->{'type'} eq "Mobile" || $ENV{'HTTP_X_UP_SUBNO'} || $ENV{'HTTP_X_EM_UID'} || $ENV{'REQUEST_METHOD'} eq "POST") && (!$real_device->{'bot_flag'})){

		# 【ファイル情報】を優先して、ホスト情報を取得
		my($multi_host) = Mebius::Host::gethostbyaddr_cache_multi();

				# UAのモバイルIDとホスト名のモバイル判定が一致した場合は、モバイルからのアクセスと判定
				if($multi_host->{'mobile_id'} && $multi_host->{'mobile_id'} eq $real_device->{'id'}){

						$access{'mobile_flag'} = 1;
						$access{'mobile_id'} = $real_device->{'id'};
						$access{'mobile_uid'} = $real_device->{'mobile_uid'};

							# $kaccess"es" を定義	# この変数は使う？
							if($access{'mobile_uid'}){ $access{'mobile_use_id'} = "$access{'mobile_id'}-$access{'mobile_uid'}"; }
							else{ $access{'mobile_use_id'} = $access{'mobile_id'}; }

							# UAデータとして記録する値を変更
							if($real_device->{'mobile_uid_agent'}) { $access{'multi_user_agent'} = $real_device->{'mobile_uid_agent'}; }
				}

			# 投稿レベルを低くする ( ホスト名が逆引き出来ずWhoisから検索して特別許可した場合と、携帯以外の端末でCookieがない場合 ) (A-2)
			# SSS => 携帯以外の GET 送信ではレベルが取得できないので、他の処理に移動する？ それとも全てのPOSTで判定しているから大丈夫？」
			if($multi_host->{'addr_to_host_flag'}){ $access{'low_level_flag'} = 1; $access{'low_level_error_type_message'} = "ホスト名の逆引き不可"; }
			#elsif(!$ENV{'HTTP_COOKIE'} && !$access{'mobile_flag'}){ $access{'low_level_flag'} = 1; $access{'low_level_error_type_message'} = "Cookieが無効";  }
	}

	# 認証済みのIDを定義 (携帯のID詐称を禁止)
	if($real_device->{'mobile_id'}){
			if($access{'mobile_flag'}){ $access{'id'} = $real_device->{'id'}; }
			else{ $access{'id'} = ""; }
	}
	else{ $access{'id'} = $real_device->{'id'}; }

	# ●投稿レベルを定義
	if(!$real_device->{'bot_flag'} && $access{'multi_user_agent'} && ($ENV{'HTTP_COOKIE'} || $access{'mobile_id'})){
			$use_device->{'level'} = 2; # 荒技 ?
			$real_device->{'level'} = 2; # 荒技 ?
			$access{'level'} = 2;
	}

# UAを整形
($access{'multi_user_agent_escaped'}) = Mebius::escape("",$access{'multi_user_agent'});

	# ●アクセスログを記録 ( 管理用 ) 
	if(rand(50) < 1 || Mebius::alocal_judge()){
			if($use_device->{'bot_flag'} && $use_device->{'type'} eq "Smart-phone"){ Mebius::AccessLog(undef,"Bot-smart-phone"); }
			if($use_device->{'bot_flag'}){ Mebius::AccessLog(undef,"BOT"); }
			#if($ENV{'HTTP_USER_AGENT'} eq ""){ Mebius::AccessLog(undef,"NOAGENT"); }
			#if($ENV{'HTTP_REFERER'} && $ENV{'HTTP_REFERER'} !~ /$basic_init->{'top_level_domain'}/){ Mebius::AccessLog(undef,"REFERER"); }
			if(Mebius::alocal_judge()){ Mebius::AccessLog(undef,"Alocal-access"); }
			#if($multi_host->{'mobile_id'} && $multi_host->{'mobile_id'} ne $real_device->{'id'}){
			#	Mebius::AccessLog(undef,"Strange-mobile-uid","ホスト名: $multi_host->{'host'} / ホスト判定のmobile_id $multi_host->{'mobile_id'} / UA判定の mobile_id $real_device->{'id'}");
			#}
	}

	# 各サブルーチンのユースフルな変数を代入
	if($real_device->{'bot_flag'}){ $access{'bot_flag'} = 1; }

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	# Near State （保存）
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,\%access); }

return(\%access);
}


#-----------------------------------------------------------
# Cookie などによって選ばれたデバイスから、各種の変数を設定
#----------------------------------------------------------
sub my_use_device{

# 宣言
my($use) = @_;
my($use_device);
my($my_cookie) = Mebius::my_cookie_main();

# Near State （呼び出し）
my $HereName1 = "my_use_device";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

	# Cookieから デバイスタイプを判定
	if($my_cookie->{'device_type'}){
		($use_device) = Mebius::device({ DeviceType => $my_cookie->{'device_type'} });
	}
	# UAからデバイスタイプを判定
	else{
		($use_device) =  Mebius::device();
	}

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }


	# Near State （保存）
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,$use_device); }

#リターン
return($use_device);

}

#-----------------------------------------------------------
# リアルデバイス端末
#-----------------------------------------------------------
sub my_real_device{

# 宣言
my($use) = @_;

# Near State （呼び出し）
my $HereName1 = "my_real_device";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ループ予防
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

# デバイス情報を取得
my($real_device) =  Mebius::device();

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	# Near State （保存）
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,$real_device); }

return($real_device);


}



#-----------------------------------------------------------
# 端末の判定 - strict
#-----------------------------------------------------------
sub device{

# 宣言
my($use) = shift if(ref $_[0] eq "HASH");
my($select_user_agent) = shift;
my($agent,%device,$OwnAccessFlag,$UserAgent);


	# ●Cookie から デバイスタイプを定義する場合
	if(exists $use->{'DeviceType'}){
		$device{'type'} = $use->{'DeviceType'};

		# 重要なフラグを立てる
		$OwnAccessFlag = 1;

	}

	# ●実際の UA から判定する場合
	else{ 

			# ●ユーザーエージェントを指定する場合
			if(exists $use->{'UserAgent'}){
					if($use->{'UserAgent'} eq ""){ return(); }
					else{ $UserAgent = $use->{'UserAgent'}; }
			}

			# ●ユーザーエージェントを指定する場合
			elsif($select_user_agent){
					if($select_user_agent eq ""){ return(); }
					else{ $UserAgent = $select_user_agent; }
			}

			# ●自分のアクセスの場合 
			else{

				$UserAgent = $ENV{'HTTP_USER_AGENT'};

				# 重要なフラグを立てる
				$OwnAccessFlag = 1;

			}


			# ● 指定されたUAに応じて、各種端末タイプを定義 

			# フィーチャーフォン
			if($UserAgent =~ /^DoCoMo/){ $device{'type'} = "Mobile"; $device{'id'} = "DOCOMO"; 	$device{'utn'} = qq( utn="utn"); }
			elsif($UserAgent =~ /UP\.Browser|^KDDI|^J-EMULATOR|^Vemulator/){ $device{'type'} = "Mobile"; $device{'id'} = "AU"; }
			elsif($UserAgent =~ /^J-PHONE|^SoftBank|^Vodafone/){ $device{'type'} = "Mobile"; $device{'id'} = "SOFTBANK"; }
			elsif($UserAgent =~ /WILLCOM|DDIPOCKET/){ $device{'type'} = "Mobile"; $device{'id'} = "WILLCOM"; }
			elsif($UserAgent =~ /^emobile/){ $device{'type'} = "Mobile"; $device{'id'} = "EMOBILE"; }
			elsif($UserAgent =~ /^Nokia|^SAMSUNG/){ $device{'type'} = "Mobile"; $device{'id'} = "FOREIGN"; }
			elsif($UserAgent =~ /\.ezweb\.ne\.jp$/){ $device{'type'} = "Mobile"; $device{'id'} = "AU"; }

			# スマートフォン
			elsif($UserAgent =~ /(Android)(.+?)(Mobile)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "Android"; }
			elsif($UserAgent =~ /(iPhone;)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "iPhone"; $device{'iphone_flag'} = 1; }
			elsif($UserAgent =~ /(iPod;)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "iPod"; $device{'iphone_flag'} = 1; }
			elsif($UserAgent =~ /(^Mozilla)(.+?)(Windows Phone)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "WindowsPhone"; }
			elsif($UserAgent =~ /(BlackBerry)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "Smart"; }
			elsif($UserAgent =~ /(^Mozilla)(.+?)(Mobile)/ && $UserAgent !~ /(iPad)/){ $device{'type'} = "Smart-phone"; $device{'id'} = "Smart"; }

			# フィーチャーフォンのフルブラウザ
			elsif($UserAgent =~ m!^Mozilla(.+)(KDDI|FOMA|SoftBank)!){
				$device{'type'} = "Full-mobile-browser";
				$device{'id'} = "FullBrowser";
			}

			# タブレットＰＣ
			elsif($UserAgent =~ /(Android)/){ $device{'type'} = "Tablet-pc"; $device{'id'} = "Tablet"; }
			elsif($UserAgent =~ /iPad/){ $device{'type'} = "Tablet-pc"; $device{'id'} = "iPad"; }
			elsif($UserAgent =~ /Kindle|Silk-Accelerated/){ $device{'type'} = "Tablet-pc"; $device{'id'} = "Kindle"; }

			# 小型ゲーム機
			elsif($UserAgent =~ /PlayStation Portable/){ $device{'type'} = "Portable-game-player"; $device{'id'} = "PSP"; }
			elsif($UserAgent =~ /PlayStation Vita/){ $device{'type'} = "Portable-game-player"; $device{'id'} = "PSVita"; }
			elsif($UserAgent eq 'Mozilla/4.0 (compatible; MSIE 6.0; Nitro) Opera 8.50 [ja]'){ $device{'type'} = "Portable-game-player"; $device{'id'} = "DS"; }
			elsif($UserAgent =~ /Nintendo (3?DSi?)/){ $device{'type'} = "Portable-game-player"; $device{'id'} = $1; $device{'ds_flag'} = 1; }

			# 家庭用ゲーム機
			elsif($UserAgent =~ /Nintendo (Wii(U)?)/){ $device{'type'} = "Home-game-player"; $device{'id'} = $1; }
			elsif($UserAgent =~ /Xbox\)/){ $device{'type'} = "Home-game-player"; $device{'id'} = "Xbox"; }
			elsif($UserAgent =~ /DreamPassport/){ $device{'type'} = "Home-game-player"; $device{'id'} = "DreamCast"; }
			elsif($UserAgent =~ /PS2; PlayStation BB Navigator/){ $device{'type'} = "Home-game-player"; $device{'id'} = "PS2"; }
			elsif($UserAgent =~ /PLAYSTATION 3;/){ $device{'type'} = "Home-game-player"; $device{'id'} = "PS3"; }

			# デスクトップ
			else{ $device{'type'} = "Desktop"; }

		# ボット判定
		($device{'bot_flag'}) = Mebius::Device::bot_judge({ UserAgent => $UserAgent });

	}

	# モバイルID
	if($device{'type'} eq "Mobile"){ $device{'mobile_id'} = $device{'id'}; }

	# デスクトップ
	if($device{'type'} =~ /^(Tablet-pc)$/){
		$device{'tablet_flag'} = 1;
	}

	# デスクトップ
	if($device{'type'} =~ /^(Tablet-pc|Desktop|Home-game-player)$/){
		$device{'wide_flag'} = 1;
	}
	else{
		$device{'narrow_flag'} = 1;
	}

	# 小さい画面フラグ
	if($device{'type'} =~ /^(Smart-phone|Full-mobile-browser)$/ || $device{'ds_flag'}){
		$device{'smart_flag'} = $device{'smart_phone_flag'} = 1;
		$device{'smart_css_flag'} = 1;
		$device{'touch_flag'} = 1;
	}

	# モバイルフラグ
	if($device{'type'} eq "Mobile"){
		$device{'mobile_flag'} = 1;
	}

	# 広告の選別
	if($device{'type'} =~ /^(Smart-phone|Full-mobile-browser)$/){
		$device{'smart_ad_flag'} = 1;
	}

	# CSSの選別
	#if($device{'type'} =~ /^(Smart-phone|Full-mobile-browser)$/){ $device{'smart_css_flag'} = 1; }

	# データサイズ対応
	if($device{'type'} =~ /^(Smart-phone|Full-mobile-browser|Portable-game-player|Mobile)$/){
		$device{'limited_datasize_flag'} = $device{'limited_flag'} = 1;
		$device{'smart_display_flag'} = 1;
	}

	# タッチ式ディスプレイか否か
	if($device{'type'} =~ /^(Smart-phone|Tablet-pc)$/){
		$device{'touch_display_flag'} = 1;
	}

	# 全スマート端末フラグ
	if($device{'type'} =~ /^(Smart-phone|Portable-game-player|Tablet-pc|Full-mobile-browser)$/){ $device{'all_smart_flag'} = 1; }

	# ブラウズタイプ ( 古い変数だけど、これを今すぐに削除すると不具合が起こるため、しばらく残しておく
	# => グローバル変数 our $device_type に代入されている )
	if($device{'type'} eq "Mobile"){ $device{'browse_type'} = "mobile"; }
	else{ $device{'browse_type'} = "desktop"; }

	# ● 携帯の UID を判定

	# ドコモ判定 
	if($device{'id'} eq "DOCOMO"){
			if($UserAgent =~ /^DoCoMo([a-zA-Z0-9 ;\(\/\.]+?);ser([0-9a-z]{15});/){
					$device{'mobile_uid'} = $2;
			}
	}

	# AU判定
	elsif($device{'id'} eq "AU"){
		my($X_UP_SUBNP);
			if($OwnAccessFlag){ $X_UP_SUBNP = $ENV{'HTTP_X_UP_SUBNO'}; }
			else{ $X_UP_SUBNP = $UserAgent; }
			if($X_UP_SUBNP =~ /^([0-9]+)_([a-z]+)\.ezweb\.ne\.jp$/){
				$device{'mobile_uid_agent'} = $X_UP_SUBNP;
				$device{'mobile_uid'} = "${1}_${2}";
			}
	}

	# SOFTBANK判定
	elsif($device{'id'} eq "SOFTBANK"){
			if($UserAgent =~ /SN([0-9]+)/){
					$device{'mobile_uid'} = $1;
			}
	}

	# Eモバイル判定
	elsif($device{'id'} eq "EMOBILE"){
		my($HTTP_X_EM_UID);
			if($OwnAccessFlag){ $HTTP_X_EM_UID =  $ENV{'HTTP_X_EM_UID'}; }
			else{ $HTTP_X_EM_UID = $UserAgent; }
			if($HTTP_X_EM_UID =~ /u([0-9a-zA-Z]+)/){
				$device{'mobile_uid_agent'} = $HTTP_X_EM_UID;
				$device{'mobile_uid'} = "$1";
			}
	}

	# ウィルコム判定
	elsif($device{'id'} eq "WILLCOM"){ }

	# $kaccess"es" を定義
	if($device{'mobile_id'} && $device{'mobile_uid'}){ $device{'mobile_full_id'} = "$device{'mobile_id'}-$device{'mobile_uid'}"; }
	elsif($device{'id'}){ $device{'mobile_full_id'} = $device{'mobile_id'}; }

# リターン
return(\%device);

}


#-----------------------------------------------------------
# IDをゲット
#-----------------------------------------------------------
sub my_id{


# Near State （呼び出し） 2.30
my $HereName1 = "my_id";
my $StateKey1 = "Normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

my($encid,undef,$id_material) = main::id();

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$encid); }

$encid;

}

#-----------------------------------------------------------
# IDの素を定義
#-----------------------------------------------------------
sub my_id_material{

my($my_access) = Mebius::my_access();
my($now_date) = Mebius::now_date_multi();
my($id_material);

	# ●携帯端末のID割り振り
	if($my_access->{'mobile_id'}){
		$id_material = "k" . int(rand(9999999));
	}
	else{
		($id_material) = Mebius::Crypt::crypt_text($ENV{'REMOTE_ADDR'},["4jfGJEfja5gjajahHJAkaksl4gjakdaf","3GJjhja93jjaDGjhjarhjgaAHajdagHFAHajadgad84jkghadVLhgdagad","4kgaHajhaAljsFasjgagaHGHadjf49gadjk","$now_date->{'yearf'}"]);
	}

$id_material;

}



#-----------------------------------------------------------
# ID を定義
#-----------------------------------------------------------
sub my_id{

# 宣言
my($type) = @_;
my($idsalt1,$idsalt2,$idsalt3) = ('7c','Mi','x8');
my($last_encid,$encid_plus,$encid_plus_body,$idjoint_mark,$first_crypt,$pure_encid,$device_encid);
my($my_cookie) = Mebius::my_cookie_main(); # 無限ループが発生するため、logined にはしない
my($my_access) = Mebius::my_access();
# ループ予防
my $HereName1 = "get_id";
my $HereKey1 = "normal";
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }

	# 別のトリップをセットする場合 ( 掲示板の個別設定より )
	if($main::bbs{'another_idsalt'}){ $idsalt1 = $main::bbs{'another_idsalt'}; }

	# 種が無い場合
	if($idsalt1 eq ""){ return(); }

	# ●携帯端末のID割り振り
	if($my_access->{'mobile_id'}){

			# ▼携帯 - 固体識別番号がある場合
			if($my_access->{'mobile_uid'}){
				# 第一変換
				($first_crypt) = Mebius::Crypt::crypt_text("MD5","$my_access->{'mobile_uid'}_$my_access->{'mobile_id'}",$idsalt1);
			}

			# ▼携帯 - 個体識別番号がない場合
			else{

					# クッキーありの場合
					if($my_cookie->{'id_material'}){
						$first_crypt = $my_cookie->{'id_material'};
					}

					# クッキーなしの場合
					else{
						# 第一変換
						($first_crypt) = Mebius::my_id_material();
					}
			}

	}

	# ●ＰＣ端末のID割り振り
	else{

			# ▼クッキーの【ID素】が既にセットされている場合
			if($my_cookie->{'id_material'}){
				$first_crypt = $my_cookie->{'id_material'};
			}

			# ▼クッキーの【ID素】がない場合
			else{
				# 第一変換
				($first_crypt) = Mebius::my_id_material();
			}

	}

# セキュリティのための第二変換
my($second_crypt) = Mebius::Crypt::crypt_text("MD5",$first_crypt,$idsalt2);

# セキュリティのための第三変換
($pure_encid) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$second_crypt,$idsalt3,10);

	# トリップの特殊キーでＩＤを変更
	if($main::trip_concept =~ /Id-change/){
		# 第三変換
		($pure_encid) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$pure_encid,"an",10);
	}

	# ●端末を認識してＩＤに付与
	# 端末ID
	if($my_access->{'id'}){ 
			if($ENV{'HTTP_COOKIE'}){ 
				$last_encid = qq($my_access->{'id'}=$pure_encid);
			} else {
				$last_encid = qq($my_access->{'id'}-$pure_encid)
			}
	}

	# ▼その他の標準ブラウザ
	else{
		my($other_salt);
			if($main::bbs{'another_idsalt'}){ $other_salt = "J5"; }
			else{ $other_salt = "xJ"; }
		my($encid_option) = Mebius::Crypt::crypt_text("MD5 Not-special-charactor",$main::agent,$other_salt,3);
		$last_encid = "${pure_encid}_${encid_option}";
	}


# グローバル変数に代入
$main::encid = $last_encid;
$main::pure_encid = $pure_encid;

	# ループ処理を予防 ( 解放 ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

# リターン
return($last_encid);


}


1;

