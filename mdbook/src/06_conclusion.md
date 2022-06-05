# Conclusion

Ocaml's module system is increadibly powerful and functors are a unique way of writing generic code. However, they do not have any concept of automatically choosing the right function for the current context. The user will always have to specify which function from which module they want exactly.

Another issue is that juggling functors, modules and module signatures can get very overwhelming and confusing. Whereas with type classes, we were able to create addition for matrices with varying outputs depending on the outputs of the additions for the matrices' element types, in Ocaml, building a generic matrix implementation even without the ability to have varying element types is already similarly complicated.

It is also rather verbose having to apply functors by hand. It is not possible for Ocaml to automatically apply functors and create unnamed modules out of them (although there are ideas on how to do so in limited cases[^modular-type-classes]), and thus, to define a library for generic matrices, the library will only be able to offer a functor that the user must then apply for every type they want to use inside the matrices. It ends up only being one line of code, but it is still not as fluent as other solutions, not to mention one has to come up with a unique name for every one of the resulting modules.

On the other hand, one thing that neither Haskell nor Rust were able to do was to convey the generic idea of a *matrix*. Both in Haskell and Rust, we were able to be generic over the elements of the matrix, **not** the implementation of it. In Ocaml, thanks to the fact that we can define a generic `Matrix` module signature, wherein we can keep the format of the matrix undefined, we were also able to create functors for both dense and sparse matrices.

In Rust for example, defining a sparse matrix would mean to define a whole new separate struct with no correlation to the dense matrix struct. A general `Matrix` trait would be difficult to define, as Rust's dynamic dispatch system is rather verbose to work with (not to mention it's not idiomatic), and there is no way to define the structure of a struct from within a trait.

> Dynamic dispatch is when the choice, which overloaded function is picked, happens at runtime and not compile time. In Rust this is done by using *trait objects* and the `dyn` keyword.

As such, it shall be mentioned that Ocaml modules aren't a direct equivalent to the notion of "Ocaml's type classes". In reality, Ocaml modules sit at a higher level. As the name suggest, whereas type classes and traits are essentially interface definitions for singular types, modules in Ocaml can include various types and define how they interact with one another. In that sense, modules in Ocaml sit on the same level of Rust's own modules. It's just with the existence of abstract module signatures as well as functors, that Ocaml modules are also found in the realm of abstract interfaces.

[^modular-type-classes]: ["Modular type classes" by Derek Dreyer, Robert Harper and Manuel M.T. Chakravarty](https://doi.org/10.1145/1190215.1190229)
