defmodule TttServer do
  use Application

  def start(_type, _args) do
    TttServer.GameArena.Supervisor.start_link
  end
end
