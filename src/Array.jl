abstract type AbstractArr{T, N} <: Assoc{Int, T}; end



struct Arr{T,N} <: AbstractArr{T, N}
    a::Array{T, N}
end

const Vec{T} = Arr{T, 1}
const Mat{T} = Arr{T, 2}

indices(a::Arr) = keys(a.a)
@propagate_inbounds getindex(a::Arr, i::Int) = a.a[i]
@propagate_inbounds getindex(a::Arr, i::Int) = a.a[i...]

@propagate_inbounds setindex!(a::Arr{T}, v::T, i::Int) where {T} = (a.a[i] = v)
@propagate_inbounds setindex!(a::Arr{T}, v::T, i::Int...) where {T} = (a.a[i...] = v)

similar(::Assoc, ::Type{T}, lens::Vararg{Int, N}) where {T, N} = Arr{T,N}(Array{T,N}(lens))
similar(::Assoc, ::Type{T}, inds::Vararg{Base.OneTo{Int}, N}) where {T, N} = Arr{T,N}(Array{T,N}(map(last, inds)))

empty(::Arr{T,N}, ::Type{Int}, ::Type{T}) where {T, N} = Arr{T,N}(Array{T,N}(ntuple(i->0, Val(N))))