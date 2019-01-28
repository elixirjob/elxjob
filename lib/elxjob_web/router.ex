defmodule ElxjobWeb.Router do
  use ElxjobWeb, :router

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

  scope "/api", ElxjobWeb do
    pipe_through :api

    get "/jobs/:id/job_contacts", JobController, :job_contacts
  end

  scope "/", ElxjobWeb do
    pipe_through :browser # Use the default browser stack

    get "/", JobController, :index

    get "/pages/conditions", PageController, :conditions
    get "/pages/project", PageController, :project

    resources "/jobs", JobController
    get "/jobs/:id/approve", JobController, :approve
  end
end
