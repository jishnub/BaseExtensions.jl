module BaseExtensions

export anynonzero, allzero, zero!, realtype, reinterpretreal, reinterpretcomplex

"""
	anynonzero(a)

Check if `a` contains any non-zero element.

# Examples
```jldoctest
julia> a = [1, 2, 0];

julia> anynonzero(a)
true

julia> a = zeros(2);

julia> anynonzero(a)
false
```
"""
anynonzero(a) = any(!iszero, a)

"""
	allzero(a)

Check if all elements of `a` are zero.

# Examples
```jldoctest
julia> a = [1, 2, 0];

julia> allzero(a)
false

julia> a = zeros(2);

julia> allzero(a)
true
```
"""
allzero(a) = all(iszero, a)

"""
	zero!(a::AbstractArray)

Set all elements of an `AbstractArray` to zero.

# Examples

```jldoctest
julia> a = [1, 2];

julia> zero!(a);

julia> a
2-element Array{Int64,1}:
 0
 0
```
"""
zero!(a::AbstractArray) = fill!(a, zero(eltype(a)))

"""
	realtype(::Complex)
	realtype(::Type{<:Complex})

Return the `eltype` of the real and imaginary parts of a `Complex` number.

# Examples

```jldoctest
julia> realtype(ComplexF64(2,2))
Float64

julia> realtype(ComplexF32(2,2))
Float32

julia> realtype(ComplexF32)
Float32
```
"""
realtype(::Type{Complex{T}}) where {T} = T
realtype(c::Complex) = realtype(typeof(c))

"""
	reinterpretreal(arr::AbstractArray{<:Complex})

Reinterpret a `Complex` array as a `Real` one containing the real and imaginary parts.

# Examples
```jldoctest
julia> a = [1 + 3im, 2+ 4im]
2-element Array{Complex{Int64},1}:
 1 + 3im
 2 + 4im

julia> reinterpretreal(a)
4-element reinterpret(Int64, ::Array{Complex{Int64},1}):
 1
 3
 2
 4
```

See also: [`reinterpretcomplex`](@ref)
"""
function reinterpretreal(arr::AbstractArray{<:Complex})
	reinterpret(realtype(eltype(arr)), arr)
end

"""
	reinterpretcomplex(arr::AbstractArray{<:Real})

Reinterpret a `Real` array as a `Complex` one assuming that the real and imaginary parts
are laid out consecutively.

# Examples
```jldoctest
julia> a = [1, 2, 3, 4];

julia> reinterpretcomplex(a)
2-element reinterpret(Complex{Int64}, ::Array{Int64,1}):
 1 + 2im
 3 + 4im
```

See also: [`reinterpretreal`](@ref)
"""
function reinterpretcomplex(arr::AbstractArray{<:Real})
	reinterpret(Complex{eltype(arr)}, arr)
end

end
