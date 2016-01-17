defmodule Dictionary do

  # error
  def error([h | _]), do: [h]

  # do nothing
  def noop(stack), do: stack

  # identity
  def _false(stack), do: [:f | stack]
  def _true(stack), do: [:t | stack]

  # arithmetic
  def _add([a | [b | t]]), do: [a+b | t]
  def _subtract([a | [b | t]]), do: [b-a | t]
  def _multiply([a | [b | t]]), do: [b*a | t]
  def _divide([a | [b | t]]), do: [b/a | t]
  def _exponent([a | [b | t]]), do: [:math.pow(b, a) | t]
  def _mod([a | [b | t]]), do: [rem(b, a) | t]

  # binary comparisons
  def _lt([a | [b | t]]), do: [(b < a && :t || :f) | t]
  def _gt([a | [b | t]]), do: [(b > a && :t || :f) | t]
  def _eq([a | [b | t]]), do: [(b == a && :t || :f) | t]

  # stack manipulation
  def depth(s), do: [ Enum.count(s) | s ]
  def drop([_ | t]), do: t
  def dup([a | t]), do: [a | [a | t]]
  def swap([a | [b | t]]), do: [b | [a | t]]
  def rot([a | [b | [c | t]]]), do: [c | [a | [b | t]]]
  def tor([a | [b | [c | t]]]), do: [b | [c | [a | t]]]
  def over([a | [b | t]]), do: [b | [a | [b | t]]]

end
