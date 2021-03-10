# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require 'pry-byebug'

require_relative './scraper'
require_relative './translator'

require 'yaml'

result= YAML.load_file('./result.yml') 

p '---------'
p result.to_h
p '---------'

article =[result.subject, result.body]


response = Transrator::Translator.new(Transrator::Client.new, article).translate_text

tt =  response.translations

tt.map do |txt|
  txt.translated_text.split("。").each{ _1.strip}
end

%(subject body).zip(tt).to_h

# presistance translated article into db

