package Query::Param;

use strict;
use warnings;

use URI::Escape qw(uri_unescape);

our $VERSION = '0.01';

########################################################################
sub new {
########################################################################
  my ( $class, $query_string ) = @_;

  my $self = bless {
    _raw     => {},  # raw key => [raw_value, ...]
    _decoded => {},  # decoded key => scalar or arrayref
  }, $class;

  $query_string //= q{};

  while ( $query_string =~ /([^&=]+)=?([^&]*)/xsmg ) {
    my ( $key, $val ) = ( $1, $2 );
    push @{ $self->{_raw}{$key} }, $val;
  }

  return $self;
}

########################################################################
sub get {
########################################################################
  my ( $self, $key ) = @_;

  return $self->{_decoded}{$key}
    if exists $self->{_decoded}{$key};

  return
    if !exists $self->{_raw}{$key};

  my @values = map { uri_unescape( $_ =~ tr/+/ /r ) } @{ $self->{_raw}{$key} };

  $self->{_decoded}{$key} = @values > 1 ? \@values : $values[0];

  return $self->{_decoded}{$key};
}

########################################################################
sub set {
########################################################################
  my ( $self, $key, $val ) = @_;

  delete $self->{_raw}{$key};
  $self->{_decoded}{$key} = $val;

  return;
}

########################################################################
sub has {
########################################################################
  my ( $self, $key ) = @_;
  return exists $self->{_raw}{$key} || exists $self->{_decoded}{$key};
}

########################################################################
sub keys {
########################################################################
  my ($self) = @_;

  my %seen;

  return grep { !$seen{$_}++ } ( keys %{ $self->{_raw} }, keys %{ $self->{_decoded} } );
}

########################################################################
sub to_string {
########################################################################
  my ($self) = @_;
  my @pairs;

  for my $key ( $self->keys ) {
    if ( exists $self->{_raw}{$key} ) {
      push @pairs, map {"$key=$_"} @{ $self->{_raw}{$key} };
    }
    elsif ( exists $self->{_decoded}{$key} ) {
      my @vals
        = ref $self->{_decoded}{$key} eq 'ARRAY'
        ? @{ $self->{_decoded}{$key} }
        : ( $self->{_decoded}{$key} );

      for my $v (@vals) {
        my $escaped_key = _form_escape($key);
        my $escaped_val = _form_escape($v);
        push @pairs, "$escaped_key=$escaped_val";
      }
    }
  }

  return join q{&}, @pairs;
}

########################################################################
sub _form_escape {
########################################################################
  my ($s) = @_;
  $s =~ s/([^\w\-\.\~ ])/sprintf("%%%02X", ord($1))/eg;
  $s =~ s/ /+/g;

  return $s;
}

########################################################################
sub pairs {
########################################################################
  my ($self) = @_;
  my @kv;

  for my $key ( $self->keys ) {
    my $val = $self->get($key);

    if ( ref $val eq 'ARRAY' ) {
      push @kv, map { ( $key => $_ ) } @$val;
    }
    else {
      push @kv, ( $key => $val );
    }
  }

  return @kv;
}

1;

__END__

=pod

=head1 NAME

Query::Param - Lightweight object interface for parsing and creating
query strings

=head1 SYNOPSIS

  use Query::Param;

  my $args = Query::Param->new("foo=1&bar=2&bar=3");

  # Object-style access
  my $foo = $args->get("foo");      # "1"
  my $bar = $args->get("bar");      # ["2", "3"]

=head1 DESCRIPTION

This module parses an application/x-www-form-urlencoded encode query
string and provides an object-oriented interface for accessing the
query parameters.

Multiple values for a parameter are stored as an array
internally. When accessed via C<get>, a scalar is returned for single
values, and an array reference for multiple values.

There are many modules that parse query strings, so why re-invent this
wheel?

=over 5

=item Simplicity

=over 10

=item * Provides exactly what's needed to parse, access, mutate, and
emit query strings - nothing more.

=item * Easy to learn: get, set, has, keys, to_string, pairs.

=item * No dependency on object systems, Moo, Moose, or Catalyst internals.

=back

=item Lazy Decoding and Isomorphic Round-Tripping

=over 10

=item * Only decodes values on demand, saving effort when you only need a subset.

=item * Preserves semantics on C<to_string()> - values go in and come
back out encoded correctly, even if original encoding format differed
(+ vs %20).

=item * Isomorphic: C<to_string()> and C<new()> are inverse operations, as
long as values are treated semantically.

=back

=item No Magic or Global Side Effects

=over 10

=item * Doesn't touch global vars (%ENV, @ARGV, etc.).

=item * Doesn't guess whether it's parsing a GET or POST - you pass it
a string explicitly.

=item * Can be used safely inside other frameworks or handlers without
surprises.

=back

=item Consistent, Predictable Behavior

=over 10

=item * Every key always returns a single value or an arrayref -
consistent rules.

=item * C<set()> replaces; multiple values only come from the original
string or if assigned intentionally.

=back

=item Tiny Footprint

=over 10

=item * Just C<URI::Escape>, no other non-core deps.

=item * Lightweight enough for CLI tools, embedded apps, or mod_perl
handlers.

=back

=item CPAN Alternatives Can Be Overkill

=over 10

=item * CGI is bloated, global, and tied to the web environment.

=item * C<CGI::Tiny> is good, but intentionally avoids mutation - no
C<set()>.

=item * C<Plack::Request> and C<HTTP::Request::Params> require full request
objects and more dependencies.

=item * Hash::MultiValue works but lacks parsing logic - and doesn't
round-trip.

=back

=back

=head1 CONSTRUCTOR

=head2 new

  my $args = Query::Param->new($query_string);

Parses the provided query string and returns a new
C<Query::Param> object.

=head1 METHODS AND SUBROUTINES

=head2 get

  $value = $args->get($key);

Returns the value associated with C<$key>. If there are multiple
values, an array reference is returned. If only one value exists, the
scalar is returned.  Returns undef if the key does not exist.

=head2 has

  if ($args->has("foo")) { ... }

Returns true if the key exists in the query string. This method
accesses the tied hash internally.

=head2 keys

Returns the keys or names of the query string parameters.

=head2 pairs

Returns a list of array references that contain key/value pairs in the
same vein as C<List::Util::pairs>.

=head2 set

Sets a query string parameter.

=head2 to_string

Creates an query string from the parsed or set parameters.

=head2 values

=head1 DEPENDENCIES

=over 5

=item *

L<URI::Escape>

=back

=head1 AUTHOR

Rob Lauer - <rlauer6@comcast.net>

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut
