defmodule Aoc16 do
  def example() do
    """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """
  end

  def example2() do
    """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """
  end

  def part_one(input) do
    {{xd, yd}, goal, walls} = parse_maze(input)
    iterate(walls, %{{xd, yd, ?>} => 0})
    |> find_min_score(goal)
  end

  def part_two(input) do
    {{xd, yd}, goal, walls} = parse_maze(input)
    visited = iterate(walls, %{{xd, yd, ?>} => 0})
    {_, best} = find_min_score(visited, goal)

    start_pts = visited 
    |> Enum.filter(fn {{x, y, _}, v} -> {x, y} == goal and v == best end)

    visited
    |> find_path(start_pts)
    |> MapSet.size()
  end


  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("16.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp find_path(visited, to_explore, acc \\ MapSet.new())
  defp find_path(_, [], acc), do: acc
  defp find_path(visited, [{{x, y, _} = p, v} | rest], acc) do
    pts = 
      [{go_back(p), v - 1}, {rotate(p, :cw), v - 1000}, {rotate(p, :ccw), v - 1000}]
      |> Enum.filter(fn {p, v} -> visited[p] == v end)
    find_path(visited, pts ++ rest, MapSet.put(acc, {x, y}))
  end

  defp find_min_score(visited, goal) do
    visited
    |> Enum.filter(fn {{x, y, _}, _} -> {x, y} == goal end)
    |> Enum.min_by(fn {_, v} -> v end)
  end

  defp iterate(walls, visited) do
    case find_new_spots(walls, visited) do
      [] -> 
        visited

      new -> 
        iterate(
          walls, Enum.reduce(new, visited, fn {p,v}, acc -> Map.put(acc, p, v) end)
        )
    end
  end

  defp find_new_spots(walls, visited) do
    visited
    |> Enum.flat_map(
      fn {p, v} -> 
        [{proceed(p), v + 1}, {rotate(p, :cw), v + 1000}, {rotate(p, :ccw), v + 1000}] 
      end
    )
    |> Enum.reject(fn {{x, y, _}, _} -> MapSet.member?(walls, {x, y}) end)
    |> Enum.filter(fn {p, v} -> not Map.has_key?(visited, p) or v < Map.get(visited, p) end)
    |> Enum.group_by(fn {p, _} -> p end, fn {_, v} -> v end)
    |> Enum.map(fn {p, vals} -> {p, Enum.min(vals)} end)
  end

  defp proceed({x, y, ?>}), do: {x + 1, y, ?>}
  defp proceed({x, y, ?v}), do: {x, y + 1, ?v}
  defp proceed({x, y, ?^}), do: {x, y - 1, ?^}
  defp proceed({x, y, ?<}), do: {x - 1, y, ?<}

  defp go_back({x, y, d} = p) do
    {x1, y1, _} = proceed(p)
    {x - (x1 - x), y - (y1 - y), d}
  end

  defp rotate({x, y, d}, type), do: {x, y, rotate(d, type)}
  defp rotate(d, :cw), do: %{?^ => ?>, ?> => ?v, ?v => ?<, ?< => ?^}[d]
  defp rotate(d, :ccw), do: %{?^ => ?<, ?< => ?v, ?v => ?>, ?> => ?^}[d]

  defp parse_maze(input) do
    by_type = input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(
      fn {line, y} -> 
        line 
        |> String.to_charlist() 
        |> Enum.with_index() 
        |> Enum.map(fn {ch, x} -> {x, y, ch} end)
    end)
    |> Enum.group_by(fn {_, _, c} -> c end, fn {x, y, _} -> {x, y} end)

    deer = by_type[?S] |> Enum.at(0)
    goal = by_type[?E] |> Enum.at(0)
    walls = by_type[?#] |> MapSet.new()

    {deer, goal, walls}
  end
end
