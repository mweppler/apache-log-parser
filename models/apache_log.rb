require_relative 'apache_log_entry'

# Parses log files that use the combined log format.
# NCSA extended/combined log format
#   "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
class ApacheLog
  attr_accessor :entries, :file, :day_hours, :remote_hosts, :requests_hours, :requests, :status_codes, :time_processeds, :user_agents

  def initialize(file = nil)
    @file = file unless file.nil?
  end

  def entries_to_json
    json = "{"
    @entries.each do |entry| 
      json << "['identity':'#{entry.identity}', 'referer':'#{entry.referer}', 'remote_host':'#{entry.remote_host}', 'request':'#{entry.request}', 'response_size':'#{entry.response_size}', 'status_code':'#{entry.status_code}', 'time_processed':'#{entry.time_processed}', 'username':'#{entry.username}', 'user_agent':'#{entry.user_agent}'],"
    end
    json.chop << "}"
  end

  def file=(file)
    begin
      @file = File.open file, 'r'
    rescue Exception => ex
      ex = nil
      @file = nil
    end
  end

  def group_entries_by group_name
    group = instance_variable_set("@#{group_name}", {})
    index = 0
    @entries.each do |entry|
      if group.key? entry.send("#{group_name.chop}")
        group[entry.send("#{group_name.chop}")] << index
      else
        group[entry.send("#{group_name.chop}")] = [index]
      end
      index += 1
    end
  end

  def group_by_day_hours
    @day_hours = {}
    @entries.each do |entry|
      if @day_hours.key? [entry.time_processed.day, entry.time_processed.hour]
        @day_hours[[entry.time_processed.day, entry.time_processed.hour]] += 1
      else
        @day_hours[[entry.time_processed.day, entry.time_processed.hour]]  = 0
      end
    end
  end

  def group_by_request_hour
    @request_hour = {}
    @entries.each do |entry|
      if @request_hour.key? [entry.request, entry.time_processed.hour]
        @request_hour[[entry.request, entry.time_processed.hour]] += 1
      else
        @request_hour[[entry.request, entry.time_processed.hour]]  = 0
      end
    end
  end

  def parse!
    if @file.nil?
      return -1
    else
      @entries ||= []
      pattern = /([^\s]*) ([^\s]*) ([^\s]*) (\[.*\]) "(.*?)" (\d+) (\d+) "(.*?)" "(.*?)"/
      puts "Loading file: #{@file.path}"
      # parse_time = Time.now
      File.open(@file, 'r') do |file|
        #inc = 1
        file.lines do |line|
          line.match(pattern) do |m|
            entry = ApacheLogEntry.new
            entry.remote_host    = m[1]
            entry.identity       = m[2]
            entry.username       = m[3]
            entry.time_processed = m[4]
            entry.request        = m[5]
            entry.status_code    = m[6]
            entry.response_size  = m[7]
            entry.referer        = m[8]
            entry.user_agent     = m[9]
            @entries << entry
          end
          # print "." if inc % 10 == 0
          #inc += 1
        end
      end
      # puts "parsed file in: #{Time.now - parse_time} seconds\n"
      if @entries.empty?
        @entries << ApacheLogEntry.new
      end
      @entries
    end
  end
end
