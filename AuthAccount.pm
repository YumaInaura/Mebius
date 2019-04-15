
use strict;
use File::Find;
use File::Basename;
package Mebius::Auth;
use Mebius::Export;
#use base qw(File::Basename);

#-----------------------------------------------------------
# �A�J�E���g�ꗗ�t�@�C��
#-----------------------------------------------------------
sub AccountListFile{

# �錾
my($type) = @_;
my(undef,$new_account,$new_handle) = @_ if($type =~ /New-account|Edit-account/);
my(undef,$search_keyword) = @_ if($type =~ /Keyword-search-mode/);
my($i,@renew_line,%data,$file_handler,$file1,%account_still,$max_line);
my($init_directory) = Mebius::BaseInitDirectory();

# �t�@�C����`
my $directory1 = Mebius::SNS::all_log_directory_path() || die;

	# �����p�t�@�C���̏ꍇ
	if($type =~ /Search-file/){
		$file1 = "${directory1}all_account.log";
		$max_line = 50000;
	}
	# �V���p�t�@�C���̏ꍇ
	elsif($type =~ /Normal-file/){
		$file1 = "${directory1}new_account.log";
		$max_line = 1000;
	}
	else{
		return();
	}

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1");
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$account2,$handle2) = split(/<>/);

			# ���C���f�b�N�X���擾
			if($type =~ /Get-index/){

					if($handle2 eq ""){ $handle2 = "�M������"; }

					# �L�[���[�h����
					if($type =~ /Keyword-search-mode/){
							if($account2 =~ /\Q$search_keyword\E/ || $handle2 =~ /\Q$search_keyword\E/){ }
							else{ next; }
					}

					# �ő�\�����ɒB�����ꍇ
					else{
							if($i >= 100 & !$main::myadmin_flag){ last; }
							if($i >= 500){ last; }
					}

					# �C���f�b�N�X�s��ǉ�
					$data{'index_line'} .= qq(<li><a href="$account2/">$handle2 - $account2</a></li>);

			}

			# �f�B���N�g���I�[�v���̕s�����炷���߂ɁA�t���O�𗧂Ă�
			$account_still{$account2} = 1;

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

				# �ő�s���ɒB�����ꍇ
				if($i > $max_line){ last; }

				# �d������A�J�E���g���͍폜
				if($type =~ /Edit-account/){
						if($account2 eq $new_account){ $handle2 = $new_handle; }
				}

				# �X�V�s��ǉ�
				push(@renew_line,"$key2<>$account2<>$handle2<>\n");

			}

	}

