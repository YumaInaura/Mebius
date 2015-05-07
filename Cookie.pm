
use strict;
package Mebius::Cookie;
use Mebius::Export;

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
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
# �N�b�L�[���n�b�V���ŃQ�b�g
#-----------------------------------------------------------
sub get{

my($cookie_name) = @_;
my(%return);
my($cookie_body) = get_body_by_name($cookie_name);

	# �W�J���ăn�b�V����
	foreach(split(/,/,$cookie_body)){

		my($name,$value) = split(/:/);
		my($name_decoded) = Mebius::decode_text($name);
		my($value_decoded) = Mebius::decode_text($value);

		$return{$name_decoded} = $value_decoded;

	}

\%return;

}

#-----------------------------------------------------------
# ���ϐ��̒�����A����� Cookie �̃Z�b�g��Ԃ�
#-----------------------------------------------------------
sub get_body_by_name{

my($cookie_name) = @_;
my($return);

	# ������Cookie ����ނ��ƂɓW�J
	foreach( split(/;/,$ENV{'HTTP_COOKIE'}) ) {
	
		# �N�b�L�[���ƃ{�f�B�ɕ���
		my($cookie_name2,$cookie_body2) = split(/=/);
		$cookie_name2 =~ s/\s//g; # �Ȃ񂾂����H

			# �w�肵�� Cookie ���q�b�g������
			if($cookie_name eq $cookie_name2){
				$return = $cookie_body2;
			}
		}

$return;

}

#-----------------------------------------------------------
# �N�b�L�[���n�b�V���ŃZ�b�g ( �V�K�쐬 )
#-----------------------------------------------------------
sub set{

my($cookie_name,$set,$expires_localtime) = @_;
my(@cookie_body);

	if(!$expires_localtime){
		$expires_localtime = 365*24*60*60;
	}

	# �n�b�V����W�J
	foreach my $set_name ( keys %$set ){

		my($set_name_encoded) = Mebius::encode_text($set_name);
		my($set_value_encoded) = Mebius::encode_text($set->{$set_name});

		push(@cookie_body,"$set_name_encoded:$set_value_encoded");

	}

my $cookie_body = join(",",@cookie_body);

set_core($cookie_name,$cookie_body,$expires_localtime);


}


#-----------------------------------------------------------
# �N�b�L�[���n�b�V���ŃZ�b�g ( �V�K�쐬�A�܂��͏㏑�� )
#-----------------------------------------------------------
sub update{

my($cookie_name,$update,$expires_localtime) = @_;

# ���݂�Cookie���擾
my($exsting_cookie) = get($cookie_name);
my %set = %$exsting_cookie;

	# ���sCookie�̒l�͂��̂܂܂ŁA�X�V���e�������㏑������
	foreach  ( keys %$update ){
		$set{$_} = $update->{$_};
	}

set($cookie_name,\%set,$expires_localtime);


}

#-----------------------------------------------------------
# �N�b�L�[���Z�b�g ( �R�A�����̏��� )
#-----------------------------------------------------------
sub set_core{

my($cookie_name,$cookie_body,$expires_localtime) = @_;
my($my_access) = Mebius::my_access();
my($set);

# ������`
my($gmt) = Mebius::Cookie::localtime_to_gmt(time + $expires_localtime);


	# �N�b�L�[�̓��e���ŏI��`
	if($my_access->{'mobile_id'} eq "AU" || $my_access->{'mobile_id'} eq "SOFTBANK"){
		$set = "$cookie_name=$cookie_body; expires=$gmt; path=/;";
	}
	elsif(Mebius::alocal_judge()){
		$set = "$cookie_name=$cookie_body; expires=$gmt; path=/;";
	}
	else{
		$set = "$cookie_name=$cookie_body; domain=mb2.jp; expires=$gmt; path=/;";
	}

# �N�b�L�[���Z�b�g
print qq(Set-Cookie: $set\n);

}

