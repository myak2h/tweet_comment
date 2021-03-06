defmodule TweetCommentWeb.Surface.CommentLiveComponent do
  use Surface.LiveComponent
  import Phoenix.HTML.Form
  alias TweetComment.Twitter
  alias TweetCommentWeb.Surface.OembedComponent
  alias Surface.Components.Raw

  def mount(socket) do
    [{:comment, comment}] = :ets.lookup(:tweet_comment, :comment)
    oembed = build_oembed(comment)

    socket =
      socket
      |> assign(:comment, comment)
      |> assign(:oembed, oembed)
      |> assign(:editing, false)

    {:ok, socket}
  end

  def updated(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={{@id}} class="container" phx-hook="TweetComment">
      <div :if={{@editing}} >
        {{ f = form_for :tweet_comment, "#", [phx_change: :update, phx_submit: :save, phx_target: @myself] }}
          <div class="comment-box">
            {{ textarea f, :comment , class: "comment-area", nrow: 3, value: @comment }}
            <OembedComponent oembed={{@oembed}}/>
            <div class="right">
              <a href="#" phx-click="cancel" phx-target={{@myself}} >Cancel</a>
              {{submit "Save" }}
            </div>
          </div>
        <#Raw></form></#Raw>
      </div>
      <div :if={{!@editing}} >
        <p>{{@comment}} </p>
        <div>
          <OembedComponent oembed={{@oembed}}/>
        </div>
        <button phx-click="edit" phx-target={{@myself}} >Edit</button>
      </div>
    </div>
    """
  end

  def handle_event("update", params, socket) do
    new_comment = params["tweet_comment"]["comment"]
    oembed = build_oembed(new_comment)

    if oembed != socket.assigns.oembed do
      {:noreply, assign(socket, oembed: oembed)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("save", params, socket) do
    new_comment = params["tweet_comment"]["comment"]
    oembed = build_oembed(new_comment)
    :ets.insert(:tweet_comment, {:comment, new_comment})
    {:noreply, assign(socket, comment: new_comment, oembed: oembed, editing: false)}
  end

  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :editing, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :editing, false)}
  end

  defp build_oembed(comment) do
    case Twitter.scan_for_tweet_url(comment) do
      [first_tweet_url | _] ->
        build_oembed_html(first_tweet_url)

      _ ->
        ""
    end
  end

  defp build_oembed_html(tweet_url) do
    case fetch_tweet_oembed(tweet_url) do
      %{"html" => html} ->
        String.replace(
          html,
          "<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>",
          ""
        )

      _ ->
        ""
    end
  end

  defp fetch_tweet_oembed(tweet_url) do
    case :ets.lookup(:tweet_comment, tweet_url) do
      [{_, oembed}] ->
        oembed

      _ ->
        do_fetch_tweet_oembed(tweet_url)
    end
  end

  defp do_fetch_tweet_oembed(tweet_url) do
    case Twitter.oembed(tweet_url) do
      {:ok, oembed} ->
        :ets.insert(:tweet_comment, {tweet_url, oembed})
        oembed

      {:error, _msg} ->
        nil
    end
  end
end
