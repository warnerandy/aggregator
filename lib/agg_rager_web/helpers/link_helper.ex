defmodule LinkHelper do

  require Logger
  @doc """
  Calls `active_link/4` with a class of "active"
  """
  def active_link(conn, controllers) do
    active_link(conn, controllers, :index, "active")
  end

    def active_link(conn, controllers, action) do
    active_link(conn, controllers, action, "active")
  end

  @doc """
  Returns the string in the 3rd argument if the expected controller
  matches the Phoenix controller that is extracted from conn. If no 3rd
  argument is passed in then it defaults to "active".

  The 2nd argument can also be an array of controllers that should
  return the active class.
  """
  def active_link(conn, controllers, actions, class) when is_list(controllers) and is_list(actions) do
    if Enum.member?(controllers, Phoenix.Controller.controller_module(conn)) && Enum.member?(actions, Phoenix.Controller.action_name(conn)) do
      class
    else
      ""
    end
  end

  def active_link(conn, controller, action, class) do
    active_link(conn, [controller], [action], class)
  end
end