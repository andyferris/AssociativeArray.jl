module AssociativeArray

import Base: indices, pairs, getindex, setindex!, similar, start, next, done, length, size,
             pairs, IndexStyle

using Base: OneTo, @propagate_inbounds

export Assoc, Dic, AbstractArr, AbstractVec, AbstractMat, Arr, Vec, Mat
export indextype, empty, issetequal
export IndexDirect, IndexToken, IndexStyle # for my own convenience

eltype(::Base.KeyIterator{<:Associative{K, V}}) where {K, V} = K

include("issetequal.jl")
include("Associative.jl")
include("Dict.jl")
include("AbstractArray.jl")
include("Array.jl")

end # module
