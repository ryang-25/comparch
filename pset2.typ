#import "notes.typ": *
#show: great-theorems-init

#show: notes.with(
  title: "Computer Architecture",
  subject: "Problem Set 2",
  author: "Roland Yang",
  date: datetime(month: 2, day: 24, year: 2025)
)
#show heading: reset-counter(tcounter, levels: 2)

#set heading(numbering: none)
#set enum(indent: 1em, numbering: "a)")
#set list(indent: 1em)

== Case Study 1

The transpose of a matrix interchanges its rows and columns; this concept is
illustrated here:

$
  mat(
    delim: "[",
    "A11", "A12", "A13", "A14";
    "A21", "A22", "A23", "A24";
    "A31", "A32", "A33", "A34";
    "A41", "A42", "A43", "A44";
  )
  arrow.r.double
  mat(
    delim: "[",
    "A11", "A21", "A31", "A41";
    "A12", "A22", "A32", "A42";
    "A13", "A23", "A33", "A43";
    "A14", "A24", "A34", "A44";
  )
$

Here is a simple C loop to show the transpose:
```c
for (int i = 0; i < 3; i++)
  for (int j = 0; j < 3; j++)
    output[j][i] = input[i][j];
```

Assume that both the input and output matrices are stored in the row major order
(row major order means that the row index changes fastest). Assume that you are
executing a 256-256 double-precision transpose on a processor with a 16 KB fully
associative (don’t worry about cache conflicts) least recently used (LRU)
replacement L1 data cache with 64-byte blocks. Assume that the L1 cache misses or prefetches
require 16 cycles and always hit in the L2 cache, and that the L2 cache can
process a request every 2 processor cycles. Assume that each iteration of the
preceding inner loop requires 4 cycles if the data are present in the L1 cache.
Assume that the cache has a write-allocate fetch-on-write policy for write misses.
Unrealistically, assume that writing back dirty cache blocks requires 0 cycles.


#problem[
  For the preceding simple implementation, this execution
  order would be nonideal for the input matrix; however, applying a loop interchange
  optimization would create a nonideal order for the output matrix. Because loop
  interchange is not sufficient to improve its performance, it must be blocked instead.

  + What should be the minimum size of the cache to take advantage of
    blocked execution?
  + How do the relative number of misses in the blocked and
    unblocked versions compare in the preceding minimum-sized cache?
  + Write code to perform a transpose with a block size parameter _B_
    that uses _B_ #sym.dot.c _B_ blocks.
  + What is the minimum associativity required of the L1 cache for
    consistent performance independent of both arrays’ position in memory?
  + Try out blocked and nonblocked 256 #sym.dot.c 256 matrix transpositions on
    a computer. How closely do the results match your expectations based on what
    you know about the computer’s memory system? Explain any discrepancies if
    possible.
]

#solution[
  + Since the cacheline is 64 bytes (8 doubles), the block size will be 8
    #sym.times 8 = 64 elements, and we need a block for input and output,
    so we end up with 2 #sym.times 64 #sym.times 8 = 1 KB.
  + The unblocked version ends up with a cache miss for every 8 elements
    in a 256 element row, and every column access is a miss, so we end up
    with 8 column misses + 1 row miss for every 8 elements in a row, while
    the blocked version does roughly 1 access on average for each element
    in both input and output matrices, so 2 for every 8 elements for a
    difference of 7 misses per 8 elements.
  +
    ```c
    for (int i = 0; i < 256; i += B)
      for (int j = 0; j < 256; j += B)
       // these will already be in cache for next loop
        for (int k = 0; k < B; k++)
          for (int l = 0; l < B; l++)
            output[j + l][i + k] = input[i + k][j + l];
    ```
  + They should be 2-way associative to avoid cache lines being allocated to the
    same region in cache.
  + With a 128 KiB 8-way L1D the blocked version took ~150 microseconds vs 600
    microseconds for the non-blocking. Using a smaller or larger block increased
    the time, however.
]
