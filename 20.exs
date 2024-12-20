defmodule Aoc20 do
  def example() do
    s = """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
    """
    {s, 2}
  end

  def part_one({input, saves_at_least}) do
    {start, stop, walls} = Aoc16.parse_maze(input)
    wave_from_start = make_wave(walls, start)
    wave_from_end = make_wave(walls, stop)
    path_len = wave_from_start[stop]
    walls
    |> remove_outer()
    |> Enum.flat_map(
      fn p -> 
        Aoc18.neighborhood(p)
        |> Enum.reject(&Enum.member?(walls, &1))
        |> Aoc8.pairs()
        |> Enum.flat_map(fn {p1, p2} -> [{p1, p2}, {p2, p1}] end)
        |> Enum.map(
          fn {p1, p2} -> {wave_from_start[p1] + wave_from_end[p2] + 2, p1, p2} end
        )
      end
    )
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn {t, _, _} -> t <= path_len - saves_at_least end)
    |> length()
  end

  def part_two({input, saves_at_least}) do
    {start, stop, walls} = Aoc16.parse_maze(input)
    wave_from_start = make_wave(walls, start)
    path_len = wave_from_start[stop]
    make_wave(walls, stop)
    |> Enum.map(
      fn {{x, y} = p, t} ->
        query_nearby(wave_from_start, p)
        |> Enum.map(
          fn {{x2, y2} = p2, t2} -> {t + t2 + abs(x - x2) + abs(y - y2), p, p2} 
        end)
        |> Enum.count(fn {t, _, _} -> t <= path_len - saves_at_least end)
      end
    )
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = {Aoc.Common.read_inputs("20.txt"), 100}
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp make_wave(walls, {x, y} = _from), do: make_wave(walls, [{x, y, 0}], %{})
  defp make_wave(_, [], visited), do: visited
  defp make_wave(walls, [{x, y, t} | rest], visited) do
    new_pts = Aoc18.neighborhood({x, y})
    |> Enum.reject(&(Enum.member?(walls, &1) or Map.has_key?(visited, &1)))
    |> Enum.map(fn {x1, y1} -> {x1, y1, t + 1} end)

    make_wave(walls, new_pts ++ rest, Map.put(visited, {x, y}, t))
  end

  defp remove_outer(walls) do
    max_x = walls |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = walls |> Enum.map(&elem(&1, 1)) |> Enum.max()
    Enum.filter(walls, fn {x, y} -> x > 0 and x < max_x and y > 0 and y < max_y end)
  end

  defp query_nearby(pts, {x, y}, d \\ 20) do
    -d..d
    |> Enum.flat_map(
      fn x1 -> 
        d2 = d - abs(x1)
        Enum.map(-d2..d2, &({x + x1, y + &1})) 
      end
    )
    |> gather_matched(pts, [])
  end

  defp gather_matched([], _, acc), do: acc
  defp gather_matched([p | rest], pts, acc) do
    case pts[p] do
      nil -> gather_matched(rest, pts, acc)
      v -> gather_matched(rest, pts, [{p, v} | acc])
    end
  end
end
