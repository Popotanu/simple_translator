# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "mechanize"
require "pry-byebug"

module Scraper
  class KRoOfficial
    BASE_PATH = URI("https://ro.gnjoy.com")
    LIST_PATH = URI("news/devnote/list.asp")
    LIST_URI = BASE_PATH + LIST_PATH

    def initialize
      @results = []
      @scraper = prepare_scraper
      @landing_uri = LIST_URI
      @post_uris = ["https://ro.gnjoy.com/news/devnote/View.asp?category=1&seq=4096364&curpage=1"].map{ URI(_1) }
    end

    def scrape
      scrape_list
      scrape_atricle
    end

    # private

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
          result[:uri] = BASE_PATH + URI(detail_path)

          post.elements.each_with_object(result) do |e, res|
            res[e.values.first.to_sym] = e.content.strip
          end

          @results << Scraper::Result.new(result)
        end
      end
      @results
    end

    def scrape_article
      post_page = @post_uris.first

      post = {}

      @scraper.get(post_page) do |page|
        published_date = page.search(".postDate").text.scan(/\d{4}\.\d{2}\.\d{2}/).first
        post[:published_date] = Date.parse(published_date).to_s

        h1 = page.search("h1")
        post[:category] = h1.search(".iconDev").text

        article = page.search("article .forPost")
        post[:body] = article.inner_text
        post[:images] = article.search("img").map do
          _1.attributes["src"].value
        end
      end

      @results << Scraper::Result.new(post)
    end
  end

  class Result
    include Comparable

    attr_reader :num, :title, :uri, :category, :body, :images, :published_date

    def initialize(article = {})
      @num = article[:num]
      @title = article[:title]
      @published_date = article[:published_date]
      @body = article[:body]
      @uri = article[:uri]
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
      @title == other.title &&
        @published_date == other.published_date &&
        @uri == other.uri
    end
  end
end

# to avoid executing real-scraping while running tests.
unless @testing
  pp Scraper::KRoOfficial.new.scrape_article if false
  pp Scraper::KRoOfficial.new.scrape_list if false
end
