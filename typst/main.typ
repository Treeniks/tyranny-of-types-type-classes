#set heading(numbering: "1.")

#let title = [
  Comparing Haskell's Type Classes to Rust's Traits and OCaml's Modules
]

#align(center, text(17pt)[
    *#title*
])

#align(center, [
    Thomas Lindae \
    Technical University of Munich \
    #link("mailto:thomas.lindae@tum.de")
])

#set par(justify: true)

#align(center)[
    *Abstract* \
    There are many ways to abstract functionality in programming languages. One important idea of abstraction is the notion of interfaces defining functionality for abstract types. Modern languages offer different approaches to such interfaces, some focus on data abstraction, while others focus on supporting ad-hoc polymorphism. We will see the differences between parametric and ad-hoc polymorphism. Furthermore we will look at three approaches to the concept of interfaces: Haskell type classes, the type class-inspired Rust traits and OCaml's ML-inherited module system, and find them to have many similarities.
]

// Unfortunately, it is currently not possible to "undo" this column settings
// meaning the figures that are supposed to span the whole width of the page
// would be stuck within the columns as well. :(
// #show: columns.with(2)

#set text(11pt)

= Introduction

Programmers are lazy. That is why they tend to spend a lot of time coming up with and developing programming language concepts that allow them to write less code for the same results, and then let the compiler do the rest of the work. Few of those convey that idea better than the concept of polymorphism, a term describing the reusing of functions and methods for varying data types.

There are many different forms of polymorphism, and in this paper we will briefly look at two of them: Parametric and ad-hoc polymorphism. Ad-hoc polymorphism is primarily used by object oriented programming languages, whereas parametric polymorphism is more well known by its use in functional languages. However, as languages have matured and gained features, most modern languages have their own concepts for both.

Afterwards we will look at one particular implementation of ad-hoc polymorphism: Type Classes. We will find that the concept of type classes also offers a way to define an interface on custom data types and thus compare them to other language interface concepts, in particular Rust Traits and OCaml Modules.

#include("02_polymorphism.typ")

#include("03_haskell.typ")

#include("04_rust.typ")

#include("05_ocaml.typ")

= Conclusion

Rust considers itself as not a particularly original language and mentions Haskell's type classes as one of its influences~@rust-reference[Chapter~20.2]. So it's no surprise that Rust's traits mirror type classes so closely. However, there are still slight differences between the two concepts. As mentioned in @rust-associated-types, associated types in Rust are namespaced inside the trait, whereas associated types in Haskell are globally namespaced. Also, Rust ensures that using generics and traits will not add runtime cost, by recompiling functions for each used combination of types individually~@rust-book[Chapter~10.1]. Haskell does not have such guarantee. Still, type classes and traits are two _very_ related concepts.

Moreover, OCaml's module system is increadibly powerful and functors are a unique way of writing generic code. However, it does not offer ad-hoc polymorphism. The user will always have to specify which function from which module they want exactly. Another issue is that juggling functors, modules and module signatures can get very overwhelming and confusing. With type classes, we were able to create addition for matrices with varying outputs depending on the outputs of the additions of the matrices' element types. In OCaml, building a generic matrix implementation even without the ability to have varying element types is already similarly complicated.

It is also rather verbose having to apply functors by hand. It is not possible for OCaml to automatically apply functors and create unnamed modules out of them (although there are ideas on how to do so in limited cases~@modular-type-classes), and thus, to define a library for generic matrices, the library will only be able to offer a functor that the user must then apply for every type they want to use inside a matrix. It is not as fluent as other solutions, not to mention one has to come up with a unique name for every one of the resulting modules.

On the other hand, neither Haskell nor Rust can convey the generic idea of a _matrix_. In both languages, we are able to be generic over the elements of the matrix, *not* the implementation of it. In OCaml, thanks to the fact that we can define a generic `Matrix` module signature, wherein we can keep the format of the matrix undefined, we were also able to create functors for both dense and sparse matrices. In Rust for example, defining a sparse matrix would mean to define a whole new separate struct with no correlation to the dense matrix struct. There is no way to define the structure of a struct from within a trait.

It shall be mentioned that OCaml modules aren't a direct equivalent to the notion of "OCaml's type classes". Instead, they sit at a higher level. As the name suggests, modules in OCaml can include various types and define how they interact with one another, whereas type classes and traits are essentially interface definitions for singular types. It's just with the existence of abstract module signatures as well as functors, that OCaml modules are also found in the realm of abstract interfaces.

#bibliography("biblio.bib")
