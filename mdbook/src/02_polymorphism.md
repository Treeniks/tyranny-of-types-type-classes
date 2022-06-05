# Types of Polymorphism

## Parametric Polymorphism

Parametric polymorphism is the idea that a function's input and/or output types can be parameters, where the exact type inserted in these parameters is irrelevant for the function's semantics. That means that *any* type can be inserted[^pierce-types].

This is best understood by the most common example for parametric polymorphism, the length function for lists in functional languages. For this, we will look at how such a function could look like in Ocaml:
```ocaml
let rec length l = match l with [] -> 0 | x::xs -> 1 + length xs
```
The inferred type of length would then be this:
```ocaml
val length : 'a list -> int
```
with the type parameter `'a`. The important thing to understanding parametric polymorphism is that the actual value of `'a` is irrelevant for how this function operates. This means that there must not be more than one implementation of `length` for different `'a`s, there is exactly one and it can be called for all types inserted into `'a` with the same semantics.

The reason this works is that we don't ever infer what the type of `x` inside the function should be. And this also makes logical sense: To determine the length of a list, we don't care about the types of the contents of that list, and we don't need to know it to determine its length.

Mind you that the compiler might still be free to compile different versions of this function, depending on what types the function is called with. Depending on how lists are implemented, small parts of the list might be laid out in memory as arrays[^functional-lists], which means that the act of getting the next value in the list requires the compiler to know the size of `'a`. However, this is hidden from the programmer and not relevant for the language definition.

The problem with parametric polymorphism is that it is inherently useless for functions that should have different implementations for different types, and potentially no implementation for some types. The obvious example for this case would be operator overloading, such as a `(+)` or a `(=)` function that does addition or checks for equality respectively.

In Ocaml, this is solved by having a different operator for different data types, for example `(+)` for `int`s and `(+.)` for `float`s. The equality check function `(=)` is handled special in Ocaml, in that every type automatically implements it. Thus the function is parametrically typed as
```ocaml
val (=) : 'a -> 'a -> bool
```
and the actual implementation of this function is then handled by the compiler and runtime system. Because this is the type of the `(=)` function, Ocaml will not give you a compile time error if you happen to try to check two functions for equality, even though functions can not generally be checked for equality. Ocaml has to throw an exception at runtime in such cases.

[^pierce-types]: ["Types and Programming Languages" by Benjamin C. Pierce](https://www.cis.upenn.edu/~bcpierce/tapl) - Chapter 23.2

[^functional-lists]: ["Fast Functional Lists" by Phil Bagwell](https://doi.org/10.1007/3-540-44854-3_3)

## Ad-hoc Polymorphism

Ad-hoc polymorphism is the idea of overloading functions for different types. This means one can have one implementation for a specific set of types, but potentially a different implementation, including none, for a different set of types.

This fixes the aforementioned problem of parametric polymorphism. Operator overloading in particular is a common example for what ad-hoc polymorphism can do. It is now thinkable to have an implementation of `(+)` for both `int -> int -> int` and `float -> float -> float`.

However, the exact implementation for ad-hoc polymorphism in a language is not necessarily trivial. If one were to write `(+) x y` inside their code, the compiler must now have special logic to determine which `(+)` should be called. It needs to figure this out from the types of `x` and `y`, whereas before it was always unambiguous what function `(+)` refers to.

While this is still reasonably simple for when `x` and `y` are variables or constants with a defined type, once `x` and `y` are themselves parameters with polymorphic types, the amount of functions that need to be created is potentially exponential[^type-classes-original].

See for example an `add2` function that is defined like so:
```ocaml
let add2 (x1, x2) (y1, y2) = (x1 + y1, x2 + y2)
```
And assuming that `(+)` is defined for `int` and `float`, then the amount of types `add2` can have is 4:
```ocaml
val add2 : int * int -> int * int -> int * int
val add2 : int * float -> int * float -> int * float
val add2 : float * int -> float * int -> float * int
val add2 : float * float -> float * float -> float * float
```
This can grow exponentially and becomes unrealistic. Thus, implementations of ad-hoc polymorphism typically have clever ways of circumventing this kind of blowup.

One way would be to use a system of dynamic dispatch, another would be to make heavy use of higher order functions[^type-classes-original], both of which are used in languages like Java and Haskell respectively.

Both solutions work on a similar idea: One must first define a sort of *standard* for the `(+)` function we can group the implemented types under. For the sake of example, let's call types that implement `(+)` *addable*. I.e. `int` and `float` are *addable*s. Then we can built a system to tell the compiler that `add2` is defined for parameters whose types are *addable*s. Whenever we define a type as *addable*, i.e. implement the `(+)` function, we also create a dictionary with information about where to find the implemented function. Since we standardized the `(+)` function under the *addable* interface, these dictionaries will look the same for every *addable* type. Thus, when calling `add2`, all we need to do is *also* pass the appropriate dictionary to `add2`.

What `add2` then has to do is use that dictionary to find the appropriate `(+)` function and call it for the arguments. That way, only one implementation for `add2` is needed to cover all *addable* types and there is no exponential blowup.

Mind you that, depending on what solution is used, there may be a runtime overhead involved.

[^type-classes-original]: ["How to make ad-hoc polymorphism less ad hoc" by Philip Wadler and Stephen Blott](https://doi.org/10.1145/75277.75283)
