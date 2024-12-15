defmodule Aoc15 do
  defmodule State do
    defstruct [:robot, :walls, :boxes]
  end

  def small_example() do
    """
    ########
    #..O.O.#
    ##@.O..#
    #...O..#
    #.#.O..#
    #...O..#
    #......#
    ########

    <^^>>>vv<v>>v<<
    """
  end

  def small_example2() do
    """
    #######
    #...#.#
    #.....#
    #..OO@#
    #..O..#
    #.....#
    #######

    <vv<<^^<<^^
    """
  end

  def example() do
    """
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
    """
  end

  def part_one(input) do
    {state, moves} = parse_input(input)
    
    moves
    |> Enum.reduce(state, &move(&1, &2, :norm))
    |> Map.get(:boxes)
    |> Enum.map(fn {x, y} -> x + 100 * y end)
    |> Enum.sum()
  end

  def part_two(input) do
    {state, moves} = parse_input(input)
    
    moves
    |> Enum.reduce(scale(state), &move(&1, &2, :wide))
    |> Map.get(:boxes)
    |> Enum.map(fn {x, y} -> x + 100 * y end)
    |> Enum.sum()
  end

  defp scale({x, y}), do: {x * 2, y}
  defp scale(%State{} = state) do
    %State{
      robot: scale(state.robot),
      walls: state.walls |> Enum.map(&scale/1) |> MapSet.new(),
      boxes: state.boxes |> Enum.map(&scale/1) |> MapSet.new(),
    }
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("15.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp move(dir, state, scale) do
    case try_move(state, dir, scale) do
      {:ok, new_state} -> new_state
      {:cannot, _} -> state
    end
  end

  defp try_move(state, dir, scale), do: try_move(state, dir, state.robot, :robot, scale)
  defp try_move(%State{} = state, dir, p, type, :norm) do
    pn = next(p, dir)
    cond do
      MapSet.member?(state.walls, pn) -> 
        {:cannot, nil}

      MapSet.member?(state.boxes, pn) -> 
        update_state(try_move(state, dir, pn, :box, :norm), pn, p, type)

      true ->
        update_state({:ok, state}, pn, p, type)
    end
  end
  defp try_move(%State{} = state, dir, p, :robot, :wide) do
    pn = next(p, dir)
    cond do
      hit_wide(state.walls, pn) != nil -> 
        {:cannot, nil}

      (ph = hit_wide(state.boxes, pn)) != nil -> 
        case try_move_rec(state, dir, box_pts(ph, dir), []) do
          {:cannot, _} -> 
            {:cannot, nil}

          {:ok, moved} -> 
            {:ok, state} = update_state({:ok, state}, pn, p, :robot)

            new_boxes = state.boxes
            |> MapSet.difference(MapSet.new(moved))
            |> MapSet.union(MapSet.new(moved |> Enum.map(&next(&1, dir))))

            {:ok, %State{state | boxes: new_boxes}}
        end

      true ->
        update_state({:ok, state}, pn, p, :robot)
    end
  end
  defp try_move_rec(state, dir, current, acc)
  defp try_move_rec(state, _, [], acc) do 
    {:ok, Enum.filter(acc, &MapSet.member?(state.boxes, &1))}
  end
  defp try_move_rec(%State{} = state, dir, [p | rest], acc) do
    pn = next(p, dir)
    pn = if dir == ?>, do: next(pn, dir), else: pn
    cond do
      hit_wide(state.walls, pn) != nil -> 
        {:cannot, nil}

      (ph = hit_wide(state.boxes, pn)) != nil ->
        try_move_rec(state, dir, box_pts(ph, dir) ++ rest, [p | acc])

      true ->
        try_move_rec(state, dir, rest, [p | acc])
    end
  end

  defp box_pts({x, y} = p, dir) when dir == ?v or dir == ?^, do: [p, {x + 1, y}]
  defp box_pts(p, _), do: [p]

  defp hit_wide(pts, {x, y} = p) do
    cond do
      MapSet.member?(pts, p) -> p
      MapSet.member?(pts, {x - 1, y}) -> {x - 1, y}
      true -> nil
    end
  end

  defp update_state({:cannot, _} = res, _, _, _), do: res
  defp update_state({:ok, state}, pn, _, :robot), do: {:ok, %{state | robot: pn}}
  defp update_state({:ok, state}, pn, p, :box) do 
    new_boxes = state.boxes |> MapSet.delete(p) |> MapSet.put(pn)
    {:ok, %{state | boxes: new_boxes}}
  end

  defp next({x, y}, ?<), do: {x - 1, y}
  defp next({x, y}, ?>), do: {x + 1, y}
  defp next({x, y}, ?^), do: {x, y - 1}
  defp next({x, y}, ?v), do: {x, y + 1}

  defp parse_input(input) do
    [field, moves] = input |> String.trim() |> String.split("\n\n")

    by_type = field
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

    state = %State{
      robot: by_type[?@] |> Enum.at(0), 
      walls: by_type[?#] |> MapSet.new(), 
      boxes: by_type[?O] |> MapSet.new()
    }

    {state, moves |> String.replace("\n", "") |> String.to_charlist()}
  end
end
