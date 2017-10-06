@testset "issetequal" begin
    v1 = [1,2,3]
    v2 = [3,2,1]
    s = Set([1,2,3])
    k = keys(Dict(1=>1, 2=>2, 3=>3))

    sets = [v1, v2, s, k]
    for s1 in sets
        for s2 in sets
            @test issetequal(s1, s2)
        end
    end

    v1_bad1 = [1,2,3,4]
    v2_bad1 = [4,3,2,1]
    s_bad1 = Set([1,2,3,4])
    k_bad1 = keys(Dict(1=>1, 2=>2, 3=>3, 4=>4))

    v1_bad2 = [1,2]
    v2_bad2 = [2,1]
    s_bad2 = Set([1,2])
    k_bad2 = keys(Dict(1=>1, 2=>2))

    v1_bad3 = [2,3,4]
    v2_bad3 = [4,3,2]
    s_bad3 = Set([2,3,4])
    k_bad3 = keys(Dict(2=>2, 3=>3, 4=>4))
    
    badsets = [v1_bad1, v2_bad1, s_bad1, k_bad1,
               v1_bad2, v2_bad2, s_bad2, k_bad2,
               v1_bad3, v2_bad3, s_bad3, k_bad3]
    
    for s1 in sets
        for s2 in badsets
            @test !issetequal(s1, s2)
        end
    end
    
    for s1 in badsets
        for s2 in sets
            @test !issetequal(s1, s2)
        end
    end     
end