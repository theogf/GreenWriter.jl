using GreenWriter
using Test

@testset "GreenWriter.jl" begin
    text = "foo(a) = 2 + 1"
    node = parse(GreenText, text)
    @test string(node) == text
    push!(node[end], " + 1")
    text = "foo(a) = 2 + 1 + 1"
    @test string(node) == text
end
