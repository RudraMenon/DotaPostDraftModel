require 'httparty'
require 'json'
t1 = Time.now
file = File.open('matchids.txt')
data = file.read
file.close
file = File.open('apiMatches/counter.txt')
counter = file.read.to_i
file.close
puts counter
matchids = data.split("\n")

callSite = "https://api.opendota.com/api/matches/"
req = ["dire_score", "draft_timings", "radiant_score", "radiant_win", "duration"]
begin
while counter < 85000 do
for i in 0..59
    goodInfo = {"radiant_comp" => [], "dire_comp" => [], "radiant_bans" => [], "dire_bans" => []}
    response = HTTParty.get(callSite+matchids[counter])
    arr = JSON.parse(response.body)
    req.each do |item|
        if item == "draft_timings" 
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
        else            
            goodInfo[item] = arr[item]
        end
    end
    respStr = ""
    goodInfo.each do |k,v|
        respStr += k + ": " + v.to_s+"\n"
    end
    # puts respStr
    
    File.write("apiMatches/"+matchids[counter]+".txt", respStr)
    counter += 1
    puts counter
end
sleep(60-16)
File.write("apiMatches/counter.txt", counter.to_s)
end
rescue 
    t2 = Time.now
    puts t2-t1

end