require "rubygems"
require "bundler"
Bundler.setup(:default)

require "dotenv/load"
require "pry-byebug"
require "google/cloud/translate"
require "singleton"

class Translator
  def initialize(client, contents)
    @client = client
    @contents = contents
  end

  def translate_text
    @client.translate_text(@contents)
  end
end

class Client
  include Singleton

  def initialize
    @service = Google::Cloud::Translate.translation_service
    @project_name = ENV["PROJECT_NAME"]
    @region = "global"
    @parent = parent
    @language_code = "ja"
  end

  def translate_text(contents)
    @service.translate_text(
      parent: @parent,
      contents: contents,
      target_language_code: @language_code
    )
  end

  private

  def parent
    @service.location_path(
      project: @project_name,
      location: @region
    )
  end
end

ORIGINAL_TEXT_PATH = "./contents.txt"

original_text = [
  FileTest.exist?(ORIGINAL_TEXT_PATH) ? File.read(ORIGINAL_TEXT_PATH) : "hello tanutnau"
]

translator = Translator.new(Client.instance, original_text)

response = translator.translate_text
translated_text = response.translations.first.translated_text

translated_text.split("。").each { puts "#{_1.strip}。"}
