# Game

## GenServer
GenServer have 3 moving parts
- client function - public interface
- module function from GenServer - client function wraps around these
- callback function - module function does some internal work and triggers these

## To start a GenServer
- `GenServer.start(Game, %{})` - starts a GenServer process without links (outside of a supervision tree)
- `GenServer.start(Game, %{})` - starts a GenServer process linked to the current process
`%{}` is the initial state of the process

## Mapping between module and callback functions
`GenServer.start_link` -> `GenServer.init/1`
`GenServer.call/3` -> `GenServer.handle_call/3`
`GenServer.cast/2` -> `GenServer.handle_cast/2`
* if we send a message via `Kernal.send/2`, `GenServer.handle_info/2` is triggered 

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
# Call
The middle element is the actual reply, the third element is what we want the state of the GenServer process to be.
`_from` is a tuple that contains the PID of the calling process. We could use this to send message back. 
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

# Cast
```
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