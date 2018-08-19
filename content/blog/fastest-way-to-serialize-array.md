+++
Description = ""
Tags = ["Development", "Python", "Serialization", "Numpy"]
Categories = ["Development", "Python"]
menu = "main"
title = "Fastest way to serialize an array in Python"
date = "2018-08-19T11:55:00+08:00"
+++

To kick start the discussion, let's first assume that we have the following 2-D `numpy` array:

```python
import numpy as np
matrix = np.random.random((10000, 384)).astype(np.float32)
```

## Approaches tried

1. The built-in `pickle`

    In Python, the built-in `pickle` module is often used to serialize/deserialize data.
    Here's how it works:

    ```python
    import pickle
    pickled_dumped = pickle.dumps(matrix, protocol=pickle.HIGHEST_PROTOCOL)
    pickle.loads(pickled_dumped) 
    ```
1. MessagePack

    [MessagePack](https://msgpack.org/) is known to a fast and compact serialization format. 
    But it can't serialize a `numpy` array directly, so let's first assume that we'll use a nested Python `list` instead.

    ```python
    matrix_as_list = matrix.tolist()
    ```

    Here's how it works:

    ```python 
    # Note how we set `use_single_float` to make sure float32 is used
    msgpack_dumped = msgpack.dumps(matrix_as_list, use_single_float=True)
    msgpack.loads(msgpack_dumped)
    ```
1. pyarrow

    `pyarrow` is the Python library for [Apache Arrow](https://github.com/apache/arrow/), which enabled fast serialization through zero-copy memory sharing.

    ```python
    pyarrow_dumped = pyarrow.serialize(matrix).to_buffer().to_pybytes()
    pyarrow.deserialize(pyarrow_dumped)
    ```

1. Non-general DIY Serialization

    This is not a general serialization solution. It can only serialize/deserialize a 2-D `numpy` array.

    ```python
    import struct

    def serialize(mat):
        n_rows = len(mat)
        n_columns = len(mat[0])
        shape = struct.pack('>II', n_rows, n_columns)
        return shape + mat.tobytes()

    def deserialize(data):
        n_rows, n_columns = struct.unpack('>II', data[:8])
        mat = np.frombuffer(data, dtype=np.float32, offset=8)
        mat.shape = (n_rows, n_columns)
        return mat

    diy_dumped = serialize(matrix)
    deserialize(diy_dumped)
    ```

## Comparison

Now let's compare these approaches in the following metrics:

1. Size (of serialized data, in bytes)
1. T_dump (Serializing time)
1. T_load (Deserializaing time)

Approach     |Size     |T_dump  |T_load  |
-------------|---------|--------|--------|
pickle       |15360156 |15.7 ms |6.01 ms |
MessagePack  |19230003 |97.6 ms |179 ms  |
pyarrow      |15360704 |17.3 ms |32.8 µs |
DIY          |<span style="color: red">15360008</span>|<span style="color: red">12.5 ms</span>|<span style="color: red">2.32 µs</span>|

## Conclusion

`MessagePack` dumps the biggest output and take the longest to serialize/deserialize. This may be related to [the way](https://github.com/msgpack/msgpack/blob/master/spec.md#float-format-family) `MessagePack` encode floating point numbers: each `float32` takes 5 bytes, not 4 bytes.

The DIY solution has only 8 bytes of overhead in size for the shape of the 2-D array, and is the fastest one. It's not a general solution, but it demonstrate that we can fallback to this approach when size and speed of serialization are the bottlenecks.

`pyarrow` is the fastest general solution I have tried in this experiment, though the overhead in size is a little larger than when using `pickle`.
The good thing about `pyarrow` is that the time taken to deserialize doesn't grow linearly with the size of array, it's about 32 µs even when I make the array 5 times larger (This is because `pyarrow` use zero-copy memory sharing to avoid moving the array around. It's why I use `np.frombuffer` in the DIY approach).

But if what you have is not a small number of big arrays, but a massive number of small arrays, using `pyarrow` may not be the right choice. Because even for a 2-D array with only 1 row, it still takes about 20 µs, there are some fixed overhead there.
