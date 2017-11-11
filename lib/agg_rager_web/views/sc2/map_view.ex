defmodule AggRagerWeb.SC2.MapView do
  use AggRagerWeb, :view

  require Logger

  def date_format(date), do: date_format date, "%d %b %Y"

  def date_format(date, format), do: date_formatter(date, format)

  defp date_formatter(date, format_string) do
    date
    |> Timex.format!(format_string, :strftime )
  end

  def match_type(type) when type == "SOLO" do
  	"1v1"
  end

  def match_type(type) when type == "TWOS" do
  	"2v2"
  end

  def match_type(type) do
  	type
  end
end
