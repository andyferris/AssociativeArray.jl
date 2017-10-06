# AssociativeArray

Melding the `Associative` and `AbstractArray` interfaces into a coherent set of indexing
rules, etc.

[![Build Status](https://travis-ci.org/andyferris/AssociativeArray.jl.svg?branch=master)](https://travis-ci.org/andyferris/AssociativeArray.jl)
[![Coverage Status](https://coveralls.io/repos/andyferris/AssociativeArray.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/andyferris/AssociativeArray.jl?branch=master)
[![codecov.io](http://codecov.io/github/andyferris/AssociativeArray.jl/coverage.svg?branch=master)](http://codecov.io/github/andyferris/AssociativeArray.jl?branch=master)

This package attempts to demonstrate that we can extend some of the (APL-inspired) rules for
indexing `AbstractArray`s in Julia, to other `Associative`s.

To acheive this, I have created my own types `Assoc`, `Dic`, `AbstractArr` and `Arr` to
"mock" the 2 most common interfaces and 2 most common types in `Base`. I have also made
`AbstractArr` a subtype of `Assoc`; however this detail is not super important.

The important thing is that now:

 * We can index a dictionary with a dictionary (to get a dictionary).
 * We can index an array with a dictionary (to get a dictionary).
 * We can index a dictionary with an array (to get an array).

Some slightly interesting consequences:

 * We can have common semantics (and in some cases merge common methods) for `indices`
   (`keys` in `Base`), `similar`, `map` and so-on, between arrays and dictionaries. 
   The common semantics should provide a more seamless and intuitive interface for generic
   programming.
 * I propose a new `empty` function for creating empty dictionaries and vectors. `similar`
   would always preserve the indices of a dictionary (the values may be unintialized).
 * There is a path forward for multidimensional (Cartesian) dictionaries and structures,
   including tables/dataframes, that use (a generalization of) the APL indexing rules.

Notes:

 * Most of the benefits can be realized in `Base` without `AbstractArray <: Associative`
   (however this requirement was useful here to help build a conformant interface).
 * I favoured using `indices` and `indextype`, to match `getindex` and `setindex!`, however
   this may not be necessary (`Base` currently uses the term "key" for this).
 * One could also consider indexing of and by `Tuple`s, such that `(a, b, c)[(2,3)] = (b, c)`,
   `Dict(:a=>1, :b=>2, :c=>3)[(:a,:c)] = (1, 3)` and `(a,b,c)[[2,1]] = [b,a]`, etc.
   (However, might clash with dictionary keys being themselves tuples). Similarly for named
   tuples.

## Semantics

The overarching philisophy is that an array is just a special kind of associative container
where lookup is fast (using linear indexing or Cartesian indexing). We then search for
commanilities between the current powerful `AbstractArray` interface and what makes sense
also for `Associative`.

### The `Assoc` abstract type

An `Assoc{I, T}` (associative container) `a` is a mapping from a unique set of indices of
type `I`, to values of type `T`. Iterating an `Assoc` returns just the values, not the
indices. A single value can be retrieved via `getindex` (`a[i]`) and set via `setindex!`
(`a[i] = v`). The set of indices can be retrieved via `indices(a)` - note that these
generally might not be ordered, and can be compared with the new `issetequal` predicate. The
values are of type `eltype(a)` and the indices type is retrieved via a new function,
`indextype(a)`.

There is a `pairs` function which returns a `Pairs` view of the `Assoc`. Iterating this will
return pairs `i => v`, and moreover, the `Pairs` type preserves the ability to perform
indexing such that `pairs(a)[i] == (i => a[i])`.

### Arrays and `AbstractArr`

To make sense of arrays in this context, we note that the *fundamental* scalar indices of
(multidimensional) arrays are `CartesianIndex`s, and the set of indices form a
`CartesianRange`.

`AbstractArr` is meant to mirror the behavior of `AbstractArray`, however we have defined
`AbstractArr{T, N} <: Assoc{CartesianIndex{N}, T}`. The subtyping enforces that we create
a common interface.

### Indexing with `Assoc`.

We all love that we can index an array like `[10, 11, 12][2:3] == [11, 12]`. Here we
generalize this to all associative containers `a1` and `a2` using the following rules to
construct `out = a1[a2]`:

 * The output container shares the indices of `a2`.
 * The values `out[i]` correspond to `a1[a2[i]]`.

Similary, for non-sclar `setindex!` with `a1[a2] = v`, we use the following rule

 * For scalar `v`, assign the value `v` to the indices indicated by the *values* of `a2`, so
   that `a1[a2[i]] = v` for all `i in indices(a2)`.
 * For `v::Assoc`, we expect to match the indices of `v` with those of `a2`, such that
   we acheive `a1[a2[i]] = v[i]` for all `i in indices(a2)`.

Note that these rules are fully compatible with the built-in Julia arrays using one-based
indexing and the *OffsetArrays.jl* package.

### `similar` and `empty` with `Assoc`

Many operations like `getindex`, `map`, etc require us to build and return new containers.
Here we overload the `similar` method to have the behaviour such that

  * `similar(a::Assoc, ::Type{T}, inds)` creates a new `Assoc` that has the indices `inds`
    and unitialized values of type `T`.
  * `similar(a::Assoc) = similar(a, eltype(a), indices(a))`
  * etc for optional new indices or eltype...

Since arrays are associative containers with `CartesianRange` as its indices, it is easy to
determine the situations where an array is the appropriate output.

Currently `similar(::Dict)` creates an empty dictionary. Here we can create empty vectors
and dictionaries (that we expect to *add* elements to) to using the new `empty` function:

 * `empty(a::Assoc, ::Type{I}, ::Type{V}` creates a new container with the appropriate
   index and element types.
 * `empty(a::Assoc, ::Type{T}) == empty(a, indextype(a), T)`
 * `empty(a::Assoc) == empty(a, indextype(a), eltype(a))`

### And so on...

From here it is relatively straightforward to define a `map` function which works well on
arrays and dictionaries via preseriving the indices of the input(s). Similar to `empty` and
`similar`, one might want appropriate methods for `zeros` and `ones` and so-on. Functions
such as `reduce` only depend on the iterator interface.

Speculatively:

 * Functions like `filter` could present a lazy view of associatives (and arrays) where
   some indices are removed (and the remainder preserved, not moved).
 * One might try to generalize the multidimensional behavior of arrays to arbitrary
   associatives, and also have a look at `broadcast` in this context.

### TODO

Performance work is ongoing in this package (for instance, linear vs Cartesian indexing,
using `Dict` more efficiently, etc).