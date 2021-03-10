require 'test/unit'
require_relative '../src/scraper'

module Scraper
  class TestResult < Test::Unit::TestCase
    def setup
      @testing = true

      now = '2020-01-02'
      num = 2
      @me = Scraper::Result.new(num: num,published_date: now, title: 'tanu' )

      @latest = Scraper::Result.new(num: num.succ)
      @oldest = Scraper::Result.new(num: num.pred)

      @similar = Scraper::Result.new(published_date: now, title: 'kitune' )

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
      assert_equal false, @me == @similar
    end

    def test_to_h
      attributes =  {
        num: 1, subject: 'poti',body: 'tanutanu', uri: URI( 'https://tanu.example.com' ), 
        category: 'animal',published_date: nil,
        images: ['https://tanutanu.example.com'] 
      }

      result= Scraper::Result.new(attributes)
      assert_equal attributes, result.to_h
    end
  end
end
