@testset "Dic constructors" begin
    dict = Dict(2=>3, 3=>4, 4=>2)

    @test @inferred(Dic(2=>3, 3=>4, 4=>2)) isa Dic{Int, Int}
    @test @inferred(Dic(dict)) isa Dic{Int, Int}
    @test @inferred(Dic()) isa Dic{Any, Any}

    @test @inferred(Dic{Int, Int}(2=>3, 3=>4, 4=>2)) isa Dic{Int, Int}
    @test @inferred(Dic{Int, Int}(dict)) isa Dic{Int, Int}
    @test @inferred(Dic{Int, Int}()) isa Dic{Int, Int}
end

@testset "Dic elemtary operations" begin
    d = Dic(1=>2, 2=>3, 3=>4)

    @test length(d) === 3

    @test issetequal(d, [2,3,4])
    @test issetequal(indices(d), [1,2,3])
    @test issetequal(pairs(d), [1=>2, 2=>3, 3=>4])

    @test d[1] === 2
    @test d[2] === 3
    @test d[3] === 4

    @test (d[1] = 10; d[1] === 10)
end

@testset "Dic fancy indexing" begin
    d1 = Dic(1=>2, 2=>3, 3=>1)

    @test d1[d1] isa Dic

    d2 = d1[d1]

    @test length(d2) === 3
    @test d2[1] === 3
    @test d2[2] === 1
    @test d2[3] === 2
end