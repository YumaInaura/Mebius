
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �틵�L�^�t�@�C��
#-----------------------------------------------------------
sub SituationFile{

# �錾
my($init) = &Init();
my($use,$select_renew) = @_;
my($i,@renew_line,%data,$file_handle1,%renew,$renew,$max_view_index);

# �t�@�C����`
#my($web_data_directory) = Mebius::BaseInitDirectory();
$data{'directory1'} = "$init->{'adv_dir'}_log_adv/";
$data{'file1'} = "$data{'directory1'}situation.log";

# �ő�s���`
my $max_line = 100;

	# �ő�\���s��
	if($use->{'MaxViewIndex'}){
		$max_view_index = $use->{'MaxViewIndex'};
	}
	else{
		$max_view_index = 5;
	}

	# �t�@�C�����J��
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file1'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$data{'f'} = open($file_handle1,"+<$data{'file1'}");

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$data{'f'}){
					# �V�K�쐬
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$data{'directory1'});
						Mebius::Fileout("Allow-empty",$data{'file1'});
						$data{'f'} = open($file_handle1,"+<$data{'file1'}");
					}
					else{
						return(\%data);
					}
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

	# �g�b�v�f�[�^��W�J
	for(1..1){
		chomp($data{"top$_"} = <$file_handle1>);
	}

# �g�b�v�f�[�^�𕪉�
($data{'key'}) = split(/<>/,$data{'top1'});

	# �X�V�p�ɓ��e���L��
	if($use->{'TypeRenew'}){ %renew = %data; }

	# �t�@�C����W�J
	while(<$file_handle1>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($comment1,$comment2,$date2,$lasttime) = split(/<>/);

			# �X�V�p
			if($use->{'TypeRenew'}){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ next; }

				# �s��ǉ�
				push(@renew_line,"$comment1<>$comment2<>$date2<>$lasttime<>\n");

			}

			# �C���f�b�N�X�擾�p
			if($use->{'TypeGetIndex'}){

				my($how_before) = Mebius::SplitTime("Color-view Plus-text-�O Get-top-unit",time - $lasttime);
				$data{'index_line'} .= qq(<tr><td class="noborder2">$comment1</td><td>$comment2</td><td class="right">$how_before</td></tr>);
					if($i >= $max_view_index){ last; }

			}

	}

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

			# �V�����s��ǉ�
			if($use->{'TypeNewLine'}){
				my $time = time;
				my($date) = Mebius::Getdate(undef,time);
				unshift(@renew_line,"$use->{'NewComment1'}<>$use->{'NewComment2'}<>$date<>$time<>\n");
			}

			# �C�ӂ̍X�V�ƃ��t�@�����X��
			($renew) = Mebius::Hash::control(\%renew,$select_renew);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$renew->{'key'}<>\n");

		# �t�@�C���X�V
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;

	}


close($file_handle1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'}){
		Mebius::Chmod(undef,$data{'file1'});
	}

	# �C���f�b�N�X���`
	if($use->{'TypeGetIndex'}){
			if($data{'index_line'}){
				$data{'index_line'} = qq(<table class="situation">$data{'index_line'}</table>);
			}
	}

	# ���^�[��
	if($use->{'TypeRenew'}){
		return($renew);
	}
	else{
		return(\%data);
	}

}



#-----------------------------------------------------------
# �S�틵�y�[�W
#-----------------------------------------------------------
sub ViewSituation{

# �Ǐ���
my($init) = Init();
my($init_login) = init_login();
my($line,$form,$selects);


my($situation) = SituationFile({ TypeGetIndex => 1 , MaxViewIndex => 50 });

$main::sub_title = "�틵 | $main::title";

my $print .= qq(<h1>�틵</h1>);
$print .= qq($init_login->{'link_line'});
$print .= qq(
<h2 id="FIGHT">�S�L�����̐틵</h2>
$situation->{'index_line'}
);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => ["�틵"] },$print);

exit;

}

1;
