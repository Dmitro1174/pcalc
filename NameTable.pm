#! /bin/perl -W

package NameTable;

use strict;
use warnings;

use Exporter qw(import);
#@ISA = qw(Exporter);

our $VERSION = '0.1';
our @EXPORT_OK = qw(is_name set_name get_name);

our %names = ( 'pi' , 3.14159265358979, 'true', 1, 'false', 0 );

# check whether name exist
sub is_name {
    
    return exists($names{shift @_});

} # sub get_name()

# set or create name
sub set_name {

    my ($name, $val) = @_;

    $names{$name} = $val;

}

# get name value
sub get_name {

    return $names{shift @_};

}




# !!!
1;

