function adjacency_matrix(adj::AbstractMatrix{T}, ::Type{S}) where {T,S}
    _dim_check(adj)
    return Matrix{S}(adj)
end

function adjacency_matrix(adj::AbstractMatrix)
    _dim_check(adj)
    return Array(adj)
end

adjacency_matrix(adj::Matrix{T}, ::Type{T}) where {T} = adjacency_matrix(adj)

function adjacency_matrix(adj::Matrix)
    _dim_check(adj)
    return adj
end

function _dim_check(adj)
    m, n = size(adj)
    (m == n) || throw(DimensionMismatch("adjacency matrix is not a square matrix: ($m, $n)"))
end


"""
    degrees(g, [T=eltype(g)]; dir=:out)

Degree of each vertex. Return a vector which contains the degree of each vertex in graph `g`.

# Arguments

- `g`: should be a adjacency matrix, `SimpleGraph`, `SimpleDiGraph` (from Graphs) or
    `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: result element type of degree vector; default is the element type of `g` (optional).
- `dir`: direction of degree; should be `:in`, `:out`, or `:both` (optional).

# Examples

```jldoctest
julia> using GraphSignals

julia> m = [0 1 1; 1 0 0; 1 0 0];

julia> GraphSignals.degrees(m)
3-element Vector{Int64}:
 2
 1
 1
```
"""
function degrees(g, ::Type{T}=eltype(g); dir::Symbol=:out) where {T}
    adj = adjacency_matrix(g, T)
    if issymmetric(adj)
        d = vec(sum(adj, dims=1))
    else
        if dir == :out
            d = vec(sum(adj, dims=1))
        elseif dir == :in
            d = vec(sum(adj, dims=2))
        elseif dir == :both
            d = vec(sum(adj, dims=1)) + vec(sum(adj, dims=2))
        else
            throw(ArgumentError("dir only accept :in, :out or :both, but got $(dir)."))
        end
    end
    return T.(d)
end

"""
    degree_matrix(g, [T=eltype(g)]; dir=:out, squared=false, inverse=false)

Degree matrix of graph `g`. Return a matrix which contains degrees of each vertex in its diagonal.
The values other than diagonal are zeros.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
- `squared::Bool`: To return a squared degree vector or not.
- `inverse::Bool`: To return a inverse degree vector or not.

# Examples

```jldoctest
julia> using GraphSignals

julia> m = [0 1 1; 1 0 0; 1 0 0];

julia> GraphSignals.degree_matrix(m)
3×3 LinearAlgebra.Diagonal{Int64, Vector{Int64}}:
 2  ⋅  ⋅
 ⋅  1  ⋅
 ⋅  ⋅  1
```
"""
function degree_matrix(g, ::Type{T}=eltype(g);
                       dir::Symbol=:out, squared::Bool=false, inverse::Bool=false) where {T}
    d = degrees(g, T, dir=dir)
    squared && (d .= sqrt.(d))
    inverse && (d .= safe_inv.(d))
    return Diagonal(T.(d))
end

safe_inv(x::T) where {T} = ifelse(iszero(x), zero(T), inv(x))

@doc raw"""
    normalized_adjacency_matrix(g, [T=float(eltype(g))]; selfloop=false)

Normalized adjacency matrix of graph `g`, defined as

```math
D^{-\frac{1}{2}} \tilde{A} D^{-\frac{1}{2}}
```

where ``D`` is degree matrix and ``\tilde{A}`` is adjacency matrix w/o self loop from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `selfloop`: Adding self loop to ``\tilde{A}`` or not.
"""
function normalized_adjacency_matrix(g, ::Type{T}=float(eltype(g));
                                     selfloop::Bool=false) where {T}
    adj = adjacency_matrix(g, T)
    selfloop && (adj += I)
    inv_sqrtD = degree_matrix(g, T, dir=:both, squared=true, inverse=true)
    return inv_sqrtD * adj * inv_sqrtD
end

