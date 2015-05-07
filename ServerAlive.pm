
use strict;
package Mebius;
use Mebius::Getstatus;

#-----------------------------------------------------------
# Not Found エラーページ - strict
#-----------------------------------------------------------
sub ServerAlive{

# 宣言
my($server_access_flag,$success_flag,$use_mode);
my($server_domain,$result_line);

# モード切り替え ( コマンドライン / HTTP )
$use_mode = "command";

my($all_server_addrs) = Mebius::Server::all_server_addrs();

	# 自サーバーからのアクセスのみ許容
	foreach(@$all_server_addrs){
			if($main::addr eq $_){ $server_access_flag = 1; }
	}
	if(!$server_access_flag && $main::addr && !$main::alocal_mode && !$main::myadmin_flag){ main::error("この機\能\は使えません。 $main::addr"); }


	# 自ホスト名を定義
	if($use_mode eq "command"){
		$server_domain = $ARGV[0];
	}
	else{
		$server_domain = $ENV{'SERVER_NAME'};
	}
	if($server_domain eq ""){ main::error("自サーバーホスト名が定義できません。"); }

	# ドメインを展開
	foreach(@main::domains){

		# 局所化
		my($success_flag,$get_status_url,@status);

		# 自分自身は調べない
		if($_ eq $server_domain){ next; }

		# 取得するURLを定義
		$get_status_url = "http://$_/";

		# ステータスをゲット
		for(1..5){

			# ステータスをゲット
			my($status) = Mebius::Getstatus("Command",$get_status_url);
			push(@status,$status);

			# 判定
			if($status eq "200"){ $success_flag = 1; last; }
			else{ sleep(60); }

		}

		$result_line .= qq( / URL: $get_status_url Status: @status);

		# 200 OK が一度も返らなかった場合、メールを送信
		if(!$success_flag){
			Mebius::Email::send_email("To-master-mobile",undef,"$_ サーバー接続不可","$_ のサーバーに上手く繋がらなかったようです。 $main::date ");
		}

		# 成功した場合
		else{
			Mebius::Email::send_email("To-master",undef,"$_ サーバー接続可","$_ のサーバーに上手く繋がったようです。");
		}

		# ログを記録
		Mebius::AccessLog(undef,"Server-Alive","$result_line");

	}


	# HTML
	if($use_mode ne "command"){ print "Content-type:text/html\n\n"; }

	# 出力
	print qq(Server alive check was done $result_line);

exit;

}

1;
