defmodule Polyglot.Template do
  def render(languages) do
    columns = size_of_columns(languages)
    total_bytes = total_languages_bytes(languages)

    IO.puts """
    #{languages
      |> Map.to_list
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.map(fn language -> render_row(language, total_bytes, columns) end)
      |> Enum.join("\n")
    }
    """
  end

  def render_row({language, bytes}, total_bytes, {col_lang, _pad, col_progress}) do
    "#{render_language_col(language, col_lang)} => #{render_progress(bytes, total_bytes, col_progress)}"
  end

  def render_language_col(name, col_size) do
    "#{name |> String.pad_leading(col_size)}"
  end

  def render_progress(value, total, col_size) do
    percentage = round((value / total) * 100)
    progress = round((percentage * (col_size - 8)) / 100)

    rendered_percentage =
      "#{percentage |> Integer.to_string |> String.pad_leading(3)}%"

    rendered_progress =
      "#{String.duplicate("#", progress) |> String.pad_trailing(col_size)}"


    "#{rendered_percentage} [#{rendered_progress}]"
  end

  def size_of_columns(languages) do
    languages_columns = languages
      |> Map.keys
      |> Enum.max_by(&String.length/1)
      |> String.length

    pad = 4

    {languages_columns, pad, terminal_width - pad - languages_columns}
  end

  def terminal_width do
    case :io.columns do
      {:ok, count} -> count
      _ -> 80
    end
  end

  def total_languages_bytes(languages) do
    languages
    |> Map.values
    |> Enum.reduce(0, &+/2)
  end
end
