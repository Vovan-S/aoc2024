defmodule Aoc8 do
  defmodule GameMap do
    defstruct [:rows, :cols, :antennas]
  end

  def example() do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
  end

  def part_one(input) do
    calculate_with_rule(parse_input(input), &get_resonant/3)
  end

  def part_two(input) do
    calculate_with_rule(parse_input(input), &get_resonant2/3)
  end

  defp calculate_with_rule(%{cols: cols, rows: rows, antennas: antennas}, rule) do
    antennas
    |> Map.to_list()
    |> Enum.flat_map(
      fn {_, pts} -> 
        pts |> pairs() |> Enum.flat_map(fn p -> rule.(p, rows, cols) end)
    end)
    |> Enum.into(MapSet.new())
    |> MapSet.size()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("8.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp parse_input(input) do
    field = input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)

    antennas = field
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {row, y}, acc_by_row ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc_by_row, fn {c, x}, acc -> parse_cell(c, x, y, acc) end)
      end
    )

    %GameMap{antennas: antennas, rows: length(field), cols: length(Enum.at(field, 0))}
  end

  defp parse_cell(c, x, y, acc)
  defp parse_cell(?., _, _, acc), do: acc
  defp parse_cell(c, x, y, acc) do
    p = {x, y}
    Map.update(acc, c, [p], fn pts -> [p | pts] end)
  end

  defp pairs(list), do: pairs(list, [])
  defp pairs([], acc), do: acc
  defp pairs([_], acc), do: acc
  defp pairs([el | rest], acc), do: pairs(rest, acc ++ Enum.map(rest, &({el, &1}))) 

  defp get_resonant({p1, p2}, rows, cols) do
    [{p1, p2}, {p2, p1}] 
    |> Enum.map(fn {{x1, y1}, {x2, y2}} -> {x2 * 2 - x1, y2 * 2 - y1} end)
    |> Enum.filter(fn {x, y} -> 0 <= x and x < cols and 0 <= y and y < rows end)
  end

  defp get_resonant2({p1, p2}, rows, cols) do
    [{p1, p2}, {p2, p1}]
    |> Enum.flat_map(fn {p1, p2} -> get_resonant_line(p1, p2, rows, cols) end)
  end

  defp get_resonant_line({x1, y1}, {x2, y2}, rows, cols, n \\ 0, acc \\ []) do
    x = x2 + (x2 - x1) * n
    y = y2 + (y2 - y1) * n
    if 0 <= x and x < cols and 0 <= y and y < rows do
      get_resonant_line({x1, y1}, {x2, y2}, rows, cols, n + 1, [{x, y} | acc])
    else acc end
  end
end
