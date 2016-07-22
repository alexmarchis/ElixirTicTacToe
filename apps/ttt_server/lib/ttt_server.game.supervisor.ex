defmodule TttServer.Game.Supervisor do
  use Supervisor

  @name TttServer.Game.Supervisor
  # Name used to identify the Game Supervisor process

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_game do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(TttServer.Game, [], restart: :temporary)
      # temporary - the child process is never restarted
    ]

    supervise(children, strategy: :simple_one_for_one)
    # one_for_one - if a child process terminates, doesn't affect other child processes. Creates game process only on start_game not init
  end
end
