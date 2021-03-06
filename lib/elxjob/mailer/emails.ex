defmodule Elxjob.Mailer.Emails do
  import Bamboo.Email

  use Bamboo.Phoenix, view: ElxjobWeb.EmailView

  defp base_email do
    new_email()
     |> from(from_email())
     |> put_header("Reply-To", "noreply@elixirjob.ru")
     # This will use the "email.html.eex" file as a layout when rendering html emails.
     # Plain text emails will not use a layout unless you use `put_text_layout`
     |> put_html_layout({ElxjobWeb.LayoutView, "email.html"})
  end

  def moderation_email(job) do
    base_email()
      |> to(admin_email())
      |> subject("Модерация")
      |> assign(:job, job)
      |> render("moderation.html")
  end

  def vacancy_email(job) do
    base_email()
      |> to(job.email)
      |> subject("Вакансия опубликована")
      |> assign(:job, job)
      |> render("vacancy.html")
  end

  def welcome_email(recipient, id, token) do
    url = "http://elixirjob.ru/jobs/#{id}/edit?owner_token=#{token}"

    html_body =
    """
      <strong>Ваша вакансия создана.</strong>
      <br/>
      <p>Ваша ссылка для редактирования:</p>
      <p>#{url}</p>
    """
    new_email()
      |> to(recipient)
      |> from(from_email())
      |> subject("Спасибо за публикацию!")
      |> html_body(html_body)
      |> text_body("Ваша вакансия создана. \n Ваша ссылка для редактирования: \n <%= url %>")
  end

  defp admin_email do
    Application.get_env(:elxjob, :admin_email)
  end

  defp from_email do
    Application.get_env(:elxjob, :from_email)
  end
end
