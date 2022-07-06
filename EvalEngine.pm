#! /bin/perl

package EvalEngine;

use strict;
use warnings;

use 5.026;
use experimental qw(switch);

use Exporter qw(import);
use NameTable;
use Builtin;
use Error;

#@ISA = qw(Exporter);

our $VERSION = '0.5';
our @EXPORT_OK = qw(@istack @dstack $state execute top main_loop);

our @istack = ();
our @dstack = ();
our $state = ''; # state of execute() sub

# now try to execute @stack
sub main_loop {
    my $res;
    my $verbose = shift;
    
    while((scalar @EvalEngine::istack) != 0) {
    
        #print "before = @EvalEngine::dstack\n";

        $res = EvalEngine::execute();
        
        if ($EvalEngine::state eq '') { # previous operation failed, nothing changed 
        
            # here we do nothing !!!
            
        } elsif($EvalEngine::state eq 'stop') {   # stop instrcution
        
            print ("stop. dstack=", "@EvalEngine::dstack") if ($verbose);
              
        } elsif ($EvalEngine::state eq 'push') { # data pushed onto stack
            
            print ("push {$res} (dstack=", "@EvalEngine::dstack", ")\n") if ($verbose);
                    
        } else {    # oper or func
        
            print ("$EvalEngine::state {$res} (dstack=", "@EvalEngine::dstack", ")\n") if ($verbose);
            #print ("{$EvalEngine::state} = ") if $verbose;
            print ("stack top=", EvalEngine::top(), "\n") if ($verbose);
        }
        
        #print "after = @EvalEngine::dstack\n";
        
    } # while...
    
    if (not defined $res) { $res = EvalEngine::top(); }
    print "total = " if ($verbose);
    if (defined $res) {
        print EvalEngine::top(), "\n"; # print last (overall) result
    } else {
        print "stack is empty.\n";
    }

} # main_loop()

#
# new execute()
# executes  instruction (one) from @istack ans push result back to stack
# returns top of the stack
# supports: +-*/; ^ - clear stack' | swap 2 top stack values
sub execute {
    my ($next, $op1, $op2, $res);
	my $ip = 0;

	if ((scalar @istack) == 0) {
		print "instruction stack is empty, stopping.\n";
		last;
	}

    $next = shift @istack;   # get next instruction
    
    if ($next =~ /(\+|\-|\*|\/|%|\?|\^|\||&)+/) {  # one char operator
    
        my $bin_name;
            
        given($next)    {   # operator ?
            # arith
            when('+')   { $bin_name = 'plus'; }
            when('-')   { $bin_name = 'minus'; }
            when('*')   { $bin_name = 'multiply'; }
            when('/')   { $bin_name = 'divide'; }
            when('%')   { $bin_name = 'percent'; }
            
            # logic
            when('&')   { $bin_name = 'logic_and'; }
            when('|')   { $bin_name = 'logic_or'; }
            
            # special
            when('?')   { $bin_name = 'print_stack'; }
            when('^')   { $bin_name = 'clear_stack'; }
            when('|')   { $bin_name = 'swap'; }
            default     {
                $bin_name = $next;
            }
        } # given...
        
        # now call !!
        $res = Builtin::call($bin_name); #print "\$bin_name=$bin_name\n";
        $state = $next;
        
        #push @dstack, $res if defined $res; # !!! it's important - result must be pushed onto data stack
    
    
    } elsif ($next =~ /^[0-9|\.]+$/ ) { # number - push it to data stack
    
        $res = $next + 0.0; 
        push @dstack, $res;
        
        $state = 'push'; # indicates data just pushed into stack
        
    } elsif ($next =~ /^\".*\"$/s) { # string literal - push it to data stack
    
        $res = substr $next, 1, length($next) - 2;
        push @dstack, $res;
        $state = 'push';
        
        
    } elsif (substr($next, 0, 1) eq '=')    {   # assign stack top to name; stack is unchanged
    
        if((scalar @dstack) == 0)  {
            print "stack is empty, cannot assign to " . substr($next, 1, length $next) . "\n";
            $res = 0;
        } else {
            NameTable::set_name (substr($next, 1, length($next) - 1), $dstack[0]);
            $res = $dstack[0];
        }
        
        $state = substr ($next, 1, length $next) . "<-"; # elide first !
        
    } elsif ($next =~ /[a-z|A-Z|_]/) {    # push value of name onto stack; OR SYMBOLIC FUCTION !!!
    
        if(NameTable::is_name($next)) {	# variable !
            
            $res = NameTable::get_name($next);
            push @dstack, $res;
            
            $state = "$next->"; ;
            
        } else {	# not variable - function or reserved word ?
        
            # translate if needed
            given($next)    {
                when('and')     { $next = 'logic_and'; }
                when('or')      { $next = 'logic_or'; }
                when('not')     { $next = 'logic_not'; }
            }
            
            # now call !!
            $res = Builtin::call($next);
            #push @dstack, $res if defined $res;
            $state = $next;
        }
    } else {
        Error::display(Error::UNSUP_OP, $next);
        $res = 0;
        $state = 'error';
    }
    
    # return
    return $res;

} # execute()

# top()
# return data stack top
sub top {
    return $dstack[scalar(@dstack) - 1];
}


# !!!
1;

