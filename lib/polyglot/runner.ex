defmodule Polyglot.Runner do
  alias Polyglot.Template
  alias Polyglot.Repos

  @per_page 100

  def run(username, config) do
    get_repos(username, config.token)
    |> decode
    |> repo_languages(username, config.token)
    |> count_languages_bytes
    |> output
  end

  def get_repos(username, token) do
    Repos.get_all(username, token)
  end

  def decode(repos) do
    repos
    |> Enum.map(fn repo -> Poison.decode!(repo) end)
    |> List.flatten
    |> Enum.map(fn %{"name" => name} -> name end)
  end

  def repo_languages(repos, username, token) do
    Repos.languages(repos, username, token)
  end

  def count_languages_bytes(repos) do
    repos
    |> Enum.reduce(%{}, fn repo, acc ->
      repo
      |> Map.keys
      |> Enum.reduce(acc, fn key, map ->
        Map.update(map, key, repo[key], fn value -> value + repo[key] end)
      end)
    end)
  end

  def output(languages) do
    Template.render(languages)
  end
end
