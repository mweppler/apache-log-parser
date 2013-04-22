[![Build Status](https://travis-ci.org/mweppler/apache-log-parser.png)](https://travis-ci.org/mweppler/apache-log-parser)  

_its just kind of a scratch your own itch thing right now..._  

## Example Usage:  

    #!/usr/bin/env ruby

    require './models/apache_log'

    start_time = Time.now
    log_file = File.dirname(__FILE__) + File::SEPARATOR + "test_data/access_log.1.server1"
    apache_log = ApacheLog.new
    apache_log.file = log_file
    apache_log.parse!

    apache_log.group_entries_by 'remote_hosts'
    apache_log.group_entries_by 'requests'
    apache_log.group_entries_by 'status_codes'
    apache_log.group_entries_by 'time_processeds'
    apache_log.group_entries_by 'user_agents'
    apache_log.group_by_request_hour

    data, labels = [], {}
    apache_log.group_by_day_hours
    inc = 0
    apache_log.day_hours.each_pair do |k,v|
      data << v
      labels[inc] = "3/#{k[0]}-#{k[1]}"
      inc += 1
    end

    # Gruff
    gruff_graph = Gruff::Line.new('1200x600')
    gruff_graph.title = "Requests to node01 per hour"
    gruff_graph.labels = labels
    gruff_graph.data('node01', data)
    #gruff_graph.data('nodeN',  data)
    gruff_graph.write("images/gruff_line_node01.png")

    # Scruffy
    scruffy_graph = Scruffy::Graph.new
    scruffy_graph.title = "Requests to node01 per hour"
    scruffy_graph.renderer = Scruffy::Renderers::Standard.new
    scruffy_graph.add :line, 'node01', data
    scruffy_graph.render :to => "images/scruff_line_node01.svg"
    scruffy_graph.render :width => 1200, :height => 600, :to => "images/scruff_line_node01.png", :as => 'png'

    elapsed = Time.now - start_time
    puts elapsed
