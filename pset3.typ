#import "notes.typ": *
#show: great-theorems-init

#show: notes.with(
  title: "Computer Architecture",
  subject: "Problem Set 3",
  author: "Roland Yang",
  date: datetime.today()
)
#show heading: reset-counter(tcounter, levels: 2)
#show link: set text(fill: blue)

#set heading(numbering: none)

== Case Study

You are tasked with designing a new processor microarchitecture and you are
trying to determine how best to allocate your hardware resources. Which of the
hardware and software techniques you learned in Chapter 3 should you apply? You
have a list of latencies for the functional units and for memory, as well as
some representative code. Your boss has been somewhat vague about the
performance requirements of your new design, but you know from experience that,
all else being equal, faster is usually better. Start with the basics.
#link(<fig347>)[Figure 3.47] provides a sequence of instructions and list of
latencies.

#blockquote[
  _Note:_ I rewrote the table in terms of absolute latencies.
]

#table(
  columns: (1fr, 1fr, auto),
  stroke: none,
  table.header(
    repeat: false,
    [*Instruction cycle latencies*], [], []
  ),
  table.hline(),
  [Memory LD], [], [4],
  [Memory SD], [], [2],
  [Integer ADD, SUB], [], [1],
  [Branches], [], [2],
  [fadd.d], [], [3],
  [fmul.d], [], [5],
  [fdiv.d], [], [11],
  table.hline(),
  [`loop:`], [`fld`], [`f2, 0(Rx)`],
  [`i0:`], [`fmul.d`], [`f2, f0, f2`],
  [`i1:`], [`fdiv.d`], [`f8, f2, f0`],
  [`i2:`], [`fld`], [`f4, 0(Ry)`],
  [`i3:`], [`fadd.d`], [`f4, f0, f4`],
  [`i4:`], [`fadd.d`], [`f10, f8, f2`],
  [`i5:`], [`fsd`], [`f4, 0(Ry)`],
  [`i6:`], [`addi`], [`Rx, Rx, 8`],
  [`i7:`], [`addi`], [`Ry, Ry, 8`],
  [`i8:`], [`sub`], [`x20, x4, Rx`],
  [`i9:`], [`bnz`], [`x20, loop`],
  table.hline(),
  table.footer(
    table.cell(align: center, colspan: 3)[
      *Figure 3.47* Code and latencies for exercises
    ]
  )
) <fig347>

#problem[
  What is the baseline performance (in cycles, per loop iteration) of the code
  sequence in Figure 3.47 if no new instruction’s execution could be initiated
  until the previous instruction’s execution had completed? Ignore front-end
  fetch and decode. Assume for now that execution does not stall for lack of the
  next instruction, but only one instruction/cycle can be issued. Assume the
  branch is taken, and that there is a one-cycle branch delay slot.
]
#solution[
  $4 + 5 + 11 + 4 + 3 + 3 + 2 + 1 + 1 + 1 + 2 = 37$, and with the delay slot
  it's 38.
]

#problem[
  Think about what latency numbers really mean—they indicate the number of
  cycles a given function requires to produce its output. If the overall
  pipeline stalls for the latency cycles of each functional unit, then you are
  at least guaranteed that any pair of back-to-back instructions (a "producer"
  followed by a "consumer") will execute correctly. But not all instruction
  pairs have a producer/consumer relationship. Sometimes two adjacent
  instructions have nothing to do with each other. How many cycles would the
  loop body in the code sequence in #link(<fig347>)[Figure 3.47] require if the
  pipeline detected true data dependences and only stalled on those, rather than
  blindly stalling everything just because one functional unit is busy? Show the
  code with `<stall>` inserted where necessary to accommodate stated latencies.
  (Hint: an instruction with latency $+2$ requires two `<stall>` cycles to be
  inserted into the code sequence.) Think of it this way: a one-cycle
  instruction has latency $1 + 0$, meaning zero extra wait states. So, latency
  $1 + 1$ implies one stall cycle; latency $1 + N$ has $N$ extra stall cycles.
]
#solution[
  #table(
    columns: (1fr, auto),
    stroke: none,
    table.header([*Instruction*], table.vline(), [Cycle \#]),
    [`fld f2, 0(Rx)`], [1],
    [3-cycle `<stall>`], [],
    [`fmul.d f2, f0, f2`], [5],
    [4-cycle `<stall>`], [],
    [`fdiv.d f8, f2, f0`], [10],
    [`fld f4, 0(Ry)`], [11],
    [3-cycle `<stall>`], [],
    [`fadd.d f4, f0, f4`], [15],
    [5-cycle `<stall>`], [],
    [`fadd.d f10, f8, f2`], [21],
    [`fsd f4, 0(Ry)`], [22],
    [`addi Rx, Rx, 8`], [23],
    [`addi Ry, Ry, 8`], [24],
    [`sub x20, x4, Rx`], [25],
    [`bnz x20, loop`], [26],
    [`<branch delay>`], [],
  )
  #blockquote[
    _Note:_ This looks a little different from the solution manual as it uses the
    instruction ordering and latencies as presented in the 6#super[th] edition of
    the book rather than the 5#super[th] as the manual seems to do.
  ]
  - If the loop starts at cycle 1, the pipeline will stall and the multiply can
    issue beginning at cycle 5.
  - Since the divide starts on cycle 10, its results won't be available until
    cycle 21, resulting in a 5 cycle stall after cycle 15.
  - The final store and the add are only a name dependency and would not stall,
    so we end up with a total of *27 cycles*.
]

