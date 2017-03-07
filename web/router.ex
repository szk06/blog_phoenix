defmodule SimpleAuth.Router do
  use SimpleAuth.Web, :router
  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated,
       handler: SimpleAuth.GuardianErrorHandler
  end
  pipeline :admin_required do
  end
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug SimpleAuth.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  #guest zone
  scope "/", SimpleAuth do
    pipe_through :browser # Use the default browser stack
    pipe_through [:browser, :with_session]
    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    #for sessions, we need new for login
    #we need create for authentication
    # we need delete for logout
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    # registered user zone
    scope "/" do
      pipe_through [:login_required]
      resources "/users", UserController, only: [:show] do
      resources "/posts", PostController
      end
      # admin zone
      scope "/admin", Admin, as: :admin do
        pipe_through [:admin_required]
        resources "/users", UserController, only: [:index, :show] do
          resources "/posts", PostController, only: [:index, :show]
        end
      end
    end

  end
  # registered user zone


  # Other scopes may use custom stacks.
  # scope "/api", SimpleAuth do
  #   pipe_through :api
  # end
end