#-----------------------------------------------------------
# ���[�J�������� GMT ��
#-----------------------------------------------------------
sub localtime_to_gmt{

my($localtime) = @_;

my @time = gmtime($localtime);
my @month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
my @week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

my $gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT", $week[$time[6]], $time[3], $month[$time[4]], $time[5]+1900, $time[2], $time[1], $time[0]);

}


#-----------------------------------------------------------
# ���C���N�b�L�[�̔z����n�b�V���ɕϊ�
#-----------------------------------------------------------
sub array_to_hash_main{

my(%cookie);

($cookie{'name'},$cookie{'refresh_second'},$cookie{'id_material'},$cookie{'font_color'},$cookie{'thread_up'},$cookie{'set_count'},$cookie{'last_post_time'},$cookie{'last_res_time'},$cookie{'gold'},$cookie{'regist_all_length'},$cookie{'regist_count'},$cookie{'font_size'},$cookie{'follow'},$cookie{'last_view_thread'},$cookie{'char'},$cookie{'use_history'},$cookie{'omit_text'},$cookie{'last_memo_time'},$cookie{'account'},$cookie{'hashed_password'},$cookie{'deleted_time'},$cookie{'bbs_news'},$cookie{'age'},$cookie{'email'},$cookie{'secret'},$cookie{'wait_second_res'},$cookie{'account_link'},$cookie{'last_set_time'},$cookie{'id_fillter'},$cookie{'account_fillter'},$cookie{'use_id_history'},$cookie{'device_type'},$cookie{'first_set_time'}) = @_;

%cookie;

}

#-----------------------------------------------------------
# ���C���N�b�L�[�̔z����n�b�V���ɕϊ�
#-----------------------------------------------------------
sub hash_to_array_main{

my(%cookie) = @_;

my @self = 
($cookie{'name'},$cookie{'refresh_second'},$cookie{'id_material'},$cookie{'font_color'},$cookie{'thread_up'},$cookie{'set_count'},$cookie{'last_post_time'},$cookie{'last_res_time'},$cookie{'gold'},$cookie{'regist_all_length'},$cookie{'regist_count'},$cookie{'font_size'},$cookie{'follow'},$cookie{'last_view_thread'},$cookie{'char'},$cookie{'use_history'},$cookie{'omit_text'},$cookie{'last_memo_time'},$cookie{'account'},$cookie{'hashed_password'},$cookie{'deleted_time'},$cookie{'bbs_news'},$cookie{'age'},$cookie{'email'},$cookie{'secret'},$cookie{'wait_second_res'},$cookie{'account_link'},$cookie{'last_set_time'},$cookie{'id_fillter'},$cookie{'account_fillter'},$cookie{'use_id_history'},$cookie{'device_type'},$cookie{'first_set_time'});

}

