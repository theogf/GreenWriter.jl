module GreenWriter

using AbstractTrees
using JuliaSyntax
using JuliaSyntax: @K_str, GreenNode, parseall, span, SyntaxHead, head, is_leaf

export GreenText, print_tree

struct GreenText
  content
  head::Union{Nothing, SyntaxHead}
  children::Vector{GreenText}
  function GreenText(content, head::Union{Nothing, SyntaxHead} = nothing, children::Vector{GreenText} = GreenText[])
    new(content, head, children)
  end
end

AbstractTrees.children(node::GreenText) = node.children
AbstractTrees.nodevalue(node::GreenText) = isnothing(node.content) ? node.head.kind : node.content
Base.show(io::IO, ::MIME"text/plain", node::GreenText) = print_tree(io, node)
Base.getindex(node::GreenText, i::Integer) = node.children[i]
Base.push!(node::GreenText, child::GreenText) = push!(node.children, child)
JuliaSyntax.kind(node::GreenText) = node.head
JuliaSyntax.is_leaf(node::GreenText) = isempty(node.children)

function GreenText(text::AbstractString)
  green_tree = parseall(GreenNode, text)
  last(fetch_node_text(green_tree, text, 1)) 
end

function fetch_node_text(node::GreenNode, text::AbstractString, cursor::Int)
  if is_leaf(node)
    text_view = view(text, cursor:(cursor + span(node) - 1))
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
  String(take!(io))  
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
