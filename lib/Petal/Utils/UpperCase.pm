package Petal::Utils::UpperCase;

use strict;
use warnings::register;

use base qw( Petal::Utils::Base );

use constant name    => 'uppercase';
use constant aliases => qw( uc );

sub process {
    my $class = shift;
    my $hash  = shift;
    my $args  = shift || confess( "'uppercase' expects a variable (got nothing)!" );
    my $result = $hash->fetch($args);
    return uc($result);
}

1;

