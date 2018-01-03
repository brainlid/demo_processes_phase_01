defmodule DemoProcesses.Step00 do
  @moduledoc """
  Demonstrate a simple example of message passing.
  """
  alias DemoProcesses.Utils

  @doc """
  Start a process and return the pid. The process can be told to remember a
  value. It can also be asked for the value it currently holds.
  """
  @spec start_process() :: pid
  def start_process do
    # create the new process that executes the `remember` function. Initial
    # value is `nil`
    spawn(__MODULE__, :remember, [nil])
  end

  @doc """
  The function that the process executes and keeps executing.
  """
  @spec remember(state :: any) :: any
  def remember(state) do
    # This process always talks in :blue
    Process.put(:color, :blue)

    new_state =
      receive do
        {:remember, value} -> value
        {:value, pid} ->
          Utils.say("I am remembering #{inspect state}")
          send(pid, {:remembered, state})
        _ ->
          # any other message is ignored and keeps the same state
        state
      end
    # recursively call function passing in the value to remember.
    remember(new_state)
  end
end
