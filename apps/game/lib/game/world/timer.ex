defmodule Game.World.Timer do
  @moduledoc """
  The timer process for the world.
  """
  require Logger
  use GenServer

  defstruct [:table, :current_tick]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    {:ok, %__MODULE__{table: :ets.new(__MODULE__, [:named_table, read_concurrency: true])},
     {:continue, :initialize_timer}}
  end

  def handle_continue(:initialize_timer, %__MODULE__{table: table}) do
    last_tick = System.monotonic_time(:millisecond)
    current_tick = System.monotonic_time(:millisecond)

    Logger.debug("Initializing timer [#{current_tick}].")

    :ets.insert(table,
      last_tick: last_tick,
      current_tick: current_tick
    )

    {:noreply, %__MODULE__{table: table, current_tick: current_tick}, {:continue, :update_timer}}
  end

  def handle_continue(:update_timer, %__MODULE__{table: table, current_tick: current_tick}) do
    new_current_tick = System.monotonic_time(:millisecond)
    diff = new_current_tick - current_tick

    :telemetry.execute([:game, :timer, :update], %{duration: diff})

    # If diff > 50 milliseconds, send a telemetry event.
    if diff > 50,
      do: :telemetry.execute([:game, :timer, :update], %{overcounter: diff}),
      else: Process.sleep(50 - diff)

    :ets.insert(table,
      last_tick: current_tick,
      current_tick: new_current_tick
    )

    # Logger.debug("Updating timer [#{diff}].")

    {:noreply, %__MODULE__{table: table, current_tick: new_current_tick},
     {:continue, :update_timer}}
  end
end