#problem[
  Consider a multiple-issue design. Suppose you have two execution pipelines,
  each capable of beginning execution of one instruction per cycle, and enough
  fetch/decode bandwidth in the front end so that it will not stall your
  execution. Assume results can be immediately forwarded from one execution unit
  to another, or to itself. Further assume that the only reason an execution
  pipeline would stall is to observe a true data dependency. Now how many cycles
  does the loop require?
]
#solution[
  #table(
    columns: (1fr, 1fr, auto),
    stroke: none,
    table.header([*Pipeline 0*],[*Pipeline 1*], table.vline(), [Cycle \#]),
    [`fld f2, 0(Rx)`], [`fld f4, 0(Ry)`], [1],
    table.cell(align: center, colspan: 2)[3-cycle `<stall>`], [],
    [`fmul.d f2, f0, f2`], [`fadd.d f4, f0, f4`], [5],
    [4-cycle `<stall>`], [2-cycle `<stall>`], [],
    [], [`fsd f4, 0(Ry)`], [8],
    [], [`addi Rx, Rx, 8`], [9],
    [`fdiv.d f8, f2, f0`], [`addi Ry, Ry, 8`], [10],
    [9-cycle `<stall>`], [`sub x20, x4, Rx`], [11],
    [`bnz x20, loop`], [], [20],
    [`fadd.d f10, f8, f2`], [], [21],
  )
  So it takes *21 cycles*.
]

#problem[
  In the multiple-issue design of Exercise 3.3, you may have recognized some
  subtle issues. Even though the two pipelines have the exact same instruction
  repertoire, they are neither identical nor interchangeable, because there is
  an implicit ordering between them that must reflect the ordering of the
  instructions in the original program. If instruction $N + 1$ begins execution
  in Execution Pipe 1 at the same time that instruction $N$ begins in Pipe 0,
  and $N + 1$ happens to require a shorter execution latency than $N$, then $N +
  1$ will complete before $N$ (even though program ordering would have implied
  otherwise). Recite at least two reasons why that could be hazardous and will
  require special considerations in the microarchitecture. Give an example of
  two instructions from the code in #link(<fig347>)[Figure 3.47] that
  demonstrate this hazard.
]
#solution[
  - If an exception occurs at an $N$ that completes after $N + 1$, then the
    #sym.mu\arch state must be reverted to handle the exception in order;
    conversely, we must also handle exceptions that occur in $N + 1$ when $N$
    has not completed.
  - If there are name or control dependencies between $N$ and $N + 1$, they must
    execute in-order.

  In exercise 3.3, we have a load in pipeline 1 completing before the other
  instructions in pipeline 0, which has #sym.mu\arch effects—it could raise an
  exception, for example.
]

