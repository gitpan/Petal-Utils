package Petal::Utils::Dump;

use strict;
use warnings;

use Carp;
use Data::Dumper;

use base qw( Petal::Utils::Base );

use constant name    => 'dump';
use constant aliases => qw();

sub process {
    my $class = shift;
    my $hash  = shift;
    my $args  = shift || confess( "'dump' expects a variable (got nothing)" );
    my $result = $hash->fetch( $args );
    return Dumper( $result );
}

1;
