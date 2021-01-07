using BaseExtensions
using Test
using Documenter
using Aqua

@testset "project quality" begin
    Aqua.test_all(BaseExtensions)
end

DocMeta.setdocmeta!(BaseExtensions, :DocTestSetup, :(using BaseExtensions); recursive=true)

@testset "docstrings" begin
    doctest(BaseExtensions)
end

@testset "anynonzero + allzero" begin
    a = [1,2,3];
    @test anynonzero(a)
    @test !allzero(a)

    a = [1,2,0];
    @test anynonzero(a)
    @test !allzero(a)

    a = zeros(3);
	@test !anynonzero(a)
	@test allzero(a)
end

@testset "zero!" begin
    a = [1, 2, 3]
    zero!(a)
    @test allzero(a)
end

@testset "realtype" begin
    c = ComplexF64(3,2)
    @test realtype(c) == Float64
    @test realtype(ComplexF64) == Float64

    c = ComplexF32(3,2)
    @test realtype(c) == Float32
    @test realtype(ComplexF32) == Float32
end

@testset "reinterpretreal" begin
	for T in [Int, Float64]
	    a = Complex{T}[1 + im, 2 + 2im]
	    @test reinterpretreal(a) == T[1, 1, 2, 2]
	end
end

@testset "reinterpretcomplex" begin
	for T in [Int, Float64]
	    a = T[1, 1, 2, 2]
	    @test reinterpretcomplex(a) == Complex{T}[1 + im, 2 + 2im]
	end
end

@testset "squeeze" begin
    A = rand(2,1,2)
    B = squeeze(A)
    @test B == reshape(A, 2, 2)
end

@testset "flipdims" begin
    A = rand(1,2,3)
    B = flipdims(A)
    @test B == permutedims(A, [3,2,1])
    @test axes(B) == reverse(axes(A))
end

@testset "filldeepcopy" begin
    A = Vector{Vector{Vector{Int}}}(undef, 3);
    filldeepcopy!(A, [ones(Int, 2) for i = 1:2]);

    A[1][1] .= 3:4;

    for i in 1:3, j = 1:2
        if i == j == 1
            @test all(A[i][j] .== 3:4)
        else
            @test all(A[i][j] .== 1)
        end
    end
end

@testset "fillcopy" begin
    A = Vector{Vector{Vector{Int}}}(undef, 3);
    fillcopy!(A, [ones(Int, 2) for i = 1:2]);

    A[1][1] .= 3:4

    for i in 1:3, j = 1:2
        if j == 1
            @test all(A[i][j] .== 3:4)
        else
            @test all(A[i][j] .== 1)
        end
    end
end