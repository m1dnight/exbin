defmodule ExBin.PadCache do
  @moduledoc """
  A GenServer process which is used to generate easily readable names.
  Should be useful for future stuff as well which requires state.
  """
  use GenServer
  require Logger
  alias __MODULE__

  defstruct pads: %{}

  def start_link() do
    GenServer.start_link(__MODULE__, %PadCache{}, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  #######
  # API #
  #######

  def store(name, dag) do
    GenServer.call(__MODULE__, {:store, dag, name})
  end

  def fetch(name) do
    GenServer.call(__MODULE__, {:fetch, name})
  end

  #############
  # Callbacks #
  #############

  def handle_call({:store, content, name}, _from, state) do
    if byte_size(content) < 2500 do
      {:reply, :ok, %{state | pads: Map.put(state.pads, name, content)}}
    else
      {:reply, :ok, state}
    end

  end

  def handle_call({:fetch, name}, _from, state) do
    {:reply, Map.get(state.pads, name, nil), state}
  end

  def handle_cast(:dump, state) do
    IO.inspect(state, pretty: true)
    {:noreply, state}
  end

  def handle_call(m, from, state) do
    Logger.debug("Call #{inspect(m)} from #{inspect(from)} with state #{inspect(state)}")
    {:reply, :response, state}
  end

  ###########
  # Helpers #
  ###########
end
