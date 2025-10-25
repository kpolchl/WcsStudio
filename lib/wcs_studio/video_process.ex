defmodule WcsStudio.VideoProcess do

  def parse_youtube_url(url) when is_binary(url) do
    cond do
      # Already an embed URL
      String.contains?(url, "/embed/") ->
        url

      # Standard watch URL: https://www.youtube.com/watch?v=VIDEO_ID
      String.contains?(url, "youtube.com/watch?v=") ->
        video_id = url
                   |> String.split("watch?v=")
                   |> List.last()
                   |> String.split("&")
                   |> List.first()

        "https://www.youtube-nocookie.com/embed/#{video_id}"

      # Short URL: https://youtu.be/VIDEO_ID
      String.contains?(url, "youtu.be/") ->
        video_id = url
                   |> String.split("youtu.be/")
                   |> List.last()
                   |> String.split("?")
                   |> List.first()

        "https://www.youtube-nocookie.com/embed/#{video_id}"

      # Mobile URL: https://m.youtube.com/watch?v=VIDEO_ID
      String.contains?(url, "m.youtube.com/watch?v=") ->
        video_id = url
                   |> String.split("watch?v=")
                   |> List.last()
                   |> String.split("&")
                   |> List.first()

        "https://www.youtube-nocookie.com/embed/#{video_id}"

      # Not a YouTube URL, return as is
      true ->
        url
    end
  end

  def parse_youtube_url(nil), do: ""

end