#problem[
  Reorder the instructions to improve performance of the code in
  #link(<fig347>)[Figure 3.47]. Assume the two-pipe machine in Exercise 3.3 and
  that the out-of-order completion issues of Exercise 3.4 have been dealt with
  successfully. Just worry about observing true data dependences and functional
  unit latencies for now. How many cycles does your reordered code take?
]
#solution[
  Although we can't improve the overall latency of the loop, we can improve
  our pipeline utilization via the following (keeping in mind functional unit
  usage).

  Assuming there is an AGU per pipeline but only one of every other functional
  unit:
  #table(
    columns: (1fr, 1fr, auto),
    stroke: none,
    table.header([*Pipeline 0*],[*Pipeline 1*], table.vline(), [Cycle \#]),
    [`fld f2, 0(Rx)`], [`fld f4, 0(Ry)`], [1],
    [`addi Rx, Rx, 8`], [`<stall>`], [2],
    [`<stall>`], [`addi Ry, Ry, 8`], [3],
    [`sub x20, x4, Rx`], [`<stall>`], [4],
    [`fmul.d f2, f0, f2`], [`fadd.d f4, f0, f4`], [5],
    [4-cycle `<stall>`], [2-cycle `<stall>`], [],
    [], [`fsd f4, 0(Ry)`], [7],
    [`fdiv.d f8, f2, f0`],  [], [10],
    [9-cycle `<stall>`], [], [],
    [`bnz x20, loop`], [], [20],
    [`fadd.d f10, f8, f2`], [], [21],
  )
]

#problem[
  Every cycle that does not initiate a new operation in a pipe is a lost
  opportunity, in the sense that your hardware is not living up to its
  potential.
  + In your reordered code from Exercise 3.5, what fraction of all
    cycles, counting both pipes, were wasted (did not initiate a new op)?
  + Loop unrolling is one standard compiler technique for finding
    more parallelism in code, in order to minimize the lost opportunities for
    performance. Hand-unroll two iterations of the loop in your reordered code
    from Exercise 3.5.
  + What speedup did you obtain? (For this exercise, just color the $N + 1$
    iteration's instructions green to distinguish them from the $N$th iteration's
    instructions; if you were actually unrolling the loop, you would have to reassign
    registers to prevent collisions between the iterations.)
]
#solution[
  + In a total of 26 opportunities there were 18 times where an instruction wasn't
    issued for a waste of $18\/26 = 69%$.
  + #table(
      columns: (1fr, 1fr, auto),
      stroke: none,
      table.header([*Pipeline 0*],[*Pipeline 1*], table.vline(), [Cycle \#]),
      [`fld f2, 0(Rx)`], [`fld f4, 0(Ry)`], [1],
      [`fld f3, 8(Rx)`], [`fld f5, 8(Ry)`], [2],
      [`addi Rx, Rx, 16`], [`<stall>`], [3],
      [`<stall>`], [`addi Ry, Ry, 16`], [4],
      [`sub x20, x4, Rx`], [`<stall>`], [5],
      [`fmul.d f2, f0, f2`], [`fmul.d f3, f0, f3`], [6],
      [`fadd.d f4, f0, f4`], [`fadd.d f5, f0, f5`], [7],
      table.cell(align: center, colspan: 2)[2-cycle `<stall>`], [],
      [`fsd f4, 0(Ry)`], [`fsd f5, 0(Ry)`], [10],
      [`fdiv.d f8, f2, f0`],  [`fdiv.d f9, f3, f0`], [11],
      table.cell(align: center, colspan: 2)[9-cycle `<stall>`], [],
      [`bnz x20, loop`], [`<stall>`], [21],
      [`fadd.d f10, f8, f2`], [`fadd.d f11, f9, f3`], [22],
    )
  + Since it takes 11 versus 21 cycles, the speedup is 48%.
]

#table(
  columns: (1fr, 1fr, auto),
  stroke: none,
  table.hline(),
  [`loop:`], [`fld`], [`f2, 0(Rx)`],
  [`i0:`], [`fmul.d`], [`f5, f0, f2`],
  [`i1:`], [`fdiv.d`], [`f8, f0, f2`],
  [`i2:`], [`fld`], [`f4, 0(Ry)`],
  [`i3:`], [`fadd.d`], [`f6, f0, f4`],
  [`i4:`], [`fadd.d`], [`f10, f8, f2`],
  [`i5:`], [`sd`], [`f4, 0(Ry)`],
  table.hline(),
  table.footer(
    table.cell(align: center, colspan: 3)[
      *Figure 3.48* Sample code for register renaming practice.
    ]
  )
) <fig348>

