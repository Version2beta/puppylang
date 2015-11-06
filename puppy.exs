defmodule Puppy do
  :ets.new(:vocabulary, [:named_table])

  def parse(s) when is_list(s) do
    {:ok, inputs, _} = :puppy_scan.string(s)
    inputs
  end

  def eval(inputs), do: eval(inputs, [])
  def eval([], stack), do: stack
  def eval(inputs, stack) when is_list(inputs) do
    case inputs do
      [{:number, _linenumber, number} | rest] ->
        eval(rest, [number | stack])
      [{:word, _linenumber, word} | rest] ->
        eval(rest, apply(Dictionary, word, [stack]))
      [{:startquote, _linenumber} | rest] ->
        { rest2, quoted } = stack_quote(rest)
        eval(rest2, [quoted | stack])
      [{word, _linenumber} | rest] ->
        eval(rest, apply(Dictionary, word, [stack]))
    end
  end

  def stack_quote(inputs), do: stack_quote(inputs, [])
  def stack_quote([h | inputs], quoted) do
    case h do
      {:endquote, _} -> { inputs, Enum.reverse(quoted) }
      _ -> stack_quote(inputs, [h | quoted])
    end
  end

  #def main(input, stack), do: eval(read(input), stack)

end

ExUnit.start
defmodule PuppyTest do
  use ExUnit.Case

  test "can parse an empty string" do
    assert [] == Puppy.parse('')
  end

  test "can parse a non-empty string" do
    assert [{:number, 1, 0}] == Puppy.parse('0')
    assert [{:number, 1, 0.0}] == Puppy.parse('0.0')
    assert [{:number, 1, 1}, {:number, 1, 1}, {:_add, 1}] == Puppy.parse('1 1 +')
  end

  test "with empty input, eval returns the stack unchanged" do
    assert [] == Puppy.eval([], [])
    assert [:foo, :bar] == Puppy.eval([], [:foo, :bar])
  end

  test "can parse noop" do
    assert [{:word, 1, :noop}] == Puppy.parse('noop')
  end

  test "noop makes no change to stack" do
    assert [:foo, :bar] == Puppy.eval([{:word, 0, :noop}], [:foo, :bar])
  end

  test "arithmetic" do
    assert [2] == Puppy.eval([{:_add, 0}], [1, 1])
    assert [0] == Puppy.eval([{:_add, 0}], [-1, 1])
    assert [1] == Puppy.eval([{:_subtract, 0}], [0, 1])
    assert [-1] == Puppy.eval([{:_subtract, 0}], [1, 0])
    assert [1] == Puppy.eval([{:_multiply, 0}], [1, 1])
    assert [0] == Puppy.eval([{:_multiply, 0}], [1, 0])
    assert [-1] == Puppy.eval([{:_multiply, 0}], [1, -1])
    assert [1] == Puppy.eval([{:_divide, 0}], [1, 1])
    assert [0] == Puppy.eval([{:_divide, 0}], [1, 0])
    assert [-1] == Puppy.eval([{:_divide, 0}], [1, -1])
    assert [1] == Puppy.eval([{:_exponent, 0}], [0, 2])
    assert [4] == Puppy.eval([{:_exponent, 0}], [2, -2])
    assert [1] == Puppy.eval([{:word, 0, :mod}], [2, 3])
    assert [2] == Puppy.eval([{:word, 0, :mod}], [3, 2])
    assert [42] == Puppy.parse('1 2 -3 - + 7 *') |> Puppy.eval
    assert [50] == Puppy.parse('10 5 3 mod ^ 2 /') |> Puppy.eval
  end

  test "binary comparison operators" do
    assert [:t] == Puppy.eval([{:_eq, 0}], [0, 0])
    assert [:f] == Puppy.eval([{:_eq, 0}], [0, 1])
    assert [:f] == Puppy.parse('0 1 =') |> Puppy.eval
    assert [:t] == Puppy.parse('1 1 =') |> Puppy.eval
    assert [:t] == Puppy.eval([{:_lt, 0}], [1, 0])
    assert [:f] == Puppy.eval([{:_lt, 0}], [0, 1])
    assert [:t] == Puppy.parse('0 1 <') |> Puppy.eval
    assert [:f] == Puppy.parse('1 0 <') |> Puppy.eval
    assert [:f] == Puppy.eval([{:_gt, 0}], [1, 0])
    assert [:t] == Puppy.eval([{:_gt, 0}], [0, 1])
    assert [:f] == Puppy.parse('0 1 >') |> Puppy.eval
    assert [:t] == Puppy.parse('1 0 >') |> Puppy.eval
  end

  test "dup ( a -- a a )" do
    assert [:a, :a] == Puppy.eval([{:word, 0, :dup}], [:a])
    assert [1, 1] == Puppy.parse('1 dup') |> Puppy.eval
  end

  test "swap ( a b -- b a )" do
    assert [:b, :a] == Puppy.eval([{:word, 0, :swap}], [:a, :b])
    assert [1, 2] == Puppy.parse('1 2 swap') |> Puppy.eval
  end

  test "rot ( a b c -- c a b )" do
    assert [:c, :a, :b] == Puppy.eval([{:word, 0, :rot}], [:a, :b, :c])
    assert [3, 1, 2] == Puppy.parse('3 2 1 rot') |> Puppy.eval
  end

  test "tor ( a b c -- b c a )" do
    assert [:b, :c, :a] == Puppy.eval([{:word, 0, :tor}], [:a, :b, :c])
    assert [2, 3, 1] == Puppy.parse('3 2 1 tor') |> Puppy.eval
  end

  test "over ( a b -- b a b )" do
    assert [:b, :a, :b] == Puppy.eval([{:word, 0, :over}], [:a, :b])
    assert [1, 0, 1] == Puppy.parse('1 0 over') |> Puppy.eval
  end

  test "counts properly" do
    assert [0] == Puppy.eval([{:word, 0, :depth}], [])
    assert [1, 0] == Puppy.parse('0 depth') |> Puppy.eval
  end

  test "can identify an input quote and put it in the stack as a list" do
    assert {[], [:a, :b]} == Puppy.stack_quote([:a, :b, {:endquote, 0}])
    assert {[:a, :b], []} == Puppy.stack_quote([{:endquote, 0}, :a, :b])
    assert [[:a, :b]] == Puppy.eval([{:startquote, 0}, :a, :b, {:endquote, 0}], [])
    assert [[:a, :b], 0] == Puppy.eval([{:startquote, 0}, :a, :b, {:endquote, 0}], [0])
    assert [[{:number, 1, 0}, {:word, 1, :a}], 1] == Puppy.parse('1 [ 0 a ]') |> Puppy.eval
  end

  test "call ( [a b ] -- a b )" do
    assert [:a, :b] == Puppy.eval([{:word, 0, :call}], [[:a, :b]])
  end

  test "quote ( .. -- [ .. ] )" do
    assert [[:a]] == Puppy.eval([{:word, 0, :quote}], [:a])
    assert [[0]] == Puppy.parse('0 quote') |> Puppy.eval
  end

end
