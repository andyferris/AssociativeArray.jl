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
#    - `pairs` - iterates index=>value `Pair`s
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

pairs(a::Assoc) = zip(indices(a), a) # TODO should be an indexable collection such that `pairs(a)[i] = (i => a[i])`. Then can e.g. `map((ind, val) -> ..., pairs(a))`.

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

# The "default" Associative (a Dict)
struct Dic{I,T} <: Assoc{I, T}
    d::Dict{I,T}
end

indices(d::Dic) = keys(d.d)
getindex(d::Dic{I}, i::I) where {I} = d.d[i]
@propagate_inbounds function setindex!(d::Dic{I,T}, v::T, i::I) where {I, T}
    d.d[i] = v
    return v
end

# This is a hack to get `similar` to work at all (probably not necessary with some more
# work / a new inner constructor for `Dict`)
default(::Type{T}) where {T} = isbits(T) ? Ref{T}()[] : zero(T)
default(::Type{String}) = ""
default(::Type{Array{T, N}}) where {T, N} = Array{T, N}()

# The default `similar` returns a `Dic`
function similar(::Assoc, ::Type{T}, inds) where {T}
    d = Dict{eltype(inds), T}()
    for i in inds
        d[i] = default(T)
    end
    return Dic(d)
end

empty(::Assoc, ::Type{I}, ::Type{T}) where {T, I} = Dic{I,T}(Dict{I,T}())