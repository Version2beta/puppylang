defmodule Puppy do
  require Dictionary

  def parse(s) when is_list(s) do
    {:ok, inputs, _} = :puppy_scan.string(s)
    inputs
  end

  def eval(inputs), do: eval(inputs, [])

  def eval([], stack), do: stack
  def eval([{:number, _linenumber, number} | rest], stack) do
    eval(rest, [number | stack])
  end
  def eval([{:string, _linenumber, string} | rest], stack) do
    eval(rest, [string | stack])
  end
  def eval([{:quoted, _linenumber, quoted} | rest], stack) do
    eval(rest, [parse(quoted) | stack])
  end
  def eval([{:definition, _linenumber, definition} | rest], stack) do
    [{:word, _, term} | defined] = parse definition
    Userdict.save(term, defined)
    eval(rest, stack)
  end
  def eval([{:word, _linenumber, word} | rest], stack) do
    :code.ensure_loaded(Dictionary) &&
    :erlang.function_exported(Dictionary, word, 1) &&
    eval(rest, apply(Dictionary, word, [stack])) ||
    eval(Userdict.lookup(word) ++ rest, stack)
  end
  def eval([{word, _linenumber} | rest], stack) do
    eval(rest, apply(Dictionary, word, [stack]))
  end

end
