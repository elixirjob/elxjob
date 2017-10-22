defmodule Elxjob.Mailer.Base do
  use Bamboo.Mailer, otp_app: :elxjob

  def send_moderation(job) do
    spawn(__MODULE__, :send_to, [job])
  end

  def send_vacancy(job) do
    spawn(__MODULE__, :send_vacancy_email, [job])
  end

  def send_to(job) do
    Elxjob.Mailer.Emails.moderation_email(job)
      |> Elxjob.Mailer.Base.deliver_later
  end

  def send_vacancy_email(job) do
    Elxjob.Mailer.Emails.vacancy_email(job)
      |> Elxjob.Mailer.Base.deliver_later
  end
end
