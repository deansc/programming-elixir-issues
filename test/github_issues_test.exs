defmodule GithubIssuesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  import Issues.GithubIssues

  test "GitHub issues repo url returned when usernmame and project are passed to issues_url." do 
    assert issues_url("deansc", "wp_roster") == "https://api.github.com/repos/deansc/wp_roster/issues"
  end

  test "handle_response should return a map composed of a status code and a body." do
    use_cassette "github_httpotion" do

      {:ok, result} = HTTPoison.get "https://api.github.com/repos/deansc/wp_roster/issues"
      assert handle_response({:ok, result}) == {:ok, Poison.decode(result.body)}
    end
  end

end
