defmodule Aoc14 do
  def example() do
    robots = """
      p=0,4 v=3,-3
      p=6,3 v=-1,-3
      p=10,3 v=-1,2
      p=2,0 v=2,-1
      p=0,0 v=1,3
      p=3,0 v=-2,-2
      p=7,6 v=-1,-3
      p=3,0 v=-1,-2
      p=9,3 v=2,3
      p=7,3 v=-1,2
      p=2,4 v=2,-3
      p=9,5 v=-3,-3
    """
    {robots, 7, 11}
  end

  def part_one({robots, rows, cols}) do
    robots
    |> parse_robots()
    |> Enum.map(&move(&1, rows, cols, 100))
    |> Enum.map(fn {p, _} -> quadrant(p, rows, cols) end)
    |> Enum.frequencies()
    |> Map.delete(0)
    |> Enum.map(fn {_, n} -> n end)
    |> Enum.product()
  end

  @doc """
  Kind of topological approach: we expect that this chirstmas tree will be as one
  huge cluster of connected robots. That means that number of clusters will suddenly
  drop, which we can detect by analyzing series of cluster numbers.
  """
  def part_two({robots, rows, cols}) do
    robots = parse_robots(robots)

    1..10000
    |> Enum.map(
      fn n -> 
        robots
        |> Enum.map(&move(&1, rows, cols, n))
        |> Enum.map(fn {p, _} -> p end)
        |> get_components()
        |> length()
      end
    )
    |> find_anomalies(window_size: 200)
    |> Enum.map(fn {_, n} -> n end)
  end

  def part_two_visualize({robots, rows, cols}, n) do
    robots
    |> parse_robots()
    |> Enum.map(&move(&1, rows, cols, n))
    |> print_robots(rows, cols)
    |> IO.puts()
  end

  def get_main_input(), do: {Aoc.Common.read_inputs("14.txt"), 103, 101}

  def get_result(part \\ 1) do
    input = get_main_input()
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp get_components(pts) do 
    get_components(MapSet.new(pts), [], [], [])
  end
  defp get_components(pts, current, acc, result)
  defp get_components(pts, [], [], result) do
    case Enum.take(pts, 1) do
      [] -> result
      [p] -> get_components(MapSet.delete(pts, p), [p], [], result)
    end
  end
  defp get_components(pts, [], acc, result) do
    get_components(pts, [], [], [acc | result])
  end
  defp get_components(pts, [{x, y} = p | rest], acc, result) do
    new_pts = [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]
    |> Enum.filter(&MapSet.member?(pts, &1))

    pts = MapSet.difference(pts, MapSet.new(new_pts))

    get_components(pts, new_pts ++ rest, [p | acc], result)
  end

  defp find_anomalies(ts, opts \\ []) do
    ts
    |> Enum.chunk_every(Keyword.get(opts, :window_size, 20), 1, :discard)
    |> Enum.with_index(1)
    |> Enum.filter(
      fn {[first | _] = window, _} -> 
        first < Enum.sum(window) / length(window) * Keyword.get(opts, :k, 0.5)
      end
    )
  end

  def print_robots(robots, rows, cols) do
    pts = robots
    |> Enum.map(fn {p, _} -> p end)
    |> MapSet.new()

    0..rows - 1
    |> Enum.map_join(
      "\n",
      fn y -> 
        0..cols - 1 
        |> Enum.map(fn x -> if MapSet.member?(pts, {x, y}), do: ?*, else: ?_ end)
        |> List.to_string()
      end
    )
  end

  defp move({{px, py}, {vx, vy}}, rows, cols, n) when n >= 0 do
    {{mod(px + vx * n, cols), mod(py + vy * n, rows)}, {vx, vy}}
  end

  defp mod(a, b) do
    case rem(a, b) do
      0 -> 0
      x when x > 0 -> x
      x when x < 0 -> b + x
    end
  end

  defp quadrant({x, y}, rows, cols) do
    {mx, my} = {div(cols, 2), div(rows, 2)}
    cond do
      x < mx and y < my -> 1
      x > mx and y < my -> 2
      x < mx and y > my -> 3
      x > mx and y > my -> 4
      true -> 0
    end
  end

  defp parse_robots(robots) do
    robots
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Regex.scan(~r/[-\d]+/, &1))
    |> Enum.map(&Enum.concat/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.map(fn [px, py, vx, vy] -> {{px, py}, {vx, vy}} end)
  end
end
