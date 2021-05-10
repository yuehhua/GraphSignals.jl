# Edge-indexing Strucutre

An edge-indexing data strucutre is designed for message-passing neural network. Message-passing neural network requires to access neighbor information for each vertex. Messages are passed from a vertex's neighbors to itself. A efficient indexing data structure is required to access incident edges or neighbor vertices from a specific vertex.

## EdgeIndex

`EdgeIndex` accepts adjacency matrix, adjacency list, and almost all graphs defined in JuliaGraphs. It is construcuted into an indexed adjacency list, which is the modified adjacency list with edge index.

```julia
julia> using LightGraphs

julia> ug = SimpleGraph(4)
{4, 0} undirected simple Int64 graph

julia> add_edge!(ug, 1, 2); add_edge!(ug, 1, 3); add_edge!(ug, 1, 4);

julia> add_edge!(ug, 2, 3); add_edge!(ug, 3, 4);

julia> ei = EdgeIndex(ug)
EdgeIndex(Graph with (#V=4, #E=5))

julia> ei.iadjl
4-element Vector{Vector{Tuple{Int64, Int64}}}:
 [(2, 1), (3, 2), (4, 3)]
 [(1, 1), (3, 4)]
 [(1, 2), (2, 4), (4, 5)]
 [(1, 3), (3, 5)]
```

The indexed adjacency list is a list of list strucutre. The inner list consists of a series of tuples containing a vertex index and a edge index, respectively.

```julia
julia> nv(ei)
4

julia> ne(ei)
5
```

Number of vertices `nv` and number of edges `ne` are compatible with JuliaGraphs.

```julia
julia> neighbors(ei, 2)
2-element Vector{Tuple{Int64, Int64}}:
 (1, 1)
 (3, 4)
```

To get neighbors of a specified vertex, `neighbors` is used by passing a `EdgeIndex` object and a vertex index. A tuple is returned and it consists of a neighbor vertex index and a edge index.

```julia
julia> get(ei, (2, 1))
1

julia> get(ei, (2, 2))

julia> get(ei, (2, 2), 0)
0
```

To get an edge index, it can be queried by `get`, which need a `EdgeIndex` object and a pair of vertex index representing a edge. If the queried edge does not exist, it returns `nothing` by default. The default return value can be changed by passing desired value as third argument.

`EdgeIndex` accepts `FeaturedGraph` as well. It takes graph in `FeaturedGraph` and construct a `EdgeIndex` object.

```julia
julia> fg = FeaturedGraph(ug)
FeaturedGraph(
	Undirected graph with (#V=4, #E=5) in SimpleGraph{Int64} <SimpleGraph{Int64}>,
)

julia> ei = EdgeIndex(fg)
EdgeIndex(Graph with (#V=4, #E=5))
```

## EdgeIndex APIs

```@docs
EdgeIndex
```

```@docs
GraphSignals.get
```

```@docs
edge_scatter
```

```@docs
neighbor_scatter
```
