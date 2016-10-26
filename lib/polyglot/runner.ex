defmodule Polyglot.Runner do
  alias Polyglot.Template

  @per_page 100

  def run(username, config) do
    get_repos(username, config.token)
    |> decode
    |> repo_languages(username, config.token)
    |> count_languages_bytes
    |> output
  end

  def get_repos(username, token) do
    get_repos(username, token, 1, [])
  end

  defp get_repos(username, token,  page, acc) do
    %{body: body, headers: headers} =
      HTTPoison.get!(repos_endpoint(username, page), %{
                     "authorization" => "token #{token}"})

    next = [body | acc]

    if contain_next_page?(headers) do
      get_repos(username, token, page + 1, next)
    else
      next
    end
  end

  def decode(repos) do
    repos
    |> Enum.map(fn repo -> Poison.decode!(repo) end)
    |> List.flatten
    |> Enum.map(fn %{"name" => name} -> name end)
  end

  def repo_languages(repos, username, token) do
    repos
    |> Stream.map(fn repo ->
      HTTPoison.get!(languages_endpoint(username, repo), %{
                   "authorization" => "token #{token}"})
    end)
    |> Stream.map(fn %{body: body} -> body end)
    |> Enum.map(fn repo -> Poison.decode!(repo) end)
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

  def contain_next_page?(headers) do
    headers
    |> Enum.find(fn
      {"Link", link} -> link |> String.contains?("next")
      _ -> false
    end)
  end

  def repos_endpoint(username, page) do
    "https://api.github.com/users/#{username}/repos?per_page=#{@per_page}&page=#{page}"
  end

  def languages_endpoint(username, repo) do
    "https://api.github.com/repos/#{username}/#{repo}/languages"
  end
end