/*
#table(
  columns: (1fr, 1fr, auto),
  stroke: none,
  table.hline(),
  [`loop`], [`fld`], [`T9, 0(Rx)`],
  [`i0:`], [`fmul.d`], [`T10, F0, T9`],
  table.cell(colspan: 3)[...],
  table.hline(),
  table.footer(
    table.cell(align: center, colspan: 3)[
      *Figure 3.49* Expected output of register renaming.
    ]
  )
) <fig349>
*/

#problem[
  Computers spend most of their time in loops, so multiple loop iterations are
  great places to speculatively find more work to keep CPU resources busy.
  Nothing is ever easy, though; the compiler emitted only one copy of that
  loop’s code, so even though multiple iterations are handling distinct data,
  they will appear to use the same registers. To keep multiple iterations'
  register usages from colliding, we rename their registers.
  #link(<fig348>)[Figure 3.48] shows example code that we would like our
  hardware to rename. A compiler could have simply unrolled the loop and used
  different registers to avoid conflicts, but if we expect our hardware to
  unroll the loop, it must also do the register renaming. How? Assume your
  hardware has a pool of temporary registers (call them `T` registers, and
  assume that there are 64 of them, `T0` through `T63`) that it can substitute
  for those registers designated by the compiler. This rename hardware is
  indexed by the src (source) register designation, and the value in the table
  is the `T` register of the last destination that targeted that register.
  (Think of these table values as producers, and the `src` registers are the
  consumers; it doesn’t much matter where the producer puts its result as long
  as its consumers can find it.) Consider the code sequence in
  #link(<fig348>)[Figure 3.48]. Every time you see a destination register in the
  code, substitute the next available `T`, beginning with `T9`. Then update all
  the `src` registers accordingly, so that true data dependences are maintained.
  Show the resulting code. (Hint: see Figure 3.49)
]
#solution[
  #table(
    columns: (1fr, 1fr, auto),
    stroke: none,
    table.hline(),
    [`loop:`], [`fld`], [`T9, 0(Rx)`],
    [`i0:`], [`fmul.d`], [`T9, F0, T9`],
    [`i1:`], [`fdiv.d`], [`T11, F0, T9`],
    [`i2:`], [`fld`], [`T12, 0(Ry)`],
    [`i3:`], [`fadd.d`], [`T13, F0, T12`],
    [`i4:`], [`fadd.d`], [`T14, T11, T9`],
    [`i5:`], [`sd`], [`T15, 0(Ry)`],
    table.hline(),
  )
]

#problem[
  Exercise 3.7 explored simple register renaming: when the hardware register
  renamer sees a source register, it substitutes the destination `T` register of
  the last instruction to have targeted that source register. When the rename
  table sees a destination register, it substitutes the next available `T` for
  it, but superscalar designs need to handle multiple instructions per clock
  cycle at every stage in the machine, including the register renaming. A
  SimpleScalar processor would therefore look up both src register mappings for
  each instruction and allocate a new dest mapping per clock cycle. Superscalar
  processors must be able to do that as well, but they must also ensure that any
  dest-to-src relationships between the two concurrent instructions are handled
  correctly. Consider the sample code sequence in Figure 3.50. Assume that we
  would like to simultaneously rename the first two instructions. Further assume
  that the next two available `T` registers to be used are known at the
  beginning of the clock cycle in which these two instructions are being
  renamed. Conceptually, what we want is for the first instruction to do its
  rename table lookups and then update the table per its destination’s `T`
  register. Then the second instruction would do exactly the same thing, and any
  inter-instruction dependency would thereby be handled correctly. But there’s
  not enough time to write that `T` register designation into the renaming table
  and then look it up again for the second instruction, all in the same clock
  cycle. That register substitution must instead be done live (in parallel with
  the register rename table update). Figure 3.51 shows a circuit diagram, using
  multiplexers and comparators, that will accomplish the necessary on-the-fly
  register renaming. Your task is to show the cycle-by-cycle state of the rename
  table for every instruction of the code shown in Figure 3.50. Assume the table
  starts out with every entry equal to its index (`T0 = 0; T1 = 1, …`) (Figure
  3.51).
]
#solution[
  #align(center)[
    #table(
      align: (auto, center, auto, center),
      columns: (auto, 3cm, auto, 3cm),
      column-gutter: (0em, 5em, 0em, 0em),
      stroke: (none, black, none, black),
      table.header(
        [],
        [$N$],
        [],
        [$N + 1$]
      ),
      [0], [0], [0], [0],
      [1], [1], [1], [1],
      [2], [2], [*2*], [*12*],
      [3], [3], [3], [3],
      [4], [4], [4], [4],
      [*5*], [*9*], [*5*], [*11*],
      [6], [6], [6], [6],
      [7], [7], [7], [7],
      [8], [8], [8], [8],
      [*9*], [*10*], [9], [9],
    )
  ]
]

