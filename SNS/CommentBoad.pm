
use strict;
package Mebius::SNS::CommentBoad;

#-----------------------------------------------------------
# �N���G�������ɓ`�����X�𑀍삷��
#-----------------------------------------------------------
sub query_to_control{


my($table_name) = Mebius::Report::main_table_name() || die ;
my(%control);
my($param) = Mebius::query_single_param();

	# �N�G����W�J
	foreach( keys %$param ) {

			# ���X�Ԏw��ő��삷��ꍇ
			if($_ =~ /^sns-comment-delete-by-res_number-([0-9a-z]+)-(\d+)(-(\d{4,}))?$/ && $param->{$_} ne ""){

					my $account = $1;
					my $target = $2;
					my $year = $4;

						if($year){
							$control{$account}{'control_years'}{$year} = 1;
						}

					$control{$account}{'res_number'}{$target}{'type'} = $param->{$_};
				Mebius::DBI->update(undef,$table_name,{ answer_time => time },"WHERE targetA='$account' AND report_res_number='$target' AND content_type='sns_comment_boad';");

			# ���e�����w��ő��삷��ꍇ ( ���`�� )
			} elsif($_ =~ /^sns-comment-delete-by-regist_time-([0-9a-z]+)-(\d+)(-(\d{4,}))?$/ && $param->{$_} ne ""){

					my $account = $1; 
					my $target = $2;
					my $year = $4;

						if($year){
							$control{$account}{'control_years'}{$year} = 1;
						}

					$control{$account}{'res_number'}{$target}{'type'} = $param->{$_};

			}

	}

	# �A�J�E���g���Ƃɓ`���̓��e�𑀍삷��
	foreach my $account ( keys %control ){

		my %years = %{$control{$account}{'control_years'}} if($control{$account}{'control_years'});

		# ���b�N�J�n
		main::lock("auth$account");

		# �t�@�C������
		my($controled) = log_file({ Control => 1 , Renew => 1  },$account,$control{$account});

			if($controled->{'controled_years'}){
				%years = (%years,%{$controled->{'controled_years'}});
			}

			# ���s�t�@�C���ő��삵�����e�N�ɉ����āA�N���Ƃ̉ߋ����O�t�@�C��������
			foreach my $year ( keys %years){
				log_file({ Control => 1 , Renew => 1 , year => $year },$account,$control{$account});
			}

		# ���b�N����
		main::unlock("auth$account");

	}


}

#-----------------------------------------------------------
# ���O�t�@�C�� ( ������ )
#-----------------------------------------------------------
sub log_file_state{

# Near State �i�Ăяo���j 2.30
my $HereName1 = "log_file_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }

my($return) = log_file(@_);

	# Near State �i�ۑ��j 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$return); }

$return;

}

