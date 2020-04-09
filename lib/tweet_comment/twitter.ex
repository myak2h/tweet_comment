defmodule TweetComment.Twitter do
  @twitter_host "twitter.com"
  @twitter_api_host "publish.twitter.com"

  def oembed(tweet_url) do
    with {:ok, %Mojito.Response{body: oembed_data}} <-
           tweet_url |> oembed_fetch_url() |> Mojito.get(),
         {:ok, data} <- Jason.decode(oembed_data) do
      {:ok, data}
    else
      {:error, %Jason.DecodeError{}} ->
        {:error, "Jason decode error for #{tweet_url}"}

      _ ->
        {:error, "oembed could not be fetched for #{tweet_url}"}
    end
  end

  def scan_for_tweet_url(comment_content) do
    comment_content
    |> String.split([" ", "\n", "\r"])
    |> Enum.reject(&(&1 == ""))
    |> Enum.filter(&is_valid_tweet_url/1)
  end

  defp oembed_fetch_url(tweet_url) do
    %URI{
      scheme: "https",
      host: @twitter_api_host,
      path: "/oembed",
      query: query_string(tweet_url)
    }
    |> URI.to_string()
  end

  defp query_string(tweet_url) do
    %{url: normalize(tweet_url)}
    |> URI.encode_query()
  end

  defp normalize(raw_tweet_url) do
    raw_tweet_url
    |> URI.parse()
    |> Map.put(:scheme, "https")
    |> Map.put(:port, 443)
    |> Map.put(:host, @twitter_host)
    |> Map.put(:query, nil)
    |> URI.to_string()
  end

  defp is_valid_tweet_url(possible_tweet_url) when is_binary(possible_tweet_url) do
    possible_tweet_url
    |> URI.parse()
    |> is_valid_tweet_url()
  end

  defp is_valid_tweet_url(%URI{
         authority: authority,
         host: host,
         path: path,
         scheme: schema
       })
       when not (is_nil(authority) or is_nil(host) or is_nil(path) or is_nil(schema)) do
    String.ends_with?(host, "twitter.com") && String.contains?(path, "/status/")
  end

  defp is_valid_tweet_url(_), do: false
end
