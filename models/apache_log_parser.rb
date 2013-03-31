#!/usr/bin/env ruby

require 'gruff'
require 'scruffy'
require 'pry'

FS = File::SEPARATOR

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

  def parse!
    if @file.nil?
      return -1
    else
      @entries = []
      pattern = /([^\s]*) ([^\s]*) ([^\s]*) (\[.*\]) "(.*?)" (\d+) (\d+) "(.*?)" "(.*?)"/
      puts "Loading file: #{@file.path}"
      # start_time = Time.now
      File.open(@file, 'r') do |file|
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
          # print "."
        end
      end
      # elapsed = Time.now - start_time
      # puts elapsed
      # print "\n"
      if @entries.empty?
        @entries << ApacheLogEntry.new
      end
      @entries
    end
  end
end

class ApacheLogEntry
  attr_accessor :identity, :referer, :remote_host, :request, :response_size, :status_code, :time_processed, :username, :user_agent
  attr_accessor :http_method, :resource, :protocol

  MONTHS = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  def http_method
    @http_method = /^(.*?)\s/.match(@request)[1]
  end

  def resource
    @resource = /\s(.*?)\s/.match(@request)[1]
  end

  def protocol 
    @protocol = /\s(HTTP.*)$/.match(@request)[1]
  end

  def time_processed=(timestamp)
    day_idx  = timestamp.index('/')
    mon_idx  = timestamp.index('/', day_idx + 1)
    hour_idx = timestamp.index(':')
    min_idx  = timestamp.index(':', hour_idx + 1)
    sec_idx  = timestamp.index(':', min_idx + 1)

    @time_processed = Time.new timestamp[mon_idx + 1...hour_idx].to_i, MONTHS.index(timestamp[day_idx + 1...mon_idx]), timestamp[1...day_idx].to_i, timestamp[hour_idx + 1...min_idx].to_i, timestamp[min_idx + 1...sec_idx].to_i, timestamp[sec_idx + 1..sec_idx + 2].to_i, (timestamp[-6...-3] + ':' + timestamp[-3...-1])
  end

  def to_json
    puts "{'identity':'#{@identity}', 'referer':'#{@referer}', 'remote_host':'#{@remote_host}', 'request':'#{@request}', 'response_size':'#{@response_size}', 'status_code':'#{@status_code}', 'time_processed':'#{@time_processed}', 'username':'#{@username}', 'user_agent':'#{@user_agent}'}"
  end
end

start_time = Time.now
#log_file = File.dirname(__FILE__) + FS + "test_data/access_log.1.server1"
log_file = File.dirname(__FILE__) + FS + "test_data/mock.log"
apache_log = ApacheLog.new
apache_log.file = log_file
apache_log.parse!

#apache_log.group_entries_by 'remote_hosts'
#apache_log.group_entries_by 'requests'
#apache_log.group_entries_by 'status_codes'
#apache_log.group_entries_by 'time_processeds'
#apache_log.group_entries_by 'user_agents'
#apache_log.group_by_request_hour

data, labels = [], {}
apache_log.group_by_day_hours
inc = 0
apache_log.day_hours.each_pair do |k,v|
  data << v
  labels[inc] = "3/#{k[0]}-#{k[1]}"
  inc += 1
end
#gruff_graph = Gruff::Line.new('1200x600')
#gruff_graph.title = "GTC webapp requests per hour"
#gruff_graph.labels = labels
#gruff_graph.data('hqnvlampwb01', data)
##gruff_graph.data('nodeN',  data)
#gruff_graph.write("images/gruff_line_hqnvlampwb01.png")

scruffy_graph = Scruffy::Graph.new
scruffy_graph.title = "GTC webapp requests per hour"
scruffy_graph.renderer = Scruffy::Renderers::Standard.new
scruffy_graph.add :line, 'hqnvlampwb01', data
scruffy_graph.render :to => "images/scruff_line_hqnvlampwb01.svg"
scruffy_graph.render :width => 1200, :height => 600, :to => "images/scruff_line_hqnvlampwb01.png", :as => 'png'

elapsed = Time.now - start_time
puts elapsed