#problem[
  If you ever get confused about what a register renamer has to do, go
  back to the assembly code you’re executing, and ask yourself what has to happen
  for the right result to be obtained. For example, consider a three-way superscalar
  machine renaming these three instructions concurrently:
  ```asm
  addi x1, x1, x1
  addi x1, x1, x1
  addi x1, x1, x1
  ```
  If the value of x1 starts out as 5, what should its value be when this sequence has
  executed?
]
#solution[
  #align(center)[
    ```asm
    addi T9, x1, x1
    addi T10, T9, T9
    addi x1, T10, T10
    ```
  ]

  and indeed we have $5 + 5 = 10$, $10 + 10 = 20$, and $20 + 20 = 40$.
]

#problem[
  Very long instruction word (VLIW) designers have a few basic choices to make
  regarding architectural rules for register use. Suppose a VLIW is designed
  with self-draining execution pipelines: once an operation is initiated, its
  results will appear in the destination register at most L cycles later (where
  L is the latency of the operation). There are never enough registers, so there
  is a temptation to wring maximum use out of the registers that exist. Consider
  Figure 3.52. If loads have a $1 + 2$ cycle latency, unroll this loop once, and
  show how a VLIW capable of two loads and two adds per cycle can use the
  minimum number of registers, in the absence of any pipeline interruptions or
  stalls. Give an example of an event that, in the presence of self-draining
  pipelines, could disrupt this pipelining and yield wrong results.
]

#problem[
  Assume a five-stage single-pipeline microarchitecture (fetch, decode, execute,
  memory, write-back) and the code in Figure 3.53. All ops are one cycle except
  LW and SW, which are $1 + 2$ cycles, and branches, which are $1 + 1$ cycles.
  There is no forwarding. Show the phases of each instruction per clock cycle
  for one iteration of the loop.
  + How many clock cycles per loop iteration are lost to branch
    overhead?
  + Assume a static branch predictor, capable of recognizing a backward branch
    in the `Decode` stage. Now how many clock cycles are wasted on branch
    overhead?
  + Assume a dynamic branch predictor. How many cycles are lost on a
    correct prediction?
]
#solution[
  I cut some empty cycles out for the sake of brevity, but the given solution
  seems incorrect—the second instruction should stall until 7 in the absence of
  forwarding!

  + We lose 4 cycles due to branch overhead. (Instruction fetch can only begin
    after branch finishes execution)
  + With a static predictor we lose 2 cycles.
  + With a dynamic predictor we lose 0 cycles.

  #set text(font: "DejaVu Sans Mono", size: 9pt)
  #show raw: set text(size: 9pt)
  #let depth = 24
  #let excluded = (4, 5, 10, 11, 18)

  #table(
    align: center,
    columns: (auto, ..{for _ in range(depth - excluded.len()) {(1fr, )} } ),
    [],
    ..{
      for i in range(depth) {
        if i in excluded { none } else{ ([#i], ) }
      }
    },
    [`lw x1, 0(x2)`],   [F], [D], [E], [M], [W], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ],
    [`addi x1, x1, 1`], [ ], [F], [D], [-], [-], [E], [M], [W], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ],
    [`sw x1, 0(x2)`],   [ ], [ ], [F], [-], [-], [D], [E], [M], [W], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ],
    [`addi x2, x2, 4`], [ ], [ ], [ ], [-], [-], [F], [D], [E], [M], [W], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ], [ ],
    [`sub x4, x3, x2`], [ ], [ ], [ ], [ ], [-], [-], [F], [D], [-], [-], [E], [M], [W], [ ], [ ], [ ], [ ], [ ], [ ],
    [`bnz x4, Loop`],   [ ], [ ], [ ], [ ], [-], [-], [-], [F], [-], [-], [D], [-], [-], [E], [M], [W], [ ], [ ], [ ],
    [`lw x1, 0(x2)`],   [ ], [ ], [ ], [ ], [-], [-], [-], [-], [-], [-], [-], [-], [-], [-], [F], [D], [E], [M], [W],
  )
]

