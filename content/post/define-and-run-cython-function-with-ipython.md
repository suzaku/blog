+++
date = "2016-05-10T08:32:28+08:00"
draft = true
title = "define and run cython function with ipython"

+++

I learned this trick in the book [Cython: A Guide for Python Programmer](http://www.amazon.com/Cython-Kurt-W-Smith/dp/1491901551/ref=sr_1_1?s=books&ie=UTF8&qid=1424746332&sr=1-1&keywords=cython).

After having both *Cython* and *IPython* installed, we can load the *cythonmagic* extension with:

```python
In [1]: %load_ext cythonmagic
```

Now we have 3 extra magic functions in the session:

* `%%cython` will cythonize and compile contents of the code cell.

```python
In [4]: %%cython
   ...: def sum_up(*numbers):
   ...:     cdef int s = 0
   ...:     for n in numbers:
   ...:         s += n
   ...:     return s
   ...:
In [5]: sum_up(1, 2, 3)
Out[5]: 6
```

* `%%cython_inline` simply passes the body of the cell to <a href="http://docs.cython.org/src/reference/compilation.html#compiling-with-cython-inline" target="_blank">Cython.inline</a>
and returns the result.

```python
In [16]: x = 3.14

In [17]: y = 2

In [18]: %%cython_inline
   ....: return x * y
   ....:
Out[18]: 6.28
```

* `%%cython_pyximport` is similar to `%%cython`, except that the contents of the code shell are written to a `.pyx` file in the current working directory and imported using `pyximport`, and a module name is required.

```python
In [21]: %%cython_pyximport double
....: def f(x):
....:     return 2.0 * x
....:
In [22]: !ls *.pyx
double.pyx
In [23]: f(4)
Out[23]: 8.0
```
