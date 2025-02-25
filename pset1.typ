#import "notes.typ": *
#show: great-theorems-init

#show: notes.with(
  title: "Computer Architecture",
  subject: "Problem Set 1",
  author: "Roland Yang",
  date: datetime(month: 2, day: 9, year: 2025)
)
#show heading: reset-counter(tcounter, levels: 2)

#set heading(numbering: none)
#set enum(indent: 1em, numbering: "a)")
#set list(indent: 1em)

== Case Study 1

#problem[ Figure 1.6 gives hypothetical relevant chip statistics that influence
 the cost of several current chips. In the next few exercises, you will be
 exploring the effect of different possible design decisions for the Intel
 chips.

 + What is the yield for the Phoenix chip?
 + Why does Phoenix have a higher defect rate than BlueDragon?
]

#solution[
  Assuming wafer yield is 100% (i.e., no bad wafers) we have
  + $"Die yield" = 1\/(1 + 0.04 times 2)^14 = 0.34$
  + The defect rate is higher because it is using a smaller node (7nm vs 10 nm).
]

#problem[ They will sell a range of chips from that factory, and they need to
 decide how much capacity to dedicate to each chip. Imagine that they will sell
 two chips. Phoenix is a completely new architecture designed with 7 nm
 technology in mind, whereas RedDragon is the same architecture as their 10 nm
 BlueDragon. Imagine that RedDragon will make a profit of \$15 per defect-free
 chip. Phoenix will make a profit of \$30 per defect-free chip. Each wafer has
 a 450 mm diameter.

  + How much profit do you make on each wafer of Phoenix chips?
  + How much profit do you make on each wafer of RedDragon chips?
  + If your demand is 50,000 RedDragon chips per month and 25,000 Phoenix chips
    per month, and your facility can fabricate 70 wafers a month, how many
    wafers should you make of each chip?
]

#solution[
  $ "Dies per wafer" = (pi d^2)/(4A) - (pi d)/sqrt(2A) =
    (pi dot 45^2)/A - (pi dot 45)/sqrt(2A) $
  + Per wafer: $(pi dot 45^2)\/(4*2) - (pi dot 45)\/sqrt(2 dot 2) = 724 dot 0.34
    = 246 dot 30 = \$7380$
  + Yield: $1\/(1 + 0.04 times 1.2)^14 = 0.52$ \
    Per wafer: $ (pi dot 45^2)/(4*1.2) - (pi dot 45)/sqrt(2 dot 1.2) = 1234 dot
      0.52 = 641 $ and $641 dot 15 = \$9615$
  + Since 25,000/ 724 = 34.5 wafers and 50,000/1234 = 40.5 wafers we should
    have a 40 RedDragon and 30 Phoenix split.
]

#problem[ Your colleague at AMD suggests that, since the yield is so poor, you
 might make chips more cheaply if you released multiple versions of the same
 chip, just with different numbers of cores. For example, you could sell
 Phoenix#super[8], Phoenix#super[4], Phoenix#super[2], and Phoenix#super[1], which
 contain 8, 4, 2, and 1 cores on each chip, respectively. If all eight cores
 are defect-free, then it is sold as Phoenix#super[8]. Chips with four to seven
 defect-free cores are sold as Phoenix#super[4], and those with two or three
 defect-free cores are sold as Phoenix#super[2]. For simplification, calculate the
 yield for a single core as the yield for a chip that is 1/8 the area of the
 original Phoenix chip. Then view that yield as an independent probability of a
 single core being defect free. Calculate the yield for each configuration as
 the probability of at the corresponding number of cores being defect
 free.

  + What is the yield for a single core being defect free as well as the yield
    for Phoenix#super[4], Phoenix#super[2] and Phoenix#super[1]?
  + Using your results from part a, determine which chips you think it would be
    worthwhile to package and sell, and why.
  + If it previously cost \$20 dollars per chip to produce Phoenix#super[8],
    what will be the cost of the new Phoenix chips, assuming that there
    are no additional costs associated with rescuing them from the trash?
  + You currently make a profit of \$30 for each defect-free Phoenix#super[8],
    and you will sell each Phoenix#super[4] chip for \$25. How much is
    your profit per Phoenix#super[8] chip if you consider (i) the purchase
    price of Phoenix#super[4] chips to be entirely profit and (ii) apply the
    profit of Phoenix#super[4] chips to each Phoenix#super[8] chip in
    proportion to how many are produced? Use the yields calculated from part
    Problem 1.3a, not from problem 1.1a. ]

