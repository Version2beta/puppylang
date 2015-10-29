defmodule Puppy do

  def parse(s) when is_list(s) do
    {:ok, inputs, _} = :puppy_scan.string(s)
    inputs
  end
  def eval([], stack), do: stack
  def eval(inputs, stack) when is_list(inputs) do
    [item | rest] = inputs
    eval(rest, apply(Dictionary, item, [stack]))
  end

  #def main(input, stack), do: eval(read(input), stack)

end

ExUnit.start
defmodule PuppyTest do
  use ExUnit.Case

  test "with empty input, eval returns the stack unchanged" do
    assert [] == Puppy.eval([], [])
    assert [:foo, :bar] == Puppy.eval([], [:foo, :bar])
  end

  test "noop makes no change to stack" do
    assert [:foo, :bar] == Puppy.eval([:noop], [:foo, :bar])
  end
  
  test "can parse an empty string" do
    assert [] == Puppy.parse('')
  end

  test "can parse a non-empty string" do
    assert [{:integer, 1, 0}] == Puppy.parse('0')
    assert [{:float, 1, 0.0}] == Puppy.parse('0.0')
    assert [{:integer, 1, 1}, {:integer, 1, 1}, {:+, 1}] == Puppy.parse('1 1 +')
  end

end
