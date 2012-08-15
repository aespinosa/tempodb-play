require 'tempodb'
require 'gsl'
require 'time'
require 'active_support/all'

module TempoContext; end
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

class TempoContext::DataPointTest < ActiveSupport::TestCase
  test "datapoint generated are unique" do
    points = generate_datapoints

    assert_equal points.map { |point| point.ts }, 
                 points.map { |point| point.ts }.uniq
  end

  test "data point value" do
    point = TempoDB::DataPoint.new(Time.now, 3)
    assert_equal 3, point.value
  end

  test "datapoint time" do
    time = Time.now
    point = TempoDB::DataPoint.new(time, 3)

    assert_equal time, point.ts
  end
end

class TempoContext::ClientTest < ActiveSupport::TestCase
  def setup
    @client = TempoDB::Client.new ENV['TEMPO_API_KEY'],
                                  ENV['TEMPO_API_SECRET']
  end

  test "tempo environment should be defined" do
    assert_includes ENV.keys, 'TEMPO_API_KEY'
  end

  test "client should not nil" do
    refute_nil @client
  end

  test "create series" do
    keys = %w(swift)
    series = @client.get_series :keys => keys

    assert_equal keys.first, series.first.key
  end

  test "dump data to series" do
    points = generate_datapoints

    assert_nothing_raised do
      @client.write_key "swift", points
    end
  end
end