"""
    laplacian_matrix(g, [T=eltype(g)]; dir=:out)

Laplacian matrix of graph `g`, defined as

```math
D - A
```

where ``D`` is degree matrix and ``A`` is adjacency matrix from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
"""
Graphs.laplacian_matrix(g, ::Type{T}=eltype(g); dir::Symbol=:out) where {T} =
    degree_matrix(g, T, dir=dir) - adjacency_matrix(g, T)

@doc raw"""
    normalized_laplacian(g, [T=float(eltype(g))]; dir=:both, selfloop=false)

Normalized Laplacian matrix of graph `g`, defined as

```math
I - D^{-\frac{1}{2}} \tilde{A} D^{-\frac{1}{2}}
```

where ``D`` is degree matrix and ``\tilde{A}`` is adjacency matrix w/o self loop from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
- `selfloop::Bool`: Adding self loop to ``\tilde{A}`` or not.
"""
function normalized_laplacian(g, ::Type{T}=float(eltype(g));
                              dir::Symbol=:both, selfloop::Bool=false) where {T}
    L = adjacency_matrix(g, T)
    if dir == :both
        selfloop && (L += I)
        inv_sqrtD = degree_matrix(g, T, dir=:both, squared=true, inverse=true)
        L .= I - inv_sqrtD * L * inv_sqrtD
    else
        inv_D = degree_matrix(g, T, dir=dir, inverse=true)
        L .= I - inv_D * L
    end
    return L
end

@doc raw"""
    scaled_laplacian(g, [T=float(eltype(g))])

Scaled Laplacien matrix of graph `g`, defined as

```math
\hat{L} = \frac{2}{\lambda_{max}} \tilde{L} - I
```

where ``\tilde{L}`` is the normalized Laplacian matrix.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
"""
function scaled_laplacian(g, ::Type{T}=float(eltype(g))) where {T}
    adj = adjacency_matrix(g, T)
    # @assert issymmetric(adj) "scaled_laplacian only works with symmetric matrices"
    E = eigen(Symmetric(Array(adj))).values
    return T(2. / maximum(E)) .* normalized_laplacian(adj, T) - I
end

"""
    transition_matrix(g, [T=float(eltype(g))]; dir=:out)

Transition matrix of performing random walk over graph `g`, defined as

```math
D^{-1} A
```

where ``D`` is degree matrix and ``A`` is adjacency matrix from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
"""
function transition_matrix(g, ::Type{T}=float(eltype(g)); dir::Symbol=:out) where {T}
    inv_D = degree_matrix(g, T; dir=dir, inverse=true)
    A = adjacency_matrix(g, T)
    return inv_D * A
end

"""
    random_walk_laplacian(g, [T=float(eltype(g))]; dir=:out)

Random walk normalized Laplacian matrix of graph `g`, defined as

```math
I - D^{-1} A
```

where ``D`` is degree matrix and ``A`` is adjacency matrix from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
"""
random_walk_laplacian(g, ::Type{T}=float(eltype(g)); dir::Symbol=:out) where {T} =
    SparseMatrixCSC(I - transition_matrix(g, T, dir=dir))

"""
    signless_laplacian(g, [T=eltype(g)]; dir=:out)

Signless Laplacian matrix of graph `g`, defined as

```math
D + A
```

where ``D`` is degree matrix and ``A`` is adjacency matrix from `g`.

# Arguments

- `g`: Should be a adjacency matrix, `FeaturedGraph`, `SimpleGraph`, `SimpleDiGraph` (from Graphs)
    or `SimpleWeightedGraph`, `SimpleWeightedDiGraph` (from SimpleWeightedGraphs).
- `T`: The element type of result degree vector. The default type is the element type of `g`.
- `dir::Symbol`: The way to calculate degree of a graph `g` regards its directions.
    Should be `:in`, `:out`, or `:both`.
"""
signless_laplacian(g, ::Type{T}=eltype(g); dir::Symbol=:out) where {T} =
    degree_matrix(g, T, dir=dir) + adjacency_matrix(g, T)
