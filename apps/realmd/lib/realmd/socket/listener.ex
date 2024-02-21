defmodule Realmd.Socket.Listener do
  @moduledoc """
  Module responsible for listening the sockets.
  """
  alias Realmd.Socket.Acceptor

  use GenServer

  require Logger

  @realmd_port 3724

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, args, {:continue, :listen}}
  end

  def handle_continue(:listen, state) do
    case :gen_tcp.listen(@realmd_port, [
           :binary,
           active: :once,
           reuseaddr: true,
           reuseport: true,
           reuseport_lb: true
         ]) do
      {:ok, socket} ->
        {:noreply, socket, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  def handle_continue(:accept, socket) do
    with {:ok, client_socket} <- handle_accept(socket),
         {:ok, pid} <- initialize_acceptor(socket),
         :ok <- give_up_control(client_socket, pid, socket) do
      {:noreply, socket, {:continue, :accept}}
    end
  end

  defp handle_accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        Logger.debug("Accepting new connection...")
        {:ok, client_socket}

      {:error, reason} ->
        {:stop, reason, socket}
    end
  end

  defp initialize_acceptor(socket) do
    case Acceptor.initialize_acceptor() do
      {:ok, pid} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to initialize acceptor: #{inspect(reason)}")
        {:stop, reason, socket}
    end
  end

  defp give_up_control(client_socket, pid, socket) do
    case :gen_tcp.controlling_process(client_socket, pid) do
      {:error, reason} ->
        Logger.error("Failed to give up control: #{inspect(reason)}. Stopping.")
        {:stop, reason, socket}

      :ok ->
        :ok
    end
  end
end
