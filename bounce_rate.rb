module BounceRate
  class << self
    def analyze(requests)
      views = requests.select(&:view?)

      map_hash(views.group_by(&:store_domain)) { |_store, reqs|
        reqs.group_by(&:ip).map { |_ip, reqs|

          # multiple hits on a single page still counts as a bounce
          if reqs.map(&:store_domain).uniq.one? 
            1
          else
            0
          end
        }.inject(&:+).to_f / reqs.size
      }
    end
  end
end
