# Haskell

Haskell supports both parametric and ad-hoc polymorphism.

## Parametric Polymorphism

Parametric polymorphism is achieved the same way it is in Ocaml, that is when writing a function that does not rely on its parameters' types, then one can define the function's type with type parameters.

For example, the list length function:
```haskell
length :: [a] -> Int
length [] = 0
length (x:xs) = 1 + length xs
```
where `a` is the type parameter for the type of the list's elements.

## Ad-hoc Polymorphism: Type Classes

Haskell developed its own system called *type classes* to support ad-hoc polymorphism, because existing solutions weren't suitable in the eyes of the language designers[^type-classes-original].

In its simplest form, a type class is not much more than an interface as seen in object oriented languages:
```haskell
class Eq a where
  (==) :: a -> a -> bool
```
Mind that it's easy to misunderstand the `a` class parameter as being similar to the `a` type parameter used for parametric polymorphism, however this is not the case. Where in the parametric polymorphism case before, `a` stood for *any* type, in this case `a` stands for a *class* or *set* of *specific* types for which instances of `Eq` exist.

This also means that the type class itself so far does nothing. We need to create an instance of the type class for a specific type, for example for `Int`:
```haskell
instance Eq Int where
  (==) x y = eqInt x y
```
assuming `eqInt` is the equality function for integers.

We could also create an instance for a different type, for example for `Float`:
```haskell
instance Eq Float where
  (==) x y = eqFloat x y
```
again, assuming `eqFloat` is the equality function for floats.

When we now try to use the `(==)` function with parameters of types other than `Int` or `Float`, we will get a compile time error.

