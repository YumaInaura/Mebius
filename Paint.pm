use strict;
use File::Copy;
package Mebius::Paint;

#-----------------------------------------------------------
# ���G�����摜�̏���
#-----------------------------------------------------------
sub Image{

# �錾
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


	# ���N�b�L�[�擾����
	if($type =~ /Get-cookie/){

		# �N�b�L�[���擾
		my($paint_cookie) = main::get_cookie("Paint");
		($cookie_concept,$cookie_session,$cookie_password) = @$paint_cookie;

		# �N�b�L�[�̃Z�b�V��������W�J
		foreach(split(/\s/,$cookie_session)){
			$i_cookie++;
				if($image_session eq $_){ next; }							# �����Z�b�V�������͏d�������Ȃ�
				if($i_cookie > 10 - 1){ next; }								# ��萔�ȏ�̃N�b�L�[�͍폜
			push(@cookie_sessions,$_);
		}
		if($type =~ /(Delete-cookie|Rename-justy)/){}						# �N�b�L�[���폜����̂ŁA�������Ȃ�
		elsif($image_session){ unshift(@cookie_sessions,$image_session); }	# �N�b�L�[��ǉ�����̂ŁA�Z�b�V�������𑫂�
		$cookie_sessions = "@cookie_sessions";

	}

	# ���N�b�L�[���폜���ă��^�[������ꍇ
	if($type =~ /Delete-cookie/){
		Mebius::set_cookie("Paint",[$cookie_concept,$cookie_sessions,$cookie_password]);
		return(1);
	}

	# ���N�b�L�[�ɃZ�b�V���������Z�b�g���ă��^�[������ꍇ
	if($type =~ /Set-cookie-session/){
		Mebius::set_cookie("Paint",[$cookie_concept,$cookie_sessions,$cookie_password]);
		return();
	}

# �����`�F�b�N
$i_postnumber =~ s/\D//;
$i_resnumber =~ s/\D//;
$realmoto =~ s/\W//g;
$image_session =~ s/\W//g;
$image_id =~ s/\D//g;

	# ���ʃ��^�[�� ??
	if($image_session eq "" && $type !~ /Justy/){ return(); }

	# �ꕔ���^�[��
	if($type =~ /(Rename-justy|Delete-image|Revive-image|Justy)/){
		if($i_postnumber eq ""){ return(); }
		if($i_resnumber eq ""){ return(); }
		if($realmoto eq ""){ return(); }
	}


# ���O�t�@�C�����`
$logfile = "${main::int_dir}_paintdata/_${realmoto}_paintdata/${i_postnumber}/${i_resnumber}-paintdata.log";
$logfile_buffer = "${main::int_dir}_paintdata/_buffer/${image_session}-paintdata.log";

	# �J�����O�t�@�C�����`
	if($type =~ /Justy/){ $logfile_open = $logfile; }
	else{ $logfile_open = $logfile_buffer; }

	# �ʃ��O���J��
	open($logfile_handler,"<$logfile_open");
		if($type =~ /Renew-logfile/){ flock($logfile_handler,1); }
	chomp(my $top1 = <$logfile_handler>);
	chomp(my $top2 = <$logfile_handler>);
	chomp(my $top3 = <$logfile_handler>);
	chomp(my $top4 = <$logfile_handler>);
	chomp(my $top5 = <$logfile_handler>);
	close($logfile_handler);

	# �ʃ��O�𕪉�
	my($timage_key,$timage_id,$timage_tail,$timage_title,$tsuper_id,$tlasttime,$tdate,$taddr,$thost,$tcnumber,$tagent,$taccount) = split(/<>/,$top1);
	my($timage_width,$timage_height,$tsamnale_width,$tsamnale_height,$timage_size,$tsamnale_size,$tanimation_size) = split(/<>/,$top2);
	my($tserver_domain,$trealmoto,$tpostnumber,$tresnumber,$tdelete_data) = split(/<>/,$top3);
	my($timage_id_used,$timage_steps,$timage_painttime,$timage_all_steps,$timage_all_painttime,$tcompress_level) = split(/<>/,$top4);
	my($tcount,$timage_session,$thandle,$ttrip,$tid,$tcomment) = split(/<>/,$top5);
	if($image_id eq ""){ $image_id = $timage_id; }
	$image_id =~ s/\W//g;
	$image_tail = $timage_tail;
	
	# �f�[�^���`
	if($image_session){ $timage_session = $image_session; }
	($image{'delete_person'},$image{'delete_date'},$image{'delete_time'}) = split(/=/,$tdelete_data);

	# �C���[�WID�̗��p���O��z��ɑ��
	foreach(split(/\s/,$timage_id_used)){
		push(@timage_id_used,$_);
	}

	# �摜�t�@�C�����`
	$image_file_buffer = "${main::paint_dir}buffer/${image_id}.$image_tail";
	$image_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_url = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";
	$image_url_buffer = "${main::paint_url}buffer/$image_id.$image_tail";
	$image_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}.$image_tail";

	# �T���l�C���t�@�C�����`
	$samnale_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";
	$samnale_file_buffer = "${main::paint_dir}buffer/${image_id}-samnale.jpg";
	$samnale_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";
	($samnale_url) = samnale_url($realmoto,$i_postnumber,$i_resnumber);
	$samnale_url_buffer = "${main::paint_url}buffer/$image_id-samnale.jpg";
	$samnale_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";

	# �A�j���[�V�����t�@�C�����`
	$animation_file_buffer = "${main::paint_dir}buffer/${image_id}.spch";
	$animation_file = "${main::paint_dir}$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_file_deleted = "${main::jak_dir}paint/$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_url = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}.spch";
	$animation_url_buffer = "${main::paint_url}buffer/$image_id.spch";
	$animation_url_deleted = "${main::jak_url}paint/$realmoto/${i_postnumber}/${i_resnumber}.spch";

	# �d���֎~�p�̃t�@�C�����`
	$logfile_redun = "${main::int_dir}_paintdata/_buffer_id/${image_id}-redun.log";

	# �f���`
	$file_block = "$realmoto-${i_postnumber}-${i_resnumber}-${image_tail}";

	# HTML�t�@�C�����`
	($html_url) = html_url($realmoto,${i_postnumber},${i_resnumber});

	# ���摜���f�[�^���폜����i�Ǘ��f�B���N�g���ֈړ��j
	if($type =~ /Delete-image/){
		
		# �G���[
		if($timage_key =~ /Deleted/){ return(); main::error("���̉摜�͊��ɍ폜�ς݂ł��B"); }

		# �f�B���N�g���쐬
		Mebius::Mkdir("","${main::jak_dir}paint/$realmoto");
		Mebius::Mkdir("","${main::jak_dir}paint/$realmoto/$i_postnumber");

		# �摜�������l�[��
		rename($image_file,$image_file_deleted);
		rename($animation_file,$animation_file_deleted);
		rename($samnale_file,$samnale_file_deleted);

	}

	# ���摜���f�[�^�𕜊�����i��ʃf�B���N�g���ֈړ��j
	if($type =~ /Revive-image/){

		# �G���[
		if($timage_key !~ /Deleted/){ return(); main::error("���̉摜�͍폜����Ă��܂���B"); }

		# �摜�������l�[��
		rename($image_file_deleted,$image_file);
		rename($animation_file_deleted,$animation_file);
		rename($samnale_file_deleted,$samnale_file);
	}

	# ���o�b�t�@�t�@�C�����폜���� ( �V�����X�g�ň�ꂽ�ꍇ )
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

	# �����O�t�@�C���̃f�[�^�����n�b�V���Ƃ��ă��^�[������ꍇ
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

		# ��ҏ��
		$image{'handle'} = $thandle;
		$image{'trip'} = $ttrip;
		$image{'id'} = $tid;
		$image{'host'} = $thost;
		$image{'cnumber'} = $tcnumber;
		$image{'agent'} = $tagent;
		$image{'account'} = $taccount;

		# �C���[�W�T�C�Y
		$image{'width'} = $timage_width;
		$image{'height'} = $timage_height;
		$image{'samnale_width'} = $tsamnale_width;
		$image{'samnale_height'} = $tsamnale_height;
		if($image{'samnale_width'} && $image{'samnale_height'}){ $image{'samnale_style'} = qq( style="width:$image{'samnale_width'}px;height:$image{'samnale_height'}px;"); }
		else{ $image{'samnale_style'} = qq( style="width:120px;height:120px;"); }

		# ���L����URL�Ȃ�
		$image{'realmoto'} = $trealmoto;
		$image{'postnumber'} = $tpostnumber;
		$image{'resnumber'} = $tresnumber;

		# ���C�����[�h�H
		if($trealmoto =~ /^(mpaint)$/){ $image{'main_type'} = 1; }

		# ���C�����[�h�łȂ��ꍇ�́A�L��URL�Ȃǂ��`
		else{
				if($trealmoto){ $image{'bbs_url'} = "/_$trealmoto/"; }
				if($trealmoto && $tpostnumber){ $image{'thread_url'} = "/_$trealmoto/$tpostnumber.html"; }
				if($trealmoto && $tpostnumber && $tresnumber){ $image{'res_url'} = "/_$image{'realmoto'}/$tpostnumber.html-$tresnumber#S$tresnumber"; }
		}

		# �y�m���摜�z�̕\���\���
		if($image{'tail'} && $image{'key'} !~ /Deleted/){ $image{'image_ok'} = 1; }

		# �N�b�L�[
		$image{'cookie_concept'} = $cookie_concept;
		$image{'cookie_session'} = $cookie_session;
		$image{'cookie_password'} = $cookie_password;

			# �摜�^�C�g��
			$image{'title'} = $timage_title;
			if($image{'title'}){
					$image{'title_and_id'} = qq($image{'session'} ( $image{'title'} ));
			}
			else{
				#$image{'title'} = $image{'session'};
				$image{'title_and_id'} = $image{'session'};
			}

			# �摜�̃^�C�g���^�O
			$image{'title_tag'} .= qq($image{'title'});
			$image{'title_tag'} .= qq( $image{'width'}x$image{'height'});
			if($image{'image_size'}){ $image{'image_size_kbyte'} = int($image{'image_size'} / 1000); }
			#if($image{'image_size_kbyte'}){ $image{'title_tag'} .= qq( $image{'image_size_kbyte'}KB); }
	
			if($image{'key'} =~ /Animation/){ $image{'title_tag'} .= qq( �A�j������); }
			$image{'title_tag'} = qq( title="$image{'title_tag'}");

			# �L�[����
			if($image{'key'} =~ /Deny-sasikae/){ $image{'deny_sasikae'} = 1; }
			if($image{'key'} =~ /Animation/){ $image{'animation_flag'} = 1; }
			if($image{'key'} =~ /Deleted/){ $image{'deleted'} = 1; }

			# �\���\���A���e�\��
			if($type =~ /Post-check/){

				# �K�{�X�e�b�v���A�y�C���g�^�C��
				$image{'must_steps'} = 80;
				$image{'must_painttime'} = 60*5;
					if($main::alocal_mode || $main::myadmin_flag >= 5){
						$image{'must_steps'} = 1;
						$image{'must_painttime'} = 3;
					}

				# �K�{�y�C���g�^�C���A�X�e�b�v���𖞂����Ă��邩�ǂ���
				if($image{'all_steps'} >= $image{'must_steps'} && $image{'all_painttime'} >= $image{'must_painttime'}
				&& $image{'key'} =~ /Edited/ && $image{'key'} !~ /Posted/
				&& $image{'lefthour'} >= 1 && !-f $image{'logfile_redun'} && -f $image{'image_file_buffer'}){
					$image{'post_ok'} = 1;
				}
				if(-f $image{'image_file_buffer'} && $image{'lefthour'} >= 1){ $image{'continue_ok'} = 1; }
				if(-f $image{'logfile_redun'}){ $image{'image_posted'} = 1; }
			}

	}

	# ���f���ւ̓��e�ɐ���
	if($type =~ /Rename-justy/){

		# �f�B���N�g���쐬
		Mebius::Mkdir("","${main::paint_dir}$realmoto");
		Mebius::Mkdir("","${main::paint_dir}$realmoto/$i_postnumber");

			# ���摜�����łɑ��݂���ꍇ
			if(-f $image_file){ main::error("���̉摜�͊��ɑ��݂��܂��B"); }
			if(-f $samnale_file){ main::error("���̃T���l�C���͊��ɑ��݂��܂��B"); }
			if(-f $animation_file){ main::error("���̃A�j���[�V�����f�[�^�͊��ɑ��݂��܂��B"); }
			if(-f $logfile){ main::error("���̉摜�͊��ɑ��݂��܂��B�i�Q�j"); }

			# �o�b�t�@����{�摜��
			if(-f $image_file_buffer){
					&File::Copy::copy($image_file_buffer,$image_file) || main::error("�摜�̐��K���Ɏ��s���܂����B");
			}
			else{ main::error("�ꎞ�ۑ��p�̉摜�����݂��܂���B"); }

			# �o�b�t�@����{�T���l�C����
			if(-f $samnale_file_buffer){
					&File::Copy::copy($samnale_file_buffer,$samnale_file) || main::error("�T���l�C���̐��K���Ɏ��s���܂����B");
			}
			else{ main::error("�ꎞ�ۑ��p�̃T���l�C�������݂��܂���B$samnale_file_buffer"); }

			# �o�b�t�@����{�A�j���f�[�^��
			if(-f $animation_file_buffer){
					&File::Copy::copy($animation_file_buffer,$animation_file) || main::error("�A�j���[�V�����f�[�^�̐��K���Ɏ��s���܂����B");
			}
			else{ main::error("�ꎞ�ۑ��p�̃A�j���[�V�����f�[�^�����݂��܂���B"); }

			# �T�C�g�S�̂́u�V�����G�������X�g�v�̍X�V
			if(!$main::secret_mode){
				require "${main::int_dir}part_newlist.pl";
				Mebius::Newlist::Paint("Renew New Justy",$image_session,$image_id,$file_block,$tsuper_id);
			}

		# �N�b�L�[�̃Z�b�V�������폜
		#Mebius::set_cookie("Paint",$cookie_concept,$cookie_sessions,$cookie_password);

	}

	# �����ʃ��O�t�@�C�����쐬/�X�V
	if($type =~ /Renew-logfile/){

		# �Ǐ���
		my($logfile_renew);

			# �������ރ��O�t�@�C���̒�`
			if($type =~ /Renew-logfile-buffer/){
				$logfile_renew = $logfile_buffer;
					if($type =~ /Posted/){ $timage_key .= qq( Posted); }
			}
			elsif($type =~ /Renew-logfile-justy/){
				$logfile_renew = $logfile;
				Mebius::Mkdir("","${main::int_dir}_paintdata/_${realmoto}_paintdata/");
				Mebius::Mkdir("","${main::int_dir}_paintdata/_${realmoto}_paintdata/$i_postnumber");
			}

			# ���f�[�^��ҏW����ꍇ
			if($type =~ /Edit-data/){
				$tcomment = $main::in{'comment'};
				$timage_title = $main::in{'image_title'};
				$timage_key =~ s/ Edited//g;
				$timage_key .= qq( Edited);
					($ttrip,$thandle) = main::trip($main::in{'name'});
					($tid) = main::id();
			}

			# ��JAVA����f�[�^���󂯎�����ꍇ
			if($type =~ /Image-post/){

				# ���p��EX�w�b�_�̉����`�F�b�N�A���f
				$timage_title = $ex{'image_title'};

				# �C���[�W�T�C�Y
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

				# �X�[�p�[ID�̏���
				if($tsuper_id eq ""){ $tsuper_id = $ex{'super_id'}; }
				($tsuper_id) = &Super_id("Image-post Renew Brand-new",$tsuper_id,$image_session,$image_id);
				$image{'super_id'} = $tsuper_id;

				# �����`�F�b�N
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

				# �T���l�C���̃T�C�Y���{�摜���傫���ꍇ�A�T�C�Y�����킹��
				if($tsamnale_width > $timage_width){ $tsamnale_width = $timage_width; }
				if($tsamnale_height > $timage_height){ $tsamnale_height = $timage_height; }

					# �g���q
					if($ex{'image_type'} =~ /^(jpg|jpeg)$/){ $timage_tail = "jpg"; }
					elsif($ex{'image_type'} =~ /^(png)$/){ $timage_tail = "png"; }
					else{ return(); }

					# ���O�t�@�C���ɏ������ޒl�̒�`
					if($ex{'animation_on'} && $timage_key !~ /Animation/){ $timage_key .= qq( Animation); }
					if($ex{'deny_sasikae'} && $timage_key !~ /Deny-sasikae/){ $timage_key .= qq( Deny-sasikae); }
					push(@timage_id_used,$image_id);

			}

			# ���摜���y���e�m��z�����ꍇ
			if($type =~ /Rename-justy/){

				$tserver_domain = $server_domain;
				$trealmoto = $realmoto;
				$tpostnumber = $i_postnumber;
				$tresnumber = $i_resnumber;

				# �X�[�p�[ID�t�@�C�����X�V
				&Super_id("Rename-justy Renew",$tsuper_id,$image_session,$file_block);

				# �d���֎~�p�t�@�C�����폜
				Mebius::Fileout("New-file",$logfile_redun);

			}

			# �Ǘ��҂ɂ��摜�̍폜�ƕ���
			if($type =~ /Delete-image/){
				$timage_key .= qq( Deleted);
				$tdelete_data = qq($main::admy_name=$main::date=$main::time);
			}
			elsif($type =~ /Revive-image/){
				$timage_key =~ s/Deleted//g;
			}

			# ���e�҃f�[�^���X�V����ꍇ�i�Ǘ��ҍ폜�̏ꍇ�͍X�V���Ȃ��j
			if(!$main::admin_mode){
				$tlasttime= $main::time;
				$tdate = $main::date;
				$taddr = $main::addr;
				$thost = $main::host;
				$tcnumber = $main::cnumber;
				$tagent = $main::agent;
				$taccount = $main::pmfile;
			}

		# �t�@�C���̏�������
push(@logfile_line,"$timage_key<>$image_id<>$timage_tail<>$timage_title<>$tsuper_id<>$tlasttime<>$tdate<>$taddr<>$thost<>$tcnumber<>$tagent<>$taccount<>\n");
		push(@logfile_line,"$timage_width<>$timage_height<>$tsamnale_width<>$tsamnale_height<>$timage_size<>$tsamnale_size<>$tanimation_size<>\n");
		push(@logfile_line,"$tserver_domain<>$trealmoto<>$tpostnumber<>$tresnumber<>$tdelete_data<>\n");
		push(@logfile_line,"@timage_id_used<>$timage_steps<>$timage_painttime<>$timage_all_steps<>$timage_all_painttime<>$tcompress_level<>\n");
		push(@logfile_line,"$tcount<>$timage_session<>$thandle<>$ttrip<>$tid<>$tcomment<>\n");

		Mebius::Fileout("",$logfile_renew,@logfile_line);

	}

	# �n�b�V����Ԃ�
	if($type =~ /Get-hash/){ return(%image); }

}

#-----------------------------------------------------------
# �X�[�p�[ID�̃��O
#-----------------------------------------------------------
sub Super_id{

# �錾
my($type,$super_id,$image_session,$image_file) = @_;
my($super_id_handler,@renewline,$logfile,$super_id_main,$super_id_key);

# �X�[�p�[ID�𕪉�
my($yearf,$monthf,$super_id_main) = split(/-/,$super_id);

# �����`�F�b�N
$image_session =~ s/\W//g;

# �X�[�p�[ID�̒�`
$super_id_main =~ s/\W//g;
if($super_id_main eq "" && $type =~ /Brand-new/){ ($super_id_main) = Mebius::Crypt::char("",12); }
if($super_id_main eq ""){ return(); }

# �NID�̒�`
$yearf =~ s/\D//g;
if($yearf eq "" && $type =~ /Brand-new/){ $yearf = $main::thisyearf; }
if($yearf eq ""){ return(); }

# ��ID�̒�`
$monthf =~ s/\D//g;
if($monthf eq "" && $type =~ /Brand-new/){ $monthf = $main::thismonthf; }
if($monthf eq ""){ return(); }


# �X�[�p�[ID�S�̂̍Ē�`
$super_id = "$yearf-$monthf-$super_id_main";

# �t�@�C����`
$logfile = "${main::int_dir}_paintdata/_super_id/$yearf/$monthf/${super_id_main}_superid.log";

	# �t�@�C�����폜����ꍇ
	if($type =~ /Delete-file/){
		unlink($logfile);
		return();
	}

# ���O�t�@�C�����J��
open($super_id_handler,$logfile);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($super_id_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$super_id_handler>);
my($tkey,$tlasttime) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$super_id_handler>){
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$image_session2,$image_file2) = split(/<>/);
		
			# �t�@�C���X�V�p
			if($type =~ /Renew/){

				# ���̍s��ǉ�
				push(@renewline,"$key2<>$image_session2<>$image_file2<>\n");				

			}

	}

