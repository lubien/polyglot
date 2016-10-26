defmodule Polyglot.Repos do
  def get_all(username, token) do
    get_all(username, token, 1, [])
  end

  defp get_all(username, token,  page, acc) do
    %{body: body, headers: headers} =
      HTTPoison.get!(repos_endpoint(username, page), %{
                     "authorization" => "token #{token}"})

    next = [body | acc]

    if contain_next_page?(headers) do
      get_all(username, token, page + 1, next)
    else
      next
    end
  end

  def contain_next_page?(headers) do
    headers
    |> Enum.find(fn
      {"Link", link} -> link |> String.contains?("next")
      _ -> false
    end)
  end

  def languages(repos, username, token) do
    repos
    |> Stream.map(fn repo ->
      HTTPoison.get!(languages_endpoint(username, repo), %{
                   "authorization" => "token #{token}"})
    end)
    |> Stream.map(fn %{body: body} -> body end)
    |> Enum.map(fn repo -> Poison.decode!(repo) end)
  end

  def repos_endpoint(username, page) do
    "https://api.github.com/users/#{username}/repos?per_page=#{@per_page}&page=#{page}"
  end

  def languages_endpoint(username, repo) do
    "https://api.github.com/repos/#{username}/#{repo}/languages"
  end
end
