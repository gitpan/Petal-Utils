package Petal::Utils;

=head1 NAME

Petal::Utils - Useful template modifiers for Petal.

=head1 SYNOPSIS

  # install the default set of Petal modifiers:
  use Petal::Utils;

  # you can also install modifiers manually:
  Petal::Utils->install( 'some_modifier', ':some_set' );

  # see below for modifiers available & template syntax

=cut

use 5.006;
use strict;
use warnings::register;

use Petal::Hash;

our $VERSION = '0.04';
our $DEBUG   = 0;

#------------------------------------------------------------------------------
# Cusomized import() so the user can select different plugins & sets

# use an Exporter-like syntax here:
our %PLUGIN_SET =
  (
   ':none'    => [],
   ':all'     => [qw( :default :hash :debug )],
   ':default' => [qw( :text :date :logic :list )],
   ':text'    => [qw( UpperCase LowerCase UC_First )],
   ':logic'   => [qw( And If Or Equal Like )],
   ':date'    => [qw( Date US_Date )],
   ':list'    => [qw( Sort )],
   ':hash'    => [qw( Each Keys )],
   ':debug'   => [qw( Dump )],
  );

sub import {
    my $class = shift;
    push @_, ':default' unless @_;
    return $class->install( @_ );
}

sub install {
    my $class = shift;

    foreach my $item (@_) {
	next unless $item;
	if ($item =~ /\A:/) {
	    $class->install_plugin_set( $item );
	} else {
	    $class->install_plugin( $item );
	}
    }

    return $class;
}

sub install_plugin_set {
    my $class = shift;
    my $set   = shift;

    my $plugins = $PLUGIN_SET{$set}
      || die "Can't install non-existent plugin set '$set'!";

    # recursive so we can have sets of sets:
    $class->install( @$plugins );
}

sub install_plugins {
    my $class = shift;
    map { $class->install_plugin( $_ ) } @_;
    return $class;
}

sub install_plugin {
    my $class = shift;
    my $name  = shift;

    my $plugin = $class->find_plugin( $name );

    warn "installing Petal plugin: '$name'\n" if $DEBUG;

    if (UNIVERSAL::can($plugin, 'install')) {
	$plugin->install;
    } else {
	$Petal::Hash::MODIFIERS->{"$plugin:"} = $plugin;
    }

    return $class;
}

sub find_plugin {
    my $class  = shift;
    my $plugin = shift;

    return \&$plugin if $class->can( $plugin );

    if (my $plugin_class = $class->load_plugin( $plugin )) {
	return $plugin_class;
    }

    die "Can't find Petal plugin: '$plugin'!";
}

sub load_plugin {
    my $class  = shift;
    my $plugin = shift;

    my $plugin_class = $class->get_plugin_class_for( $plugin );
    return $plugin_class if $plugin_class->can( 'process' );

    eval "require $plugin_class";
    if ($@) {
	warnings::warn("error loading $plugin plugin: $@") if warnings::enabled;
	return;
    }

    return $plugin_class;
}

sub get_plugin_class_for {
    my $class  = shift;
    my $plugin = shift;
    my $plugin_class = "$class\::$plugin";
}


#------------------------------------------------------------------------------
# Plugins

## See Petal::Utils::<plugin> for plugin classes
## (plugins are now loaded as needed)

## Alternatively, use subs to insert new modifiers into the Petal Modifiers
## hash. Note that we do not get the $class value in this format.

# This style is deprecated:
# sub foo {
#    my $hash = shift;
#    my $args = shift;
#    my $result = $hash->fetch( $args );
#    return 'foo '.$result;
# }

1;

__END__

=head1 DESCRIPTION

The Petal::Utils package contains commonly used L<Petal> modifiers (or plugins),
and bundles them with an easy-to-use installation interface.  By default, a
set of modifiers are installed into Petal when you use this module.  You can
change which modifiers are installed by naming them after the use statement:

  # use the default set:
  use Petal::Utils qw( :default );

  # use the date set of modifiers:
  use Petal::Utils qw( :date );

  # use only named modifiers, plus the debug set:
  use Petal::Utils qw( UpperCase Date :debug );

  # don't install any modifiers
  use Petal::Utils qw();

