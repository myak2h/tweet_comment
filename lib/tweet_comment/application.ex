defmodule TweetComment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      TweetCommentWeb.Endpoint
      # Starts a worker by calling: TweetComment.Worker.start_link(arg)
      # {TweetComment.Worker, arg},
    ]

    :ets.new(:tweet_comment, [:set, :named_table, :public])

    :ets.insert(
      :tweet_comment,
      {:comment,
       "Here is a comment with a tweet in it. https://twitter.com/TheEllenShow/status/440322224407314432"}
    )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TweetComment.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TweetCommentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
