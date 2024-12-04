defmodule Aoc4 do
  def example() do
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  end

  def part_one(input) do
    lines = parse_inputs(input)

    Enum.concat(
      [
        lines, 
        transpose(lines), 
        get_diagonals(lines), 
        get_diagonals(Enum.reverse(lines)),
      ]
    )
    |> Enum.flat_map(fn list -> Enum.chunk_every(list, 4, 1, :discard) end)
    |> Enum.count(fn seq -> seq == ~c"XMAS" or seq == ~c"SAMX" end)
  end

  def part_two(input) do
    input
    |> parse_inputs()
    |> Enum.map(fn list -> Enum.chunk_every(list, 3, 1, :discard) end)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn list -> list |> Enum.zip() |> Enum.count(&is_xmas?/1) end)
    |> Enum.sum()
  end

  def get_result(part \\ 1) do
    input = Aoc.Common.read_inputs("4.txt")
    case part do
      1 -> part_one(input)
      2 -> part_two(input)
    end
  end

  defp transpose(lines) do
    lines
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp get_diagonals(lines) do
    upper = get_upper_half_diagonals(lines)

    lower = lines
    |> transpose()
    |> get_upper_half_diagonals()
    |> Enum.drop(1)

    (upper ++ lower)
    |> Enum.filter(fn list -> length(list) >= 4 end)
  end

  defp get_upper_half_diagonals(lines) do
    lines
    |> Enum.with_index(fn line, i -> Enum.drop(line, i) ++ pad(i) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn list -> Enum.reject(list, &is_nil/1) end)
  end

  defp pad(0), do: []
  defp pad(n), do: Enum.map(1..n, fn _ -> nil end)

  defp parse_inputs(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
  end

  defp is_xmas?({[a11, _, a13], [_, a22, _], [a31, _, a33]}) do
    is_mas?([a11, a22, a33]) and is_mas?([a13, a22, a31])
  end

  defp is_mas?(list), do: list == ~c"MAS" or list == ~c"SAM"
end
