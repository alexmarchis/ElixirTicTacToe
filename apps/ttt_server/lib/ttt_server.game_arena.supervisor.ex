defmodule TttServer.GameArena.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(TttServer.GameArena, [GameArena]),
      supervisor(TttServer.Game.Supervisor, []),
      supervisor(TttServer.Player.Supervisor, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
