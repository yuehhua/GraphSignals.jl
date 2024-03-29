abstract type AbstractGraphSignal end

struct NullGraphSignal <: AbstractGraphSignal
end

signal(::NullGraphSignal) = nothing
node_feature(::NullGraphSignal) = nothing
edge_feature(::NullGraphSignal) = nothing
global_feature(::NullGraphSignal) = nothing

has_node_feature(::NullGraphSignal) = false
has_edge_feature(::NullGraphSignal) = false
has_global_feature(::NullGraphSignal) = false

nf_dims_repr(::NullGraphSignal) = 0
ef_dims_repr(::NullGraphSignal) = 0
gf_dims_repr(::NullGraphSignal) = 0

check_num_nodes(graph_nv::Real, ::NullGraphSignal) = nothing
check_num_edges(graph_nv::Real, ::NullGraphSignal) = nothing


struct NodeSignal{T} <: AbstractGraphSignal
    signal::T
end

@functor NodeSignal

NodeSignal(::Nothing) = NullGraphSignal()
NodeSignal(::NullGraphSignal) = NullGraphSignal()
NodeSignal(s::NodeSignal) = s

signal(s::NodeSignal) = s.signal
node_feature(s::NodeSignal) = s.signal
has_node_feature(::NodeSignal) = true
nf_dims_repr(s::NodeSignal) = size(s.signal, 1)
check_num_nodes(graph_nv::Real, s::NodeSignal) = check_num_nodes(graph_nv, size(s.signal, 2))


struct EdgeSignal{T} <: AbstractGraphSignal
    signal::T
end

@functor EdgeSignal

EdgeSignal(::Nothing) = NullGraphSignal()
EdgeSignal(::NullGraphSignal) = NullGraphSignal()
EdgeSignal(s::EdgeSignal) = s

signal(s::EdgeSignal) = s.signal
edge_feature(s::EdgeSignal) = s.signal
has_edge_feature(::EdgeSignal) = true
ef_dims_repr(s::EdgeSignal) = size(s.signal, 1)
check_num_edges(graph_ne::Real, s::EdgeSignal) = check_num_edges(graph_ne, size(s.signal, 2))


struct GlobalSignal{T} <: AbstractGraphSignal
    signal::T
end

@functor GlobalSignal

GlobalSignal(::Nothing) = NullGraphSignal()
GlobalSignal(::NullGraphSignal) = NullGraphSignal()
GlobalSignal(s::GlobalSignal) = s

signal(s::GlobalSignal) = s.signal
global_feature(s::GlobalSignal) = s.signal
has_global_feature(::GlobalSignal) = true
gf_dims_repr(s::GlobalSignal) = size(s.signal, 1)
