#! /usr/perl -W

package Error;

use strict;
#use warnings;
use 5.026;
use experimental qw(switch);

use Exporter qw(import);

our $VERSION = '0.3';
our @EXPORT_OK = qw(display INSUF_ARGS UNSUP_OP UNEXP_END INVAL_OPER CANNOT_OPEN CANNOT_READ UNQUOTED EMPTY_STACK UNDEFINED_OP);

# error codes
use constant {
    INSUF_ARGS => 1,
    UNSUP_OP => 2,
    UNEXP_END => 3,
    INVAL_OPER => 4,
    CANNOT_OPEN =>5,
    CANNOT_READ => 6,
    UNQUOTED => 7,
    EMPTY_STACK => 8,
    UNDEFINED_OP => 9
};

# general error message
sub display {
    my ($code, $details) = (shift @_, shift @_);
    my $msg = '';
    
    given($code) {
        when(INSUF_ARGS)    { $msg = "insufficient data for operation"; }
        when(UNSUP_OP)      { $msg = 'unsupported operation'; }
        when(UNEXP_END)     { $msg = 'unexpected end of expression'; }
        when(INVAL_OPER)    { $msg = 'invalid operator'; }
        when(CANNOT_OPEN)   { $msg = 'cannot open file'; }
        when(CANNOT_READ)   { $msg = 'cannot read file'; }
        when(UNQUOTED)      { $msg = "unquoted string literal"; }
        when(EMPTY_STACK)   { $msg = 'data stack is empty'; }
        when(UNDEFINED_OP)  { $msg = 'undefined function'; }
        default             { $msg = 'some unknown error '; }
    }
    
    
    print STDERR "$msg" , (defined $details ? ": `$details`" : ''), "; ignoring\n";
    
    
} # display()

# !!!
1;

