require './models/apache_log_parser'

describe "apache log" do

  let(:apache_log) { ApacheLog.new }
  let(:log_file) { File.dirname(__FILE__) + FS + "mock.log" }

  it "instantiates an apache log object" do
    apache_log.class.should equal(ApacheLog)
  end

  it "accepts a log file as input to the initialize method" do
    ap = ApacheLog.new log_file
  end

  it "accepts a log file after instantiation" do
    apache_log.file = log_file
  end

  it "ensures the log file exists or sets it to nil" do
    apache_log.file = 'asfd'
  end

  it "fails to parse an invalid apache log file" do
    apache_log.parse!.should equal(-1)
  end

  it "parses a valid apache log file into a list of log entries" do
    apache_log.file = log_file
    apache_log.parse! 
    apache_log.entries.class.should equal(Array)
  end

  describe "entry" do
    # before do
    #   @scanner = SessPoolScanner.new
    # end
    # let(:entries) { apache_log }
    # subject {  }
    subject do
      apache_log.file = log_file
      apache_log.parse! 
      apache_log.entries[0]
    end

    it "instantiates an apache log entry object" do
      subject.class.should equal(ApacheLogEntry)
    end

    it "has a remote_host attribute (%h is the remote host (ie the client IP))" do
      subject.remote_host.should_not be(nil)
    end

    it "has an identity attribute (%l is the identity of the user determined by identd (not usually used since not reliable))" do
      subject.identity.should_not be(nil)
    end

    it "has a username attribute (%u is the user name determined by HTTP authentication)" do
      subject.username.should_not be(nil)
    end

    it "has a time_processed attribute (%t is the time the server finished processing the request)" do
      subject.time_processed.should_not be(nil)
    end

    it "has a request attribute (%r is the request line from the client. (\"GET / HTTP/1.0\"))" do
      subject.request.should_not be(nil)
    end

    it "has a status_code attribute (%>s is the status code sent from the server to the client (200, 404 etc.))" do
      subject.status_code.should_not be(nil)
    end

    it "has a response_size attribute (%b is the size of the response to the client (in bytes))" do
      subject.response_size.should_not be(nil)
    end

    it "has a referer attribute (Referer is the page that linked to this URL.)" do
      subject.referer.should_not be(nil)
    end

    it "has a user_agent attribute (User-agent is the browser identification string.)" do
      subject.user_agent.should_not be(nil)
    end
  end
end
