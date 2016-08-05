defmodule WebServer.Router do
  use WebServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", WebServer do
      pipe_through :api

      post "/gamearena/player/:name", GameArenaController, :get_player
      post "/gamearena/game/:playerId", GameArenaController, :find_game
      post "/gamearena/game/place_move/:gameId/:playerId/:position", GameArenaController, :place_move
      post "/gamearena/game/get_status/:gameId/:playerId", GameArenaController, :get_status
      get "/gamearena/player/statistics/:playerId", GameArenaController, :get_player_statistics
  end
end
