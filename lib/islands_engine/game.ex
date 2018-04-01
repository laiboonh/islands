defmodule IslandsEngine.Game do

  alias IslandsEngine.{Board, Guesses, Rules}

  use GenServer
"""
  def handle_info(:first, state) do
    IO.puts "This message has been handled by handle_info/2, matching on :first"
    {:noreply, state}
  end

  def handle_call(:demo_call, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:demo_cast, new_value}, state) do
    {:noreply, Map.put(state, :test, new_value)}
  end
""" 

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, Rules: Rules.new()}}
  end

  

end
