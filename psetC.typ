#import "notes.typ": *
#show: great-theorems-init

#show: notes.with(
  title: "Computer Architecture",
  subject: "Problem Set C",
  author: "Roland Yang",
  date: datetime(day: 7, month: 5, year: 2025)
)
#show heading: reset-counter(tcounter, levels: 2)
#show link: set text(fill: blue)

#set heading(numbering: none)

#tcounter.update(1)
#problem[ Suppose the branch frequencies (as percentages of all instructions)
 are as follows:
  #table(
    columns: (1fr, auto),
    stroke: (x: none, y: black),
    [Conditional branches],  [15%],
    [Jumps and calls], [1%],
    [Taken conditional branches], [60% are taken],
  )
  + We are examining a four-stage pipeline where the branch is resolved at the
    end of the second cycle for unconditional branches and at the end of the
    third cycle for conditional branches. Assuming that only the first pipe
    stage can always be completed independent of whether the branch is taken
    and ignoring other pipeline stalls, how much faster would the machine be
    without any branch hazards?
  + Now assume a high-performance processor in which we have a 15-deep pipeline
    where the branch is resolved at the end of the fifth cycle for
    unconditional branches and at the end of the tenth cycle for conditional
    branches. Assuming that only the first pipe stage can always be completed
    independent of whether the branch is taken and ignoring other pipeline
    stalls, how much faster would the machine be without any branch hazards?
]
#solution[
  + Let the pipeline speedup be $P_"ideal" = "Depth" / (1 + "stall cycles")$. If
    we have a predict not-taken scheme, then the stall for untaken and
    unconditional branch is the same (1 cycle), but a taken branch incurs an
    additional cycle on top of that because the processor must flush the
    pipeline for an additional penalty. We can calculate an average stall cycle
    per instruction based on the frequency of the instructions: $(1% times 1) +
    (60% times 15% times 2) + (40% times 15% times 1) = .25$ stall cycles per
    instruction, so we would obtain a $1 + .25 = 1.25$x speedup without hazards.
  + A similar analysis, where $(1% times 4) + (60% times 15% times 9) + (40%
    times 15% times 8) = 1.33$ stall cycles per instruction, which would be a
    1.33x speedup without hazards.
]

#problem[
  We begin with a computer implemented in single-cycle implementation. When the
  stages are split by functionality, the stages do not require exactly the same
  amount of time. The original machine had a clock cycle time of 7 ns. After the
  stages were split, the measured times were IF, 1 ns; ID, 1.5 ns; EX, 1 ns; MEM,
  2 ns; and WB, 1.5 ns. The pipeline register delay is 0.1 ns.

  + What is the clock cycle time of the 5-stage pipelined machine?
  + If there is a stall every four instructions, what is the CPI of the new
    machine?
  + What is the speedup of the pipelined machine over the single-cycle machine?
  + If the pipelined machine had an infinite number of stages, what would its
    speedup be over the single-cycle machine?
]
#solution[
  + Since MEM takes 2 ns, the clock cycle time must be at least that, and with
    the register delay of 0.1 ns is 2.1 ns.
  + One stall every four instructions is 5/4 = 1.25 CPI
  + If the effective CPI of the unpipelined is 7/2.1 = 3.33, then using the
    formula $"Speedup" = "CPI"/(1 + "Stalls per isn")$ gives 3.33/(1 + 0.25) =
    2.66x speedup.
  + We would only be constrained by pipeline register delay at 0.1 ns, so
    7/0.1 = 70, 70/1 = 70x speedup.
]
