#! /bin/perl -W

#
#   Built-In functions
#

package Builtin;

use strict;
#use warnings;

use Exporter qw(import);
use NameTable;
use EvalEngine;
use Error;
use Utils;

#@ISA = qw(Exporter);

our $VERSION = '0.3.1';
our @EXPORT_OK = qw(is_builtin %opers);

#
# new oper mechanics: key - operation (function) name, value - minimal number of params
our %opers = (
    
    # first arithmetics
    "plus" => 2, "minus" => 2, "multiply" => 2, "divide" => 2, "percent" => 2,
    
    # special operators
    "clear_stack" => 0, "print_stack" => 0, "swap" => 2,
    
    # numeric functions
    "sum" => 2, "factorial" => 1, "range" => 2, "ln" => 1, "tsin" => 1, "tcos" => 1, "prod" => 2,
    
    # logical
    "logic_and" => 2, "logic_or" => 2, "logic_not" => 1,
    
    # string functions
    "len" => 1, "upper" => 1, "lower" => 1, "trim" => 1, "conc" => 2, "regexp" => 1,
    
    # special funcs
    "prints" => 0
    
);


# checks whether name is a builtin function
sub is_builtin  {
    my $name = shift;
    
    return defined $opers{$name};

} # is_builtin()

#
# call(sub_name)
# calls specified sub
sub call {

    my $name = shift @_;
    my $argnum = $opers{$name};
    my $res = 0;
    
    #print "call: {name=$name} {argnum=$argnum}\n";
    
    if (not defined $argnum) {
        Error::display(Error::UNDEFINED_OP, $name); #print "here !\n";
    } else {
    
        if (scalar (@EvalEngine::dstack) < $argnum) {
            Error::display(Error::INSUF_ARGS, $name);
        } else {
            no strict 'refs';
            $res = &$name();   # call !
        }
    } # if ...
    
    return $res;
    
} # call()

# +
sub plus {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = $op1 + $op2;

    push @EvalEngine::dstack, $res;
    
    return $res;
}

# -
sub minus {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = $op1 - $op2;

    push @EvalEngine::dstack, $res;
    
    return $res;
}

sub multiply {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = $op1 * $op2;

    push @EvalEngine::dstack, $res;
    
    return $res;
}

# /
sub divide {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = $op1 / $op2;

    push @EvalEngine::dstack, $res;
    
    return $res;
}

# %
sub percent {
    my $perc = pop @EvalEngine::dstack;
    my $srcnum = pop @EvalEngine::dstack;

	my $res = ($perc / 100) * $srcnum;

	push @EvalEngine::dstack, $res;

    return $res;
}

# &
# logic and
sub logic_and {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = Utils::bool($op1) && Utils::bool($op2);

    push @EvalEngine::dstack, $res;
    
    return $res;

}

# |
# logic or
sub logic_or {
    my ($op2, $op1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;
        
    $res = Utils::bool($op1) || Utils::bool($op2);

    push @EvalEngine::dstack, $res;
    
    return $res;

}

#
# logic not
sub logic_not {
    my $op = pop @EvalEngine::dstack;
    
    my $res = Utils::bool(not Utils::bool($op));
    
    push @EvalEngine::dstack, $res;
    
    return $res;
}


# factorial
sub factorial {
	my $arg = shift @EvalEngine::dstack;
	
	my $res = int_factorial($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# internal factorial calculation
sub int_factorial {
    my $arg = shift @_;
    
    return $arg == 0 ? 1 : $arg * int_factorial($arg - 1);
}

# sum
# summs all data in @dstack
sub sum {
    my $acc = 0;

    while(scalar(@EvalEngine::dstack) != 0) {
        $acc += pop @EvalEngine::dstack;
    }
    
    push @EvalEngine::dstack, $acc;
    
    return $acc;

} # sum()

# prod
# product() function
sub prod {
    my $acc = 1;

    while(scalar(@EvalEngine::dstack) != 0) {
        $acc *= pop @EvalEngine::dstack;
    }
    
    push @EvalEngine::dstack, $acc;
    
    return $acc;

} # prod()

# avg()
# average value
sub avg {
    my ($num, $acc) = (0,0);
    
    while(scalar(@EvalEngine::dstack) != 0) {
        $acc += pop @EvalEngine::dstack;
        $num++;
    }

    my $res = $acc / $num;
    push @EvalEngine::dstack, $acc;
    
    return $res;
    
} # avg()

# range()
# generates range of numbers on stack
sub range {
    my $to = pop @EvalEngine::dstack;
    my $from = pop @EvalEngine::dstack;
    my $res; # undefined
    
    for($from .. $to) {
        push @EvalEngine::dstack, $_;
    }

    return $res;
} # range()

# ln()
# natural logarithm
sub ln {
    my $arg = pop @EvalEngine::dstack;
	my $res = log($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# tsin()
# trigonometic sine
sub tsin {
    my $arg = pop @EvalEngine::dstack;
    my $res = sin($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# tcos()
# trigonometic cosine
sub tcos {
    my $arg = pop @EvalEngine::dstack;
	my $res = cos($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# len()
# length of string
sub len {
    my $arg = pop @EvalEngine::dstack;
    my $res = length $arg;
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# upper()
# string to upper case
sub upper {
    my $arg = pop @EvalEngine::dstack;
    my $res = uc($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# lower()
# string to lower case
sub lower {
    my $arg = pop @EvalEngine::dstack;
    my $res = lc($arg);
	
	push @EvalEngine::dstack, $res;
	
	return $res;
}

# clear_stack()
# clears data stack
sub clear_stack {

    @EvalEngine::dstack = ();
    
    return 0;

}

# print_stack()
# prints data stack contents
sub print_stack {
    my $res; # undefined
    
    print "stack: ";
    for(@EvalEngine::dstack) {
        print "$_ ";
    }

    print "\n";
    
    return $res;
}

# swap()
# swaps 2 toppest stack values
sub swap {

    my ($v1, $v2) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    my $res;    # undefined
    
    push @EvalEngine::dstack, $v2;
    push @EvalEngine::dstack, $v1;
    
    return $res;
}

# prints()
# prints stack top value
sub prints {
    my $res;    # undefined
    
    print "stack top: ", EvalEngine::top(), "\n";

    return $res;
}

sub trim {
    my $arg = pop @EvalEngine::dstack;
    my $res;
    
    ($arg) = $arg =~ /^\s*(.*?)\s*$/;
    #$arg =~ s/\s+$//g;
    $res = $arg;
    
    push @EvalEngine::dstack, $res;
    
    return $res;

}

# regexp()
# performs RE match operation
sub regexp {
    my $patt = pop @EvalEngine::dstack;
    my $subs = pop @EvalEngine::dstack;
    
    my $res = Utils::bool($subs =~ /$patt/);
    
    push @EvalEngine::dstack, $res;
    
    return $res;
}

# conc()
# string contecanation
sub conc {
    my ($s2, $s1) = (pop @EvalEngine::dstack, pop @EvalEngine::dstack);
    
    my $res = $s1 . $s2;
    
    push @EvalEngine::dstack, $res;
    
    return $res;
}

# !!!
1;

