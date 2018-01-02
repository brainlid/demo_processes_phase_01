defmodule DemoProcesses.Step03 do
  @moduledoc """
  Demonstrate a simple example of message passing using a GenServer and a `call`.
  """
  use GenServer
  alias DemoProcesses.Utils

  ###
  ### CLIENT
  ###

  @doc """
  Start a process and return the pid. The process can be told to remember a
  value. It can also be asked for the value it currently holds.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def remember_sync(server, value) do
    GenServer.call(server, {:remember, value})
  end

  def value_sync(server) do
    GenServer.call(server, :value)
  end

  def remember_async(server, value) do
    GenServer.cast(server, {:remember, value})
  end

  def value_async(server) do
    GenServer.cast(server, {:value, self()})
  end

  ###
  ### SERVER
  ###

  def init(initial_state) do
    Process.put(:color, :blue)
    {:ok, initial_state}
  end

  def handle_call({:remember, value}, _from, _state) do
    new_state = value
    Utils.say("Replying with #{inspect new_state}")
    {:reply, :ok, new_state}
  end
  def handle_call(:value, _from, state) do
    Utils.say("Replying with #{inspect state}")
    {:reply, state, state}
  end

  def handle_cast({:remember, value}, _state) do
    new_state = value
    Utils.say("Silently remembering #{inspect new_state}")
    {:noreply, new_state}
  end
  def handle_cast({:value, from}, state) do
    Utils.say("Async asked for value")
    send_value_to(from, state)
    {:noreply, state}
  end

  defp send_value_to(pid, value) do
    Utils.say("Sending #{inspect value} to #{inspect pid}")
    send(pid, {:remembered, value})
  end
end
