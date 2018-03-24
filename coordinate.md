# Coordinate

## alias
`alias` is lexically scoped and available within the module
Hence within the module we can do something like `%Coordinate{row: row, col: col}`

## enforce_keys
Because of `@enforce_keys` there is compile time & runtime time check that disallow calls like `%Coordinate{row: 1}` 

## module attribute
`@board_range` serves as a constant

## guard
`when row in @board_range and col in @board_range` creates a new function clause that accepts a limited set of values.