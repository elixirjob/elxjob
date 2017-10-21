defmodule ElxjobWeb.JobController do
  use ElxjobWeb, :controller
  require IEx

  alias Elxjob.Jobs
  alias Elxjob.Jobs.Job
  alias Elxjob.Repo

  def index(conn, params) do
    query =
      if is_nil(params["type"]) || params["type"] == "" do
        Jobs.query_jobs
      else
        %{"q" => q, "type" => type} = params
        select_query(params) |> Jobs.query_jobs_with
      end

    page =
      query
      |> Repo.paginate(params)

    render conn, :index,
      page_title: "Список вакансии",
      jobs: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      q: q,
      type: type
  end

  def new(conn, _params) do
    changeset = Jobs.change_job(%Job{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job" => job_params}) do
    case Jobs.create_job(job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    IEx.pry
    job = Jobs.get_job!(id)
    render(conn, "show.html", job: job)
  end

  def edit(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    changeset = Jobs.change_job(job)
    render(conn, "edit.html", job: job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    case Jobs.update_job(job, job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", job: job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    {:ok, _job} = Jobs.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: job_path(conn, :index))
  end

  defp select_query(params) do
    case params["type"] do
      "occupation" ->
        [occupation: params["q"]]
      "location" ->
        [location: params["q"]]
      "remote" ->
        [remote: params["q"]]
      "" -> [archive: false]
    end
  end
end
