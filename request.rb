require 'pry'

Request = Struct.new(:path, :time, :ip) do
  OUT_PATTERN  = %r(/out/\d+)
  VIEW_PATTERN = %r(/view\d*/.*)

  LOG_LINE_PATTERN = %r(
    (?<ip>\d*\.\d*.\d*.\d*).* # ip octet
    \[(?<day>[[:digit:]]+)/(?<month>[[:alpha:]]{3})/(?<year>[[:digit:]]+) # date
    :(?<hour>[[:digit:]]{2}):(?<minutes>[[:digit:]]{2}):(?<second>[[:digit:]]{2}).*\] # time
    .*GET[[:blank:]]*(?<path>/.*)[[:blank:]]*HTTP.* # request path
  )x

  def self.from_log(log)
    log.each_line.map(&method(:from_log_line))
  end

  def self.from_log_line(line)
    match = LOG_LINE_PATTERN.match(line)

    return unless match

    year    = Integer(match[:year])
    month   = match[:month]
    day     = Integer(match[:day].reverse.chomp("0").reverse)
    hour    = Integer(match[:hour].reverse.chomp("0").reverse)
    minutes = Integer(match[:minutes].reverse.chomp("0").reverse)
    second  = Integer(match[:second].reverse.chomp("0").reverse)

    new(
      match[:path].strip,
      Time.new(year, month, day, hour, minutes, second),
      match[:ip])
  end

  def store_domain
    path.split('/').last.split('?').first
  end

  def hour_minutes
    Time.new(time.year, time.month, time.day, time.hour, time.min, 0)
  end

  def out?
    !!OUT_PATTERN.match(path)
  end

  def view?
    !!VIEW_PATTERN.match(path)
  end
end
