defmodule Userdict do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  def lookup(term) do
    GenServer.call(__MODULE__, {:lookup, term})
  end
  def save(term, definition) do
    GenServer.cast(__MODULE__, {:save, term, definition})
  end


  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, term}, _from, state) do
    { :reply,
      Map.get(state, term, [{:string, 1, 'Unknown term: ' ++ to_char_list(term)}, {:error, 1}]),
      state }
  end

  def handle_cast({:save, term, definition}, state) do
    {:noreply, save(term, definition, state)}
  end


  defp save(term, definition, state) do
    Map.put(state, term, definition)
  end

end
