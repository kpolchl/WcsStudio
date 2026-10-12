defmodule WcsStudio.VideoProcessTest do
  use ExUnit.Case, async: true

  alias WcsStudio.VideoProcess

  describe "parse_youtube_url/1" do
    test "returns an empty string for nil" do
      assert VideoProcess.parse_youtube_url(nil) == ""
    end

    test "leaves an already-embedded URL untouched" do
      url = "https://www.youtube-nocookie.com/embed/abcdef"
      assert VideoProcess.parse_youtube_url(url) == url
    end

    test "converts a standard youtube.com watch URL" do
      assert VideoProcess.parse_youtube_url("https://www.youtube.com/watch?v=abcdef") ==
               "https://www.youtube-nocookie.com/embed/abcdef"
    end

    test "stops at an ampersand in a watch URL" do
      assert VideoProcess.parse_youtube_url(
               "https://www.youtube.com/watch?v=abcdef&feature=share"
             ) == "https://www.youtube-nocookie.com/embed/abcdef"
    end

    test "converts a short youtu.be URL" do
      assert VideoProcess.parse_youtube_url("https://youtu.be/abcdef") ==
               "https://www.youtube-nocookie.com/embed/abcdef"
    end

    test "stops at a query string in a youtu.be URL" do
      assert VideoProcess.parse_youtube_url("https://youtu.be/abcdef?t=42") ==
               "https://www.youtube-nocookie.com/embed/abcdef"
    end

    test "returns an unrecognised URL unchanged" do
      assert VideoProcess.parse_youtube_url("https://example.com/video") ==
               "https://example.com/video"
    end
  end
end
