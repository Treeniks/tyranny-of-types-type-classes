= Haskell

Haskell supports both parametric and ad-hoc polymorphism.

== Parametric Polymorphism

Parametric polymorphism is achieved the same way it is in OCaml, that is, when writing a function that does not rely on its parameters' types, then one can define the function's type with type parameters.

// ===== removed to fit within the page limit
For example, the list length function:
```haskell
length :: [a] -> Int
length [] = 0
length (x:xs) = 1 + length xs
```
where ```haskell a``` is the type parameter for the type of the list's elements.
// =====

== Ad-hoc Polymorphism: Type Classes <haskell-type-classes>

According to the Haskell committee, there was no standard solution available for ad-hoc polymorphism when they designed the language, so _type classes_ were developed and judged successful enough to be included in the Haskell design~@type-classes-original.

In its simplest form, a type class is not much more than an interface as seen in object oriented languages, meaning it simply defines a named set of operations. For example, to define an interface for checking values for equality, one can define an ```haskell Eq``` type class with a class parameter ```haskell a```, for which a ```haskell (==)``` function should exist:
```haskell
class Eq a where (==) :: a -> a -> bool
```
// ===== removed to fit within the page limit
Mind that it's easy to misunderstand the ```haskell a``` class parameter as being similar to a type parameter used for parametric polymorphism, however this is not the case. Where with parametric polymorphism, ```haskell a``` would stand for _any_ type, in this case ```haskell a``` stands for a _class_ or _set_ of _specific_ types for which instances of ```haskell Eq``` exist.
// =====

The type class itself so far provides no functionality. We need to create an instance of the type class for a specific type, for example for ```haskell Int```:
```haskell
instance Eq Int where (==) x y = eqInt x y
```
Similarly, an instance of the ```haskell Eq``` type class can be created for the specific type ```haskell Float```:
```haskell
instance Eq Float where (==) x y = eqFloat x y
```
When we now try to use the ```haskell (==)``` function with parameters of types other than ```haskell Int``` or ```haskell Float```, we will get a compile time error.

=== Type constraints <constraints>

So far, we have seen how we can use type classes to overload functions defined _within_ the type class, however we can also use them to define standalone functions with types implementing specific type classes.

Assume we want to define some kind of cost to our data types. We can use a type class to convey this idea:
```haskell
class Cost a where cost :: a -> Int
```
A possible instance for some custom data type could then look like this:
```haskell
data Custom = Cheap | Expensive
instance Cost Custom where
  cost Cheap = 0
  cost Expensive = 1
```
Now say we want to define a function ```haskell cheapest``` that takes a list of elements of a type that defines a ```haskell cost```, and then return the cheapest element of that list. Such a function could look like this:
```haskell
cheapest :: Cost a => [a] -> a
cheapest [x] = x
cheapest (x:xs)
  | cost x <= cost y = x
  | otherwise = y
  where y = cheapest xs
```
Note the function's type ```haskell Cost a => [a] -> a```. It means that ```haskell cheapest``` is a function of type ```haskell [a] -> a``` for any type ```haskell a``` that is an instance of ```haskell Cost```.

The similarities to parametric polymorphism are a lot more fitting in this case: ```haskell a``` for the ```haskell cheapest``` function is also a type parameter where the exact type does not matter for the function. The difference is that, whereas in the case of ```haskell length```, any type can be inserted into ```haskell a```, for ```haskell cheapest``` only types that implement a ```haskell cost``` can be used. This is necessary as the ```haskell cost``` function is used in the implementation of ```haskell cheapest```.

=== Creating instances from other instances

One particular strength of type classes is that they allow one to create instances based on other existing type class instances. We extend the example from \autoref{constraints} to illustrate this: We are given a list of ```haskell Custom```s and want to determine the overall sum of the list's costs. We could write an instance for ```haskell Cost [Custom]```, however this seems rather verbose, considering we might want to have an implementation of this function for other Cost instances, too. Instead, we can define an instance of the ```haskell Cost``` type class for any list of type ```haskell [a]``` where ```haskell a``` has an instance for ```haskell Cost```:
```haskell
instance Cost a => Cost [a] where
  cost = sum . map cost
```
Now, Haskell will automatically create an instance for ```haskell Cost [Custom]``` the moment we create the instance for ```haskell Cost Custom```.

