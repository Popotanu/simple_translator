# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "mechanize"
require "pry-byebug"

module Scraper
  class KRoOfficial
    BASE_PATH = "https://ro.gnjoy.com/news/devnote/"
    LIST_PATH = "list.asp"
    LIST_URI = BASE_PATH + LIST_PATH

    def initialize
      @results = []
      @scraper = prepare_scraper
      @landing_uri = URI(LIST_URI)
    end

    def scrape
      scrape_list
      scrape_article
    end

    private

    def prepare_scraper
      Mechanize.new { |agent|
        agent.user_agent_alias = "Mac Safari"
      }
    end

    def scrape_list
      @scraper.get(@landing_uri) do |list_page|
        posts = list_page.search(".devnote tbody tr")

        posts.each do |post|
          result = {}
          detail_path = post.search("a").attribute("href").content
          result[:uri] = URI(BASE_PATH + detail_path)

          post.elements.each_with_object(result) do |e, res|
            res[e.values.first.to_sym] = e.content.strip
          end

          @results << Scraper::Result.new(result)
        end
      end

      @results
    end

    def scrape_article
      @results = @results[0..2]
      @results.each do |result|
        p result.uri
        @scraper.get(result.uri.to_s) do |page|
          article = page.search("article .forPost")
          detail = {}
          p article.inner_text
          detail[:body] = article.inner_text
          detail[:images] = article.search("img").map do
            _1.attributes["src"].value
          end

          result.fill_in_detail(**detail)
        end

        sleep 2
      end

      @results
    end
  end

  class Result
    include Comparable

    attr_reader :num, :subject, :uri, :category, :body, :images, :published_date

    def initialize(article = {})
      @num = article[:num]
      @subject = article[:subject]
      @published_date = Date.parse(article[:date]).to_s
      @body = article[:body]
      @uri = URI(article[:uri])
      @category = article[:category]
      @images = article[:images]
    end

    def <=>(other)
      if @num < other.num
        -1
      elsif @num == other.num
        0
      else
        1
      end
    end

    def ==(other)
      @subject == other.subject &&
        @published_date == other.published_date &&
        @uri == other.uri
    end

    def fill_in_detail(body: nil, images: [])
      @body = body
      @images = images
    end
  end
end

# to avoid executing real-scraping while running tests.
unless @testing
  pp Scraper::KRoOfficial.new.scrape
end
