require 'test/unit'
require 'tempodb'
require 'gsl'
require 'time'
require 'active_support/all'

class TempoTest < Test::Unit::TestCase
  def setup
    @client = TempoDB::Client.new ENV['TEMPO_API_KEY'],
                                  ENV['TEMPO_API_SECRET']
  end

  def test_tempo_environment_should_be_defined
    assert_includes ENV.keys, 'TEMPO_API_KEY'
  end

  def test_client_not_nil
    refute_nil @client
  end

  def test_create_series
    keys = %w(swift)
    series = @client.get_series :keys => keys

    assert_equal keys.first, series.first.key
  end

  def generate_datapoints
    rng = GSL::Rng.alloc GSL::Rng::TAUS, Time.now.to_i

    points = []
    time = Time.now
    1000.times do
      time = 1.minute.since time
      points << TempoDB::DataPoint.new(time, rng.gaussian)
    end
    points
  end
  private :generate_datapoints

  def test_datapoint_generated_are_unique
    points = generate_datapoints

    assert_equal points.map { |point| point.ts }, 
                 points.map { |point| point.ts }.uniq
  end

  def test_dump_data_to_series
    points = generate_datapoints

    assert_nothing_raised do
      @client.write_key "swift", points
    end
  end

  def test_datapoint_value
    point = TempoDB::DataPoint.new(Time.now, 3)
    assert_equal 3, point.value
  end

  def test_test_datapoint_time
    time = Time.now
    point = TempoDB::DataPoint.new(time, 3)

    assert_equal time, point.ts
  end
end
