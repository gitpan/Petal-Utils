package Petal::Utils::LowerCase;

use strict;
use warnings::register;

use base qw( Petal::Utils::Base );

use constant name    => 'lowercase';
use constant aliases => qw( lc );

sub process {
    my $class = shift;
    my $hash  = shift;
    my $args  = shift || confess( "'lowercase' expects a variable (got nothing)!" );
    my $result = $hash->fetch($args);
    return lc($result);
}

1;
