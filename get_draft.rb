# frozen_string_literal: true

require 'httparty'
require 'json'

file = File.open('matchids.txt')
file2 = File.open('apiMatches/counter.txt')

data = file.read
counter = file2.read.to_i

matchids = data.split("\n")

file.close
file2.close

call_site = 'https://api.opendota.com/api/matches/'

req = %w[dire_score draft_timings radiant_score radiant_win duration]

def set_info(keys, values)
  infos = {}

  (0..keys.length - 1).each do |i|
    infos[keys[i]] = values[i]
  end

  infos
end

def set_team_info
  info = %w[radiant_comp dire_comp radiant_bans dire_bans]

  v = [[], [], [], []]

  a = set_info(info, v)

  a
end

def get_case(option)
  case option

  when 0

    k = %w[item team diff pick_d]

    v = %w[picks_bans team 0 is_pick]

  when 1

    k = %w[item team diff pick_d]

    v = %w[draft_timings active_team 2 pick]

  end

  got_case = set_info(k, v)

  got_case
end

def to_text(arr, option)
  arr[item].each do |pick|
    pick[option[team]] = if pick[option[team]] == option[diff].to_i

                           'radiant'

                         else

                           'dire'

                         end
  end
end

def bad_devs(arr, option)
  got_case = get_case option

  good_infos = set_team_info

  to_text arr got_case

  arr[item].each do |pick|
    if !pick[got_case[pick_d]]

      good_infos[pick[got_case[team]] + '_bans'].push(pick['hero_id'])

    else

      good_infos[pick[got_case[team]] + '_comp'].push(pick['hero_id'])

    end
  end

  good_infos
end

while counter < 40_000

  t1 = Time.now

  (0..59).each do |_i|
    good_info = set_team_info

    response = HTTParty.get(call_site + matchids[counter])

    arr = JSON.parse(response.body)

    begin
      req.each do |item|
        if item == 'draft_timings'

          a = if arr[item].nil?

                bad_devs arr 0

              else

                bad_devs arr 1

              end

          a.each do |k, v|
            good_info[k] = v
          end

        else

          good_info[item] = arr[item]

        end
      end

      resp_str = ''

      good_info.each do |k, v|
        resp_str += k + ': ' + v.to_s + "\n"
      end
    rescue StandardError
      resp_str = response
    end

    counter += 1

    File.write('apiMatches/' + matchids[counter] + '.txt', resp_str)

    File.write('apiMatches/counter.txt', counter.to_s)

    puts counter
  end

  t2 = Time.now

  puts t2 - t1
  begin
    sleep(62 - (t2 - t1))
  rescue WhyDIdItTakeSoLong
    puts t2 - t1
  end
end
