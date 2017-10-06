# Interesting cross-type indexing operations (Dic[Arr] -> Arr, etc)
@testset "indexing" begin
    v1 = Vec([4,3,2])
    d1 = Dic(4=>11, 3=>12, 2=>13)

    @test d1[v1] isa Vec{Int}
    @test d1[v1] == Vec([11,12,13])

    d2 = Dic(4=>3, 5=>2, 6=>1)
    v2 = Vec([11,12,13])

    @test v2[d2] isa Dic{Int, Int}
    @test v2[d2] == Dic(4=>13, 5=>12, 6=>11)
end