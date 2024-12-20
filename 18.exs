defmodule Aoc18 do
  def example() do
    s = """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """
    {s, 7, 7, 12}
  end

  def part_one({input, rows, cols, to_simulate}) do
    input 
    |> parse_input()
    |> Enum.take(to_simulate)
    |> MapSet.new()
    |> find_path(rows, cols, [{0, 0, 0}])
    |> Map.get({cols - 1, rows - 1})
  end

  def part_two({input, rows, cols, _}) do
    input
    |> parse_input()
    |> find_max_bits(rows, cols)
  end

  def get_result(part \\ 1) do
    input = {Aoc.Common.read_inputs("18.txt"), 71, 71, 1024}
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp find_path(bits, rows, cols, to_explore, visited \\ %{}) do
    visited = to_explore 
    |> Enum.reduce(visited, fn {x, y, t}, a -> Map.put_new(a, {x, y}, t) end)

    new_pts = to_explore
    |> Enum.flat_map(
      fn {x, y, t} ->
        neighborhood({x, y})
        |> Enum.filter(
          fn {x1, y1} -> 
            x1 >= 0 and x1 < cols and y1 >= 0 and y1 < rows 
            and not MapSet.member?(bits, {x1, y1})
            and not Map.has_key?(visited, {x1, y1})
          end
        )
        |> Enum.map(fn {x1, y1} -> {x1, y1, t + 1} end)
      end
    )
    |> MapSet.new()

    cond do
      Map.has_key?(visited, {cols - 1, rows - 1}) -> visited
      MapSet.size(new_pts) == 0 -> visited
      true -> find_path(bits, rows, cols, new_pts, visited)
    end
  end

  defp restore_path(pt, visited, acc \\ [])
  defp restore_path({0, 0, 0}, _, acc), do: [{0, 0} | acc]
  defp restore_path({x, y, t}, visited, acc) do
    {x1, y1} = neighborhood({x, y})
    |> Enum.find(fn p2 -> visited[p2] == t - 1 end)
    
    restore_path({x1, y1, t - 1}, visited, [{x, y} | acc])
  end

  def neighborhood({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  defp find_max_bits(all_bits, rows, cols, lower_bound \\ 0)
  defp find_max_bits(_, _, _, nil), do: :err
  defp find_max_bits(all_bits, rows, cols, lower_bound) do
    visited = all_bits
    |> Enum.take(lower_bound)
    |> MapSet.new()
    |> find_path(rows, cols, [{0, 0, 0}])

    case visited[{cols - 1, rows - 1}] do
      nil -> 
        Enum.at(all_bits, lower_bound - 1)

      t -> 
        path = restore_path({cols - 1, rows - 1, t}, visited) |> MapSet.new()
        new_lb = Enum.find_index(all_bits, &MapSet.member?(path, &1)) + 1
        find_max_bits(all_bits, rows, cols, new_lb)
    end
  end

  defp parse_input(input_str) do
    Regex.scan(~r/(\d+),(\d+)/, input_str)
    |> Enum.map(fn [_, x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  end
end
