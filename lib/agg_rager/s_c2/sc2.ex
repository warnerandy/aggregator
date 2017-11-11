defmodule SC2 do

	require Logger

	alias AggRager.SC2.Season
	alias AggRager.SC2.Player
	alias AggRager.SC2.Match
	alias AggRager.SC2.PlayerSeason

	def get_current_season(client) do
		client 
			|> make_oauth_request("https://us.api.battle.net/data/sc2/season/current")
	end

	def get_ladder(client, id) when not is_nil(id) do
		client 
			|> make_oauth_request("https://us.api.battle.net/data/sc2/ladder/#{id}")
	end

	def get_profile(client) do
		client 
			|> make_oauth_request("https://us.api.battle.net/sc2/profile/user")
			|> Map.get("characters")
			|> Enum.map(fn character -> Map.take(character, ["id", "realm", "name", "displayName", "clanName", "clanTag", "career", "season"]) end)
	end

	def get_ladders(client, player) do
		api_key = CoherenceAssent.config("battle_net")[:client_id]
		
		make_api_request("https://us.api.battle.net/sc2/profile/#{player.player_id}/#{player.realm}/#{player.display_name}/ladders?apikey=#{api_key}")
			|> Map.get("currentSeason")
			|> Enum.filter(fn(ladder) -> length(ladder["ladder"]) > 0 end)
	end

	def get_match_history(_client, user_struct) do
		api_key = CoherenceAssent.config("battle_net")[:client_id]

		%Player{:display_name => displayName, :player_id => id, :realm => realm} = user_struct
		
		make_api_request("https://us.api.battle.net/sc2/profile/#{id}/#{realm}/#{displayName}/matches?apikey=#{api_key}")
			|> Map.get("matches")
	end

	def get_user_data(client) do
		client 
			|> make_oauth_request("https://us.api.battle.net/data/sc2/character/MooCow-1765/1265837")
	end

	defp make_oauth_request(client, url) do
		Logger.info url
		case OAuth2.Client.get(client, url) do
			{:ok, resp} -> resp.body
			{:error, %OAuth2.Response{body: body}} ->
				Logger.info "Something bad happened: #{inspect body}"
				%{}
			{:error, %OAuth2.Error{reason: reason}} ->
				Logger.info "#{reason}"
				%{}
		end
	end

	defp make_api_request(url) do
		case HTTPoison.get(url) do
		  {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
		    body |> Poison.decode!
		  {:ok, %HTTPoison.Response{status_code: 404}} ->
		   "Not found :("
		  {:error, %HTTPoison.Error{reason: reason}} ->
		    reason
		end
	end

	def get_match_stats(match_stats) do
		match_stats
		|> Enum.group_by(&(Map.get(&1,:map)), &(Map.get(&1,:decision)))
		|> Enum.map(fn ({map,results}) -> 
			total = Enum.count(results)
			wins = Enum.count(Enum.filter(results,&(&1 == "WIN")))
			losses = total - wins
			{map, [total: total, wins: wins, losses: losses, pct: round(Float.floor((wins/total) * 100))]} end)
	end

	def get_recent_record(match_stats) do

		
		total_matches = Enum.count(match_stats)
		wins = Enum.count(Enum.filter(match_stats, &(Map.get(&1,:decision) == "WIN")))

		record_by_date = get_record_by_date(match_stats)

		[
			overall: [
				total: total_matches,
				wins: wins,
				losses: (total_matches - wins)
				],
			by_date: record_by_date
		]
	end

	def get_record_by_date(match_stats) do
		match_stats
		|> Enum.group_by(fn (match) ->
			(DateTime.to_date(Map.get(match, :date))) end, &(Map.get(&1,:decision)))
		|> Enum.map(fn ({date,results}) -> 
			total = Enum.count(results)
			wins = Enum.count(Enum.filter(results,&(&1 == "WIN")))
			{date, [total: total, wins: wins, losses: total - wins]} end)
		|> Enum.sort(&(Date.compare(elem(&1,0), elem(&2,0)) == :lt))
		|> Enum.reverse
	end

end