#!/usr/bin/env ruby

require 'unirest'
require 'rottentomatoes'

include RottenTomatoes

MOVIES_DIR = "/Volumes/NOMAD/movies/jp/Movies"

# These code snippets use an open-source library. http://unirest.io/ruby
def get_meta_score(movie)
  response = Unirest.post "https://byroredux-metacritic.p.mashape.com/find/movie",
    headers:{
      "X-Mashape-Key" => "JNXrjvNKyZmshLRy8BK4AGSxThxHp1SVGrNjsndU1VRrCh4Ozp",
      "Content-Type" => "application/x-www-form-urlencoded",
      "Accept" => "application/json"
    },
    parameters:{
      "retry" => 4,
      "title" => "#{movie}"
    }

  r = response.body["result"]
  
  if r == false
    "--"
  else
    r["score"].to_i
  end
end

# https://github.com/nmunson/rottentomatoes
def get_rt_scores(movie)
  Rotten.api_key = "umkdd9jxkmggskjzcutpe9an"
  r = RottenMovie.find(:title => "#{movie}", :limit => 1)
  
  if r.empty?
    { :critics_score => "--", :audience_score => "--" }
  else
    { :critics_score => r.ratings.critics_score, :audience_score => r.ratings.audience_score }
  end
end

# generate hash map of genre => [movies]
movies = Dir[MOVIES_DIR + "/*"].inject({}) do |h,dir|
  h[dir.split("/").last] = Dir.entries(dir).inject([]) do |a,name| 
    # TODO: some movie names are nil
    a << name.split(".").first
    a
  end

  h
end

movies.each do |genre,movie_list|
  puts "\n\n#{genre}\n\n"
  
  movie_list.each do |movie| 
    
    unless movie == nil
      rt = get_rt_scores(movie)
      puts "#{movie}: #{get_meta_score(movie)} #{rt[:critics_score]} #{rt[:audience_score]}"
      $stdout.flush
    end
  end
end

puts "\n\nEND"
