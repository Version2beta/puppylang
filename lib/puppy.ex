defmodule Puppy do
  require Dictionary

  def puppy(str) when is_list(str), do: parse(str) |> eval
  def puppy(str, stack) when is_list(str) and is_list(stack), do: parse(str) |> eval(stack)

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
    eval(rest, [quoted | stack])
  end
  def eval([{:quote, _linenumber} | rest], stack) do
    eval(rest, [to_char_list(Enum.join(Enum.reverse(stack), " "))])
  end
  def eval([{:cond, _linenumber} | rest], [:t | [quote | stack]]), do: eval(parse(quote) ++ rest, stack)
  def eval([{:cond, _linenumber} | rest], [:f | [_quote | stack]]), do: eval(rest, stack)
  def eval([{:call, _linenumber} | rest], [head | stack]) do
    eval(parse(head) ++ rest, stack)
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
