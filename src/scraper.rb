# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "mechanize"
require "pry-byebug"

TARGET_URI = URI("https://ro.gnjoy.com/news/devnote/list.asp")

module Scraper
  class KRoOfficial
    def initialize
      @url = TARGET_URI
      @results = []
      @scraper = prepare_scraper
      @landing_uri = URI("")
      @post_uris = ["https://ro.gnjoy.com/news/devnote/View.asp?category=1&seq=4096364&curpage=1"].map{ URI(_1) }
    end

    def prepare_scraper
      Mechanize.new { |agent|
        agent.user_agent_alias = "Mac Safari"
      }
    end

    def scrape

    end

    def scrape_list
    end

    def scrape_article
      post_page = @post_uris.first

      post = {}

      @scraper.get(post_page) do |page|

        published_date = page.search(".postDate").text.scan(/\d{4}\.\d{2}\.\d{2}/).first
        post[:published_date] = Date.parse(published_date).to_s

        h1 = page.search('h1')
        post[:category] = h1.search('.iconDev').text 

        article = page.search("article .forPost")
        post[:body] = article.inner_text 
        post[:images] = article.search("img").map do 
          _1.attributes["src"].value
        end
      end

      @results << Scraper::Result.new(post)
    end

    def scrape_title
    end

    def scrape_body
    end
  end

  class Result
    include Comparable

    attr_reader :title, :uri, :category, :body, :images, :published_date

    def initialize(article={})
      @title = article[:title]
      @published_date = article[:published_date]
      @body = article[:body]
      @uri = article[:uri]
      @category = article[:category]
      @images = article[:images]
    end

    def <=>(other)
      if @published_date < other.published_date
        -1
      elsif @published_date == other.published_date
        0
      else
        1
      end
    end

    def ==(other)
      @title == other.title &&
        @published_date == other.published_date &&
          @uri == other.uri
    end
  end
end

# to avoid executing real-scraping while running tests.
unless @testing
  Scraper::KRoOfficial.new.scrape_article
end





