defmodule Polyglot.Runner do
  alias Polyglot.Template
  alias Polyglot.Repos

  def run(username, config) do
    get_repos(username, config.token)
    |> decode
    |> get_languages(username, config.token)
    |> merge_languages
    |> output
  end

  def get_repos(username, token) do
    case Repos.get_all(username, token) do
      {:ok, repos} -> repos
      {:error, :not_found} ->
        IO.puts "Username/organization #{username} not found"
        exit(:normal)
    end
  end

  def decode(repos) do
    repos
    |> Enum.map(&Map.get(&1, "name"))
  end

  def get_languages(repos, username, token) do
    Repos.languages(repos, username, token)
  end

  def merge_languages(repos) do
    repos
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  def output(languages) do
    Template.render(languages)
  end
end
