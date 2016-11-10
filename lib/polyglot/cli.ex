defmodule Polyglot.CLI do
  alias Polyglot.Runner

  @option_parser_opts [
    strict: [
      help: :boolean,
      token: :string,
      forks: :boolean,
    ],
    aliases: [
      h: :help,
      t: :token,
    ]
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    argv
    |> OptionParser.parse(@option_parser_opts)
  end

  def process({[help: true], _, _}) do
    IO.puts """
    Usage: polyglot username [--help]
    """
  end

  def process({flags, [username], _}) do
    config = %{
      token: Keyword.get(flags, :token, ""),
      forks?: Keyword.get(flags, :forks, false),
    }

    Runner.run(username, config)
  end
end
