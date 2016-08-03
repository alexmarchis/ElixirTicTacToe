defmodule TttServer.Player.Supervisor do
  use Supervisor

  @name TttServer.Player.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_player() do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(TttServer.Player, [], restart: :temporary)
      # currently we can't afford to have the supervisor restart the process as we won't be able to find it
      #TODO implement naming registration for Games and Players
    ]

    supervise(children, strategy: :simple_one_for_one)
    # simple_one_for_one, good for dynamically attaching processes
  end
end
