# encoding: UTF-8

require File.dirname(__FILE__) + '/test_helper.rb'

class TestOauth < Test::Unit::TestCase

  def test_parameter_escaping
    assert_equal '%E3%81%82', OAuth::Helper.escape('あ')
    assert_equal '%C3%A9', OAuth::Helper.escape('é')
  end
end
