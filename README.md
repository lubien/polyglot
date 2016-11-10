# Polyglot

> Know how much of what languages you've been writting on GitHub

## Build

```
mix deps.get
mix #=> aliased mix.escript_build
```

## Usage

```
Usage: polyglot username [--help]

  -t, --token   GitHub personal access token.

                GitHub limits to 60 requests in a small
                amount of time. Use a token to have a
                limit of 1000 requests.

  --forks       Count forks too
```

## TODO

- Tests
- Travis CI

## License

[MIT](LICENSE.md)
