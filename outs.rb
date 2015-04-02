module Outs
  class << self
    def analyze(requests)
      outs = requests.select(&:out?)

      outs_count_per_minute = map_hash(outs.group_by(&:hour_minutes)) { |_time, reqs|
        reqs.size
      }

      outs_counts = outs_count_per_minute.values

      {
        min: min(outs_count_per_minute),
        max: max(outs_count_per_minute),
        median: median(outs_counts),
        mean: mean(outs_counts),
        stdev: stdev(outs_counts),
      }
    end

    private

    def min(outs)
      outs.min_by { |_time, reqs| reqs }
    end

    def max(outs)
      outs.max_by { |_time, reqs| reqs.size }
    end

    def median(enum)
      sorted = enum.sort
      len = enum.size

      (sorted[(len - 1) / 2] + sorted[len / 2]).to_f / 2
    end

    def mean(enum)
      enum.inject(&:+).to_f / enum.size
    end

    def variance(enum)
      m = mean(enum)

      enum.inject(0) { |acc, i| acc + (i - m) ** 2 }.to_f / enum.size
    end

    def stdev(enum)
      Math.sqrt(variance(enum))
    end
  end
end
