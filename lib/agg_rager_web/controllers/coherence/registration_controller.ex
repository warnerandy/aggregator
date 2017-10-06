defmodule AggRagerWeb.Coherence.RegistrationController do
  @moduledoc """
  Handle account registration actions.

  Actions:

  * new - render the register form
  * create - create a new user account
  * edit - edit the user account
  * update - update the user account
  * delete - delete the user account
  """
  use CoherenceWeb, :controller

  alias Coherence.Messages
  alias AggRager.Coherence.Schemas

  require Logger

  @type schema :: Ecto.Schema.t
  @type conn :: Plug.Conn.t
  @type params :: Map.t

  @dialyzer [
    {:nowarn_function, update: 2},
  ]

  plug Coherence.RequireLogin when action in ~w(show edit update delete)a
  plug Coherence.ValidateOption, :registerable
  plug :scrub_params, "registration" when action in [:create, :update]

  plug :layout_view, view: Coherence.RegistrationView, caller: __MODULE__
  plug :redirect_logged_in when action in [:new, :create]

  @doc """
  Render the new user form.
  """
  @spec new(conn, params) :: conn
  def new(conn, _params) do
    user_schema = Config.user_schema
    changeset = Controller.changeset(:registration, user_schema, user_schema.__struct__)
    render(conn, :new, email: "", changeset: changeset)
  end

  @doc """
  Create the new user account.

  Creates the new user account. Create and send a confirmation if
  this option is enabled.
  """
  @spec create(conn, params) :: conn
  def create(conn, %{"registration" => registration_params} = params) do
    user_schema = Config.user_schema
    :registration
    |> Controller.changeset(user_schema, user_schema.__struct__, registration_params)
    |> Schemas.create
    |> case do
      {:ok, user} ->
        conn
        |> send_confirmation(user, user_schema)
        |> redirect_or_login(user, params, Config.allow_unconfirmed_access_for)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp redirect_or_login(conn, _user, params, 0) do
    redirect_to(conn, :registration_create, params)
  end
  defp redirect_or_login(conn, user, params, _) do
    conn
    |> Controller.login_user(user, params)
    |> redirect_to(:session_create, params)
  end

  @doc """
  Show the registration page.
  """
  @spec show(conn, any) :: conn
  def show(conn, _) do 

    user_response = get_session(conn, :auth_client)
      |> SC2.get_profile()

    api_match_response = get_session(conn, :auth_client)
      |> SC2.get_match_history(user_response)
      |> Enum.map(fn (match) -> Map.replace(match, "date", convert_date(match["date"])) end)
    
    api_ladder_response = get_session(conn, :auth_client)
      |> SC2.get_ladders(user_response)

    ladder_response = api_ladder_response
      |> Enum.map(fn (ladder) -> Map.get(ladder, "ladder") end)
      |> List.flatten
      |> Enum.map(fn (ladder) -> ladder["ladderId"] end)
      |> Enum.map(fn (ladderId) -> SC2.get_ladder(get_session(conn, :auth_client),ladderId) end)

    # user_response = get_session(conn, :auth_client)
    #   |> SC2.get_user_data()

    # Logger.info inspect user_response

    user = Map.merge(Coherence.current_user(conn), %{"profile" => user_response, "ladders" => api_ladder_response, "matches" => api_match_response})


    Coherence.update_user_login(conn, user)
    
    # Logger.info inspect ladder_response

    render(conn, "show.html", [user: user])
  end

  defp convert_date(unix_date) do
    case DateTime.from_unix(unix_date) do
      {:ok, date} ->
        DateTime.to_string(date)
    end
  end

  @doc """
  Edit the registration.
  """
  @spec edit(conn, any) :: conn
  def edit(conn, _) do
    user = Coherence.current_user(conn)
    changeset = Controller.changeset(:registration, user.__struct__, user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  @doc """
  Update the registration.
  """
  @spec update(conn, params) :: conn
  def update(conn, %{"registration" => user_params} = params) do
    user_schema = Config.user_schema
    user = Coherence.current_user(conn)
    :registration
    |> Controller.changeset(user_schema, user, user_params)
    |> Schemas.update
    |> case do
      {:ok, user} ->
        Config.auth_module
        |> apply(Config.update_login, [conn, user, [id_key: Config.schema_key]])
        |> put_flash(:info, Messages.backend().account_updated_successfully())
        |> redirect_to(:registration_update, params, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  @doc """
  Delete a registration.
  """
  @spec update(conn, params) :: conn
  def delete(conn, params) do
    user = Coherence.current_user(conn)
    conn = Controller.logout_user(conn)
    Schemas.delete! user
    redirect_to(conn, :registration_delete, params)
  end
end