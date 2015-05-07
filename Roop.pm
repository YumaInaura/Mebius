
# �錾
use strict;
package Mebius::Roop;

#-----------------------------------------------------------
# ���[�v������ꍇ�� die
#-----------------------------------------------------------
sub block{

# �錾
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# �K�{���ڂ��`�F�b�N
	if(!defined $PackageName){ die("Perl Die! Package key is empty."); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty."); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

	if($roop{$PackageName}{$RoopName}{$RoopKey}){ return("Perl Die ! Block roop."); }
	else{ return(); }

}

#-----------------------------------------------------------
# �t���O������
#-----------------------------------------------------------
sub relese{

# �錾
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# �K�{���ڂ��`�F�b�N
	if(!defined $PackageName){ die("Perl Die! Package key is empty"); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty"); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

$roop{$PackageName}{$RoopName}{$RoopKey} = undef;

}

#-----------------------------------------------------------
# �t���O�𗧂Ă�
#-----------------------------------------------------------
sub set{

# �錾
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# �K�{���ڂ��`�F�b�N
	if(!defined $PackageName){ die("Perl Die! Package key is empty"); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty"); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

$roop{$PackageName}{$RoopName}{$RoopKey} = 1;

}

#-----------------------------------------------------------
# �ϐ������Z�b�g
#-----------------------------------------------------------
sub all_reset{
undef(our %roop);
}


1;
