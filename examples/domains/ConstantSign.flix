/**
 * An implementation of the sign domain lifted over the constant propagation domain.
 */
namespace Domain/ConstantSign {

    ///
    /// The elements of the constant-sign lattice.
    ///
    enum ConstantSign {
                  case Top,

        case Neg,          case Pos,

                case Cst(BigInt),

                  case Bot
    }

    ///
    /// Returns `true` iff `e1` is equal to `e2`.
    ///
    def equ(e1: ConstantSign, e2: ConstantSign): Bool = e1 == e2

    ///
    /// Returns `true` iff `e1` is less than or equal to `e2`.
    ///
    #reflexive #antiSymmetric #transitive #leastElement(Bot) #greatestElement(Top)
    def leq(e1: ConstantSign, e2: ConstantSign): Bool = match (e1, e2) with {
        case (Bot, _)           => true
        case (Cst(n1), Cst(n2)) => n1 == n2
        case (Cst(n), Neg)      => n <= 0ii
        case (Cst(n), Pos)      => n >= 0ii
        case (Neg, Neg)         => true
        case (Pos, Pos)         => true
        case (_, Top)           => true
        case _                  => false
    }

    ///
    /// Returns the least upper bound of `e1` and `e2`.
    ///
    #upperBound #leastUpperBound #commutative #associative
    def lub(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, x)           => x
        case (x, Bot)           => x
        case (Cst(n1), Cst(n2)) => switch {
            case n1 == n2                       => Cst(n1)
            case n1 >= 0ii && n2 >= 0ii         => Pos
            case n1 <= 0ii && n2 <= 0ii         => Neg
            case true                           => Top
        }
        case (Cst(n), Neg)      => if (n <= 0ii) Neg else Top
        case (Neg, Cst(n))      => if (n <= 0ii) Neg else Top
        case (Cst(n), Pos)      => if (n >= 0ii) Pos else Top
        case (Pos, Cst(n))      => if (n >= 0ii) Pos else Top
        case (Neg, Neg)         => Neg
        case (Pos, Pos)         => Pos
        case _                  => Top
    }

    ///
    /// Returns the greatest lower bound of `e1` and `e2`.
    ///
    #lowerBound #greatestLowerBound #commutative #associative
    def glb(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Top, x)           => x
        case (x, Top)           => x
        case (Cst(n1), Cst(n2)) => if (n1 == n2) Cst(n1) else Bot
        case (Neg, Cst(n))      => if (n <= 0ii) Cst(n) else Bot
        case (Cst(n), Neg)      => if (n <= 0ii) Cst(n) else Bot
        case (Pos, Cst(n))      => if (n >= 0ii) Cst(n) else Bot
        case (Cst(n), Pos)      => if (n >= 0ii) Cst(n) else Bot
        case (Neg, Neg)         => Neg
        case (Pos, Pos)         => Pos
        case (Neg, Pos)         => Cst(0ii)
        case (Pos, Neg)         => Cst(0ii)
        case _                  => Bot
    }

    ///
    /// Abstracts a concrete number into the domain.
    ///
    def alpha(i: BigInt): ConstantSign = Cst(i)

    ///
    /// Over-approximates integer `increment`.
    ///
    #safe1(x -> x + 1ii)
    #strict1 #monotone1
    def inc(e: ConstantSign): ConstantSign = match e with {
        case Bot    => Bot
        case Cst(n) => Cst(n + 1ii)
        case Neg    => Top
        case Pos    => Pos
        case Top    => Top
    }

    ///
    /// Over-approximates integer `decrement`.
    ///
    #safe1(x -> x - 1ii)
    #strict1 #monotone1
    def dec(e: ConstantSign): ConstantSign = match e with {
        case Bot    => Bot
        case Cst(n) => Cst(n - 1ii)
        case Neg    => Neg
        case Pos    => Top
        case Top    => Top
    }

    ///
    /// Over-approximates integer `addition`.
    ///
    #safe2((x, y) -> x + y)
    #strict2 #monotone2 #commutative
    def plus(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, _)           => Bot
        case (_, Bot)           => Bot
        case (Cst(n1), Cst(n2)) => Cst(n1 + n2)
        case (Cst(n1), Neg)     => if (n1 <= 0ii) Neg else Top
        case (Neg, Cst(n1))     => if (n1 <= 0ii) Neg else Top
        case (Cst(n1), Pos)     => if (n1 >= 0ii) Pos else Top
        case (Pos, Cst(n1))     => if (n1 >= 0ii) Pos else Top
        case (Neg, Neg)         => Neg
        case (Pos, Pos)         => Pos
        case _                  => Top
    }

    ///
    /// Over-approximates integer `subtraction`.
    ///
    #safe2((x, y) -> x - y)
    #strict2 #monotone2
    def minus(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, _)           => Bot
        case (_, Bot)           => Bot
        case (Cst(n1), Cst(n2)) => Cst(n1 - n2)
        case (Cst(n1), Neg)     => if (n1 >= 0ii) Pos else Top
        case (Neg, Cst(n1))     => if (n1 >= 0ii) Neg else Top
        case (Cst(n1), Pos)     => if (n1 <= 0ii) Neg else Top
        case (Pos, Cst(n1))     => if (n1 <= 0ii) Pos else Top
        case (Pos, Neg)         => Pos
        case (Neg, Pos)         => Neg
        case _                  => Top
    }

    ///
    /// Over-approximates integer `multiplication`.
    ///
    #safe2((x, y) -> x * y)
    #strict2 #monotone2 #commutative #associative
    def times(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, _)           => Bot
        case (_, Bot)           => Bot
        case (Cst(n1), Cst(n2)) => Cst(n1 * n2)
        case (Cst(0ii), _)      => Cst(0ii)
        case (_, Cst(0ii))      => Cst(0ii)
        case (Cst(n1), Neg)     => if (n1 > 0ii) Neg else Pos
        case (Neg, Cst(n1))     => if (n1 > 0ii) Neg else Pos
        case (Cst(n1), Pos)     => if (n1 < 0ii) Neg else Pos
        case (Pos, Cst(n1))     => if (n1 < 0ii) Neg else Pos
        case (Neg, Neg)         => Pos
        case (Pos, Neg)         => Neg
        case (Neg, Pos)         => Neg
        case (Pos, Pos)         => Pos
        case _                  => Top
    }

    ///
    /// Over-approximates integer `division`.
    ///
    /// NB: We cannot prove safety directly because modulus is not a total function.
    #strict2 #monotone2
    def divide(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, _)           => Bot
        case (_, Bot)           => Bot
        case (_, Cst(0ii))      => Bot
        case (Cst(0ii), _)      => Cst(0ii)
        case (Cst(n1), Cst(n2)) => Cst(n1 / n2)
        case (Cst(n1), Neg)     => if (n1 > 0ii) Neg else Pos
        case (Neg, Cst(n1))     => if (n1 > 0ii) Neg else Pos
        case (Cst(n1), Pos)     => if (n1 < 0ii) Neg else Pos
        case (Pos, Cst(n1))     => if (n1 < 0ii) Neg else Pos
        case (Neg, Neg)         => Pos
        case (Pos, Neg)         => Neg
        case (Neg, Pos)         => Neg
        case (Pos, Pos)         => Pos
        case _                  => Top
    }

    ///
    /// Over-approximates integer `modulus`.
    ///
    /// NB: We cannot prove safety directly because modulus is not a total function.
    #strict2 #monotone2
    def modulo(e1: ConstantSign, e2: ConstantSign): ConstantSign = match (e1, e2) with {
        case (Bot, _)           => Bot
        case (_, Bot)           => Bot
        case (_, Cst(0ii))      => Bot
        case (Cst(n1), Cst(n2)) => Cst(n1 % n2)
        case _                  => Top
    }

    ///
    /// Over-approximates `equal`.
    ///
    #PartialOrder.safe2((x, y) -> x == y, alpha, Belnap.alpha, Belnap.leq)
    #Bounded.strict2(Bot, Bot, Belnap/Belnap.Bot)
    #PartialOrder.monotone2(leq, leq, Belnap.leq)
    #commutative
    def eq(e1: ConstantSign, e2: ConstantSign): Belnap.Belnap = match (e1, e2) with {
        case (Bot, _)           => Belnap/Belnap.Bot
        case (_, Bot)           => Belnap/Belnap.Bot
        case (Cst(n1), Cst(n2)) => Belnap.alpha(n1 == n2)
        case (Cst(n1), Neg)     => if (n1 > 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case (Neg, Cst(n1))     => if (n1 > 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case (Cst(n1), Pos)     => if (n1 < 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case (Pos, Cst(n1))     => if (n1 < 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case _                  => Belnap/Belnap.Top
    }

    ///
    /// Over-approximates `not equal`.
    ///
    #PartialOrder.safe2((x, y) -> x != y, alpha, Belnap.alpha, Belnap.leq)
    #Bounded.strict2(Bot, Bot, Belnap/Belnap.Bot)
    #PartialOrder.monotone2(leq, leq, Belnap.leq)
    #commutative
    def neq(e1: ConstantSign, e2: ConstantSign): Belnap.Belnap = Belnap.not(eq(e1, e2))

    ///
    /// Over-approximates `less than`.
    ///
    #PartialOrder.safe2((x, y) -> x < y, alpha, Belnap.alpha, Belnap.leq)
    #Bounded.strict2(Bot, Bot, Belnap/Belnap.Bot)
    #PartialOrder.monotone2(leq, leq, Belnap.leq)
    def less(e1: ConstantSign, e2: ConstantSign): Belnap.Belnap = match (e1, e2) with {
        case (Bot, _)           => Belnap/Belnap.Bot
        case (_, Bot)           => Belnap/Belnap.Bot
        case (Cst(n1), Cst(n2)) => Belnap.alpha(n1 < n2)
        case (Cst(n1), Neg)     => if (n1 > 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case (Neg, Cst(n1))     => if (n1 > 0ii) Belnap/Belnap.True else Belnap/Belnap.Top
        case (Cst(n1), Pos)     => if (n1 < 0ii) Belnap/Belnap.True else Belnap/Belnap.Top
        case (Pos, Cst(n1))     => if (n1 < 0ii) Belnap/Belnap.False else Belnap/Belnap.Top
        case _                  => Belnap/Belnap.Top
    }

    ///
    /// Over-approximates `less than or equal`.
    ///
    #PartialOrder.safe2((x, y) -> x <= y, alpha, Belnap.alpha, Belnap.leq)
    #Bounded.strict2(Bot, Bot, Belnap/Belnap.Bot)
    #PartialOrder.monotone2(leq, leq, Belnap.leq)
    def lessEqual(e1: ConstantSign, e2: ConstantSign): Belnap.Belnap = Belnap.or(e1 `less` e2, e1 `eq` e2)

    let ConstantSign<> = (Bot, Top, equ, leq, lub, glb)


    //
    // ## Specialized Laws
    //

    law upperBound(lub: (ConstantSign, ConstantSign) -> ConstantSign): Bool = JoinLattice.upperBound(leq, lub)

    law leastUpperBound(lub: (ConstantSign, ConstantSign) -> ConstantSign): Bool = JoinLattice.leastUpperBound(leq, lub)

    law lowerBound(glb: (ConstantSign, ConstantSign) -> ConstantSign): Bool = MeetLattice.lowerBound(leq, glb)

    law greatestLowerBound(glb: (ConstantSign, ConstantSign) -> ConstantSign): Bool = MeetLattice.greatestLowerBound(leq, glb)

    law leastElement(leq: (ConstantSign, ConstantSign) -> Bool, bot: ConstantSign): Bool = Bounded.leastElement(bot, leq)

    law greatestElement(leq: (ConstantSign, ConstantSign) -> Bool, top: ConstantSign): Bool = Bounded.greatestElement(top, leq)

    law strict1(f: ConstantSign -> ConstantSign): Bool = Bounded.strict1(f, Bot, Bot)

    law strict2(f: (ConstantSign, ConstantSign) -> ConstantSign): Bool = Bounded.strict2(f, Bot, Bot, Bot)

    law monotone1(f: ConstantSign -> ConstantSign): Bool = PartialOrder.monotone1(f, leq, leq)

    law monotone2(f: (ConstantSign, ConstantSign) -> ConstantSign): Bool = PartialOrder.monotone2(f, leq, leq, leq)

    law safe1(fa: ConstantSign -> ConstantSign, fc: BigInt -> BigInt): Bool = PartialOrder.safe1(fa, fc, alpha, alpha, leq)

    law safe2(fa: (ConstantSign, ConstantSign) -> ConstantSign, fc: (BigInt, BigInt) -> BigInt): Bool = PartialOrder.safe2(fa, fc, alpha, alpha, leq)

}