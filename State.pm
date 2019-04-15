
use strict;
package Mebius::State;

#-----------------------------------------------------------
# Near State �ϐ����R�[�� => ���x�D�� ?
#-----------------------------------------------------------
sub Call{

	# �X�C�b�` => �����ł����������邽�߁A�R�����g�A�E�g���Ă�������
	#if(!Mebius::Switch::NearState()){ return(); }

# �錾
my($PackageName,$MethodName,$StateKey) = @_;
our(%state);

	# ���^�[��
	# exists ����Ȃ��ŒP���� return($_); ���Ă��܂��ƁA�l�� 0 �̏ꍇ�ɑΉ��ł��Ȃ����߁A�K�� exists ���肷��
	if(exists $state{$PackageName}{$MethodName}{$StateKey}){
		return($state{$PackageName}{$MethodName}{$StateKey});
	}
	else{
		return();
	}

}

#-----------------------------------------------------------
# Near State �ϐ����Z�[�u=> ���x�D�� ?
#-----------------------------------------------------------
sub Save{

	# �X�C�b�` => �����ł����������邽�߁A�R�����g�A�E�g���Ă�������
	#if(!Mebius::Switch::NearState()){ return(); }

# �錾
my($PackageName,$MethodName,$StateKey,$SaveValue) = @_;
our(%state);

	# �K�{���ڂ��`�F�b�N
	# $SaveValue �� undef �̏ꍇ�ł��L���ɏ������������̂ŁAif(!defined){} ����������Ȃ�Ȃ�
	if(!defined $PackageName){ die("Perl Die!  PackageName is not defined."); }
	if(!defined $MethodName){ die("Perl Die! StateName is not defined."); }
	#if(!defined $StateKey){ die("Perl Die! StateKey is not defined."); }

	# �ϐ������ɃZ�b�g����Ă���ꍇ�̓v���O�����o�O�Ȃ̂ŃG���[���o��
	if(exists $state{$PackageName}{$MethodName}{$StateKey}){
		die("Perl Die!  Same State Package , State Name , and State Key is selected. ( $PackageName => $MethodName => $StateKey : $SaveValue ) ");
	}

	# �ϐ����Z�b�g����
	else{
			# Save���e������ꍇ�͂��̂܂܃Z�b�g
			if(defined $SaveValue){
				$state{$PackageName}{$MethodName}{$StateKey} = $SaveValue;
			}
			# �Z�[�u�l�� undef �̏ꍇ�ɂ��Ή� ( �d�v �F �K�� null �l���Z�b�g���邱�� )
			# ������ undef ���Z�b�g���Ă��܂��ƁA&Call �Ăяo����ɒl���擾�ł��Ȃ��̂Œ���
			else{
				$state{$PackageName}{$MethodName}{$StateKey} = "";
			}
	}


}


#-----------------------------------------------------------
# Call State����Ȃ������񐔂��J�E���g ( State �̋L�q�Ƀ~�X������ƁA�����ŃJ�E���^���c��Ȑ��ɂȂ� )
#-----------------------------------------------------------
sub ElseCount{

# �錾
my($PackageName,$MethodName,$StateKey) = @_;

	# ���[�J���ŃJ�E���g
	#if(Mebius::alocal_judge()){

		# �Ǐ���
		our(%state_count);

			# ��O����
			if(!defined $PackageName){ die("Perl Die!  PackageName is not defined"); }
			if(!defined $MethodName){ die("Perl Die!  StateName is not defined"); }
			if(!defined $StateKey){ die("Perl Die!  StateKey is not defined"); }

			if(Mebius::alocal_judge()){  
				$state_count{$PackageName}{$MethodName}{$StateKey}++;
			}
		our $state_else_count++;


	#}

	# ���A���T�[�o�[�ł͉������Ȃ�
	#else{
	#	return();
	#}

}

#-----------------------------------------------------------
# ��O�J�E���^���擾
#-----------------------------------------------------------
sub GetElseCountMulti{
our %state_count;
return(\%state_count);
}


