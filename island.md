# Island

## `case` expression revision
```elixir
def max(a,b) do
  case a>=b do
    true -> a
    false -> b
  end
end
```

## `with` expression revision
An `else` option can be given to modify what is being returned from `with`
```elixir
with {:ok, login} <- {:ok, "alice"},
  {:ok, email} <- {:ok, "some_email"} do
  %{login: login, email: email}
end
```

## Construct a list set of coordinates
We cannot use `Enum.reduce` because its possible to have invalid coordinates being generated while running through the offsets. 
[`Enum.reduce_while`](https://hexdocs.pm/elixir/Enum.html#reduce_while/3) can do the job.

## type checks
`[|] = offsets` is checking that the type of right hand side is a List the return value of the this expression is the right hand side since pattern matching is successful
The same goes for this `%Coordinate{} = upper_left`

## example usage
```
ex(1)> alias IslandsEngine.{Coordinate, Island}
[IslandsEngine.Coordinate, IslandsEngine.Island]
iex(2)> {:ok, coord1} = Coordinate.new(4,6)
{:ok, %IslandsEngine.Coordinate{col: 6, row: 4}}
iex(3)> Island.new(:l_shape, coord1)
{:ok,
 %IslandsEngine.Island{
   coordinates: #MapSet<[
     %IslandsEngine.Coordinate{col: 6, row: 4},
     %IslandsEngine.Coordinate{col: 6, row: 5},
     %IslandsEngine.Coordinate{col: 6, row: 6},
     %IslandsEngine.Coordinate{col: 7, row: 6}
   ]>,
   hit_coordinates: #MapSet<[]>
 }}
```