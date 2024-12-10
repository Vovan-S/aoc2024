defmodule Aoc10 do
  def example() do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end

  def part_one(input) do
    input = parse_input(input)

    input
    |> find_zeros()
    |> Enum.map(fn p -> climb_up(make_map(input), 1, MapSet.new([p])) end)
    |> Enum.map(fn pts -> MapSet.size(pts) end)
    |> Enum.sum()
  end

  def part_two(input) do
    input = parse_input(input)

    input
    |> find_zeros()
    |> Enum.map(
      fn {i, j} -> climb_up_unique(make_map(input), 1, MapSet.new([{i, j, 1}])) end
    )
    |> Enum.map(fn pts -> pts |> Enum.map(fn {_, _, n} -> n end) |> Enum.sum() end)
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("10.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end
  
  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.map(&1, fn el -> el - ?0 end))
  end

  defp make_map(input), do: input |> Enum.map(&List.to_tuple/1) |> List.to_tuple()

  defp find_zeros(field) when is_list(field) do
    field
    |> Enum.with_index()
    |> Enum.flat_map(
      fn {list, i} -> 
        list |> Enum.with_index() |> Enum.map(fn {el, j} -> {el, i, j} end)
    end)
    |> Enum.filter(fn {el, _, _} -> el == 0 end)
    |> Enum.map(fn {_, i, j} -> {i, j} end)
  end

  defp climb_up(map, level, points)
  defp climb_up(_, 10, points), do: points
  defp climb_up(map, level, points) do
    points = points
    |> Enum.flat_map(fn {i, j} -> neighborhood(map, i, j) end)
    |> Enum.filter(fn {_, _, el} -> el == level end)
    |> Enum.map(fn {i, j, _} -> {i, j} end)
    |> Enum.into(MapSet.new())

    climb_up(map, level + 1, points)
  end

  defp neighborhood(map, i, j) do
    rows = tuple_size(map)
    cols = tuple_size(elem(map, 0))
    [{i + 1, j}, {i, j + 1}, {i - 1, j}, {i, j - 1}]
    |> Enum.filter(fn {i, j} -> 0 <= i and i < rows and 0 <= j and j < cols end)
    |> Enum.map(fn {i, j} -> {i, j, map |> elem(i) |> elem(j)} end)
  end

  defp climb_up_unique(map, level, points)
  defp climb_up_unique(_, 10, points), do: points
  defp climb_up_unique(map, level, points) do
    points = points
    |> Enum.flat_map(
      fn {i, j, ord} -> 
        neighborhood(map, i, j) 
        |> Enum.map(fn {i1, j1, el} -> {i1, j1, el, ord} end)
    end)
    |> Enum.filter(fn {_, _, el, _} -> el == level end)
    |> Enum.reduce(
      %{}, 
      fn {i, j, _, ord}, acc -> 
        Map.put(acc, {i, j}, Map.get(acc, {i, j}, 0) + ord) 
      end
    )
    |> Map.to_list()
    |> Enum.map(fn {{i, j}, ord} -> {i, j, ord} end)

    climb_up_unique(map, level + 1, points)
  end
end
