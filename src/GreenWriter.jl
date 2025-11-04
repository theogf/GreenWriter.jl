module GreenWriter

using AbstractTrees
using JuliaSyntax
using JuliaSyntax: @K_str, GreenNode, parsestmt, span, SyntaxHead, head, is_leaf

export GreenText, print_tree

"A richer version of `GreenNode` with the text contained in the leaves."
struct GreenText
    content
    head::Union{Nothing,SyntaxHead}
    children::Vector{GreenText}
    function GreenText(
        content,
        head::Union{Nothing,SyntaxHead}=nothing,
        children::Vector{GreenText}=GreenText[],
    )
        return new(content, head, children)
    end
end

AbstractTrees.children(node::GreenText) = node.children
function AbstractTrees.nodevalue(node::GreenText)
    return isnothing(node.content) ? node.head.kind : node.content
end
Base.show(io::IO, ::MIME"text/plain", node::GreenText) = print_tree(io, node)
Base.getindex(node::GreenText, i::Integer) = node.children[i]
Base.lastindex(node::GreenText) = length(node.children)
Base.push!(node::GreenText, child::GreenText) = push!(node.children, child)
Base.push!(node::GreenText, text::AbstractString) = push!(node, GreenText(text))
JuliaSyntax.kind(node::GreenText) = node.head
JuliaSyntax.is_leaf(node::GreenText) = isempty(node.children)

function Base.parse(::Type{GreenText}, text::AbstractString)
    green_tree = parseall(GreenNode, text)
    return last(fetch_node_text(green_tree, text, 1))
end

"Map the `GreenNode` syntax tree into a [`GreenText`](@ref) syntax tree node."
function fetch_node_text(node::GreenNode, text::AbstractString, cursor::Int)
    if is_leaf(node)
        text_view = view(text, cursor:thisind(text, cursor + span(node) - 1))

        cursor + span(node), GreenText(text_view, head(node))
    else
        new_children = map(JuliaSyntax.children(node)) do child
            cursor, green_child = fetch_node_text(child, text, cursor)
            green_child
        end
        cursor, GreenText(nothing, head(node), new_children)
    end
end

function Base.string(node::GreenText)
    io = IOBuffer()
    write(io, node)
    return String(take!(io))
end

function Base.write(io::IO, node::GreenText)
    if is_leaf(node)
        print(io, node.content)
    else
        for child in children(node)
            write(io, child)
        end
    end
end

end
