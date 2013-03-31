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
