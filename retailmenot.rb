require 'csv'
require 'pp'
require 'pathname'

require_relative 'request'
require_relative 'outs'
require_relative 'bounce_rate'

def map_hash(enum, &block)
  Hash[enum.map { |e| [Array(e).first, yield(*e)] }]
end

LOG_FILE = Pathname(ARGV[0])

REQUESTS = Request.from_log(LOG_FILE).compact

OUTS         = Outs.analyze(REQUESTS)
BOUNCE_RATES = BounceRate.analyze(REQUESTS)

CSV.open('outs.csv', 'wb') do |csv|
  p OUTS
  csv << ['min', 'min_time', 'max', 'max_time', 'median', 'mean', 'stdev']
  csv << [
    OUTS[:min].last,
    OUTS[:min].first,
    OUTS[:max].last,
    OUTS[:max].first,
    OUTS[:median],
    OUTS[:median],
    OUTS[:stdev],
  ]
end

CSV.open('bounce_rates.csv', 'wb') do |csv|
  csv << ['store_domain', 'bouce_rate']

  BOUNCE_RATES.to_a.each do |row|
    csv << row
  end
end