This looks quite similar to type constraints and this is no coincidence. We are essentially doing a type constraint, only for the entire instance of a type class. We can see this as applying the type constraint to every function declared within the type class. As such, we can again use ```haskell a```'s ```haskell cost``` function inside the ```haskell Cost [a]``` instance's functions.

// MAYBE mention scoping rules here, as done in Rust

// Type classes also support the notion of subclasses, however we will not cover this here as it exceeds the scope of this paper.
// MAYBE cover this anyway?

=== Multiple Parameters <haskell-add>

Standard Haskell does not allow for type classes to have more than one class parameter. However, modern compilers like `ghc` support the `-XMultiParamTypeClasses` compiler option that allows one to create type classes with multiple parameters.

The most obvious limitation this solves is the fact that, with single parameter type classes and the perspective of operator overloading, we can only define an ```haskell add``` function to add values of the same type. With multiple parameters, one could define an ```haskell Add``` type class that allows adding two values of different types. #footnote[This is not how the ```haskell add``` function is implemented in standard Haskell, but this is how it _could_ be done.]
```haskell
class Add a b where add :: a -> b -> a
```
However this is still quite ugly as the return type of the addition is simply the type of the first argument, which need not always be what we want. An obvious fix to this would be adding a third parameter to the ```haskell Add``` type class:
```haskell
class Add a b c where add :: a -> b -> c
```
While this works, it poses a strange issue: One can define multiple additions for the same type that have a different output. Let's say we define the following instances for the ```haskell Add``` type class with three parameters:
```haskell
instance Add Int Float Int where
  add x y = x + floatToInt y
instance Add Int Float Float where
  add x y = intToFloat x + y
```
At first this might seem fine, however when one were to write ```haskell add 1 3.2```, the actual return type of such an expression is not well defined anymore and needs to be annotated explicitly for every call, e.g. ```haskell add 1 3.2 :: Float```. This is not very ergonomic, thus a different more elegant solution exists.

// https://downloads.haskell.org/~ghc/7.8.4/docs/html/users_guide/type-class-extensions.html#:~:text=7.6.2.2.2.%C2%A0Adding%20functional%20dependencies
// FUNCTIONAL DEPENDENCIES CAN ALSO FIX THIS POTENTIALLY

=== Associated types

// ONLY WORKS WITH TypeFamilies COMPILER OPTION

Associated Types are a way to define more class parameters, that are defined inside the instance of a type class and not in its signature. That means we can define ```haskell Add``` with three class parameters, where the third of those is fixed once the other two are.

In our ```haskell Add``` example, a solution using an associated type could look like this:
```haskell
class Add a b where
  type AddOutput a b
  add :: a -> b -> AddOutput a b
```
We define that with any instance of ```haskell Add a b``` for specific types ```haskell a``` and ```haskell b```, there shall also be a third type that's given the name ```haskell AddOutput a b```. This type is then the output of our ```haskell add``` function. This concept ensures that there shall only be one well defined output type for an addition of two specific types ```haskell a``` and ```haskell b```.

To define an addition for ```haskell Int``` and ```haskell Float```, this means we have to decide what output we would even want in this case. Let's assume the choice was made to output a ```haskell Float``` in this case, the instance for the ```haskell Add``` type class would then look like this:
```haskell
instance Add Int Float where
  type AddOutput Int Float = Float
  add x y = intToFloat x + y
```
One unfortunate limitation is that the ```haskell AddOutput``` name is not namespaced, i.e. we will need to have a different name for each associated type we have inside of different type classes.

=== A matrix example <haskell-matrix>

Let's assume we have a data type called ```haskell Matrix a``` which describes a matrix whose elements are of type ```haskell a```. We can then use our previously defined ```haskell Add``` type class to define a matrix addition for any matrices whose elements' types are addable:
```haskell
instance Add a b => Add (Matrix a) (Matrix b) where
  type AddOutput (Matrix a) (Matrix b) =
    Matrix (AddOutput a b)
  add x y = -- ...
```
The first line can be read as "implement ```haskell Add``` for two matrices whose elements' types implement ```haskell Add```". The second and third lines mean "the output of such an addition shall be another matrix whose elements' type is that of the output of adding the elements of the original two matrices together".

Note that this is *not* how standard Haskell implements overloaded addition. Instead, Haskell has a ```haskell Num``` type class that defines multiple operators, such as ```haskell (+)``` and the unary negate, and only defines those operations on two elements _of the same type_. We introduced our ```haskell Add``` type class merely to showcase multiple parameters and associated types.