#-----------------------------------------------------------
# ���C���N�b�L�[���Z�b�g
#-----------------------------------------------------------
sub set_main{

# Cookie�Z�b�g
my($set_cookie,$use) = @_;
my($my_account) = Mebius::my_account();
my($my_access) = Mebius::my_access();
my($my_real_device) = Mebius::my_real_device();
my($init_directory) = Mebius::BaseInitDirectory();
my(%set_cookie,$renew_cookie_logined);

	if($use->{'source'} eq "utf8"){
		$set_cookie = hash_to_shift_jis($set_cookie);
	}

# �N�b�L�[��
my $cookie_name = "love_me_aura";

# �����̎��R��Cookie���擾
my($cookie) = Mebius::my_cookie_main();

# �J�E���g�𑝂₷
$set_cookie->{'+'}{'set_count'} = 1;
	# �Ǘ��ԍ����Ȃ��ꍇ�̓Z�b�g����
	if($cookie->{'char'} eq ""){ ($set_cookie->{'char'}) = Mebius::Crypt::char(undef,20); }
	# ���߂ẴZ�b�g�̏ꍇ�́A���̎������L�^����
	if(!$cookie->{'first_set_time'}){ $set_cookie->{'first_set_time'} = time; }
	# ID�̑f���Ȃ��ꍇ�̓Z�b�g���� ( Cookie ���Z�b�g�ł��Ȃ����ł̃n�b�V�����͕��ׂ�������? ��������Ȃ��̂ŁACookie�L�������𔻒肷�� )
	if(!$cookie->{'id_material'} && $ENV{'HTTP_COOKIE'}){ ($set_cookie->{'id_material'}) = Mebius::my_id_material(); }
	# �ŏI�Z�b�g�����i���ݎ����j���L�^����
	$set_cookie->{'last_set_time'} = time;

# Cookie��C�ӂ̒l�ɏ�������
my($renew_natural_cookie) = Mebius::Hash::control($cookie,$set_cookie);

	# ��Cookie�̃Z�[�u�@�\
	if($use->{'SaveToFile'}){

		# ���R��Cookie�̕ύX���e���L�����Ă��� 
		my %renew_natural_cookie = %$renew_natural_cookie;

		# ���O�C��Cookie���擾
		my($cookie_logined) = Mebius::my_cookie_main_logined();

		# �C�ӂ̒l�ɏ�������
		($renew_cookie_logined) = Mebius::Hash::control($cookie_logined,$set_cookie);


			# ���̎��ʔԍ��t�@�C���ւ̃Z�[�u
			if($my_access->{'mobile_uid'}){

					my %renew_save_mobile;

					# �l���ŏI���肳�ꂽCookie�̃n�b�V�����A�Z�[�u�f�[�^�p�̃n�b�V���ɕϊ�
					foreach(keys %$renew_cookie_logined){
							$renew_save_mobile{"cookie_$_"} = $renew_cookie_logined->{$_};
					}
					$renew_save_mobile{'+'}{'set_cookie_count'} = 1;
		
				# �t�@�C�����X�V
				my($renewed_save_data) = Mebius::save_data({ FileType => "Mobile" , Renew => 1 , select_renew => \%renew_save_mobile },$my_access->{'multi_user_agent'});

					# �t�@�C���ɋL�^�����l�ł́A����Cookie��ύX���Ȃ� (���X��Cookie�l�ŏ㏑������)
					#foreach(keys %$renewed_save_data){
					#			if($_ =~ /^cookie_(\w+)$/){ $renew_natural_cookie{$1} = $cookie->{$1}; }
					#}

			}

			# �� �A�J�E���g�ւ̃Z�[�u
			elsif($my_account->{'login_flag'}){

					my %renew_account;

					# �l���ŏI���肳�ꂽCookie�̃n�b�V�����A�A�J�E���g�p�̃n�b�V���ɕϊ�
					foreach(keys %$renew_cookie_logined){
							$renew_account{"cookie_$_"} = $renew_cookie_logined->{$_};
					}
					$renew_account{'+'}{'set_cookie_count'} = 1;

				# �t�@�C�����X�V
				my(%renewed_account) =  Mebius::Auth::File("Renew",$my_account->{'file'},\%renew_account);

					# �t�@�C���ɋL�^�����l�ł́A����Cookie��ύX���Ȃ� (���X��Cookie�l�ŏ㏑������)
					foreach(keys %renewed_account){
								if($_ =~ /^cookie_(\w+)$/){ $renew_natural_cookie{$1} = $cookie->{$1}; }
					}

			}

		# ���t�@�����X���Ē�`
		$renew_natural_cookie = \%renew_natural_cookie;

	}

# �ŏI��`���ꂽSet Cookie�̃n�b�V����z��ɕϊ�
my(@set_cookie) = Mebius::Cookie::hash_to_array_main(%$renew_natural_cookie);

# ���ۂ� Cookie ��z��ŃZ�b�g
my($setted_cookie) = Mebius::set_cookie($cookie_name,\@set_cookie);

	# Sum Cookie ���Z�b�g
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
# Sum���Z�b�g
#-----------------------------------------------------------
sub set_sum{

my($cookie_name,$cookie_body) = @_;
my($hashed_cookie_body) = Mebius::Cookie::hash_sum($cookie_body);
my $time = time;

Mebius::set_cookie("Sum",["$cookie_name:$hashed_cookie_body:$time"]);

}

#-----------------------------------------------------------
# Sum���ƍ�
#-----------------------------------------------------------
sub collation_sum{

my($cookie_name,$cookie_body) = @_;
my($collect_flag,$hashed_sum_hit,$set_time_hit,$cookie_name_hit);
my($my_real_device) = Mebius::my_real_device();

		my($hashed_cookie_body) = Mebius::Cookie::hash_sum($cookie_body);

		# �T�����擾
		my($sum_cookie,$sum_cookie_body) = main::get_cookie("Sum");

			foreach(@$sum_cookie){

				# �s�𕪉�
				my($cookie_name2,$hashed_sum2,$set_time2) = split(/\:/,$_);

						# �Y���� Cookie �����q�b�g�����{
						if($cookie_name2 eq $cookie_name){

								$hashed_sum_hit = $hashed_sum2;
								$set_time_hit = $set_time2;
								$cookie_name_hit = $cookie_name2;
						}
			}

	# �ƍ�
	if($hashed_cookie_body eq $hashed_sum_hit){ $collect_flag = 1; }

	# DS�̏ꍇ�͉������Ȃ�
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
# Cookie �� sum ���n�b�V����
#-----------------------------------------------------------
sub hash_sum{

my($cookie_all_text) = @_;

my($sum) = Mebius::Crypt::crypt_text($cookie_all_text,"Fdglda9856y5AGHHGt4gdajfsdagj48fgahsdf4ytgjad5agh7hDdagg8");

$sum;

}

#-----------------------------------------------------------
# Cookie �� sum ��F��
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
# �N�b�L�[���Q�b�g
#-----------------------------------------------------------
sub get_cookie{

# �錾
my($cookie_name) = @_;
my(@cook,%cook);

	# �擾����N�b�L�[��I�ԁi�S�́����J�e�S���j
	if(!$cookie_name) { die("Perl Die! Cookie name is empty.") }

	# Cookie�S�̂𕪉����āA�C�ӂ�ID�����o��
	foreach( split(/;/,$ENV{'HTTP_COOKIE'}) ) {
		my($key,$val) = split(/=/);
		$key =~ s/\s//g;
		$cook{$key} = $val;
	}

	# �f�[�^��URL�f�R�[�h���ĕ���
	foreach ( split(/<>/, $cook{$cookie_name}) ) {
		s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;
		($_) = Mebius::escape(undef,$_);
		push(@cook,$_);
	}


# ���^�[������
return(\@cook,$cook{$cookie_name});


}

#-----------------------------------------------------------
# ���O�C�����Ă���ꍇ�� Cookie���㏑��
#-----------------------------------------------------------
sub my_cookie_main_logined{

my($use) = @_;
my(%self,$colect_flag);
my($init_directory) = Mebius::BaseInitDirectory();

# Near State �i�Ăяo���j 2.10
my $HereName1 = "my_cookie_main_logined";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# ���[�v�\�h
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ die($roop); } else { Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1); }


# �f�[�^���擾
my($my_access) = Mebius::my_access();
my($my_account) = Mebius::my_account();

# Cookie�𕁒ʂɃQ�b�g
my($my_cookie_main) = Mebius::my_cookie_main();

# �l���R�s�[���Ă���
%self = %$my_cookie_main;

	# ���g�ь̎��ʔԍ��̃Z�[�u�f�[�^���Ăяo��
	if($my_access->{'mobile_uid'}){
		my($save_mobile) = Mebius::save_data({ FileType => "Mobile" },$my_access->{'multi_user_agent'});
			if($save_mobile->{'f'}){
					foreach(%$save_mobile){
						if($_ =~ /^cookie_(\w+)$/){ $self{$1} = $save_mobile->{$_}; }
					}
				$self{'call_save_data_flag'} = 1;
			}

	}

	# ���A�J�E���g�f�[�^���擾���āA�l���㏑������
	elsif($my_account->{'login_flag'}){
			foreach(keys %$my_account){
					if($_ =~ /^cookie_(\w+)$/){ $self{$1} = $my_account->{$_}; }
			}
		$self{'call_save_data_flag'} = 1;
	}

	# ���[�v������\�h ( ��� ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereKey1); }

	# Near State �i�ۑ��j 2.10
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
# ���C���̃N�b�L�[���n�b�V���Ƃ��Ď擾
#-----------------------------------------------------------
sub my_cookie_main{

my($use) = @_;
my($colect_flag);

# Near State �i�Ăяo���j 2.10
my $HereName1 = "my_cookie_main";
my $HereKey1 = $HereName1;
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$HereKey1);
	if(defined $state){ return($state); }
	else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$HereKey1); }

