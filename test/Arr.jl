@testset "Vec" begin
    @test Vec([1,2,3]) isa Vec{Int}

    v = Vec([3,2,1])

    @test length(v) === 3
    @test indices(v) === Base.OneTo(3)

    @test v[1] === 3
    @test v[2] === 2
    @test v[3] === 1

    @test v[v] isa Vec
    v2 = v[v]
    @test v2 == Vec([1,2,3])
end