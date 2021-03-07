require 'test/unit'
require_relative '../src/scraper'



module Scraper
  class TestResult < Test::Unit::TestCase
    def setup
      @testing = true

      now = Date.parse('2020-01-02')
      @me = Scraper::Result.new(published_date: now, title: 'tanu' )

      @similar = Scraper::Result.new(published_date: now, title: 'kitune' )

      @latest = Scraper::Result.new(published_date: Date.parse('2020-01-03'))
      @oldest = Scraper::Result.new(published_date: Date.parse('2020-01-01'))
    end

    def test_comparable
      assert_equal true, @me < @latest
      assert_equal false, @me < @me

      assert_equal true, @me <= @me
      assert_equal true, @me >= @me

      assert_equal false, @me > @me
      assert_equal true, @me > @oldest
    end

    def test_equality
      assert_equal true, @me == @me
      assert_equal false, @me == @latest
      assert_equal false, @me == @similar
    end
  end
end
