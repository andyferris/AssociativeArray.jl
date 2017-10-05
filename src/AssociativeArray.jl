module AssociativeArray

import Base: @propagate_inbounds
import Base: indices, pairs, getindex, setindex!, similar, start, next, done, length, size,
             pairs, IndexStyle

export Assoc, Dic, AbstractArr, Arr
export indextype, empty
export IndexDirect, IndexToken, IndexStyle # for my own convenience

eltype(::Base.KeyIterator{<:Associative{K, V}}) where {K, V} = K

include("Associative.jl")
include("Array.jl")

end # module
