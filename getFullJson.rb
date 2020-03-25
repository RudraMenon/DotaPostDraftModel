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

while counter < 85000 do
    for i in 0..59
        response = HTTParty.get(callSite+matchids[counter])
        json = response.body
        counter += 1
        File.write("apiMatches/"+matchids[counter]+".txt", json)
        File.write("apiMatches/counter.txt", counter.to_s)
        puts counter
    end
    sleep(50)
end
        