close($file_handler);


	# ���f�B���N�g������J���ꍇ
	if($type =~ /Open-directory/){

		# �Ǐ���
		my($directory_handler,$directory_foreach);

		# �f�B���N�g�����J��
		opendir($directory_handler,"${init_directory}_id/");
		my @directory = grep(!/^\./,readdir($directory_handler));
		close $directory_handler;

			# �f�B���N�g���t�@�C����W�J
			foreach $directory_foreach (@directory){

				# �g���q�ƃA�J�E���g�������𕪗�����
				my($account2) = split(/\./,$directory_foreach);

					# ���Ɉꗗ�t�@�C���ɑ��݂���A�J�E���g�͏������Ȃ�
					if($account_still{$account2}){ next; }

						# �A�J�E���g���J��
						my(%account2) = Mebius::Auth::File("Not-file-check Get-hash",$account2);

							# �s��ǉ�����
							if($type =~ /Renew/){
										if($account2{'handle'}){ unshift(@renew_line,"<>$account2<>$account2{'handle'}<>\n"); }
							}
			}

	}

	# �V�K�A�J�E���g��ǉ�
	if($type =~ /New-account/){
			unshift(@renew_line,"<>$new_account<>$new_handle<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);


}

#-----------------------------------------------------------
# �S�A�J�E���g���f�B�e�N�g������擾
#-----------------------------------------------------------
sub all_account_from_directory{

# �錾
my($use) = @_;
my $i = my $hit = my $done = 0;
our(@all_account);
my($share_directory) = Mebius::share_directory_path();	
my($init_directory) = Mebius::BaseInitDirectory();

File::Find::find( \&Mebius::Auth::find_account_directory, "${share_directory}_account/");

# �}�[�N
#my $mark = "Old-save-data-tranced-2013-07-18";

	# �S�A�J�E���g��W�J
	foreach my $account (@all_account){

		# ���E���h�J�E���^
		$i++;

			# �A�J�E���g������
			if(Mebius::Auth::AccountName(undef,$account)){ next; }

		# HIT�J�E���^
		$hit++;

		# �f�B���N�g����`
		my($account_directory) = Mebius::Auth::account_directory($account);
			if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

			# �����݂Ȃǂ̃f�[�^���R�s�[
			#if(exists $use->{'SaveDataCopy'} && $ARGV[0] eq "do"){

			#	my(%renew_account,$check);

			#		my(%now_account_data) = Mebius::Auth::File("Not-file-check",$account);

			#			if($now_account_data{'concept'} =~ /$mark/){
			#				print "$done / $i\t\t\@$account\t\tstill\n";
			#				next;
			#			}

			#		my(%old_account_data) = Mebius::Auth::File("Move-from-file Not-file-check",$account);

			#				if(!$old_account_data{'f'} || !$now_account_data{'f'}){
			#					print "$done / $i \t\t\@$account\t\tnot-file\n";
			#					next;
			#				}

			#		my($save_old) = Mebius::save_data({ FileType => "Account" },$account);

			#			foreach(keys %$save_old){
			#					if($_ =~ /^cookie_/){ $renew_account{$_} = $save_old->{$_}; }
			#			}
			#			$renew_account{'.'}{'concept'} = " $mark";

			#		my(%renewed) = Mebius::Auth::File("Renew",$account,\%renew_account);

			#		$done++;

			# �o��
			print qq($done / $i\t\t\@$account\t\tdone \n);
			print qq($account => $account_directory\n);
			#}

		#print qq($account\n);

			my(%now_account_data) = Mebius::Auth::File("Not-file-check",$account);

				if(exists $use->{'FileToDBI'} && $ARGV[0] eq "do"){
					my($renew_utf8) = hash_to_utf8(\%now_account_data);
					$renew_utf8->{'account'} = $account;
					$done++;
					Mebius::SNS::Account->update_or_insert_main_table($renew_utf8);	
				}

				if(exists $use->{'FriendsToMainFile'} && ($ARGV[0] eq "do" || $ARGV[0] eq "test")){
					my(%friends) = Mebius::Auth::FriendIndex("",$account);
						if(ref $friends{'accounts'} eq "ARRAY"){
								Mebius::Auth::File("Renew Not-file-check",$account,{ friend_accounts => "@{$friends{'accounts'}}" });
						}
				}



	}

	if($ARGV[0] ne "do"){
		print "If you need some action , enter 'do' at command ( ARGV )";
	}

}


#-----------------------------------------------------------
# �A�J�E���g�f�B���N�g�����������ꍇ�̏���
#-----------------------------------------------------------
sub find_account_directory{

# �錾
our(@all_account,$i_file);

my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();	

# �f�B���N�g����
my $path = $File::Find::name;

	# �A�J�E���g�f�B���N�g���𔭌������ꍇ
	if($path =~ m!^${share_directory}_account/\w/\w/(\w+)$!){

		$i_file++;

		my $account = $1;
		my($dir_name) = File::Basename::basename($path);

		print "$i_file Found : $path / account: $account\n";

			if($ARGV[0] eq "test"){ 
					if($account =~ /(aurayuma|aaaa)/){
						1;
						push(@all_account,$account);
					} else {
						print	" ...but escape.\n";
					}
			} else {
				push(@all_account,$account);
			}



	}

}

1;