# �N�b�L�[�Q�b�g�i���C��)
my($main_cookie,$main_cookie_body) = Mebius::get_cookie("love_me_aura");
my(%self) = Mebius::Cookie::array_to_hash_main(@$main_cookie);

	# Cookie�����݂���ꍇ
	if($main_cookie_body){
			# SUM���ƍ� 2012/3/15 (��) �ȍ~
			if($self{'last_set_time'} >= 1331798291){
				my($collect_flag) = Mebius::Cookie::collation_sum("love_me_aura",$main_cookie_body);
			}
	}

# ����̒l�̃G�X�P�[�v
($self{'char_escaped'} = $self{'char'}) =~ s/[^0-9a-zA-Z]//g;

	# Near State �i�ۑ��j 2.10
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$HereKey1,\%self); }

\%self;

}

#-----------------------------------------------------------
# Cookie���Z�b�g
#-----------------------------------------------------------
sub set_cookie{

# �錾
my($use) = shift if(ref $_[0] eq "HASH");
my($cookie_name,$set_cookie) = @_;
my(@savecook,@savemobile,$set_cnumber);
my($i,$gmt,$cook,$setdomain,$onset_flag,@saveaccount,$cookie_body,$set_cfirst_set_time,%self);
my($my_access) = Mebius::my_access();

# ���O��`
my $HereName1 = "set_cookie";
my $HereKey1 = $cookie_name;

# ���ȏ�̓��ꖼ�ł� Set-cookie ���֎~ ( ���ڈȍ~�͖������� )
my($roop) = Mebius::Roop::block(__PACKAGE__,$HereName1,$HereKey1);
	if($roop){ 
		#Mebius::AccessLog(undef,"SET-2COOKIES");
		return();
	}
	else{
		Mebius::Roop::set(__PACKAGE__,$HereName1,$HereKey1);
	}

	# �N�b�L�[�����`
	if($cookie_name eq "") { die("Perl Die! Cookie name is empty.") }

	# ��d�Z�b�g����� 
	#if($done{"cookie=>$cookie_name"}){
	#	$done{"cookie=>$cookie_name"}++;
	#	Mebius::AccessLog(undef,"SET-2COOKIES",qq(�Z�b�g�� \$done{"cookie=>$cookie_name"} == $done{"cookie=>$cookie_name"}));
	#}
	#else{ $done{"cookie=>$cookie_name"}++; }

	# �L�^�p�f�[�^���G���R�[�h
	foreach(@$set_cookie){
		$i++;
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
		push(@{$self{'setted'}},$_); # �O���󂯌p���p
	}

# �N�b�L�[���Z�b�g
Mebius::Cookie::set_core($cookie_name,$cook,365*24*60*60);

	# ��d�N�b�L�[�̍폜
	#if($dobcookienum >= 2){
	#print "Set-Cookie: ${cookie_setname}=$cook; max-age=0; expires=Fri, 5-Oct-1979 08:10:00 GMT; path=/;\n";
	#}


$self{'body'} = $cook;

	# ���[�v������\�h ( ��� ) 1.1
	if($HereName1){ Mebius::Roop::relese(__PACKAGE__,$HereName1,$HereName1); }


\%self;


}


#-----------------------------------------------------------
# Cnumber �̃n�b�V����
#-----------------------------------------------------------
sub hashed_cookie_char{

# �錾
my($type,$cnumber) = @_;
my($hashed_cnumber);

	# ���^�[��
	if($cnumber eq "" || $cnumber =~ /[^a-zA-Z0-9]/){ return(); }

	# �Í���
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
