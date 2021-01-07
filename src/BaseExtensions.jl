module BaseExtensions

export anynonzero
export allzero
export zero!
export realtype
export reinterpretreal
export reinterpretcomplex
export squeeze
export flipdims
export fillcopy
export fillcopy!
export filldeepcopy
export filldeepcopy!

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
2-element $(Array{Int,1}):
 0
 0
```
"""
zero!(a::AbstractArray) = fill!(a, zero(eltype(a)))

"""
	realtype(::Complex)
	realtype(::Type{<:Complex})

Return the type of the real and imaginary parts of a `Complex` number.

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
2-element $(Array{Complex{Int},1}):
 1 + 3im
 2 + 4im

julia> reinterpretreal(a)
4-element reinterpret($Int, ::$(Array{Complex{Int},1})):
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
2-element reinterpret(Complex{$Int}, ::$(Array{Int,1})):
 1 + 2im
 3 + 4im
```

See also: [`reinterpretreal`](@ref)
"""
function reinterpretcomplex(arr::AbstractArray{<:Real})
	reinterpret(Complex{eltype(arr)}, arr)
end

"""
	squeeze(A)

Remove dimensions from `A` that have `size(A, dim) == 1`. 
Returns a view that shares the underlying data with `A`.

# Examples
```jldoctest
julia> A = reshape(collect(1:4), 1, 4)
1×4 $(Array{Int,2}):
 1  2  3  4

julia> B = squeeze(A)
4-element $(Array{Int,1}):
 1
 2
 3
 4
```
"""
function squeeze(A)
	dims = Tuple(findall(==(1), size(A)))
	dropdims(A, dims = dims)
end

"""
	flipdims(A)

Permute `A` so that the sequence of axes is reversed. For 2D arrays this is an eager transpose.
The operation is not recursive.

# Examples
```jldoctest
julia> A = reshape(collect(1:8), 2, 4)
2×4 $(Array{Int,2}):
 1  3  5  7
 2  4  6  8

julia> B = flipdims(A)
4×2 $(Array{Int,2}):
 1  2
 3  4
 5  6
 7  8

julia> A = reshape(collect(1:8), 2, 2, 2)
2×2×2 $(Array{Int,3}):
[:, :, 1] =
 1  3
 2  4

[:, :, 2] =
 5  7
 6  8

julia> flipdims(A)
2×2×2 $(Array{Int,3}):
[:, :, 1] =
 1  3
 5  7

[:, :, 2] =
 2  4
 6  8
```
"""
function flipdims(A)
	permutedims(A, reverse(collect(1:ndims(A))))
end

"""
	fillcopy(x, dims...)

Create an array filled with shallow copies of `x`, where the dimensions or indices of the array is 
specfied through the keyword `dims`. As in `copy`, only the outer container of `x` is copied.

Unlike `fill`, returns an array where each element is unique. 

# Examples
```jldoctest
julia> A = fillcopy(ones(2), 2, 2)
2×2 $(Array{Array{Float64,1},2}):
 [1.0, 1.0]  [1.0, 1.0]
 [1.0, 1.0]  [1.0, 1.0]

julia> A[1,1] === A[2,2]
false

julia> A[1,1] .= 2;

julia> A
2×2 $(Array{Array{Float64,1},2}):
 [2.0, 2.0]  [1.0, 1.0]
 [1.0, 1.0]  [1.0, 1.0]

julia> B = fillcopy(A, 2)
2-element $(Array{Array{Array{Float64,1},2},1}):
 [[2.0, 2.0] [1.0, 1.0]; [1.0, 1.0] [1.0, 1.0]]
 [[2.0, 2.0] [1.0, 1.0]; [1.0, 1.0] [1.0, 1.0]]

julia> B[2] === B[1]
false

julia> B[2][1] === B[1][1]
true
```

See also: [`filldeepcopy`](@ref)
"""
function fillcopy(x, inds...)
	A = similar(Array{typeof(x)}, inds)
	fillcopy!(A, x)
	return A
end

"""
	fillcopy!(A, x)

Fill `A` with shallow copies of `x`. As in `copy`, only the outer container of `x` is copied.

# Examples
```jldoctest
julia> A = Vector{Vector{Vector{Int}}}(undef, 3);

julia> fillcopy!(A, [[1,2], [1, 2,3]])
3-element $(Array{Array{Array{Int,1},1},1}):
 [[1, 2], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]

julia> A[1][1] === A[2][1]
true

julia> A[1][1] .= 4:5;

julia> A
3-element $(Array{Array{Array{Int,1},1},1}):
 [[4, 5], [1, 2, 3]]
 [[4, 5], [1, 2, 3]]
 [[4, 5], [1, 2, 3]]
```

See also: [`filldeepcopy!`](@ref)
"""
function fillcopy!(A, x)
	@inbounds for i in eachindex(A)
		A[i] = copy(x)
	end
	return A
end

"""
	filldeepcopy(x, dims...)

Create an array filled with deep copies of `x`, where the dimensions or indices of the array is 
specfied through the keyword `dims`. As in `deepcopy`, the copy operation is recursive, and each element 
in the returned array will be completely unique in identity, albeit equal to `x` in value.

# Examples
```jldoctest
julia> A = filldeepcopy(ones(2), 2, 2)
2×2 $(Array{Array{Float64,1},2}):
 [1.0, 1.0]  [1.0, 1.0]
 [1.0, 1.0]  [1.0, 1.0]

julia> A[1,1] === A[2,2]
false

julia> A[1,1] .= 2;

julia> A
2×2 $(Array{Array{Float64,1},2}):
 [2.0, 2.0]  [1.0, 1.0]
 [1.0, 1.0]  [1.0, 1.0]

julia> B = filldeepcopy(A, 2)
2-element $(Array{Array{Array{Float64,1},2},1}):
 [[2.0, 2.0] [1.0, 1.0]; [1.0, 1.0] [1.0, 1.0]]
 [[2.0, 2.0] [1.0, 1.0]; [1.0, 1.0] [1.0, 1.0]]

julia> B[2] === B[1]
false

julia> B[2][1] === B[1][1]
false
```

See also: [`fillcopy`](@ref)
"""
function filldeepcopy(x, inds...)
	A = similar(Array{typeof(x)}, inds)
	filldeepcopy!(A, x)
	return A
end

"""
	filldeepcopy!(A, x)

Fill `A` with deep copies of `x`. The operation is recursive and each element in `A` will be 
completely unique in identity, albeit equal to `x` in value.

# Examples
```jldoctest
julia> A = Vector{Vector{Vector{Int}}}(undef, 3);

julia> filldeepcopy!(A, [[1,2], [1, 2,3]])
3-element $(Array{Array{Array{Int,1},1},1}):
 [[1, 2], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]

julia> A[1][1] === A[2][1]
false

julia> A[1][1] .= 4:5;

julia> A
3-element $(Array{Array{Array{Int,1},1},1}):
 [[4, 5], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]
 [[1, 2], [1, 2, 3]]
```

See also: [`fillcopy!`](@ref)
"""
function filldeepcopy!(A, x)
	@inbounds for i in eachindex(A)
		A[i] = deepcopy(x)
	end
	return A
end

end
