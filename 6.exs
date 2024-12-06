defmodule Aoc6 do
  defmodule State do
    defstruct [:field, :x, :y, :dir]

    def iterate(%State{} = s) do
      case set_visited(s) do
        {:ok, s} -> 
          {x, y} = step(s.dir, s.x, s.y)
          case get_value(s, x, y) do
            :out -> {:halt, s}
            :obs -> {:ok, %{s | dir: rotate(s.dir)}}
            _ -> {:ok, %{s | x: x, y: y}}
          end

        err -> err
      end
    end

    def set_obs(%State{field: f} = s, x, y) do
      row = elem(f, y)
      case elem(row, x) do
        [] -> {:ok, %{s | field: put_elem(f, y, put_elem(row, x, :obs))}}
        _ -> {:err, s}
      end
    end

    defp set_visited(%State{} = s) do
      row = elem(s.field, s.y)
      visited = elem(row, s.x)
      if Enum.member?(visited, s.dir) do
        {:loop, s}
      else
        new_row = put_elem(row, s.x, [s.dir | visited])
        {:ok, %{s | field: put_elem(s.field, s.y, new_row)}}
      end
    end

    defp get_value(%{field: f}, x, y) when y < 0 or y >= tuple_size(f) or x < 0 do
      :out
    end
    defp get_value(%{field: f}, x, y) do
      row = elem(f, y)
      cond do
         x >= tuple_size(row) -> :out
         true -> elem(row, x)
      end
    end

    defp step(:up, x, y), do: {x, y - 1}
    defp step(:right, x, y), do: {x + 1, y}
    defp step(:down, x, y), do: {x, y + 1}
    defp step(:left, x, y), do: {x - 1, y}

    defp rotate(:up), do: :right
    defp rotate(:right), do: :down
    defp rotate(:down), do: :left
    defp rotate(:left), do: :up
  end
  
  def example() do
    """ 
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
  end

  def part_one(input) do
    {:ok, state} = input
    |> parse_field()
    |> simulate_guard()

    state.field
    |> Tuple.to_list()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn line -> Enum.count(line, &is_visited?/1) end)
    |> Enum.sum()
  end

  def part_two(input) do
    state = parse_field(input)

    {:halt, path} = simulate_guard(state)

    path.field
    |> Tuple.to_list()
    |> Enum.with_index()
    |> Enum.flat_map(
      fn {line, y} -> 
        line 
        |> Tuple.to_list() 
        |> Enum.with_index() 
        |> Enum.map(fn {c, x} -> {x, y, c} end)
      end)
    |> Enum.filter(fn {_, _, c} -> is_visited?(c) end)
    |> Enum.count(fn {x, y, _} -> is_block?(state, x, y) end)
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("6.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp simulate_guard({:ok, state}), do: simulate_guard(state)
  defp simulate_guard({:halt, _} = res), do: res
  defp simulate_guard({:loop, _} = res), do: res
  defp simulate_guard(state), do: simulate_guard(State.iterate(state))

  defp is_block?(%{x: x1, y: y1}, x, y) when x == x1 and y == y1, do: false
  defp is_block?(state, x, y) do
    case State.set_obs(state, x, y) do
      {:err, _} -> false
      {:ok, state} -> (state |> simulate_guard() |> elem(0)) == :loop
    end
  end

  defp is_visited?(cell), do: is_list(cell) and not Enum.empty?(cell)

  defp parse_field(input) do
    lines = input
    |> String.trim()
    |> String.split("\n")

    field = lines
    |> Enum.map(
      fn line -> 
        line 
        |> String.to_charlist()
        |> Enum.map(&Map.get(%{?# => :obs}, &1, [])) 
        |> List.to_tuple()
      end)
    |> List.to_tuple()

    {:found, {x, y, dir}} = Enum.reduce(lines, {nil, {0, 0, nil}}, &find_guard/2)
    %State{field: field, x: x, y: y, dir: dir}
  end

  defp find_guard(line_or_char, acc)
  defp find_guard(_, {:found, _} = acc), do: acc
  defp find_guard(c, {_, {x, y, _}}) when is_integer(c) do
    enc = %{?^ => :up, ?V => :down, ?> => :left, ?< => :right}
    case Map.get(enc, c) do
       nil -> {nil, {x + 1, y, nil}}
       dir -> {:found, {x, y, dir}}
    end
  end
  defp find_guard(list, {_, {_, y, _}}) when is_bitstring(list) do
    list = String.to_charlist(list)
    case Enum.reduce(list, {nil, {0, y, nil}}, &find_guard/2) do
      {:found, _} = acc -> acc
      _ -> {nil, {0, y + 1, nil}}
    end
  end
end
