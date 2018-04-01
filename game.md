# Game

## GenServer
GenServer have 3 moving parts
- client function - public interface
- module function from GenServer - client function wraps around these
- callback function - module function does some internal work and triggers these

## To start a GenServer
- `GenServer.start(Game, %{})` - starts a GenServer process without links (outside of a supervision tree)
- `GenServer.start_link(Game, %{})` - starts a GenServer process linked to the current process
`%{}` is the initial state of the process

## Mapping between module and callback functions
- `GenServer.start_link/3` -> `GenServer.init/1`
- `GenServer.call/3` -> `GenServer.handle_call/3`
- `GenServer.cast/2` -> `GenServer.handle_cast/2`
- If we send a message via `Kernal.send/2`, `GenServer.handle_info/2` is triggered 

## Send message
```elixir
def handle_info(:first, state) do
  IO.puts "This message has been handled by handle_info/2, matching on :first"
  {:noreply, state}
end
```
Notice that the return value of `send` is the message itself. The return tuple in `handle_info` tells the GenServer behaviour that we don't need to send a message back to the caller and that the value bound to the `state` variable should become the new state of the GenServer process. 
```
iex(5)> {:ok, pid} = GenServer.start(Game, %{})
{:ok, #PID<0.145.0>}
iex(6)> send(pid, :first)
This message has been handled by handle_info/2, matching on :first
:first
```
## Call
`:demo_call` marks which `handle_call` clause to execute.
`_from` is a tuple that contains the PID of the calling process. We could use this to send message back. 
In the return value, the middle element `state` is the actual reply, the third element `state` is what we want the state of the GenServer process to be.
```elixir
def handle_call(:demo_call, _from, state) do
  {:reply, state, state}
end
```
Notice that `handle_call` returns a tuple while we only saw the server state in the console. This is because GenServer processed our callback's return value internally in order to formulate a final reply to the caller. It stripped out the `:reply` tag and useed the final `state` element to set the new state in the GenServer process.
```
iex(8)> {:ok, pid} = GenServer.start(Game, %{test: "test value"})
{:ok, #PID<0.159.0>}
iex(9)> GenServer.call(pid, :demo_call)
%{test: "test value"}
```

## Cast
```elixir
def handle_cast({:demo_cast, new_value}, state) do
  {:noreply, Map.put(state, :test, new_value)}
end
```
```
iex(11)> {:ok, pid} = GenServer.start(Game, %{test: "test value"})
{:ok, #PID<0.173.0>}
iex(12)> GenServer.cast(pid, {:demo_cast, "another value"})
:ok
iex(13)> GenServer.call(pid, :demo_call)
%{test: "another value"}
```

## Initialise
`:sys.get_state/1` can be used to get the state of a genserver process
```
iex(4)> {:ok, game} = Game.start_link("Frank")
{:ok, #PID<0.143.0>}
iex(5)> :sys.get_state
get_state/1    get_state/2
iex(5)> :sys.get_state(game)
%{
  Rules: %IslandsEngine.Rules{
    player1: :islands_not_set,
    player2: :islands_not_set,
    state: :initialized
  },
  player1: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: "Frank"
  },
  player2: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: nil
  }
}
```

`Kernal.put_in/2` will tranform values nested in a map and return the whole transformed map

## Naming GenServer Processes

### Registration via local name
`:islands_game` is only visible on the same node on which the process is spawned
Elixir does not garbage collect atoms, so the list of atoms will grow as we spawn more games.
BEAM enforces a hard limit of about a million atoms, once we hit the limit the whole node will crash.
```
ex(1)> alias IslandsEngine.Game
IslandsEngine.Game
iex(2)> GenServer.start_link(Game, "Frank", name: :islands_game)
{:ok, #PID<0.115.0>}
iex(3)> :sys.get_state(:islands_game)
%{
  player1: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: "Frank"
  },
  player2: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: nil
  },
  rules: %IslandsEngine.Rules{
    player1: :islands_not_set,
    player2: :islands_not_set,
    state: :initialized
  }
```

### Registration via Erlang's global name service
The global name registry works across all connecte nodes in the system. If we add more nodes, they will automatically know about the global registered processes.
```
iex(4)> GenServer.start_link(Game, "Frank", name: {:global, "game:Frank"})
{:ok, #PID<0.119.0>}
iex(5)> :sys.get_state({:global, "game:Frank"})
%{
  player1: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: "Frank"
  },
  player2: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: nil
  },
  rules: %IslandsEngine.Rules{
    player1: :islands_not_set,
    player2: :islands_not_set,
    state: :initialized
  }
}
```

### Registration via `Registry` module
```elixir
def start_link(name) when is_binary(name), do:
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))

defp via_tuple(name), do: 
    {:via, Registry, {Registry.Game, name}}    
```
We also need to start a Registry process when we start the IslandsEngine application.
In `application.ex`
```
children = [
      # Starts a worker by calling: IslandsEngine.Worker.start_link(arg)
      # {IslandsEngine.Worker, arg},
      {Registry, keys: :unique, name: Registry.Game}
    ]
```
```
iex(1)> alias IslandsEngine.Game
IslandsEngine.Game
iex(2)> Game.start_link("Lena")
{:ok, #PID<0.131.0>}
iex(3)> :sys.get_state({:via, Registry, {Registry.Game, "Lena"}})
%{
  player1: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: "Lena"
  },
  player2: %{
    board: %{},
    guesses: %IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>},
    name: nil
  },
  rules: %IslandsEngine.Rules{
    player1: :islands_not_set,
    player2: :islands_not_set,
    state: :initialized
  }
}
iex(4)>
    board: %{},
```