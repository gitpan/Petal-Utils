package Petal::Utils::Base;

#rename: package Petal::Plugin; ?

use strict;
use warnings::register;

use Carp;

## Define the enclosed packages inside the Petal Modifiers hash
sub install {
    my $class = shift;

    foreach my $name ($class->name, $class->aliases) {
	$Petal::Hash::MODIFIERS->{"$name:"} = $class;
    }

    return $class;
}

sub process {
    my $class = shift;
    confess( "$class does not override process()" );
}

sub name {
    my $class = shift;
    confess( "$class does not override name()" );
}

sub aliases {
    my $class = shift;
    confess( "$class does not override aliases()" );
}

sub split_first_arg {
    my $class = shift;
    my $args  = shift;
    # don't use split(/\s/,...) as we might kill an expression that way
    return ($args =~ /\A(.+?)\s+(.*)\z/);
}

1;

