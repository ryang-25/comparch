#import "notes.typ": *
#show: great-theorems-init

#show: notes.with(
  title: "Computer Architecture",
  subject: "Problem Set A",
  author: "Roland Yang",
  date: datetime(day: 13, month: 4, year: 2025)
)
#show heading: reset-counter(tcounter, levels: 2)
#show link: set text(fill: blue)

#set heading(numbering: none)

#problem[
  Compute the effective CPI for an implementation of an embedded RISC-V CPU using
  #link(<figa29>)[Figure A.29]. Assume we have made the following measurements of
  average CPI for each of the instruction types:
]

#table(
  columns: (1fr, auto),
  stroke: (x: none, y: black),
  table.header(
    repeat: false,
    [*Instruction*], [*Clock cycles*]
  ),
  [All ALU operations],  [1.0],
  [Loads], [5.0],
  [Stores], [3.0],
  [Branches], [],
  [#h(1em) Taken], [5.0],
  [#h(1em) Not taken], [3.0],
  [Jumps], [3.0],
) <figa29>
#align(center)[
  Average the instruction frequencies of astar and
  gcc to obtain the instruction mix.
]

#solution[
  For astar:
  $5 times .28 + 3 times .06 + 4 times .18 + 3 times .02 + 1 times .46 = 2.82$ \
  gcc: $5 times .17 + 3 times .23 + 4 times .20 + 3 times .04 + 1 times .36 = 2.82$
  so average CPI is $2.82$.
]

#tcounter.update(6)
#problem[
  Consider the following fragment of C code:
  ```c
  for (int i = 0; i < 100; i++) {
      A[i] = B[i] + C;
  }
  ```

  Assume that `A` and `B` are arrays of 64-bit integers, and `C` and `i` are
  64-bit integers. Assume that all data values and their addresses are kept in
  memory (at addresses 1000, 3000, 5000, and 7000 for `A`, `B`, `C`, and `i`,
  respectively) except when they are operated on. Assume that values in
  registers are lost between iterations of the loop. Assume all addresses and
  words are 64 bits.

  + Write the code for RISC-V. How many instructions are required dynamically?
    How many memory-data references will be executed? What is the code size in
    bytes?
  + Write the code for x86. How many instructions are required
    dynamically? How many memory-data references will be executed? What is the
    code size in bytes?
  + Write the code for a stack machine. Assume all operations occur
    on top of the stack. Push and pop are the only instructions that access
    memory; all others remove their operands from the stack and replace them
    with the result. The implementation uses a hardwired stack for only the top
    two stack entries, which keeps the processor circuit very small and low in
    cost. Additional stack positions are kept in memory locations, and accesses
    to these stack positions require memory references. How many instructions
    are required dynamically? How many memory-data references will be executed?
  + Instead of the code fragment above, write a routine for
    computing a matrix multiplication for dense, single precision matrices, also
    known as SGEMM. For input matrices of size 100 $times$ 100, how many
    instructions are required dynamically? How many memory-data references will
    be executed?
  + As the matrix size increases, how does this affect the number
    of instructions executed dynamically or the number of memory-data
    references?
]
#solution[
  + A RISC-V example is $14 times 100 + 4 = 1404$ instructions and makes
    $5 times 100 + 1 = 501$ references in 56 bytes.
    ```asm
    loop:
      lui s0, 2 # 2 << 12
      lw s1, -1192(s0) # s1 = [7000], imm is signed
      addi a0, zero, 101
      bge s1, a0, out
      addi a1, zero, 8
      mul a1, s1, a1
      lui a2, 1 # 1 << 12
      add a3, a1, a2
      ld a3, -1096(a3) # a3 = [3000]
      ld a4, 904(a2) # a4 = 5000
      add a3, a3, a4 # a3 = a3 + a4
      sw a3, 1000(a1) # [1000 + 8*i] = a3
      addi s0, s0, 1
      sw s0, -1192(s0) # [7000] = s1
    out:
      ...
    ```
  + An x64 example is $8 times 100 + 3 = 803$ instructions, makes
    $5 times 100 + 1 = 501$ references in 47 bytes.
    ```asm
    loop:
      mov ecx, [7000]
      cmp ecx, 100
      ja out
      mov rax, [3000 + 8*ecx]
      add rax, [5000]
      mov [1000 + 8*ecx], rax
      incd [7000]
      jmp loop
    out:
      ...
    ```
  + I guess it'd look like this:
    ```
    loop:
      push i
      push 100
      cmp
      ja out
      push B
      push 8
      push i
      mul
      add
      push C
      add
      push A
      push 8
      push i
      mul
      add
      store
      push i
      push 1
      add
      store
      jmp loop
    out:
      ...
    ```
    we'd need $22 times 100 + 4 = 2204$ instructions and
    $7 times 100 + 1 = 701$ references.
  + ```c
    for (int i = 0; i < 100; i++) {
      for (int j = 0; j < 100; j++) {
        float result = 0;
        for (int k = 0; k < 100; k++)
          result += a[i][k] * b[k][j];
        out[i][j] = result;
      }
    }
  ```
  + As the matrix size increases, both instructions
    executed grow cubically $O(n^3)$.
]
