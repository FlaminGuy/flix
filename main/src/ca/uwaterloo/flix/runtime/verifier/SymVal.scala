package ca.uwaterloo.flix.runtime.verifier

import ca.uwaterloo.flix.language.ast.ExecutableAst.Expression
import ca.uwaterloo.flix.language.ast.Name

/**
  * Symbolic Values.
  */
sealed trait SymVal

object SymVal {

  /**
    * An atomic symbolic variable.
    *
    * @param ident the identifier.
    */
  case class AtomicVar(ident: Name.Ident) extends SymVal

  /**
    * The `Unit` value.
    */
  case object Unit extends SymVal

  /**
    * The `True` value.
    */
  case object True extends SymVal

  /**
    * The `False` value.
    */
  case object False extends SymVal

  /**
    * A Char value.
    */
  case class Char(lit: Int) extends SymVal

  /**
    * A Float32 value.
    */
  case class Float32(lit: Float) extends SymVal

  /**
    * A Float64 value.
    */
  case class Float64(lit: Double) extends SymVal

  /**
    * An Int8 value.
    *
    * @param lit the int literal.
    */
  case class Int8(lit: Byte) extends SymVal

  /**
    * An Int16 value.
    *
    * @param lit the int literal.
    */
  case class Int16(lit: Short) extends SymVal

  /**
    * An Int32 value.
    *
    * @param lit the int literal.
    */
  case class Int32(lit: Int) extends SymVal

  /**
    * An Int64 value.
    *
    * @param lit the int literal.
    */
  case class Int64(lit: Long) extends SymVal

  /**
    * A BigInt value.
    *
    * @param lit the int literal.
    */
  case class BigInt(lit: java.math.BigInteger) extends SymVal

  /**
    * A String value.
    *
    * @param lit the int literal.
    */
  case class Str(lit: String) extends SymVal

  /**
    * A tag value.
    *
    * @param tag the tag name.
    * @param elm the tagged value.
    */
  case class Tag(tag: String, elm: SymVal) extends SymVal

  /**
    * A tuple value.
    *
    * @param elms the elements of the tuple.
    */
  case class Tuple(elms: List[SymVal]) extends SymVal

  /**
    * A closure value.
    *
    * @param exp the expression of the closure.
    * @param env the closure environment.
    */
  case class Closure(exp: Expression.Ref, env: List[SymVal]) extends SymVal

}