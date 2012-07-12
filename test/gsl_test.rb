require 'test/unit'
require 'gsl'

class GslTest < Test::Unit::TestCase
  include GSL

  def test_gaussian
    rng = Rng.alloc Rng::TAUS, Time.now.to_i
    sigma = 1
    seq = rng.gaussian sigma, 1000
    average = seq.sum / seq.size

    assert_in_delta 0,  average, sigma
  end

  def test_rng_class
    rng = Rng.alloc Rng::TAUS, Time.now.to_i
    assert_instance_of Rng, rng
  end
end
