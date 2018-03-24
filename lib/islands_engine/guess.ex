defmodule IslandsEngine.Guess do
  alias __MODULE__

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new(), do:
    %Guess{hits: MapSet.new(), misses: MapSet.new()}
end  