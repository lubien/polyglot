defmodule Polyglot.CLI do
  alias Polyglot.Runner

  @option_parser_opts [
    strict: [
      help: :boolean,
    ],
    aliases: [
      h: :help,
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

  def process({_, [username], _}) do
    Runner.run(username)
  end
end
