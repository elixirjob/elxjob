defmodule Periodically.HhVacancyFetcher do
    use GenServer

    alias Hh.VacancyFetcher

    def start_link do
      GenServer.start_link(__MODULE__, %{})
    end

    def init(state) do
      schedule_work() # Schedule work to be performed at some point
      {:ok, state}
    end

    def handle_info(:work, state) do
      # Do the work you desire here
      VacancyFetcher.handle_vacancy_search("elixir")
      VacancyFetcher.handle_vacancy_search("erlang")

      schedule_work() # Reschedule once more
      {:noreply, state}
    end

    defp schedule_work() do
      Process.send_after(self(), :work, 24 * 60 * 60 * 1000) # In 24 hours
    end
  end
