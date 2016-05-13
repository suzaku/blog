+++
Categories = ["Development", "GoLang"]
Description = ""
Tags = ["Development", "golang"]
date = "2016-05-13T17:16:52+08:00"
title = "Be careful of shared array"

+++

In Go, when you take a slice of an existing slice, you get two slices sharing the same underlying array.

```go
package main

import "fmt"

func main() {
    s1 := []int{1, 2, 3}
    // A slice of s1 => {2, 3}
    s2 := s1[1:3]

    // The 0th element of s2 is the 1th element of s1
    s2[0] = 42

    fmt.Println(s1)  // [1 42 3]
    fmt.Println(s2)  // [42 3]
}
```

And we can append items to slices with the built-in function `append`.

```go
package main

import "fmt"

func main() {
    s1 := []int{1, 2, 3}
    // A slice of s1 => {2}
    s2 := s1[1:2]

    s2 = append(s2, 42)

    fmt.Println(s1)  // [1 2 42]
    fmt.Println(s2)  // [2 42]
}
```

Buf if there's not available capacity for appending new items, `append` would create a new bigger underlying array for you, and the returned slice will point to this new array.


```go
package main

import "fmt"

func main() {
    s1 := []int{1, 2, 3}
    // Create a slice of s1 => {2, 3}
    // The len of s2 would be 2, and the capacity would also be 2
    // Which is to say, s2 is full
    s2 := s1[1:3]

    // Not available capacity for the new item
    // `append` helps us replace the underlying array with a bigger one
    s2 = append(s2, 42)

    // Now that the underlying array for s2 is a different one
    // updating an item of s2 would have no effect on s1
    s2[0] = 11
    
    fmt.Println(s1) // [1 2 3]
    fmt.Println(s2) // [11 3 42]
}
```

So we need to be careful, two related slices may independently grow and change their underlying array.
