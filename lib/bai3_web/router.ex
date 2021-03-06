defmodule Bai3Web.Router do
  use Bai3Web, :router

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

  scope "/", Bai3Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/register", PageController, :register
    get "/login", PageController, :login
    get "/logout", PageController, :logout
    get "/change_password", PageController, :change_password
    get "/settings", PageController, :settings
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bai3Web do
  #   pipe_through :api
  # end
end
