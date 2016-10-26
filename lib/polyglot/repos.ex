defmodule Polyglot.Repos do
  @per_page 100

  def get_all(username, token) do
    get_all(username, token, 1, [])
  end

  defp get_all(username, token,  page, acc) do
    case get(repos_endpoint(username, page), token) do
      {:error, _} = response -> response

      %{body: body, headers: headers} ->
        next = [body | acc]

        if contain_next_page?(headers) do
          get_all(username, token, page + 1, next)
        else
          {:ok, next}
        end
    end
  end

  def languages(repos, username, token) do
    repos
    |> Stream.map(&get!(languages_endpoint(username, &1), token))
    |> Stream.map(fn %{body: body} -> body end)
    |> Enum.map(&Poison.decode!/1)
  end

  defp handle_response({:ok, %{status_code: 404}}), do: {:error, :not_found}
  defp handle_response({_, response}), do: response

  defp get(url, token) do
    HTTPoison.get(url, %{"authorization" => "token #{token}"})
    |> handle_response
  end

  defp get!(url, token) do
    HTTPoison.get!(url, %{"authorization" => "token #{token}"})
  end

  defp contain_next_page?(headers) do
    headers
    |> Enum.find(fn
      {"Link", link} -> link |> String.contains?("next")
      _ -> false
    end)
  end

  defp repos_endpoint(username, page) do
    "https://api.github.com/users/#{username}/repos?per_page=#{@per_page}&page=#{page}"
  end

  defp languages_endpoint(username, repo) do
    "https://api.github.com/repos/#{username}/#{repo}/languages"
  end
end
