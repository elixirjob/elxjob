defmodule Periodically.JobArchiver do
  use GenServer

  alias Elxjob.Jobs

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    archive_jobs()
    delete_jobs()

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp archive_jobs  do
    Jobs.archived_jobs(false)
    |> Enum.map(&handle_job/1)
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000) # In 24 hours
  end

  defp handle_job(job)  do
    if Timex.compare(Timex.today, job.actual_till) != -1 do
      Jobs.update_job(job, %{archive: true, hh_vacancy_id: nil})
    end
  end

  defp delete_jobs do
    Jobs.archived_jobs(true)
    |> Enum.map(&delete_job/1)
  end

  defp delete_job(job) do
    how_long_ago = job.actual_till |> Timex.shift(months: 12)
    if Timex.compare(how_long_ago, job.actual_till) != -1 do
      Jobs.delete_job(job)
    end
  end
end
