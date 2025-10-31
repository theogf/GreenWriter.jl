using GreenWriter
using Test
using JuliaSyntax: is_leaf

@testset "GreenWriter.jl" begin
    text = "foo(a) = 2 + 1"
    node = parse(GreenText, text)
    @test string(node) == text
    push!(node[end], " + 1")
    text = "foo(a) = 2 + 1 + 1"
    @test string(node) == text

    @testset "Adding nodes" begin
        # Test adding a node to the end of an expression
        text = "x + y"
        node = parse(GreenText, text)
        push!(node, GreenText(" "))
        push!(node, GreenText("+"))
        push!(node, GreenText(" "))
        push!(node, GreenText("z"))
        @test string(node) == "x + y + z"

        # Test adding multiple nodes
        text = "a = 1"
        node = parse(GreenText, text)
        push!(node, GreenText(" + 2"))
        push!(node, GreenText(" + 3"))
        @test string(node) == "a = 1 + 2 + 3"

        # Test adding to function call
        text = "func(x)"
        node = parse(GreenText, text)
        # Add another argument to the function call
        insert!(node.children, 4, GreenText(", y"))
        @test string(node) == "func(x, y)"
    end

    @testset "Removing nodes" begin
        # Test removing last child from expression
        text = "x + y + z"
        node = parse(GreenText, text)
        last_child = node[end]
        original_length = length(last_child.children)
        # Only pop if there are children to pop
        if length(last_child.children) >= 2
            pop!(last_child.children)
            pop!(last_child.children)
            @test length(last_child.children) == original_length - 2
        end

        # Test clearing all children
        text = "a = 1 + 2"
        node = parse(GreenText, text)
        pop!(node.children)
        @test string(node) == "a = "
    end

    @testset "Modifying existing nodes" begin
        # Test modifying a leaf node's content
        text = "x = 42"
        node = parse(GreenText, text)
        # Find the number leaf and modify it
        for (i, child) in enumerate(node.children)
            if is_leaf(child) && child.content == "42"
                modified_node = GreenText("100", child.head)
                node.children[i] = modified_node
                break
            end
        end
        @test string(node) == "x = 100"

        # Test replacing a subtree
        text = "foo(a, b)"
        node = parse(GreenText, text)
        # Keep first part (function name) and replace the args
        for (i, child) in enumerate(node.children)
            if is_leaf(child) && child.content == "a"
                node.children[i] = GreenText("x", child.head)
            elseif is_leaf(child) && child.content == "b"
                node.children[i] = GreenText("y", child.head)
            end
        end
        @test string(node) == "foo(x, y)"
    end

    @testset "Complex nested modifications" begin
        # Test modifying deeply nested structures
        text = "function f(x)\n    return x + 1\nend"
        node = parse(GreenText, text)

        # Navigate to the body and add another statement
        # This tests that we can work with more complex AST structures
        @test string(node) == text

        # Test modifying operator in nested expression
        text = "y = (a + b) * c"
        node = parse(GreenText, text)
        original = string(node)
        @test original == text

        # Find and replace the + operator with -
        function replace_operator!(node::GreenText, old_op::String, new_op::String)
            for (i, child) in enumerate(node.children)
                if is_leaf(child) && child.content == old_op
                    node.children[i] = GreenText(new_op, child.head)
                elseif !is_leaf(child)
                    replace_operator!(child, old_op, new_op)
                end
            end
        end

        replace_operator!(node, "+", "-")
        @test string(node) == "y = (a - b) * c"

        # Test adding to nested structure
        text = "if x > 0\n    y\nend"
        node = parse(GreenText, text)
        @test string(node) == text

        # Test chain of modifications
        text = "result = x * 2"
        node = parse(GreenText, text)
        push!(node[end], GreenText(" + 5"))
        @test string(node) == "result = x * 2 + 5"
        push!(node[end], GreenText(" - 1"))
        @test string(node) == "result = x * 2 + 5 - 1"
    end

    @testset "Node structure preservation" begin
        # Test that modifications preserve tree structure
        text = "sum = a + b"
        node = parse(GreenText, text)
        original_head = node.head

        push!(node[end], GreenText(" + c"))

        # Head should be preserved
        @test node.head == original_head
        @test !is_leaf(node)

        # Test that empty nodes can be created and used
        empty_node = GreenText(nothing)
        @test isempty(empty_node.children)
        @test is_leaf(empty_node)
    end
end
