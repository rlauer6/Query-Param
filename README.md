# NAME

Query::Param - Lightweight object interface for parsing and creating
query strings

# SYNOPSIS

    use Query::Param;

    my $args = Query::Param->new("foo=1&bar=2&bar=3");

    # Object-style access
    my $foo = $args->get("foo");      # "1"
    my $bar = $args->get("bar");      # ["2", "3"]

# DESCRIPTION

This module parses an application/x-www-form-urlencoded encode query
string and provides an object-oriented interface for accessing the
query parameters.

Multiple values for a parameter are stored as an array
internally. When accessed via `get`, a scalar is returned for single
values, and an array reference for multiple values.

There are many modules that parse query strings, so why re-invent this
wheel?

- Simplicity
    - Provides exactly what's needed to parse, access, mutate, and
    emit query strings - nothing more.
    - Easy to learn: get, set, has, keys, to\_string, pairs.
    - No dependency on object systems, Moo, Moose, or Catalyst internals.
- Lazy Decoding and Isomorphic Round-Tripping
    - Only decodes values on demand, saving effort when you only need a subset.
    - Preserves semantics on `to_string()` - values go in and come
    back out encoded correctly, even if original encoding format differed
    (+ vs %20).
    - Isomorphic: `to_string()` and `new()` are inverse operations, as
    long as values are treated semantically.
- No Magic or Global Side Effects
    - Doesn't touch global vars (%ENV, @ARGV, etc.).
    - Doesn't guess whether it's parsing a GET or POST - you pass it
    a string explicitly.
    - Can be used safely inside other frameworks or handlers without
    surprises.
- Consistent, Predictable Behavior
    - Every key always returns a single value or an arrayref -
    consistent rules.
    - `set()` replaces; multiple values only come from the original
    string or if assigned intentionally.
- Tiny Footprint
    - Just `URI::Escape`, no other non-core deps.
    - Lightweight enough for CLI tools, embedded apps, or mod\_perl
    handlers.
- CPAN Alternatives Can Be Overkill
    - CGI is bloated, global, and tied to the web environment.
    - `CGI::Tiny` is good, but intentionally avoids mutation - no
    `set()`.
    - `Plack::Request` and `HTTP::Request::Params` require full request
    objects and more dependencies.
    - Hash::MultiValue works but lacks parsing logic - and doesn't
    round-trip.

# CONSTRUCTOR

## new

    my $args = Query::Param->new($query_string);

Parses the provided query string and returns a new
`Query::Param` object.

# METHODS AND SUBROUTINES

## get

    $value = $args->get($key);

Returns the value associated with `$key`. If there are multiple
values, an array reference is returned. If only one value exists, the
scalar is returned.  Returns undef if the key does not exist.

## has

    if ($args->has("foo")) { ... }

Returns true if the key exists in the query string. This method
accesses the tied hash internally.

## keys

Returns the keys or names of the query string parameters.

## pairs

Returns a list of array references that contain key/value pairs in the
same vein as `List::Util::pairs`.

## set

Sets a query string parameter.

## to\_string

Creates an query string from the parsed or set parameters.

## values

# DEPENDENCIES

- [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape)

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>

# LICENSE

This module is released under the same terms as Perl itself.