#-----------------------------------------------------------
# ��O�J�E���^���擾
#-----------------------------------------------------------
sub GetElseCount{
our $state_else_count;
return($state_else_count);
}


#-----------------------------------------------------------
# �ϐ����폜
#-----------------------------------------------------------
sub AllReset{

	# �X�C�b�` => �����ł����������邽�߁A�R�����g�A�E�g���Ă�������
	#if(!Mebius::Switch::NearState()){ return(); }

undef(our %state);
#undef(our %state_count);
undef(our $state_else_count);


}

#-----------------------------------------------------------
# Near State �ϐ����R�[��
#-----------------------------------------------------------
sub call_parmanent{

	# �X�C�b�` => �����ł����������邽�߁A�R�����g�A�E�g���Ă�������
	#if(!Mebius::Switch::NearState()){ return(); }

# �錾
my $use = shift if(ref $_[0] eq "HASH"); # �擪�����t�@�����X�ł���΁A�ȍ~�̈�����������炵�Ď󂯎��
my($PackageName,$MethodName,$StateKey) = @_;
our(%state_parmanent,%counter_parmanent);

	# ���^�[��
	# exists ����Ȃ��ŒP���� return($_); ���Ă��܂��ƁA�l�� 0 �̏ꍇ�ɑΉ��ł��Ȃ����߁A�K�� exists ���肷��
	if(exists $state_parmanent{$PackageName}{$MethodName}{$StateKey}){

			# �ő�Ăяo���񐔂𒴂��ă��Z�b�g����ꍇ
			if($use->{'MaxCall'} && $use->{'MaxCall'} >= $counter_parmanent{$PackageName}{$MethodName}{$StateKey}){
				$counter_parmanent{$PackageName}{$MethodName}{$StateKey} = 0;
			}
			# �Ăяo���J�E���^�𑝂₷
			else{
				$counter_parmanent{$PackageName}{$MethodName}{$StateKey}++;
			}

		return($state_parmanent{$PackageName}{$MethodName}{$StateKey});
	}
	else{
		return();
	}

}

#-----------------------------------------------------------
# Near State �ϐ����Z�[�u
#-----------------------------------------------------------
sub save_parmanent{

	# �X�C�b�` => �����ł����������邽�߁A�R�����g�A�E�g���Ă�������
	#if(!Mebius::Switch::NearState()){ return(); }

# �錾
my($PackageName,$MethodName,$StateKey,$SaveValue) = @_;
our(%state_parmanent);

	# �K�{���ڂ��`�F�b�N
	# $SaveValue �� undef �̏ꍇ�ł��L���ɏ������������̂ŁAif(!defined){} ����������Ȃ�Ȃ�
	if(!defined $PackageName){ die("Perl Die!  PackageName is not defined."); }
	if(!defined $MethodName){ die("Perl Die! StateName is not defined."); }
	if(!defined $StateKey){ die("Perl Die! StateKey is not defined."); }

	# �ϐ������ɃZ�b�g����Ă���ꍇ�̓v���O�����o�O�Ȃ̂ŃG���[���o��
	if(exists $state_parmanent{$PackageName}{$MethodName}{$StateKey}){
		die("Perl Die!  Same State Package , State Name , and State Key is selected. ( $PackageName => $MethodName => $StateKey : $SaveValue ) ");
	}

	# �ϐ����Z�b�g����
	else{
			# Save���e������ꍇ�͂��̂܂܃Z�b�g
			if(defined $SaveValue){
				$state_parmanent{$PackageName}{$MethodName}{$StateKey} = $SaveValue;
			}
			# �Z�[�u�l�� undef �̏ꍇ�ɂ��Ή� ( �d�v �F �K�� null �l���Z�b�g���邱�� )
			# ������ undef ���Z�b�g���Ă��܂��ƁA&Call �Ăяo����ɒl���擾�ł��Ȃ��̂Œ���
			else{
				$state_parmanent{$PackageName}{$MethodName}{$StateKey} = "";
			}
	}


}

1;

