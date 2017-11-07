defmodule AggRagerWeb.SC2.MapView do
  use AggRagerWeb, :view

  require Logger

  def date_format(date), do: date_format date, "%d %b %Y"

  def date_format(date, format), do: date_formatter(date, format)

  defp date_formatter(date, format_string) do
  	Logger.info "#{inspect date}, #{format_string}"
    date
    |> Timex.format!(format_string, :strftime )
  end
end
