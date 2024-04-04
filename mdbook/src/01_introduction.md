# Introduction

Programmers are lazy. That is why they tend to spend a lot of time coming up with and developing programming language concepts that allow them to write less code for the same results, and then let the compiler do the rest of the work. Few of those convey that idea better than the concept of polymorphism, a term describing the reusing of functions and methods for varying data types.

There are many different forms of polymorphism, and in this paper we will briefly look at two of them: Parametric and ad-hoc polymorphism. Ad-hoc polymorphism is primarily used by object oriented programming languages, whereas parametric polymorphism is more well known by its use in functional languages. However, as languages have matured and gained features, most modern languages have their own concepts for both.

Afterwards we will look at one particular implementation of ad-hoc polymorphism: Type Classes. We will find that the concept of type classes also offers a way to define an interface on custom data types and thus compare them to other language interface concepts, in particular Rust Traits and OCaml Modules.
