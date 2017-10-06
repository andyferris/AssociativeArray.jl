# Perhaps this could even be a typealias rather than a subtype...
abstract type AbstractArr{T, N} <: Assoc{CartesianIndex{N}, T}; end
const AbstractVec{T} = AbstractArr{T, 1}
const AbstractMat{T} = AbstractArr{T, 2}

#=
@propagate_inbounds function getindex(a::AbstractArr, i...)
    _getindex(IndexStyle(a), a, cartesian(a, i1, i2, is...)]
end

cartesian(a, i::Integer...) = CartesianIndex(i)
cartesian(a, i...) = Base.to_indices(a, i)

getindex(a::AbstractArr, s::Base.Slice) = _getindex(a::)
=#