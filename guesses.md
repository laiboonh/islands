# Guesses

## Example usage
`update_in/2` takes a path to the nested data structure we want to update and a function to transform its value
```
iex(1)> alias IslandsEngine.{Coordinate, Guesses}
[IslandsEngine.Coordinate, IslandsEngine.Guesses]
iex(2)> guesses = Guesses.new()
%IslandsEngine.Guesses{hits: #MapSet<[]>, misses: #MapSet<[]>}
iex(3)> {:ok, coord1} = Coordinate.new(1,2)
{:ok, %IslandsEngine.Coordinate{col: 2, row: 1}}
iex(4)> {:ok, coord2} = Coordinate.new(2,2)
{:ok, %IslandsEngine.Coordinate{col: 2, row: 2}}
iex(5)> guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
%IslandsEngine.Guesses{
  hits: #MapSet<[%IslandsEngine.Coordinate{col: 2, row: 1}]>,
  misses: #MapSet<[]>
}
iex(6)> guesses = update_in(guesses.hits, &MapSet.put(&1, coord2))
%IslandsEngine.Guesses{
  hits: #MapSet<[
    %IslandsEngine.Coordinate{col: 2, row: 1},
    %IslandsEngine.Coordinate{col: 2, row: 2}
  ]>,
  misses: #MapSet<[]>
}
iex(7)> guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
%IslandsEngine.Guesses{
  hits: #MapSet<[
    %IslandsEngine.Coordinate{col: 2, row: 1},
    %IslandsEngine.Coordinate{col: 2, row: 2}
  ]>,
  misses: #MapSet<[]>
}
```