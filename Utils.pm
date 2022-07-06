#! /bin/perl

package Utils;

use strict;
#use warnings;

use Exporter qw(import);
use NameTable;
use EvalEngine;

#@ISA = qw(Exporter);

our $VERSION = '0.3';
our @EXPORT_OK = qw(list_view check_params load_file bool);

sub list_view {
}

# check_params()
# checks whether stack contains sufficient data
sub check_params {
    my $num = shift @_;
    
    return (scalar(@EvalEngine::dstack) >= $num);
    
} # check_params()

# load_file(file_name)
# loads text into string; 0 if failed
sub load_file {
    my $name = shift;
    my $text = '';
    
    if (open PROG, "<$name") {
    
        while(<PROG>) {
            $text = $text . $_;
        }
        
        close PROG;
    
    } else {
        return 0;
    }
    
    return $text;
    
} # load_file()

# bool()
# treat value as boolean
sub bool {
    my $val = shift;
    
    return $val ? 1 : 0;

}


# !!!
1;