You'll find a list of plugin sets throughout this document.  You can also get
a complete list by looking at the variable:

  %Petal::Utils::PLUGIN_SET;

For details on how the plugins are installed, see the "Advanced Petal" section
of the L<Petal> documentation.

=head1 MODIFIERS

Each modifier is listed under the set it belongs to.

=head2 :text

=over 4

=item lowercase:, lc: $string

Make the entire string lowercase.

  <p tal:content="lc: $string">lower</p>

=item uppercase:, uc: $string

Make the entire string uppercase.

  <p tal:content="uc: $string">upper</p>

=item uc_first: $string

Make the first letter of the string uppercase.

  <p tal:content="uc_first: $string">uc_first</p>

=back

=head2 :date

=over 4

=item date: $date

Convert a time() integer to a date string using L<Date::Format>.

  <span tal:replace="date: $date">Jan  1 1970 01:00:01</span>

=item us_date: $date

Convert an international date stamp (e.g., yyyymmdd, yyyy-mm-dd, yyyy/mm/dd)
to US format (mm/dd/yyyy).

  <p tal:content="us_date: $date">2003-09-05</p>

=back

=head2 :logic

=over 4

=item if: $expr1 then: $expr2 else: $expr3

Do an if/then/else test and return the value of the expression executed.
Truthfulness of $expr1 is according to Perl (e.g., non-zero, non-empty string).

  <p tal:attributes="class if: on_a_page then: a_class else: another_class">
    Some text here...
  </p>

=item or: $expr1 $expr2

Do a logical or.  Truthfulness is according to Perl (e.g., non-zero, non-empty
string).

  <p tal:if="or: $first $second">
    first or second = <span tal:replace="or: $first $second">or</span>
  </p>

=item and: $expr1 $expr2

Do a logical and.  Truthfulness is according to Perl (e.g., non-zero, non-empty
string).

  first and second = <span tal:replace="and: $first $second">and</span>

=item equal:, eq: $expr1 $expr2

Test for equality.  Numbers are compared with C<==>, strings with C<eq>.
Truthfulness is according to Perl (e.g., non-zero, non-empty string).

  first eq second = <span tal:replace="eq: $first $second">equal</span>

=item like: $expr $regex

Test for equality to a regular expression (see L<perlre>).

  name like regex = <span tal:replace="like: $name ^Will.+m">like</span>

=back

=head2 :list

=over 4

=item sort: $list

Sort the values in a list before returning it.

  <ul>
    <li tal:repeat="item sort: $array_ref">$item</li>
  </ul>

=back

=head2 :hash

=over 4

=item keys: $hash

Return a list of keys for a hashref. Note: It appears that values cannot be
accessed with dynamic keys. If you need the keys and values, use "each:".

  <ul>
    <li tal:repeat="key keys: $hash_ref"><span tal:replace="key">key</span></li>
  </ul>

=item each: $hash

Return a list of key/value pairs for a hashref.

  <ul>
    <li tal:repeat="item each: $hash_ref">
      <span tal:replace="item/key">key</span> => <span tal:replace="item/val">value</span>
    </li>
  </ul>

=back

=head2 :debug

=over 4

=item dump: $expr

Dump the data strcture of the value given.

  dump name: <span tal:replace="dump: name">dump</span>

=back

=head1 SUPERSETS

At the time of writing, the following supersets were available:

   ':none'    => [],
   ':all'     => [qw( :default :hash :debug )],
   ':default' => [qw( :text :date :logic :list )],

See C<%Petal::Utils::PLUGIN_SET> for an up-to-date list.

=head1 AUTHOR

William McKee <william@knowmad.com>, and Steve Purkis <spurkis@epn.nu>

=head1 COPYRIGHT

Copyright (C) 2003 William McKee & Steve Purkis.

This module is free software and is distributed under the same license as Perl
itself. Use it at your own risk.

=head1 THANKS

Thanks to Jean-Michel Hiver for making L<Petal> available to the Perl community.

=head1 SEE ALSO

L<Petal>

=cut