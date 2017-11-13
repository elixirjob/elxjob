
case Application.ensure_all_started(:ex_machina) do
    {:ok, _} -> :ok
    {:error, {_, msg}} ->
        IO.puts """
        ==========================
        Error happen when try start application: #{Enum.join(Tuple.to_list(msg), " ")}
        ==========================
        """
end

ExUnit.start()
# Ecto.Adapters.SQL.Sandbox.mode(Elxjob.Repo, :manual)

