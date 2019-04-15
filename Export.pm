
use strict;

use Mebius::Encoding;
use Mebius::Console;

package Mebius::Export;

# Exporterを継承
#use base 'Exporter';
use Exporter;

our @ISA = qw(Exporter);
# エクスポートする関数を記述
our @EXPORT = qw(
say esc e h shift_jis shift_jis_return utf8_return utf8 gq_utf8 g_utf8 g_shift_jis hash_to_utf8 hash_to_shift_jis if_defined f
console console_exit local
);

sub say{ print $_[0]; print "\n"; }
sub super_chomp{ my($text) = @_; $text =~ s/(\r|\n|\r\n)$//g; $text; }
sub esc{
 Escape::HTML([$_[0]]);
}


sub e{
Escape::HTML([$_[0]],$_[1]);
}

sub h{
Escape::HTML([$_[0]],$_[1]);
}

sub f{
Mebius::DBI->escape(@_);
}

sub d{
Escape::DataFile(@_);
}

sub shift_jis{
Mebius::Encoding::utf8_to_sjis(@_);
}

sub shift_jis_return{
Mebius::Encoding::utf8_to_shift_jis_return(@_);
}

sub utf8{
Mebius::Encoding::sjis_to_utf8(@_);
}

sub utf8_return{
Mebius::Encoding::shift_jis_to_utf8_return(@_);
}

sub gq_utf8{
Mebius::Encoding::guess_query_and_utf8(@_);
}

sub g_utf8{
Mebius::Encoding::guess_and_utf8(@_);
}
sub g_shift_jis{
Mebius::Encoding::guess_and_shift_jis(@_);
}

sub if_defined{
Mebius::if_defined_set(@_);
}

sub hash_to_utf8{
Mebius::Encoding::hash_to_utf8(@_);
}

sub hash_to_shift_jis{
Mebius::Encoding::hash_to_shift_jis(@_);
}



#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub console_exit{

my $console = new Mebius::Console;
$console->console_exit(@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub local{

	if(($ENV{'SERVER_ADDR'} eq "127.0.0.1" || $ENV{'SERVER_ADDR'} =~ /^192\.168\.0\.[0-9]+$/ || $ENV{'HTTP_HOST'} eq "localhost") && $ENV{'DOCUMENT_ROOT'} =~ /^C:/){ return(1); }
	elsif($ENV{'SESSIONNAME'} eq "Console" && $ENV{'SYSTEMDRIVE'} eq "C:"){ return(1); }
	else{ return(); }


}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub console{

my $console = new Mebius::Console;
$console->console(@_);

}


1;

