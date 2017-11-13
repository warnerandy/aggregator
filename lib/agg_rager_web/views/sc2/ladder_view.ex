defmodule AggRagerWeb.SC2.LadderView do
  use AggRagerWeb, :view

    def league(league) do
    	case (league) do
    		0 -> "bronze"
    		1 -> "silver"
    		2 -> "gold"
    		3 -> "platinum"
    		4 -> "diamond"
    		5 -> "master"
    		6 -> "grandmaster"
    	end
    end
end
