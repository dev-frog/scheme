# Write a Scheme in Haskell
## Algorithmic Language Scheme

 Scheme is a statically scoped and properly tail-recursive dialect of the Lisp programming language invented by `Guy Lewis Steele Jr.` and `Gerald Jay Sussman.` It was designed to have an exceptionally clear and simple semantics and few different ways to form expressions


### Install Haskell
[arch_linux]

```bash
$ sudo pacman -S ghc cabal-install happy alex haskell-haddock-libra
```


### Compile and run
 ```bash
$ ghc --make -dynamic main.hs 

$ ./main "(3.2 3 5)"

$ ./main "(+ 2 2)"

$ ./main "(+ 2 (-4 1))"

$ ./main "(+ 2 (- 4 1))"

$ ./main "(- (+ 4 6 3) 3 5 2)"

 ```

### Reference
[Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours)
[George Hotz ](https://www.youtube.com/watch?v=5QsC_VeYL4g&t=23s)