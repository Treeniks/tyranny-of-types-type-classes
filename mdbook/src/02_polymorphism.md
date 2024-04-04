# Types of Polymorphism

As defined by Benjamin C. Pierce[^pierce-types-23.2], a polymorphic type system refers to a type system that allows a single piece of code to be used with multiple types. There are several varieties of polymorphism, of which we will cover two.

## Parametric Polymorphism

Parametric polymorphism is the idea that a function's input types can be parameters, where the exact type inserted in these parameters is irrelevant for the function's semantics. That means that *any* type can be inserted[^pierce-types-23.2].

This is best understood by a common example for parametric polymorphism, the length function for lists in functional languages. For this, we will look at how such a function could look like in OCaml:

```ocaml
let rec length l =
  match l with
  | [] -> 0
  | x::xs -> 1 + length xs
```
The inferred type of length would then be
```ocaml
val length : 'a list -> int
```
where `'a` is a type parameter. The important thing to understand about parametric polymorphism is that the actual value of `'a` is irrelevant to how this function operates. This means that there must not be more than one implementation of `length` for different concrete instantiations of `'a`. Instead there is exactly one implementation and it can be called for all types of lists with the same semantics.

The reason this works is that we don't ever infer what the type of `x` inside the function should be. To determine the length of a list, the type of the list's elements is irrelevant.

The compiler might still be free to compile different versions of this function, depending on what types the function is called with. Depending on how lists are implemented, small parts of the list might be laid out in memory as arrays[^functional-lists], which means that the act of getting the next value in the list requires the compiler to know the size of `'a`. However, this is hidden from the programmer and not relevant for the language definition.

The problem with parametric polymorphism is that it is inherently useless for functions that should have different implementations for different types, and potentially no implementation for some types. The obvious example for this case would be operator overloading, such as a `(+)` function that does addition.


In OCaml, this is solved by having a different operator for different data types, for example `(+)` for `int`s and `(+.)` for `float`s. The equality check function `(=)` is handled special in OCaml, in that every type automatically implements it. Thus the function is parametrically typed as
```ocaml
val (=) : 'a -> 'a -> bool
```
and the implementation of this function is handled by the compiler and runtime system. Because this is the type of the `(=)` function, OCaml will not give you a compile time error if you happen to try to check two functions for equality, even though functions can not generally be checked for equality. OCaml can only throw an exception at runtime in such cases.

## Ad-hoc Polymorphism

Ad-hoc polymorphism is the idea of overloading functions for different types[^pierce-types-23.2]. This means one can have one implementation for a specific set of types, but potentially a different implementation, including none, for a different set of types. This fixes the aforementioned problem of parametric polymorphism. Operator overloading in particular is a common use case for ad-hoc polymorphism. It allows to have different implementations of `(+)`, both for `int -> int -> int` and `float -> float -> float`.

However, the exact implementation for ad-hoc polymorphism in a language is not necessarily trivial. If one were to write `(+) x y` inside their code, the compiler must now be able to determine which `(+)` should be called. It needs to figure this out from the types of `x` and `y`, whereas before it was always unambiguous what function `(+)` refers to. While this is still reasonably simple when `x` and `y` are variables or constants with a defined type, once `x` and `y` are themselves parameters with polymorphic types, the amount of functions that need to be created is potentially exponential[^type-classes-original].

See for example an `add2` function that is defined like so:
```ocaml
let add2 (x1, x2) (y1, y2) = (x1 + y1, x2 + y2)
```
Assuming that `(+)` is defined for both `int` and `float`, then there are four possible types for `add2`:
```ocaml
val add2 : int * int -> int * int -> int * int
val add2 : int * float -> int * float -> int * float
val add2 : float * int -> float * int -> float * int
val add2 : float * float -> float * float -> float * float
```
This can grow exponentially and becomes inefficient. Thus, implementations of ad-hoc polymorphism typically have clever ways of circumventing this kind of blowup.

One way is to use a system of dynamic dispatch as seen in Java, another is to make heavy use of higher order functions as seen in Haskell[^type-classes-original]. Both approaches work on a similar idea: One must first define a sort of *standard* for the `(+)` function we can group the implemented types under. For the sake of example, we will call types that implement `(+)` *addable*. I.e. `int` and `float` are *addable*s. Then we can built a system to tell the compiler that `add2` is defined for parameters whose types are *addable*s. Whenever we define a type as *addable*, i.e. implement the `(+)` function, we also create a dictionary with information about where to find the implemented function. Since we standardized the `(+)` function under the *addable* interface, these dictionaries will look the same for every *addable* type. When calling `add2`, all we need to do is also pass the appropriate dictionary to `add2`. `add2` then uses that dictionary to find the appropriate `(+)` function and call it for the arguments. That way, only one implementation for `add2` is needed to cover all *addable* types and there is no exponential blowup. However, depending on what solution is used, there may be a runtime overhead involved.

[^pierce-types-23.2]: ["Types and programming languages" by Benjamin C. Pierce](https://www.cis.upenn.edu/~bcpierce/tapl/); Chapter 23.2

[^functional-lists]: ["Fast Functional Lists" by Phil Bagwell](https://doi.org/10.1007/3-540-44854-3_3)

[^type-classes-original]: ["How to make ad-hoc polymorphism less ad hoc" by Philip Wadler and Stephen Blott](https://doi.org/10.1145/75277.75283)
