abstract type Assoc{I, T}; end

indices(a::Assoc) = error("`indices` not defined for $(typeof(a))")
getindex(::Assoc{I}, ::I) where {I} = error("`getindex` not defined for $(typeof(a))")
function setindex!(::Assoc{I, T}, ::T, ::I) where {I, T}
    error("`setindex` not defined for $(typeof(a))")
end

struct IndexDirect <: IndexStyle; end
struct IndexToken <: IndexStyle; end
IndexStyle(::Assoc) = IndexDirect()

# Implement this interface:
#    - `indices(::Assoc)`
#    - `getindex(::Assoc{I}, ::I) where I`
#    - `setindex!(::Assoc{I, T}, ::T, ::I) where I` (optional)
#    - `Base.IndexStyle(::Assoc)` -> `IndexDirect` or `IndexToken`
#      (if `IndexToken`, implement `gettokenindex` and `gettokenvalue`)
#
# Get for free:
#    - `indextype`, `eltype`
#    - `pairs` - iterates index=>value `Pair`s (also indexible)
#    - `getindex(::Assoc{I,T}, ::Assoc{K2, I})` returning an Assoc{K2,T}
#    - similarly for `setindex!`
#    - length, iteration, etc...
#    - similar
#
# TODO: 
#    - view (same indexing behavior as `getindex`)
#    - map (values, preserves indices)
#    - filter (preserves a subset of indices)
#    - SAC.jl functions ?

indextype(::Assoc{I}) where {I} = I
indextype(::Type{<:Assoc{I}}) where {I} = I
eltype(::Assoc{<:Any, T}) where {T} = T
eltype(::Type{<:Assoc{<:Any, T}}) where {T} = T

"""
    Pairs(a::Assoc)

Returns a new `Assoc` with the same indices as `a`, where each value is now a `Pair` of
the index and value.
"""
struct Pairs{I, T, A <: Assoc{I, T}} <: Assoc{I, Pair{I, T}}
    a::A
end
Pairs(a::Assoc{I,T}) where {I, T} = Pairs{I, T, typeof(a)}(a)

indices(p::Pairs) = indices(p.a)
IndexStyle(p::Pairs) = IndexStyle(p.a)
@propagate_inbounds getindex(p::Pairs{I}, i::I) where {I} = (i => p.a[i])
@propagate_inbounds getindex(p::Pairs{<:CartesianIndex}, i::Int) = (i => p.a[i])
tokens(p::Pairs) = tokens(p.a)
gettokenindex(p::Pairs, t) = gettokenindex(p.a, t)
gettokenvalue(p::Pairs, t) = (gettokenindex(p.a, t) => gettokenvalue(p.a, t))

pairs(a::Assoc) = Pairs(a)

length(a::Assoc) = length(indices(a))

start(a::Assoc) = _start(IndexStyle(a), a)
_start(::IndexDirect, a::Assoc) = start(indices(a))
_start(::IndexToken, a::Assoc) = start(tokens(a)) #?

@propagate_inbounds next(a::Assoc, i) = _next(IndexStyle(a), a, i)
@propagate_inbounds function _next(::IndexDirect, a::Assoc, i)
    (j, i2) = next(indices(a), i)
    return (a[j], i2)
end
@propagate_inbounds function _next(::IndexToken, a::Assoc, i)
    (j, i2) = next(tokens(a), i)
    return (gettokenvalue(a, j), i2)
end

done(a::Assoc, i) = _done(IndexStyle(a), a, i)
_done(::IndexDirect, a::Assoc, i) = done(indices(a), i)
_done(::IndexToken, a::Assoc, i) = done(tokens(a), i)

@propagate_inbounds function getindex(a::Assoc, inds::Assoc)
    out = similar(a, indices(inds))
    for (i, j) in pairs(inds)
        out[i] = a[j]
    end
    return out
end

@propagate_inbounds function setindex!(a::Assoc{I,T}, v, i::I) where {I,T}
    a[i] = convert(T, v)
    return v
end

@propagate_inbounds function setindex!(a::Assoc{I,T}, v::T, inds::Associative) where {I,T}
    for i in inds
        a[i] = v
    end
    return v
end

@propagate_inbounds function setindex!(a::Assoc{I,T}, v, inds::Associative) where {I,T}
    a[inds] = convert(T, v)
end

@propagate_inbounds function setindex!(a::Assoc{I,T}, v::Associative, inds::Associative) where {I,T}
    for (i, j) in pais(inds)
        a[j] = v[i]
    end
    return v
end


# Similar works a bit like for `Array`... 
similar(a::Assoc) = similar(a, eltype(a), indices(a))
similar(a::Assoc, ::Type{T}) where {T} = similar(a, T, indices(a))
similar(a::Assoc, i) = similar(a, eltype(a), i)
similar(a::Assoc, dims::Union{Integer, AbstractUnitRange}...) = similar(a, eltype(a), dims...)

# `empty` is much like `similar`, but with no defined indices (expects `push` or `setindex`
# or whatever to create indices)
empty(a::Assoc) = empty(a, indextype(a), eltype(a))
empty(a::Assoc, ::Type{T}) where {T} = empty(a, indextype(a), T)

# A couple of basic methods for now:
function Base.:(==)(a::Assoc, b::Assoc)
    if !issetequal(a, b)
        return false
    end

    for i in indices(a)
        if a[i] != b[i]
            return false
        end
    end
    return true
end

function Base.map(f, a::Assoc)
    out = similar(a, Base.promote_op(f, eltype(a)))
    for i in indices(a)
        @inbounds out[i] = f(a[i])
    end
end