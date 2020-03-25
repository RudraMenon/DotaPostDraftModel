require 'httparty'
require 'json'

file = File.open('matchids.txt')
data = file.read
file.close
file = File.open('apiMatches/counter.txt')
counter = file.read.to_i
file.close
matchids = data.split("\n")

callSite = "https://api.opendota.com/api/matches/"
req = ["dire_score", "draft_timings", "radiant_score", "radiant_win", "duration"]

def badDevs arr
    item = "picks_bans"
    goodInfos = {"radiant_comp" => [], "dire_comp" => [], "radiant_bans" => [], "dire_bans" => []}
    arr[item].each do |pick|
        if pick["team"] == 0
            pick["team"] = "radiant"
        else 
            pick["team"] = "dire"
        end
        if !pick["is_pick"]
            goodInfos[pick["team"]+"_bans"].push(pick["hero_id"])
        else
            goodInfos[pick["team"]+"_comp"].push(pick["hero_id"])
        end
    end
    goodInfos
end

while counter < 85000 do
for i in 0..59
    goodInfo = {"radiant_comp" => [], "dire_comp" => [], "radiant_bans" => [], "dire_bans" => []}
    response = HTTParty.get(callSite+matchids[counter])
    arr = JSON.parse(response.body)
    begin
    req.each do |item|
        if item == "draft_timings"
            if arr[item] == nil
                a = badDevs arr
                a.each do |k, v|
                    goodInfo[k] = v
                end
            else
                arr[item].each do |pick|
                    if pick["active_team"] == 2 
                        pick["active_team"] = "radiant"
                    else 
                        pick["active_team"] = "dire"
                    end
                    if !pick["pick"]
                        goodInfo[pick["active_team"]+"_bans"].push(pick["hero_id"])
                    else
                        goodInfo[pick["active_team"]+"_comp"].push(pick["hero_id"])
                    end
                end
            end
        else            
            goodInfo[item] = arr[item]
        end
    end

    respStr = ""
    goodInfo.each do |k,v|
        respStr += k + ": " + v.to_s+"\n"
    end
    
    rescue 
        respStr = response
    end

    counter += 1
    File.write("apiMatches/"+matchids[counter]+".txt", respStr)
    File.write("apiMatches/counter.txt", counter.to_s)
    
    puts counter
end

sleep(60)

end