#solution[ For a single core: $1\/(1 + 0.04*0.25)^14 = 0.87$ We use binomial
 probability $ P(k) = binom(8, k)(0.87)^k (1-0.87)^(8-k) $
  +
    - Phoenix#super[8]: $(0.87)^8 = 0.33$
    - Phoenix#super[4]: $0.392 + 0.205 + 0.061 + 0.011 = .67$
    - Phoenix#super[2]: $ 0.0014 + 0.0001 = .0015$
    - Phoenix#super[1]: $ 4.37 dot 10^(-6)$
  + Likely just Phoenix#super[8] and Phoenix#super[4] because the others do not
    yield enough to be worthwhile
  + Since the cost of the die is $ C_"die" = C_"wafer"/("Dies"_"Wafer" times
    "Yield" ) $ we solve for wafer cost and add the yields so $ C_"wafer" =
    C_"die" times 720 times 0.34 = \$4896 $ and then the new cost is \$6.80.
  + Since there are roughly 2 Phoenix#super[4] chips produced for each
    Phoenix#super[8] then we have $30 + 2 dot 25 = 80$ profit per chip.
]

== Exercises
#tcounter.update(7)
#problem[ You are designing a system for a real-time application in which
 specific deadlines must be met. Finishing the computation faster gains
 nothing. You find that your system can execute the necessary code, in the
 worst case, twice as fast as necessary.

  + How much energy do you save if you execute at the current speed and turn
     off the system when the computation is complete?
  + How much energy do you save if you set the voltage and frequency to be half
    as much?
]
#solution[
  + 50%
  + Depends only on voltage, and energy consumed is $\(1/2\)^2 arrow 75%$
]

#problem[ Server farms such as Google and Yahoo! provide enough
compute capacity for the highest request rate of the day. Imagine that most of
the time these servers operate at only 60% capacity. Assume further that the power
does not scale linearly with the load; that is, when the servers are operating at 60%
capacity, they consume 90% of maximum power. The servers could be turned off,
but they would take too long to restart in response to more load. A new system has
been proposed that allows for a quick restart but requires 20% of the maximum
power while in this "barely alive" state.

  + How much power savings would be achieved by turning off 60% of the servers?
  + How much power savings would be achieved by placing 60% of the servers in
    the “barely alive” state?
  + How much power savings would be achieved by reducing the voltage by 20% and
    frequency by 40%?
  + How much power savings would be achieved by placing 30% of the servers in
    the“barely alive” state and 30% off?
]
#solution[
  I don't think the answers in the solution manual are right :(

  + $60%$
  + $.60 dot .20 = .12 arrow .40 + .12 = 52%$
  + $1 - .8^2 dot .6 = 62%$
  + $.3 - .3*.2 = 24%$
]

#problem[ Availability is the most important consideration for designing
servers, followed closely by scalability and throughput.

  + We have a single processor with a failure in time (FIT) of 100. What is the
    mean time to failure (MTTF) for this system?
  + If it takes one day to get the system running again, what is the
    availability of the system?
  + Imagine that the government, to cut costs, is going to build a supercomputer
    out of inexpensive computers rather than expensive, reliable
    computers. What is the MTTF for a system with 1000 processors? Assume that
    if one fails, they all fail.
]
#solution[
  + $10^9/100 =$ 10 million hours
  + 10 million / (10 million + 24) = 99.999 (3 nines of availability)
  + Would be the MTTF of a single processor / 1000
]
