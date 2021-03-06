__precompile__(true)

module IndirectArrays

export IndirectArray

"""
    IndirectArray(index, values)

creates an array `A` where the values are looked up in the value table,
`values`, using the `index`.  Concretely, `A[i,j] =
values[index[i,j]]`.
"""
struct IndirectArray{T,N,A<:AbstractArray{<:Integer,N},V<:AbstractVector{T}} <: AbstractArray{T,N}
    index::A
    values::V

    @inline function IndirectArray{T,N,A,V}(index, values) where {T,N,A,V}
        # The typical logic for testing bounds and then using
        # @inbounds will not check whether index is inbounds for
        # values. So we had better check this on construction.
        @boundscheck checkbounds(values, index)
        new{T,N,A,V}(index, values)
    end
end
Base.@propagate_inbounds IndirectArray(index::AbstractArray{<:Integer,N}, values::AbstractVector{T}) where {T,N} =
    IndirectArray{T,N,typeof(index),typeof(values)}(index, values)

Base.size(A::IndirectArray) = size(A.index)
Base.indices(A::IndirectArray) = indices(A.index)
Base.IndexStyle(::Type{IndirectArray{T,N,A,V}}) where {T,N,A,V} = IndexStyle(A)

@inline function Base.getindex(A::IndirectArray, i::Int)
    @boundscheck checkbounds(A.index, i)
    @inbounds idx = A.index[i]
    @boundscheck checkbounds(A.values, idx)
    @inbounds ret = A.values[idx]
    ret
end

@inline function Base.getindex(A::IndirectArray{T,N}, I::Vararg{Int,N}) where {T,N}
    @boundscheck checkbounds(A.index, I...)
    @inbounds idx = A.index[I...]
    @boundscheck checkbounds(A.values, idx)
    @inbounds ret = A.values[idx]
    ret
end

end # module
