defmodule PhxLivePollerWeb.ErrorJSONTest do
  # use PhxLivePollerWeb.ConnCase, async: true
  use ExUnit.Case

  test "renders 404" do
    assert PhxLivePollerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PhxLivePollerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
