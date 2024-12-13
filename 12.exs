defmodule Aoc12 do
  def example() do
    """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """
  end

  def small_example() do
    """
    AAAA
    BBCD
    BBCC
    EEEC
    """
  end

  def part_one(input) do
    field = parse_input(input)

    field
    |> find_clusters()
    |> Enum.map(fn cl -> perimeter(field, cl) * square(field, cl) end)
    |> Enum.sum()
  end

  def part_two(input) do
    field = parse_input(input)

    field
    |> find_clusters()
    |> Enum.map(fn cl -> count_sides(field, cl) * square(field, cl) end)
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("12.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp find_clusters(field) do
    {rows, cols} = {tuple_size(field), tuple_size(elem(field, 0))}

    free = (0..rows-1) 
    |> Enum.flat_map(fn j -> Enum.map(0..cols-1, &({&1, j})) end)
    |> Enum.into(MapSet.new())

    find_clusters(field, [], free, [], nil, [])
  end

  defp find_clusters(field, outer, free, clusters, current, acc)
  defp find_clusters(field, [], free, clusters, nil, _) do
    case Enum.take(free, 1) do
      [] -> clusters
      [p] = outer -> find_clusters(
        field, outer, MapSet.delete(free, p), clusters, get_value(field, p), []
      )
    end
  end
  defp find_clusters(field, [], free, clusters, value, acc) do
    find_clusters(field, [], free, [{value, acc} | clusters], nil, [])
  end
  defp find_clusters(field, [p | rest], free, clusters, value, acc) do
    new_points = neighborhood(field, p)
    |> Enum.filter(
      fn p -> MapSet.member?(free, p) and get_value(field, p) == value end
    )

    free = MapSet.difference(free, MapSet.new(new_points))
    find_clusters(field, new_points ++ rest, free, clusters, value, [p | acc])
  end

  defp shape(field), do: {tuple_size(field), tuple_size(elem(field, 0))}

  defp square(_, {_, points}), do: length(points)

  defp perimeter(field, cluster), do: length(perimeter_items(field, cluster))
  
  defp count_sides(field, cluster) do
    perimeter_items(field, cluster)
    |> MapSet.new()
    |> count_sides({nil, nil}, nil, 0)
  end

  defp count_sides(items, current, dir, sum)
  defp count_sides(items, {nil, nil}, nil, sum) do
    case Enum.take(items, 1) do
      [] -> sum
      [{p, dp} = x] -> count_sides(MapSet.delete(items, x), {p, p}, dp, sum)
    end
  end
  defp count_sides(items, {nil, nil}, _, sum) do 
    count_sides(items, {nil, nil}, nil, sum + 1)
  end
  defp count_sides(items, {lp, rp}, {dx, dy} = dp, sum) do
    {lp, items} = check_side_collapse(items, lp, {1 - abs(dx), 1 - abs(dy)}, dp)
    {rp, items} = check_side_collapse(items, rp, {abs(dx) - 1, abs(dy) - 1}, dp)
    count_sides(items, {lp, rp}, dp, sum)
  end

  defp check_side_collapse(items, nil, _, _), do: {nil, items}
  defp check_side_collapse(items, {x, y}, {dx, dy}, dp) do
    entry = {{x + dx, y + dy}, dp}
    case MapSet.member?(items, entry) do
      true -> {{x + dx, y + dy}, MapSet.delete(items, entry)}
      false -> {nil, items}
    end
  end

  defp perimeter_items(field, {value, points}) do
    {rows, cols} = shape(field)

    points
    |> Enum.flat_map(
      fn p -> 
        directions()
        |> Enum.map(&({p, &1}))
        |> Enum.filter(
          fn {{x, y}, {dx, dy}} ->
            {x2, y2} = p2 = {x + dx, y + dy}
            
            x2 < 0 or x2 >= cols or y2 < 0 or y2 >= rows 
              or get_value(field, p2) != value
          end)
      end)
  end

  defp get_value(field, {x, y}), do: field |> elem(y) |> elem(x)

  defp neighborhood(map, {i, j}) do
    {rows, cols} = shape(map)

    directions()
    |> Enum.map(fn {dx, dy} -> {i + dx, j + dy} end)
    |> Enum.filter(fn {i, j} -> 0 <= i and i < rows and 0 <= j and j < cols end)
  end

  defp directions(), do: [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.to_charlist() |> List.to_tuple() end)
    |> List.to_tuple()
  end
end
