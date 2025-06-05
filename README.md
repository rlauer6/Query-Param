# NAME

Query::Param - Lightweight object interface for parsing and creating
query strings

# SYNOPSIS

    use Query::Param;

    my $args = Query::Param->new("foo=1&bar=2&bar=3&empty=&encoded=%25+%2B");

    # Object-style access
    my $foo     = $args->get("foo");         # scalar: "1"
    my $bar     = $args->get("bar");         # arrayref: ["2", "3"]
    my $encoded = $args->get("encoded");     # scalar: "% +"

    # CGI-style access
    my $foo_again = $args->param("foo");     # same as get("foo")
    my @keys      = $args->param;            # all parameter names

    # Get all decoded parameters
    my $all = $args->params;                 # { foo => "1", bar => ["2", "3"], ... }

    # Legacy-compatible flat hash
    my $vars = $args->Vars;                  # { foo => "1", bar => "3", ... }

    # Check for presence
    if ( $args->has("bar") ) { ... }

    # Update or add parameters
    $args->set("foo", "updated");
    $args->set("new", "value");

    # Get query string back
    my $str = $args->to_string;              # bar=2&bar=3&empty=&encoded=%25%20%2B&foo=updated&new=value

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

# CGI COMPATIBILITY

This module supports key methods from [CGI](https://metacpan.org/pod/CGI) for interoperability:

- `param()` - scalar or arrayref return, regardless of context
- `Vars()` - returns a hashref of flattened scalar values (last-value wins)
- `get()` - equivalent to `param($key)`
- `params()` - returns a hashref retaining all values (including
arrayrefs)
- `to_string()` - round-trips encoded input with full fidelity

**Note**: Unlike CGI.pm, `param()` and `get()` do not change behavior
depending on context. They always return a scalar (if one value) or an
arrayref (if multiple values). This avoids subtle bugs and improves
predictability.

# THREAD SAFETY

This module does not use any global state. It is safe to use in
threaded, embedded, and reentrant environments such as mod\_perl,
Plack, or inside event loops.

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

## param

    my @names = $q->param;
    my $value = $q->param('key');

Returns the list of all parameter names when called with no arguments.

When called with a key, returns the value for that parameter. If the
parameter occurred multiple times in the original query string,
returns an array reference of values. Otherwise, returns a scalar
value.

This method is provided for compatibility with `CGI-`param>, but
unlike CGI.pm, it always returns a scalar or array reference
regardless of context. Internally, it delegates to `get()`.

## params

    my $hashref = $q->params;

Returns a hash reference containing all decoded parameters.

Each key corresponds to a parameter name. The value is either a scalar
(if the parameter had a single value) or an array reference (if the
parameter occurred multiple times).

This method is intended as a replacement for `CGI-`Vars> and provides
a consistent view of all parameters for inspection, testing, or
export.

## set

Sets a query string parameter.

## to\_string

Creates an query string from the parsed or set parameters.

## Vars

    my $vars = $q->Vars;

Returns a hash reference where each key maps to a scalar value.

If a parameter occurred multiple times in the query string, only the
last value is preserved - consistent with `CGI-`Vars>, but
potentially lossy.

This method is provided for compatibility with legacy code that
expects flattened query strings. Use `params()` instead to retain
full value lists and avoid silent data loss.

# DEPENDENCIES

- [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape)

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>

# LICENSE

This module is released under the same terms as Perl itself.