close($super_id_handler);

	# �t�@�C���X�V�p
	if($type =~ /Renew/){

		# �g�b�v�f�[�^���Ȃ��ꍇ
		if($tkey eq ""){ $tkey = 1; }

		# �f�B���N�g���쐬
		Mebius::Mkdir("","${main::int_dir}_paintdata/_super_id/$yearf");
		Mebius::Mkdir("","${main::int_dir}_paintdata/_super_id/$yearf/$monthf");

		# �V�����s��ǉ�
		if($type =~ /Image-post/){ $super_id_key .= qq( Buffer); }
		elsif($type =~ /Rename-justy/){ $super_id_key .= qq( BBS); }
		unshift(@renewline,"$super_id_key<>$image_session<>$image_file<>\n");

		# �g�b�v�f�[�^��ǉ�
		unshift(@renewline,"$tkey<>$main::time<>\n");

		# ���O�t�@�C�����X�V
		Mebius::Fileout("",$logfile,@renewline);

		# ���^�[��
		return($super_id);

	}

}


#-----------------------------------------------------------
# �L�����o�X�T�C�Y
#-----------------------------------------------------------
sub Canvas_size{

# �Ǐ���
my($type,$canvas_width,$canvas_height) = @_;
my(@canvas_size,$allow_width_flag,$allow_height_flag,$error_flag);

# �L�����o�X�T�C�Y�̎�ނ��`
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


	# �ᔽ���`�F�b�N
	if($type =~ /Violation-check/){

		# �����`�F�b�N
		if($canvas_width =~ /\D/){ $error_flag = qq(�L�����o�X�T�C�Y�i���j�͔��p�����Ŏw�肵�Ă��������B); }
		if($canvas_height =~ /\D/){ $error_flag = qq(�L�����o�X�T�C�Y�i�c�j�͔��p�����Ŏw�肵�Ă��������B); }

		# �z���W�J
		foreach(@canvas_size){
			if($canvas_width == $_){ $allow_width_flag = 1; }
			if($canvas_height == $_){ $allow_height_flag = 1; }
		}

		# �ᔽ���Ă���ꍇ
		if(!$allow_width_flag){ $error_flag = qq(�L�����o�X�T�C�Y�i�c�j�̎w�肪�s���ł�); }
		if(!$allow_height_flag){ $error_flag = qq(�L�����o�X�T�C�Y�i�c�j�̎w�肪�s���ł��B); }

		return($error_flag);
	}

# ���^�[��

return(@canvas_size);

}


#-----------------------------------------------------------
# �T���l�C����URL
#-----------------------------------------------------------
sub samnale_url{

my($realmoto,$i_postnumber,$i_resnumber) = @_;

my $self = "${main::paint_url}$realmoto/${i_postnumber}/${i_resnumber}-samnale.jpg";

}

#-----------------------------------------------------------
# HTML�y�[�W��URL
#-----------------------------------------------------------
sub html_url{

my($realmoto,$i_postnumber,$i_resnumber) = @_;

my	$self = "${main::main_url}pallet-viewer-$realmoto-${i_postnumber}-${i_resnumber}.html";

}



1;