#-----------------------------------------------------------
# ���O�t�@�C�����J��
#-----------------------------------------------------------
sub log_file{

# �錾

my($use,$account,$control) = @_;
my($logfile,$renew_flag,@renew_line,$comment_handler,$top1,@years,$now_file_flag,$past_file_flag,%self);
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my $admin_flag = 1 if($my_account->{'admin_flag'} || Mebius::Admin::admin_mode_judge());

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �v���t�B�[�����J��
my(%account) = Mebius::Auth::File(undef,$account);

	# �N�ʃt�@�C�����J���ꍇ
	if($use->{'year'} =~ /^(\d+)$/){
		$past_file_flag = 1;
		$logfile = "${account_directory}comments/${account}_$use->{'year'}_comment.cgi";

	# ���s�t�@�C�����J���ꍇ
	} else {
		$now_file_flag = 1;
		$logfile = "${account_directory}comments/${account}_comment.cgi";
	}

# �����s�R�����g���J��
$self{'f'} = open($comment_handler,"<",$logfile);

# �t�@�C�����b�N
	if($use->{'Renew'}){
		flock($comment_handler,1);
	}

	# �g�b�v�f�[�^�𕪉��A�ǉ�
	if($now_file_flag){
		$top1 = <$comment_handler>;
		push @renew_line , $top1;
	}

	# �R�����g�t�@�C����W�J
	while(<$comment_handler>){

		# �Ǐ���
		my($newkey,$foreach,$control_flag,%data);

		# ���̍s�𕪉�
		chomp;
		($data{'key'},$data{'regist_time'},$data{'account'},$data{'name'},$data{'trip'},$data{'id'},$data{'comment'},$data{'dates'},$data{'ip'},$data{'res_number'},$data{'control_account'},$data{'control_handle'},$data{'concept'},$data{'text_color'}) = split(/<>/);
		$data{'main_account'} = $account;

		my($year,$month,$day,$hour,$min,$sec) = split(/,/,$data{'dates'});
		push @{$self{'res_data'}} , \%data;
		$self{'res_data_per_res_number'}{$data{'res_number'}} = \%data;

				# ���폜�̔��f
				{ 

					my $value;


						# �p�����[�^����A���̃��X�ɑ΂��āA���삪�Ȃ���Ă��邩�ǂ����𔻒�
						if($control->{'res_number'}->{$data{'res_number'}}->{'type'}){
							$value = $control->{'res_number'}->{$data{'res_number'}}->{'type'};
						} elsif($control->{'regist_time'}->{$data{'regist_time'}}->{'type'}) {
							$value = $control->{'regist_time'}->{$data{'regist_time'}}->{'type'};
						}

						# ����̓��e�𔻒�
						if($data{'key'} eq "1" && $value eq "delete" && ($admin_flag || $account eq $my_account->{'id'} || $data{'account'} eq $my_account->{'id'})){ $control_flag = "delete"; }
						elsif($data{'key'} eq "1" && $value eq "penalty" && $admin_flag){ $control_flag = "penalty"; }
						elsif($data{'key'} ne "1" && $value eq "revive" && $admin_flag){ $control_flag = "revive"; }

				}

			# �폜�s���q�b�g�����ꍇ
			if($control_flag){

					# �폜�p�ɔN�x���L��
					$self{'controled_years'}{$year} = 1; 

					# �폜����ꍇ
					if($control_flag eq "delete" || $control_flag eq "penalty"){

							# �v���t�B�[�����J��
							#my(%account) = Mebius::Auth::File("Not-file-check",$account2);

							# �Ǘ��ғ��e�͍폜�ł��Ȃ�
							#if($account{'admin'} && !$admin_flag){
							#	close($comment_handler);
							#	main::error("�Ǘ��҂̃R�����g ( $comment - No.$res ) �͍폜�ł��܂���B");
							#}

							# �폜�^�C�v��U�蕪��
							if($data{'account'} eq $my_account->{'id'}){ $newkey = 3; }
							elsif($account eq $my_account->{'id'}){ $newkey = 2; }
							elsif($admin_flag){
								$newkey = 4;
								$data{'control_account'} = $my_account->{'id'};
							}

						# �Ǘ��ҍ폜�̏ꍇ�A�y�i���e�B��^����
						if($admin_flag && $control_flag eq "penalty"){
								# �ߋ��t�@�C���̏ꍇ�̂݁A�y�i���e�B������i�d���y�i���e�B�̉���j
								if($past_file_flag){
									Mebius::Authpenalty("Penalty",$data{'account'},$data{'comment'},"SNS - $account�̓`���� No.$data{'res_number'}","$basic_init->{'auth_url'}$data{'account'}/viewcomment#$data{'res_number'}");
									Mebius::AuthPenaltyOption("Penalty",$data{'account'},6*60*60);
								}
								# ���X�R���Z�v�g��ύX
								if($data{'concept'} !~ /Penalty-done/){ $data{'concept'} .= qq( Penalty-done); }
						}


					}

					# ��������ꍇ
					elsif($control_flag eq "revive" && $admin_flag){

						$newkey = 1;

							# �Ǘ��ҕ����̏ꍇ�A�y�i���e�B�����炷
							if($past_file_flag && $data{'res_concept'} =~ /Penalty-done/){
								Mebius::Authpenalty("Repair",$data{'account'});
							}

						# ���X�R���Z�v�g�̑���
						$data{'concept'} =~ s/(\s?)Penalty-done//g;

					}

				# �X�V�s��ǉ��A�폜�ؖ��t���O�𗧂Ă�
			if($newkey){
				$data{'key'} = $newkey;
			}

	push(@renew_line,Mebius::add_line_for_file([$data{'key'},$data{'regist_time'},$data{'account'},$data{'name'},$data{'trip'},$data{'id'},$data{'comment'},$data{'dates'},$data{'ip'},$data{'res_number'},$data{'control_account'},$data{'control_handle'},$data{'concept'},$data{'text_color'}]));
				$renew_flag = 1;

			}
			else{ push @renew_line , "$_\n"; }
	}

close($comment_handler);

	# ���O�t�@�C�����X�V
	if($renew_flag && $use->{'Renew'}){ Mebius::Fileout("",$logfile,@renew_line); }

# ���^�[��
return(\%self);

}



1;
