defmodule ElxjobWeb.PageController do
  use ElxjobWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def project(conn, _params) do
    render conn, "project.html"
  end

  def conditions(conn, _params) do
    render conn, "conditions.html"
  end
end
