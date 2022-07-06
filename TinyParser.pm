#! /bin/perl -W

package TinyParser;

use strict;
use warnings;

use Exporter qw(import);
#@ISA = qw(Exporter);

our $VERSION = '0.4';
our @EXPORT_OK = qw(parse);

use Error;

# parses string into token's list
#
sub parse {
    my $txt = shift @_;
    my @res = ();
    my ($char, $pos, $len, $tmp) = ('', 0, length $txt, '');
    
    while(1) {
        if ($pos >= $len) { last; };
        
        # yield next char
        $char = substr($txt, $pos, 1);
        
        # test for whitespace
        while($char =~ m/\s/)    {   # pass whitespaces
        
            #print "WS(`$char`) at $pos\n";
        
            $pos++;
            if ($pos >= $len) { return @res; }
            
            $char = substr($txt, $pos, 1); 
            
        }
        
        # parse further
        if ($char eq '"') {     # string literal
        
            my $cont = 1;
            $tmp = '"'; 
            
            do {
                $pos++; 
                $char = substr($txt, $pos, 1);
                
                if (not ($pos >= $len || $char eq '"')) { 
                    $tmp = $tmp . $char;
                } else {
                    $tmp = $tmp . '"';
                    $pos++;
                    $cont = 0;
                }
                
            } while($cont);
            
            if ($char ne '"') {
                Error::display Error::UNQUOTED, 0;
            }
            
            push @res, $tmp; #print "tmp=$tmp\n";
            $tmp = '';
            $EvalEngine::state = 'push';
        
        } elsif ($char =~ m/\d/) { # digit
        
            while($char =~ m/\d|\./) {
                $tmp = $tmp . $char;
                $pos++;
                if ($pos >= $len) { last; }
                $char = substr($txt, $pos, 1);
            }
            
            push @res, $tmp + 0.0;    #print "digit=`$tmp` at $pos\n";
            $tmp = '';
            $EvalEngine::state = 'push';
            
        } elsif ($char eq ';') {    # just for readability; does nothing
        
            $pos++;
            
            if ($pos >= $len) { last; }
            $char = substr($txt, $pos, 1);
            next;
            
        } elsif ($char eq '=') {    # set name to the value from top of the stack
        
            $pos++;
            
            if ($pos >= $len) {
                Error::display Error::UNEXP_END, $pos;
                last;
            }
            
            $char = substr ($txt, $pos, 1);
            $tmp = '='; # ! must precede name in that case
            
            while($char =~ m/[A-Z|a-z|_]/) {
                $tmp = $tmp . $char;
                $pos++;
                if ($pos >= $len) { last; }
                $char = substr($txt, $pos, 1);
            } # while...
            
            $pos++;
            
            push @res, $tmp;    #print "name: `$tmp`\n";
            $tmp = '';
            
        } elsif ($char =~ m/[A-Z|a-z|_]/) {    # just name
        
            while($char =~ m/[A-Z|a-z|_]/) {
                $tmp = $tmp . $char;
                $pos++;
                if ($pos >= $len) { last; }
                $char = substr($txt, $pos, 1);
            }
            
            push @res, $tmp;
            $tmp = '';
        
        } elsif ($char =~ m/\+|\-|\*|\/|\^|%|\?|&|\|/) { # operator
        
            $pos++;
            push @res, $char;
            
        } else {
            Error::display Error::INVAL_OPER, "`$char` at position $pos";
            last;
        }
        
    } # while...
    
    
    # return
    return @res;
} # sub parse

# !!!
1;

