# Conclusion

Rust considers itself as not a particularly original language and mentions Haskell's type classes as one of its influences[^rust-reference-20.2]. So it's no surprise that Rust's traits mirror type classes so closely. However, there are still slight differences between the two concepts. As mentioned in ["Associated types"](04_rust.md#associated-types), associated types in Rust are namespaced inside the trait, whereas associated types in Haskell are globally namespaced. Also, Rust ensures that using generics and traits will not add runtime cost, by recompiling functions for each used combination of types individually[^rust-book-10.1]. Haskell does not have such guarantee. Still, type classes and traits are two *very* related concepts.

Moreover, OCaml's module system is increadibly powerful and functors are a unique way of writing generic code. However, it does not offer ad-hoc polymorphism. The user will always have to specify which function from which module they want exactly. Another issue is that juggling functors, modules and module signatures can get very overwhelming and confusing. With type classes, we were able to create addition for matrices with varying outputs depending on the outputs of the additions of the matrices' element types. In OCaml, building a generic matrix implementation even without the ability to have varying element types is already similarly complicated.

It is also rather verbose having to apply functors by hand. It is not possible for OCaml to automatically apply functors and create unnamed modules out of them (although there are ideas on how to do so in limited cases[^modular-type-classes]), and thus, to define a library for generic matrices, the library will only be able to offer a functor that the user must then apply for every type they want to use inside a matrix. It is not as fluent as other solutions, not to mention one has to come up with a unique name for every one of the resulting modules.

On the other hand, neither Haskell nor Rust can convey the generic idea of a *matrix*. In both languages, we are able to be generic over the elements of the matrix, **not** the implementation of it. In OCaml, thanks to the fact that we can define a generic `Matrix` module signature, wherein we can keep the format of the matrix undefined, we were also able to create functors for both dense and sparse matrices.
In Rust for example, defining a sparse matrix would mean to define a whole new separate struct with no correlation to the dense matrix struct. There is no way to define the structure of a struct from within a trait.

It shall be mentioned that OCaml modules aren't a direct equivalent to the notion of "OCaml's type classes". Instead, they sit at a higher level. As the name suggests, modules in OCaml can include various types and define how they interact with one another, whereas type classes and traits are essentially interface definitions for singular types. It's just with the existence of abstract module signatures as well as functors, that OCaml modules are also found in the realm of abstract interfaces.

[^rust-reference-20.2]: ["The Rust Reference"; Chapter 20.2](https://doc.rust-lang.org/reference/influences.html)

[^rust-book-10.1]: ["The Rust Programming Language" by Steve Klabnik and Carol Nichols](https://doc.rust-lang.org/book/ch10-01-syntax.html); Chapter 10.1

[^modular-type-classes]: ["Modular type classes" by Derek Dreyer, Robert Harper and Manuel M.T. Chakravarty](https://doi.org/10.1145/1190215.1190229)
