defmodule ElxjobWeb.JobController do
  require Logger
  use ElxjobWeb, :controller
  import Elxjob.Crypto

  alias Elxjob.Jobs
  alias Elxjob.Jobs.Job
  alias Elxjob.Repo

  plug :jobs_size
  plug :scrub_params, "job" when action in [:create]

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
      page_title:    "Список вакансии",
      jobs:          page.entries,
      page_number:   page.page_number,
      page_size:     page.page_size,
      total_pages:   page.total_pages,
      total_entries: page.total_entries,
      q:             q,
      type:          type
  end

  def new(conn, _params) do
    changeset = Jobs.change_job(%Job{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job" => job_params}) do
    changeset = job_params |> Map.put("owner_token", make_token(25))

    case Jobs.create_job(changeset) do
      {:ok, job} ->
        Elxjob.Mailer.Base.send_moderation(job)
        conn
          |> put_flash(:info, "Вакансия размещена успешно. \n После модерации Вы получите письмо на указанный email.")
          |> redirect(to: job_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, errors: changeset.errors)
    end
  end

  def show(conn, %{"id" => id}) do
    case Jobs.get_job!(id) do
      :error ->
        conn
        |> put_flash(:error, "Вакансия не найдена.")
        |> redirect(to: job_path(conn, :index))
      job ->
        spawn(Jobs, :update_views, [job])
        render(conn, "show.html", job: job)
    end
  end

  def edit(conn, job_params) do
    job = Jobs.get_job!(job_params["id"])
    changeset = Jobs.change_job(job)

    case job.owner_token == job_params["owner_token"] || job_params["admin_token"] == admin_token() do
      true ->
        render(conn, "edit.html", job: job, changeset: changeset)
      _ ->
        conn
        |> put_flash(:error, "Вы не можете редактировать данную вакансию.")
        |> redirect(to: job_path(conn, :show, job))
    end
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

  def approve(conn, %{"id" => id,
                      "admin_token" => token,
                      "moderation" => result,
                      "admin" => admin}) do

    cond do
      admin_token() != token ->
        conn |> redirect(to: job_path(conn, :index))

      result == "false" ->
        delete_and_redirect(conn, id)

      true ->
        handle_update_job(conn, id, result, admin)
    end
  end

  # TODO: archived?
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

  defp jobs_size(conn, _params) do
    assign(conn, :count_jobs, length(Jobs.list_jobs))
  end

  defp admin_token do
    System.get_env("ADMIN_TOKEN")
  end

  defp delete_and_redirect(conn, id) do
    Jobs.get_job!(id) |>Jobs.delete_job()
    conn
      |> put_flash(:info, "Вакансия удалена успешно.")
      |> redirect(to: job_path(conn, :index))
  end

  defp handle_update_job(conn, id, result, admin) do
    job = Jobs.get_job!(id)
    case Jobs.update_job(job, %{"moderation" => result}) do
      {:ok, job} ->
        if admin != "true", do: Elxjob.Mailer.Base.send_vacancy(job)

        conn
          |> put_flash(:info, "Вакансия обновлена.")
          |> redirect(to: job_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", job: job, changeset: changeset)
    end
  end
end
