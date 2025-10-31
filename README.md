# GreenWriter

[![Build Status](https://github.com/theogf/GreenWriter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/theogf/GreenWriter.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Description

GreenWriter.jl is meant to be an extension to [JuliaSyntax.jl](https://github.com/JuliaLang/JuliaSyntax.jl) and more specifically to its `GreenNode` objects.

When parsing a text or document with `GreenNode` the `String` equivalent is stored as relative pointer to the document.
While extremely efficient it does not allow to manipulate the given tree and convert it back to a text.

`GreenWriter` provide the `GreenText` node which wraps the `GreenNode` and additionally keep track of the text, this allows to add, delete and modify existing nodes easily.
Note that only the leafs contain text.

## Usage

### Building a `GreenText`

Use `parse(GreenText, text)` to get a `GreenText` root node.
`GreenText` follows the `AbstractTrees` interface so you can call `print_tree` (exported) to visualize your complete tree.

### Converting back to text

You can either call `string(greentext)` or use the more general `write(io, ::GreenText)`
