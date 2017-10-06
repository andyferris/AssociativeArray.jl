# The default `AbstractArr`, more-or-less `Array`
struct Arr{T,N} <: AbstractArr{T, N}
    a::Array{T, N}
end

const Vec{T} = Arr{T, 1}
Vec(v::Vector{T}) where {T} = Vec{T}(v) 

const Mat{T} = Arr{T, 2}
Mat(m::Matrix{T}) where {T} = Mat{T}(m)

indices(a::Arr) = keys(a.a)

# Support getindex, etc, like currently exists
@propagate_inbounds getindex(a::Arr, i::Int) = a.a[i]
@propagate_inbounds getindex(a::Arr{<:Any, N}, i::Vararg{Int, N}) where {N} = a.a[i...]
@propagate_inbounds getindex(a::Arr{<:Any, N}, i::CartesianIndex{N}) where {N} = a.a[i]
@propagate_inbounds getindex(a::Arr, i::Union{Int,AbstractVector{Int},Colon}...) = Arr(a.a[i])

@propagate_inbounds setindex!(a::Arr{T}, v, i...) where {T} = (a.a[i...] = v; v)

similar(a::Assoc, lengths::Vararg{Int, N}) where {T, N} = similar(a, eltype(a), lengths...)
similar(a::Assoc, ::Type{T}, lengths::Vararg{Int, N}) where {T, N} = similar(a, T, CartesianRange(lengths))
similar(::Assoc, ::Type{T}, inds::Base.OneTo{Int}) where {T} = Vec{T}(Vector{T}(last(inds)))
similar(::Assoc, ::Type{T}, inds::CartesianRange{N}) where {T, N} = Arr{T, N}(Array{T, N}(map(last, inds)))

empty(::Assoc{T,N}, ::Type{CartesianIndex{1}}, ::Type{T}) where {T, N} = Vec{T}(Vector{T}(ntuple(i->0, Val(N))))
# No point making empty 0D, 2D, 3D, etc arrays... makes no sense!