#problem[
  Let’s consider what dynamic scheduling might achieve here. Assume a
  microarchitecture as shown in Figure 3.54. Assume that the arithmetic-logical
  units (ALUs) can do all arithmetic ops (`fmul.d`, `fdiv.d`, `fadd.d`, `addi`,
  `sub`) and branches, and that the Reservation Station (RS) can dispatch, at
  most, one operation to each functional unit per cycle (one op to each ALU plus
  one memory op to the `fld`/`fsd`).
  + Suppose all of the instructions from the sequence in #link(<fig347>)[Figure 3.47]
    are present in the RS, with no renaming having been done. Highlight any
    instructions in the code where register renaming would improve performance.
    (Hint: look for read-after-write and write-after-write hazards. Assume the
    same functional unit latencies as in #link(<fig347>)[Figure 3.47].)
  + Suppose the register-renamed version of the code from part (a) is
    resident in the RS in clock cycle N, with latencies as given in
    #link(<fig347>)[Figure 3.47]. Show how the RS should dispatch these
    instructions out of order, clock by clock, to obtain optimal performance on
    this code. (Assume the same RS restrictions as in part (a). Also assume that
    results must be written into the RS before they’re available for use—no
    bypassing.) How many clock cycles does the code sequence take?
  + Part (b) lets the RS try to optimally schedule these instructions. But
    in reality, the whole instruction sequence of interest is not usually
    present in the RS. Instead, various events clear the RS, and as a new code
    sequence streams in from the decoder, the RS must choose to dispatch what it
    has. Suppose that the RS is empty. In cycle 0, the first two
    register-renamed instructions of this sequence appear in the RS. Assume it
    takes one clock cycle to dispatch any op, and assume functional unit
    latencies are as they were for Exercise 3.2. Further assume that the front
    end (decoder/register-renamer) will continue to supply two new instructions
    per clock cycle. Show the cycle-by-cycle order of dispatch of the RS. How
    many clock cycles does this code sequence require now?
  + If you wanted to improve the results of part (c), which would have
    helped most: (1) Another ALU? (2) Another LD/ST unit? (3) Full bypassing of
    ALU results to subsequent operations? or (4) Cutting the longest latency in
    half? What’s the speedup?
  + Now let’s consider speculation, the act of fetching, decoding, and
    executing beyond one or more conditional branches. Our motivation to do this
    is twofold: the dispatch schedule we came up with in part (c) had lots of
    nops, and we know computers spend most of their time executing loops (which
    implies the branch back to the top of the loop is pretty predictable). Loops
    tell us where to find more work to do; our sparse dispatch schedule suggests
    we have opportunities to do some of that work earlier than before. In part
    (d) you found the critical path through the loop. Imagine folding a second
    copy of that path onto the schedule you got in part (b). How many more clock
    cycles would be required to do two loops’ worth of work (assuming all
    instructions are resident in the RS)? (Assume all functional units are fully
    pipelined.)
]
\
#solution[
  + We could rename `i2` and `i5` to improve performance—as well as renaming
    the `addi`s so that there are no unnecessary dependencies across loop
    iterations.
  /*
  + #align(center)[
      #table(
        align: (auto, center, auto, center),
        columns: (auto, 3cm, auto, 3cm),
        column-gutter: (0em, 5em, 0em, 0em),
        stroke: (none, black, none, black),
        table.header(
          [],
          [ALU 0],
          [ALU 1],
          [LD/ST]
        ),
        [0], [0], [0], [0],
        [1], [1], [1], [1],
        [2], [2], [*2*], [*12*],
        [3], [3], [3], [3],
        [4], [4], [4], [4],
        [5], [*9*], [*5*], [*11*],
        [6], [6], [6], [6],
        [7], [7], [7], [7],
        [8], [8], [8], [8],
        [9], [*10*], [9], [9],
        [3],
        [4],
        [5],
        [6],
        [7],
        [8],
        [9],

      )
    ]
  */
]
