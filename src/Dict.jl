# The "default" Associative (a Dict)
struct Dic{I, T} <: Assoc{I, T}
    d::Dict{I, T}
end

Dic(pairs::Pair...) = Dic(Dict(pairs...))
Dic{I, T}(pairs::Pair{>:I, >:T}...) where {I, T} = Dic(Dict(pairs...))
Dic() = Dic{Any, Any}()
Dic{I, T}() where {I, T} = Dic{I, T}(Dict{I, T}())

indices(d::Dic) = keys(d.d) # TODO: should this return an `AbstractSet` or something?
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