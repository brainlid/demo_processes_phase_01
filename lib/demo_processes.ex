defmodule DemoProcesses do
  @moduledoc """
  Documentation for DemoProcesses.
  """
  alias DemoProcesses.{Step01, Step02, Step03, Utils}

  @doc """
  Start Step01 "remembering" process and a have a short conversation with it.

  Effectively...

      pid = Step01.start_process()

      send(pid, {:remember, "Processes are powerful!"})
      send(pid, {:value, self()})

      # listen for the answer
      receive do
        {:remembered, value} ->
          # received the `value` answer
      end

  """
  def step_01 do
    Utils.clear()

    # start the process that remembers something
    pid = Step01.start_process()

    # tell the process to remember the value "Processes are powerful!"
    send(pid, {:remember, "Processes are powerful!"})
    Utils.say "Remember \"Processes are powerful!\""

    # ask the process the value it is remembering
    send(pid, {:value, self()})
    Utils.say "What are you remembering?"

    # listen for the process to respond
    receive do
      {:remembered, value} ->
        Utils.say "Thank you. I was told #{inspect value}"
      other ->
        Utils.say "Don't know what you're talking about... #{inspect other}"
    after
      5_000 -> raise("Didn't get a response after 5 seconds of waiting.")
    end
  end

  @doc """
  Simple 3 process example showing easy concurrency and handling of slower
  IO operations.
  """
  def step_02 do
    Utils.clear()

    data = ["Adam", "John", "Jill", "Beth", "Carl", "Zoe", "Juan", "Mark",
            "Tom", "Samantha", "Brandon"]

    # start the "rock" IO process
    rock_pid = Step02.hire_rocker()

    # start the "welcome" IO process
    welcome_pid = Step02.hire_welcomer()

    # start the "sorter" process, give it the other pids
    sorter_pid = Step02.hire_sorter(rock_pid, welcome_pid)

    # randomize the names and send them all to the sorter process
    Enum.each(data, fn(name) -> send(sorter_pid, {:sort, name}) end)
    IO.puts("---- All messages sent to Sorter")
    :ok
  end

  @doc """
  Redo of step_01 with a GenServer to formalize the "call" idea.
  """
  def step_03 do
    Utils.clear()

    # start the process that remembers something
    {:ok, pid} = Step03.start_link()

    # tell the process to remember the value "Processes are powerful!"
    Utils.say "Remember \"Processes are powerful!\""
    :ok = Step03.remember_sync(pid, "Processes are powerful!")

    # ask the process the value it is remembering
    Utils.say "What are you remembering?"
    value = Step03.value_sync(pid)
    Utils.say "Thank you. I was told #{inspect value}"
  end

  @doc """
  Redo of step_03 where async used intentionally.
  """
  def step_04 do
    Utils.clear()

    # start the process that remembers something
    {:ok, pid} = Step03.start_link()

    # tell the process to remember the value "Processes are powerful!"
    Utils.say "Remember \"Processes are powerful!\""
    Step03.remember_async(pid, "Processes are powerful!")
    Utils.say "Doing other stuff..."
    Utils.say "Doing other stuff, again..."

    # ask the process the value it is remembering
    Utils.say "What did I tell you to remember?"
    Step03.value_async(pid)
    receive do
      {:remembered, value} -> Utils.say "Ah right. Thanks! Got #{inspect value}"
      other -> Utils.say "Huh? #{inspect other}?"
    end
  end

end
