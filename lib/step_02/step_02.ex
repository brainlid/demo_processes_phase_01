defmodule DemoProcesses.Step02 do
  @moduledoc """
  !!!!!!!!!!!!!!!!
  """
  alias DemoProcesses.Utils

  @doc """
  Start a process and return the pid. The process can be told to remember a
  value. It can also be asked for the value it currently holds.
  """
  @spec hire_welcomer() :: pid
  def hire_welcomer do
    spawn(__MODULE__, :say_welcome, [])
  end

  @spec hire_rocker() :: pid
  def hire_rocker do
    spawn(__MODULE__, :say_rock, [])
  end

  @spec hire_sorter(low_pid :: pid, high_pid :: pid) :: pid
  def hire_sorter(low_pid, high_pid) do
    spawn(__MODULE__, :sort_messages, [low_pid, high_pid])
  end

  @doc """
  Wait for messages to process and perform an IO operation to welcome a person.
  """
  def say_welcome() do
    Process.put(:color, :magenta)
    receive do
      {:say, name} -> Utils.say("A special welcome to #{inspect name}!")
      _ -> nil
    end
    # recursively call function to wait for things to process.
    say_welcome()
  end

  @doc """
  Wait for messages to process and perform an IO operation to greet a person.
  """
  def say_rock() do
    Process.put(:color, :green)
    receive do
      {:say, name} -> Utils.say("#{inspect name}, you rock!")
      _ -> nil
    end
    # recursively call function to wait for things to process.
    say_rock()
  end

  def sort_messages(low_pid, high_pid) do
    Process.put(:color, :blue)
    receive do
      {:sort, name} ->
        cond do
          Regex.match?(~r/^[a-m]/i, name) ->
            Utils.say("Sorted #{inspect name} to LOW half", delay: :lookup)
            send(low_pid, {:say, name})
          Regex.match?(~r/^[n-z]/i, name) ->
            Utils.say("Sorted #{inspect name} to HIGH half", delay: :lookup)
            send(high_pid, {:say, name})
          true -> nil
        end
        # recursively keep processing messages
        sort_messages(low_pid, high_pid)
      _ -> nil
    after
      # if no messages left to process (2ms delay)
      2 -> Utils.say("All names sorted to processes")
    end
  end
end
