T = Float32

@testset "cuda/linalg" begin
    in_channel = 3
    out_channel = 5
    N = 6

    adjs = Dict(
        :simple => [0. 1. 1. 0. 0. 0.;
                    1. 0. 1. 0. 1. 0.;
                    1. 1. 0. 1. 0. 1.;
                    0. 0. 1. 0. 0. 0.;
                    0. 1. 0. 0. 0. 0.;
                    0. 0. 1. 0. 0. 0.],
        :weight => [0. 2. 2. 0. 0. 0.;
                    2. 0. 1. 0. 2. 0.;
                    2. 1. 0. 5. 0. 2.;
                    0. 0. 5. 0. 0. 0.;
                    0. 2. 0. 0. 0. 0.;
                    0. 0. 2. 0. 0. 0.],
    )

    degs = Dict(
        :simple => [2. 0. 0. 0. 0. 0.;
                    0. 3. 0. 0. 0. 0.;
                    0. 0. 4. 0. 0. 0.;
                    0. 0. 0. 1. 0. 0.;
                    0. 0. 0. 0. 1. 0.;
                    0. 0. 0. 0. 0. 1.],
        :weight => [4. 0. 0. 0. 0. 0.;
                    0. 5. 0. 0. 0. 0.;
                    0. 0. 10. 0. 0. 0.;
                    0. 0. 0. 5. 0. 0.;
                    0. 0. 0. 0. 2. 0.;
                    0. 0. 0. 0. 0. 2.]
    )

    laps = Dict(
        :simple => [2. -1. -1. 0. 0. 0.;
                    -1. 3. -1. 0. -1. 0.;
                    -1. -1. 4. -1. 0. -1.;
                    0. 0. -1. 1. 0. 0.;
                    0. -1. 0. 0. 1. 0.;
                    0. 0. -1. 0. 0. 1.],
        :weight => [4. -2. -2. 0. 0. 0.;
                    -2. 5. -1. 0. -2. 0.;
                    -2. -1. 10. -5. 0. -2.;
                    0. 0. -5. 5. 0. 0.;
                    0. -2. 0. 0. 2. 0.;
                    0. 0. -2. 0. 0. 2.],
    )

    norm_laps = Dict(
        :simple => [1. -1/sqrt(2*3) -1/sqrt(2*4) 0. 0. 0.;
                    -1/sqrt(2*3) 1. -1/sqrt(3*4) 0. -1/sqrt(3) 0.;
                    -1/sqrt(2*4) -1/sqrt(3*4) 1. -1/2 0. -1/2;
                    0. 0. -1/2 1. 0. 0.;
                    0. -1/sqrt(3) 0. 0. 1. 0.;
                    0. 0. -1/2 0. 0. 1.],
        :weight => [1. -2/sqrt(4*5) -2/sqrt(4*10) 0. 0. 0.;
                    -2/sqrt(4*5) 1. -1/sqrt(5*10) 0. -2/sqrt(2*5) 0.;
                    -2/sqrt(4*10) -1/sqrt(5*10) 1. -5/sqrt(5*10) 0. -2/sqrt(2*10);
                    0. 0. -5/sqrt(5*10) 1. 0. 0.;
                    0. -2/sqrt(2*5) 0. 0. 1. 0.;
                    0. 0. -2/sqrt(2*10) 0. 0. 1.]
    )

    @testset "undirected graph" begin
        adjm = [0 1 0 1;
                1 0 1 0;
                0 1 0 1;
                1 0 1 0]
        deg = [2 0 0 0;
               0 2 0 0;
               0 0 2 0;
               0 0 0 2]
        isd = [√2, √2, √2, √2]
        lap = [2 -1 0 -1;
               -1 2 -1 0;
               0 -1 2 -1;
               -1 0 -1 2]
        norm_lap = [1. -.5 0. -.5;
                    -.5 1. -.5 0.;
                    0. -.5 1. -.5;
                    -.5 0. -.5 1.]
        scaled_lap = [0 -0.5 0 -0.5;
                      -0.5 0 -0.5 -0;
                      0 -0.5 0 -0.5;
                      -0.5 0 -0.5 0]
        rw_lap = [1 -.5 0 -.5;
                  -.5 1 -.5 0;
                  0 -.5 1 -.5;
                  -.5 0 -.5 1]

        @test GraphSignals.adjacency_matrix(adjm |> gpu, Int32) isa CuMatrix{Int32}
        @test GraphSignals.adjacency_matrix(adjm |> gpu) isa CuMatrix{Int64}

        fg = FeaturedGraph(T.(adjm)) |> gpu
        @test collect(GraphSignals.adjacency_matrix(fg)) == adjm
        @test collect(GraphSignals.degrees(fg; dir=:both)) == [2, 2, 2, 2]
        D = GraphSignals.degree_matrix(fg, T, dir=:out)
        @test collect(D) == T.(deg)
        @test GraphSignals.degree_matrix(fg, T; dir=:in) == D
        @test GraphSignals.degree_matrix(fg, T; dir=:both) == D
        @test eltype(D) == T
        L = Graphs.laplacian_matrix(fg, T)
        @test collect(L) == T.(lap)
        @test eltype(L) == T

        NA = GraphSignals.normalized_adjacency_matrix(fg, T)
        @test collect(NA) ≈ T.(I - norm_lap)
        @test eltype(NA) == T

        NA = GraphSignals.normalized_adjacency_matrix(fg, T, selfloop=true)
        @test eltype(NA) == T

        NL = GraphSignals.normalized_laplacian(fg, T)
        @test collect(NL) ≈ T.(norm_lap)
        @test eltype(NL) == T

        SL = GraphSignals.scaled_laplacian(fg, T)
        @test SL isa CuMatrix{T}
        @test collect(SL) ≈ T.(scaled_lap)
        @test eltype(SL) == T

        # RW = GraphSignals.random_walk_laplacian(fg, T)
        # @test RW == T.(rw_lap)
        # @test eltype(RW) == T
    end

    # @testset "directed" begin
    #     adjm = [0 2 0 3;
    #             0 0 4 0;
    #             2 0 0 1;
    #             0 0 0 0]
    #     degs = Dict(
    #         :out  => diagm(0=>[2, 2, 4, 4]),
    #         :in   => diagm(0=>[5, 4, 3, 0]),
    #         :both => diagm(0=>[7, 6, 7, 4]),
    #     )
    #     laps = Dict(
    #         :out  => degs[:out] - adjm,
    #         :in   => degs[:in] - adjm,
    #         :both => degs[:both] - adjm,
    #     )
    #     norm_laps = Dict(
    #         :out  => I - diagm(0=>[1/2, 1/2, 1/4, 1/4])*adjm,
    #         :in   => I - diagm(0=>[1/5, 1/4, 1/3, 0])*adjm,
    #     )
    #     sig_laps = Dict(
    #         :out  => degs[:out] + adjm,
    #         :in   => degs[:in] + adjm,
    #         :both => degs[:both] + adjm,
    #     )
    #     rw_laps = Dict(
    #         :out  => I - diagm(0=>[1/2, 1/2, 1/4, 1/4]) * adjm,
    #         :in   => I - diagm(0=>[1/5, 1/4, 1/3, 0]) * adjm,
    #         :both => I - diagm(0=>[1/7, 1/6, 1/7, 1/4]) * adjm,
    #     )

    #     for g in [adjm, sparse(adjm)]
    #         for dir in [:out, :in, :both]
    #             D = GraphSignals.degree_matrix(g, T, dir=dir)
    #             @test D == T.(degs[dir])
    #             @test eltype(D) == T

    #             L = Graphs.laplacian_matrix(g, T, dir=dir)
    #             @test L == T.(laps[dir])
    #             @test eltype(L) == T

    #             SL = GraphSignals.signless_laplacian(g, T, dir=dir)
    #             @test SL == T.(sig_laps[dir])
    #             @test eltype(SL) == T
    #         end
    #         @test_throws DomainError GraphSignals.degree_matrix(g, dir=:other)
    #     end

    #     for g in [adjm, sparse(adjm)]
    #         for dir in [:out, :in]
    #             L = normalized_laplacian(g, T, dir=dir)
    #             @test L == T.(norm_laps[dir])
    #             @test eltype(L) == T
    #         end

    #         for dir in [:out, :in, :both]
    #             RW = GraphSignals.random_walk_laplacian(g, T, dir=dir)
    #             @test RW == T.(rw_laps[dir])
    #             @test eltype(RW) == T
    #         end
    #     end
    # end
end
