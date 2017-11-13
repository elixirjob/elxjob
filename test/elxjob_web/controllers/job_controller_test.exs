defmodule ElxjobWeb.JobControllerTest do
  use ElxjobWeb.ConnCase
  use Bamboo.Test

  alias Elxjob.Jobs

  @update_attrs %{title: "Update job", remote: true}
  @invalid_attrs %{title: ""}

  def fixture(:job) do
    job = insert(:job)

    {:ok, job: job}
  end

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Последние вакансии"
    end

    test "render valid job", %{conn: conn} do
      job = insert(:job)
      conn = get conn, job_path(conn, :index)

      assert html_response(conn, 200) =~ job.title
    end

    test "not render archived jobs", %{conn: conn} do
      job = insert(:job, title: "Archived JOB", archive: true)

      conn = get conn, job_path(conn, :index)
      refute html_response(conn, 200) =~ job.title
    end

    test "renders only moderated jobs", %{conn: conn} do
      not_moderated_job = insert(:job, title: "Not Moderate Job", moderation: false)
      moderated_job = insert(:job)

      conn = get conn, job_path(conn, :index)

      refute html_response(conn, 200) =~ not_moderated_job.title
      assert html_response(conn, 200) =~ moderated_job.title
    end

    test "render only remote jobs", %{conn: conn} do
      remote_job = insert(:job, %{title: "RemoteJOB", remote: true})
      office_job = insert(:job, %{remote: false})
      conn = get conn, job_path(conn, :index, %{"type" => "remote", "q" => "true"})

      assert conn.assigns.total_entries == 1
      refute conn.resp_body =~ office_job.title
      assert conn.resp_body =~ remote_job.title
    end
  end

  describe "new job" do
    test "renders form", %{conn: conn} do
      conn = get conn, job_path(conn, :new)
      assert html_response(conn, 200) =~ "Название должности"
    end
  end

  describe "create job" do
    test "adds owner token", %{conn: conn} do
      post conn, job_path(conn, :create), job: job_attrs()
      new_job = Jobs.list_jobs |> List.last
      refute is_nil(new_job.owner_token)
    end

    test "redirects to index when data is valid", %{conn: conn} do
      conn = post conn, job_path(conn, :create), job: job_attrs()

      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Последние вакансии"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, job_path(conn, :create), job: @invalid_attrs
      assert html_response(conn, 200) =~ "Форма заполнена не корректно"
    end

    # TODO:
    test "call mailer" do

    end
  end

  describe "edit job" do
    setup [:create_job]

    test "renders form for editing chosen job", %{conn: conn, job: job} do
      conn = get conn, job_path(conn, :edit, job)
      assert html_response(conn, 200) =~ job.title
    end
  end

  describe "update job" do
    setup [:create_job]

    test "redirects when data is valid", %{conn: conn, job: job} do
      conn = put conn, job_path(conn, :update, job), job: @update_attrs
      assert redirected_to(conn) == job_path(conn, :show, job)

      conn = get conn, job_path(conn, :show, job)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, job: job} do
      conn = put conn, job_path(conn, :update, job), job: @invalid_attrs
      assert html_response(conn, 200) =~ "Форма заполнена не корректно"
    end
  end

  describe "delete job" do
    setup [:create_job]

    test "deletes chosen job", %{conn: conn, job: job} do
      conn = delete conn, job_path(conn, :delete, job)
      assert redirected_to(conn) == job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, job_path(conn, :show, job)
      end
    end
  end

  defp job_attrs do
    insert(:job) |> Map.from_struct()
  end

  defp create_job(_) do
    fixture(:job)
  end
end
