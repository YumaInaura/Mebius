
use strict;
package Mebius::Auth;
use Mebius::Query;

#-----------------------------------------------------------
# サーバー間リダイレクト
#-----------------------------------------------------------
sub ServerMove{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$server_domain) = @_;
my(undef,undef,$redirect_last_url,$plus_query,$exclusion_names) = @_ if($type =~ /Use-all-query/);
my($redirect_url_top,$doned_query,$doned,$max_doned,$redirect_url_plus);
my($q) = Mebius::query_state();

	# 処理最大回数
	if($type =~ /All-domains/){
		$max_doned = $basic_init->{'number_of_domains'};
	}
	elsif($type =~ /All-servers/){
		$max_doned = $basic_init->{'number_of_servers'};
	}

	# 処理完了回数
	{

		$doned = $main::in{'doned'};
			if(!$doned){ $doned = 1; }
		$doned_query = $doned + 1;
	}

	# リダイレクト先を $dec_postbuf から定義 ($decoded_query が空の場合は、ForeachQuery 内の処理で補完する )
	if($type =~ /Use-all-query/){
		
		my($query) = Mebius::ForeachQuery(undef,undef,"doned,$exclusion_names");
		$redirect_url_plus = qq(?$query&doned=$doned_query);
			if($plus_query && $doned == 1){ $redirect_url_plus .= qq(&$plus_query); }
	}

	# 全ドメイン ( Cookieのための処理 )  
	if($type =~ /All-domains/){
			if($server_domain eq "sns.mb2.jp"){
				$redirect_url_top = "http://mb2.jp/_auth2/"
			}
			elsif($server_domain eq "mb2.jp"){
				$redirect_url_top = "http://aurasoul.mb2.jp/_auth/"
			}
			elsif($server_domain eq "aurasoul.mb2.jp"){
				$redirect_url_top = "http://sns.mb2.jp/"
			}
			elsif($server_domain eq "localhost"){
				$redirect_url_top = "http://localhost/_auth/"
			}
	}

	# サーバー毎
	else{
			if($server_domain eq "aurasoul.mb2.jp" || $server_domain eq "sns.mb2.jp"){
				$redirect_url_top = "http://mb2.jp/_auth2/"
			}
			elsif($server_domain eq "mb2.jp"){
				$redirect_url_top = "http://sns.mb2.jp/"
			}
			elsif($server_domain eq "localhost"){
				$redirect_url_top = "http://localhost/_auth/"
			}
	}


	# 処理回数がマックスに達した場合
	if($type =~ /Direct-redirect/ && $doned >= $max_doned){

			# クエリ引数から戻り先を取得
			my($backurl) = Mebius::back_url( $q->param('back_url') );

			# 戻り先が指定されており、なおかつ正規のURLの場合
			if($type =~ /Backurl/ && $backurl->{'url'}){
				Mebius::Redirect(undef,$backurl->{'url'});
			}
			# 最終的なリダイレクト先URL
			elsif($redirect_last_url){
				Mebius::Redirect(undef,$redirect_last_url);
			}
			else{
				return();
			}
	}
	# すぐリダイレクト
	elsif($type =~ /Direct-redirect/ && $redirect_url_top){

#if($main::myadmin_flag >= 5){
#main::error("$redirect_url_top$redirect_url_plus");
#}

		Mebius::Redirect(undef,"$redirect_url_top$redirect_url_plus");
	}



return($redirect_url_top);

}

1;