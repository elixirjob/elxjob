defmodule Elixirjob.Mailer do
  # use Bamboo.Mailer, otp_app: :elixirjob

  # def send_moderation(job) do
  #   spawn(__MODULE__, :send_to, [job])
  #   # send_to(job)
  # end

  # def send_vacancy(job) do
  #   spawn(__MODULE__, :send_vacancy_email, [job])
  # end

  # def send_to(job) do
  #   Elixirjob.Emails.moderation_email(job)
  #     |> Elixirjob.Mailer.deliver_later
  # end

  # def send_vacancy_email(job) do
  #   Elixirjob.Emails.vacancy_email(job)
  #     |> Elixirjob.Mailer.deliver_later
  # end
end
