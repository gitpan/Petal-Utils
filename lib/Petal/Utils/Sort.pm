package Petal::Utils::Sort;

use strict;
use warnings;

use Carp;

use base qw( Petal::Utils::Base );

use constant name    => 'sort';
use constant aliases => qw();

sub process {
    my $class = shift;
    my $hash  = shift;
    my $args  = shift || confess( "'sort' expects an array ref (got nothing)!" );

    my $result = $hash->fetch( $args );

    confess( "1st arg to 'sort' is not an array ($args = $result)!" )
      unless ref($result) eq 'ARRAY'; # ignore object for now

    return [ sort @$result ];
}

1;
