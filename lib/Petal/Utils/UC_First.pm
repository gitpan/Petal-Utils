package Petal::Utils::UC_First;

use strict;
use warnings::register;

use base qw( Petal::Utils::Base );

use constant name    => 'uc_first';
use constant aliases => qw();

sub process {
    my $class = shift;
    my $hash  = shift;
    my $args  = shift || confess( "'uc_first' expects a variable (got nothing)!" );
    my $result = $hash->fetch($args);
    return "\u$result";
}

1;

__END__

# Uppercase the first letter of the string
