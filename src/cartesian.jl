"""
    CartInd(i1, i2, is...)

Represents a "scalar" index of a multidimensional associative (`Assoc`/`Arr`).
"""
struct CartInd{N, T <: NTuple{N,Any}}
    inds::T
end
CartInd(inds::T) where {N, T <: NTuple{N, Any}} = CartInd{N, T}(inds)
CartInd{N}(inds::T) where {N, T <: NTuple{N, Any}} = CartInd{N, T}(inds)
CartInd(inds...) = CartInd(inds)

"""
    CartProd(indices1, indices2, ...)

Represents the Cartesian product of the index sets `indices1`, `indices2`, ect. The elements
are `CartInd(first(indices1), first(indices2), ...)` and so-on.
"""
struct CartProd{N, I <: CartInd{N}, T <: CartInd{N}, Inds <: NTuple{N,Any}} <: Associative{I, T}
    indices::Inds
end
# TODO constructors that `collect` on `KeyIterator`s and so-on?

# The indices of a Cartesian product are another Cartesian Product.
# e.g. if c = CartProd(([:a,:b,:c], 2:4)), then indices(c) = CartProd(OneTo(3), OneTo(3))
indices(c::CartProd) = CartProd(map(indices, c.indices))
IndexStyle(c::CartProd) = IndexDirect()
@propagate_inbounds function getindex(c::CartProd{N}, i::CartInd{N})
    CartInd(map(getindex, c.indices, i.inds))
end

# Eventually this falls back to a Cartesian range
start(c::CartProd{N, NTuple{N, OneTo}}) = map(start, c.indices)
function next(c::CartProd{N}, inds::NTuple{N, Any})

end
done(c::CartProd{N}, inds::NTuple{N, Any}) = all(map(done, c.indices, i))



# TODO CartSlice - may be a mixture of ranges and scalars, dimensions following APL rules