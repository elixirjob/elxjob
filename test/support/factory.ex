defmodule Elxjob.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Elxjob.Repo

  def job_factory do
    %Elxjob.Jobs.Job{
            title: "TestJobVacancy",
      description: "description",
       occupation: 1,
           remote: false,
      actual_till: Timex.today,
            email: "tt@tt.tt",
         location: "Moscow",
       moderation: true,
          archive: false
    }
  end

  # def article_factory do
  #   %MyApp.Article{
  #     title: "Use ExMachina!",
  #     # associations are inserted when you call `insert`
  #     author: build(:user),
  #   }
  # end

  # def comment_factory do
  #   %MyApp.Comment{
  #     text: "It's great!",
  #     article: build(:article),
  #   }
  # end
end
