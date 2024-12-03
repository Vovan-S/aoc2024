defmodule Aoc.Common do
  def read_inputs(inputs_name) do
    File.read!("inputs/" <> inputs_name)
  end
end
