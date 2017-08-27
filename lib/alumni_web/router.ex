defmodule AlumniWeb.Router do
  use AlumniWeb, :router

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

  scope "/api", AlumniWeb do
    pipe_through :api

    get "/events", EventController, :list
  end

  scope "/", AlumniWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
end
