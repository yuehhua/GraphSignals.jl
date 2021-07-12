# FeaturedGraph

## Construct a FeaturedGraph and graph representations

A `FeaturedGraph` is aimed to represent a composition of graph representation and graph signals. A graph representation is required to construct a `FeaturedGraph` object. Graph representation can be accepted in several forms: adjacency matrix, adjacency list or graph representation provided from JuliaGraphs.

```julia
julia> adj = [0 1 1;
              1 0 1;
              1 1 0]
3×3 Matrix{Int64}:
 0  1  1
 1  0  1
 1  1  0

julia> FeaturedGraph(adj)
FeaturedGraph{Matrix{Int64}, FillArrays.Fill{Int64, 2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}, FillArrays.Fill{Int64, 2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}, FillArrays.Fill{Int64, 1, Tuple{Base.OneTo{Int64}}}}([0 1 1; 1 0 1; 1 1 0], 0×3 Fill{Int64}: entries equal to 0, 0×3 Fill{Int64}: entries equal to 0, 0-element Fill{Int64}: entries equal to 0, 3×3 Fill{Int64}: entries equal to 0, :adjm, false)
```

Currently, `SimpleGraph` and `SimpleDiGraph` from LightGraphs.jl, `SimpleWeightedGraph` and `SimpleWeightedDiGraph` from SimpleWeightedGraphs.jl, as well as `MetaGraph` and `MetaDiGraph` from MetaGraphs.jl are supported.

If a graph representation is not given, a `FeaturedGraph` object will be regarded as a `NullGraph`. A `NullGraph` object is just used as a special case of `FeaturedGraph` to represent a null object.

```julia
julia> FeaturedGraph()
NullGraph()
```

## Graph Signals

Graph signals is a collection of any signals defined on a graph. Graph signals can be the signals related to vertex, edges or graph itself. If a vertex signal is given, it is recorded as a node feature in `FeaturedGraph`. A node feature is stored as the form of generic array, of which type is `AbstractArray`. A node feature can be indexed by the node index, which is the same as indexing a node on pre-defined graph. 

If you 

```julia
julia> fg = FeaturedGraph(adj)
FeaturedGraph{Matrix{Int64}, FillArrays.Fill{Int64, 2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}, FillArrays.Fill{Int64, 2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}, FillArrays.Fill{Int64, 1, Tuple{Base.OneTo{Int64}}}}([0 1 1; 1 0 1; 1 1 0], 0×3 Fill{Int64}: entries equal to 0, 0×3 Fill{Int64}: entries equal to 0, 0-element Fill{Int64}: entries equal to 0, 3×3 Fill{Int64}: entries equal to 0, :adjm, false)

julia> fg.nf = rand(5, 3)
```

In general, a node feature can be optional in constructing a `FeaturedGraph`. `FeaturedGraph` is designed to be mutable, so a node feature is allowed to assigned after construction.

```julia

```

## FeaturedGraph APIs

### FeaturedGraph constructors

```@docs
NullGraph()
```

```@docs
FeaturedGraph
```

### Getter methods

```@docs
graph
```

```@docs
node_feature
```

```@docs
edge_feature
```

```@docs
global_feature
```

### Check methods

```@docs
has_graph
```

```@docs
has_node_feature
```

```@docs
has_edge_feature
```

```@docs
has_global_feature
```
