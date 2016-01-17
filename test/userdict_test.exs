defmodule UserdictTest do
  use ExUnit.Case

  setup do
    Userdict.start_link
    :ok
  end

  test "can save and recall a term" do
    Userdict.save(:test, [:save, :recall])
    assert [:save, :recall] == Userdict.lookup(:test)
  end

  test "returns term unknown error for undefined term" do
    assert [{:string, 1, 'Unknown term: undefined'}, {:error, 1}] == Userdict.lookup(:undefined)
  end
end
