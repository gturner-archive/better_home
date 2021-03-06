require 'rake'

task :update_db => :environment do
    puts 'Updating database..'

    # Score.destroy_all

    neighborhoods = ["mission", "bernal heights", "central richmond", "excelsior", "bayview", "central sunset", "downtown", "pacific heights", "nob hill", "visitacion valley", "parkside", "inner richmond", "south of market", "tenderloin", "noe valley", "inner sunset", "outer sunset", "portola", "russian hill", "outer parkside"]

    @addressinformation = AddressInformation.new

    puts "Finding scores . . . . . . "
    neighborhoods.each do |neighborhood|
      score = Score.find_by_neighborhood(neighborhood)
      score.update(neighborhood: neighborhood, eviction_score: @addressinformation.eviction_score(neighborhood, 2015), fire_safety_score: @addressinformation.fire_safety_score(neighborhood, 2015), crime_score: @addressinformation.crime_score(neighborhood, 2015), fire_incidents_score: @addressinformation.fire_incidents_score(neighborhood, 2015), traffic_score: @addressinformation.traffic_violations_score(neighborhood, 2015))
    end

    puts 'Update complete.'
end



task :update_api_calls => :environment do
  def get_walkscore_stuff(neighbor)
    hash = {}
    walk = WalkscoreMain.get_walkscore("#{neighbor} san francisco ca")

    transit = WalkscoreMain.get_transitscore("#{neighbor} san francisco ca")
    hash["walk_score"] = ( 5 - (walk["walkscore"]/20.0).ceil) if walk["walkscore"]
    hash["transit_score"] = ( 5 - (transit["transit_score"]/20.0).ceil) if transit["transit_score"]
    hash
  end

  neighborhoods = [
     "Mission",
     "Bernal Heights",
     "Central Richmond",
     "Excelsior",
     "Bayview",
     "Central Sunset",
     "Downtown",
     "Pacific Heights",
     "Nob Hill",
     "Visitacion Valley",
     "Parkside",
     "Inner Richmond",
     "South of Market",
     "Tenderloin",
     "Noe Valley",
     "Inner Sunset",
     "Outer Sunset",
     "Portola",
     "Russian Hill",
     "Outer Parkside",
     "Outer Richmond",
     "Hayes Valley",
     "Marina",
     "Crocker Amazon",
     "Lower Pacific Heights",
     "South Beach",
     "Eureka Valley - Dolores Heights - Castro",
     "Haight-Ashbury",
     "Van Ness - Civic Center",
     "Potrero Hill",
     "Stonestown",
     "Mission Terrace",
     "Ingleside",
     "Western Addition",
     "Outer Mission",
     "North Panhandle",
     "Silver Terrace",
     "Cow Hollow",
     "Glen Park",
     "Lake",
     "Telegraph Hill",
     "Lone Mountain",
     "Oceanview",
     "Ingleside Heights",
     "Alamo Square",
     "Chinatown",
     "North Beach",
     "Sunnyside",
     "Lakeshore",
     "Hunters Point",
     "Parnassus - Ashbury",
     "Inner Parkside",
     "Jordan Park - Laurel Heights",
     "Miraloma Park",
     "Presidio Heights",
     "Mission Bay",
     "Yerba Buena",
     "Corona Heights",
     "Financial District",
     "Midtown Terrace",
     "Twin Peaks",
     "Merced Heights",
     "Forest Knolls",
     "Duboce Triangle",
     "Buena Vista Park",
     "Golden Gate Heights",
     "Forest Hill",
     "West Portal",
     "Diamond Heights",
     "Anza Vista",
     "North Waterfront",
     "Westwood Park",
     "Westwood Highlands",
     "Forest Hill Extension",
     "Little Hollywood",
     "Lakeside",
     "Central Waterfront - Dogpatch",
     "Pine Lake Park",
     "Ingleside Terrace",
     "St. Francis Wood",
     "Mount Davidson Manor",
     "Sea Cliff",
     "Monterey Heights",
     "Merced Manor",
     "Presidio",
     "Sherwood Forest",
     "Balboa Terrace",
     "Clarendon Heights",
     "Golden Gate Park"
  ].map(&:downcase)

    puts "Updating api calls.."

    neighborhoods.each do |neighborhood|
      walkscore_hash = get_walkscore_stuff(neighborhood)
      if score_update = Score.find_by_neighborhood(neighborhood)
        puts "Updating walkscores . . . . . ."
        walkscore_hash["walk_score"] = 2 unless walkscore_hash["walk_score"]
        walkscore_hash["transit_score"] = 2 unless walkscore_hash["transit_score"]
        score_update.update!( walk_score: walkscore_hash["walk_score"],
                             transit_score: walkscore_hash["transit_score"])
      else
        puts "Finding walkscores . . . . . ."
        walkscore_hash["walk_score"] = 2 unless walkscore_hash["walk_score"]
        walkscore_hash["transit_score"] = 2 unless walkscore_hash["transit_score"]
        Score.create!(neighborhood: neighborhood,
                     walk_score: walkscore_hash["walk_score"],
                     transit_score: walkscore_hash["transit_score"])
      end
    end

  puts "Update complete."
end
