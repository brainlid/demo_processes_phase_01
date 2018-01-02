defmodule DemoProcesses.Utils do
  @moduledoc """
  Simple Util functions to help keep the demo code clearer.
  """
  alias IO.ANSI

  def clear() do
    IO.puts(ANSI.default_color() <> ANSI.clear())
  end

  @doc """
  "Say" a message. Writes to stdout using `IO.puts`. Includes the pid of the
  speaker to help make a dialog clearer.
  """
  def say(message) do
    color = Process.get(:color, :grey)
    color_func = color_func(color)
    IO.puts(color_func.() <> "#{inspect self()}: " <> message <> ANSI.default_color())
    # wait 2 seconds after saying it.
    Process.sleep(2_000)
  end

  @doc """
  Return the function to call for the desired color.
  """
  def color_func(color)
  def color_func(:grey), do: &ANSI.light_black/0
  def color_func(:blue), do: &ANSI.blue/0
  def color_func(:green), do: &ANSI.green/0
  def color_func(:magenta), do: &ANSI.magenta/0

  def color_func(other) do
    IO.puts("UNSUPPORTED COLOR: #{inspect other}")
    &ANSI.default_color/0
  end
end