[^type-classes-original]: ["How to make ad-hoc polymorphism less ad hoc" by Philip Wadler and Stephen Blott](https://doi.org/10.1145/75277.75283)

### Type constraints

So far, we have seen how we can use type classes to overload functions defined *within* the type class, however we can also use them to define standalone functions with types implementing specific type classes.

Assume we want to define some kind of cost to our data types. We can use a type class to convey this idea:
```haskell
class Cost a where
  cost :: a -> Int
```
A possible instance for some custom data type could then look something like this:
```haskell
data Custom = Cheap | Expensive

instance Cost Custom where
  cost Cheap = 0
  cost Expensive = 1
```

Now let's say we want to define a function `cheapest` that takes a list of elements of a type that defines a `cost`, and then return the cheapest element of that list. Such a function could then look like this:
```haskell
cheapest :: Cost a => [a] -> a
cheapest [x] = x
cheapest (x:xs)
  | cost x <= cost y = x
  | otherwise = y
  where y = cheapest xs
```
The important part here is `cheapest`'s type: `Cost a => [a] -> a` means that `cheapest` is a function of type `[a] -> a` for any type `a` that has an instance of `Cost`.

Mind you that the similarities to the parametric polymorphism `a` are a lot more fitting in this case: `a` for the `cheapest` function is also a type parameter where the exact type does not matter for the function. The difference is that, whereas in the case of `length`, any type can be inserted into `a`, for `cheapest` only types that implement a `cost` can be used. This is necessary as the `cost` function is used in the implementation of `cheapest`. This is a natural extension of the parametric polymorphism system Haskell uses and allows for much stronger expressiveness.

### Creating instances from other instances

One particular strength of type classes is that they allow one to create instances based on other existing type class instances. This is best seen with an example.

We'll extend the example from the ["Type constraints"](#type-constraints) section:
We are given a list of `Custom`s and want to determine the overall sum of the list's costs. We could write an instance for `Cost [Custom]`, however this seems rather verbose, especially when assuming we have many different custom types that define a cost, and many different lists of those custom types.

Instead, we can define an instance of the `Cost` type class for any list of type `[a]` where `a` has an instance for `Cost`:
```haskell
instance Cost a => Cost [a] where
  cost = sum . map cost
```
Now, Haskell will automatically create an instance for `Cost [Custom]` the moment we create the instance for `Cost Custom`.

This looks quite similar to type constraints and this is no coincidence. We are essentially doing a type constraint, only for the entire instance of a type class. We can see this as applying the type constraint to every function declared within the type class. As such, we can again use `a`'s `cost` function inside the `Cost [a]` instance's functions.

Type classes also supports the notion of subclasses, however we will not cover this here as it exceeds the scope of this paper.

### Multiple Parameters

The default standardized Haskell definition does not allow for type classes to have more than one class parameter. However, modern implementations like `ghc` allow for the `-XMultiParamTypeClasses` compiler option that allow one to create type classes with multiple parameters.

The most obvious limitation this solves is the fact that, with single parameter type classes and the perspective of operator overloading, we can only define an `add` function to add values of the same type. With multiple parameters, one could define an `Add` type class that allows adding two values of different types.
```haskell
class Add a b where
  add :: a -> b -> a
```

> This is not how the `add` function is implemented in standard Haskell, but this is how it *could* be done. We will find this to be relevant when comparing this to Rust's traits later on.

However this is still quite ugly as currently the return type of the addition is simply the first type paramter `a`. Now assuming we have a more complicated set of types where the output of adding two of them is a third independent type. An obvious fix to this would be adding a third parameter to the `Add` type class like so:
```haskell
class Add a b c where
  add :: a -> b -> c
```

While this works, it poses a strange issue: One can define multiple additions for the same type that have a different output. Let's say we define the following instances for this new `Add` type class:
```haskell
instance Add Int Float Int where
  add x y = x + roundFloatInt y

instance Add Int Float Float where
  add x y = intToFloat x + y
```
where `roundFloatInt` and `intToFloat` are `Float` to `Int` or `Int` to `Float` conversions respectively. At first this might seem fine, however when one were to write `add 1 3.2`, the actual return type of such an expression is not well defined anymore and needs to be specialized with every call, e.g. `add 1 3.2 :: Float`. This is not very ergonomic, thus a different more elegant solution exists.

<!-- https://downloads.haskell.org/~ghc/7.8.4/docs/html/users_guide/type-class-extensions.html#:~:text=7.6.2.2.2.%C2%A0Adding%20functional%20dependencies
functional dependencies can also fix this potentially -->

### Associated types

Associated Types are a way to define more class parameters, that are defined inside the instance of a type class and not in its signature. That means we can define `Add` with three class parameters, where the third of those is fixed once the other two are.

In our `Add` example, a solution using an associated type could look like this:
```haskell
class Add a b where
  type AddOutput a b
  add :: a -> b -> AddOutput a b
```
Here we define that with any instance of `Add a b` for specific types `a` and `b`, there shall also be a third type that's given the name `AddOutput a b`. This type is then the output of our `add` function. This concept ensures that there shall only be one well defined output type for an addition of two specific types `a` and `b`.

To define an addition for `Int` and `Float`, this means we have to decide what output we would even want in this case. Let's assume the choice was made to output a `Float` in this case, the instance for the `Add` type class would then look like this:
```haskell
instance Add Int Float where
  type AddOutput Int Float = Float
  add x y = intToFloat x + y
```
One unfortunate limitation is that the `AddOutput` name is not namespaced, i.e. we will need to have a different name for each associated type we have inside of different type classes.

### A matrix example

Let's assume we have a data type called `Matrix a` which describes a matrix whose elements are of type `a`. We can then use our previously defined `Add` type class to define a matrix addition for any types of matrices that should be addable. We will ignore the matrices' size constraints for them to be addable, as well as the implementation of the action.
```haskell
instance Add a b => Add (Matrix a) (Matrix b) where
  type AddOutput (Matrix a) (Matrix b) =
    Matrix (AddOutput a b)
  add x y = -- ...
```
The first line can be read as "implement `Add` for two matrices whose elements' types implement `Add`". The second and third lines mean "the output of such an addition shall be another matrix whose elements' type is that of the output of adding the elements of the original two matrices together".

To make this clear again: This is **not** how Haskell typically implements overloaded addition. Instead, Haskell defines a `Num` type class that defines multiple operators, such as `(+)` and the unary negate, and only defines those operations on two elements *of the same type*. What we did here was merely to showcase the strength of an overloading system that allows for multiple parameters and associated types, and how operator overloading could be solved using these.
