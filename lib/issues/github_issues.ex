defmodule Issues.GithubIssues do
  alias HTTPoison.Response, as: Response
  alias HTTPoison.Error, as: Error

  @user_agent [{"User-agent", "Elixir"}]  
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do 
    issues_url(user, project)
      |> HTTPoison.get(@user_agent)
      |> handle_response
  end
  
  def issues_url(user, project), do: "#{@github_url}/repos/#{user}/#{project}/issues"

  def handle_response({:ok, %Response{status_code: 200, body: body}}), do: {:ok, body}
  def handle_response({:ok, %Response{status_code: ___, body: body}}), do: {:error, body}
  def handle_response({:error, %Error{reason: reason}}), do: {:error, reason}
end