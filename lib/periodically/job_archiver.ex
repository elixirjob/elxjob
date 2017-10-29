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
    Jobs.list_jobs
    |> Enum.map(fn(x) -> archive?(x) end)


    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000) # In 24 hours
  end

  defp archive?(job) do
    if Timex.compare(Timex.today, job.actual_till) != -1, do: Jobs.update_job(job, %{archive: true})
  end
end
