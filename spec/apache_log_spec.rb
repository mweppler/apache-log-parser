require 'spec_helper'

describe "Apache Log Parser" do
  let(:apache_log) { ApacheLog.new }
  let(:log_file) { File.dirname(__FILE__) + File::SEPARATOR + "../test_data/mock.log" }

  context ApacheLog do
    it "instantiates an object" do
      expect(apache_log.class).to eql(described_class)
    end

    it "accepts a log file as input to the initialize method" do
      ap = described_class.new log_file
      expect(ap.file).to eql(log_file)
    end

    it "accepts a log file after instantiation" do
      apache_log.file = log_file
      expect(apache_log.file.path).to eql(log_file)
    end

    it "ensures the log file exists or sets it to nil" do
      apache_log.file = 'asfd'
      expect(apache_log.file).to eql(nil)
    end

    it "fails to parse an invalid apache log file" do
      expect(apache_log.parse!).to eql(-1)
    end

    it "parses a valid apache log file into a list of log entries" do
      apache_log.file = log_file
      apache_log.parse!
      expect(apache_log.entries.class).to eql(Array)
    end
  end

  context ApacheLogEntry do
    subject do
      apache_log.file = log_file
      apache_log.parse!
      apache_log.entries[0]
    end

    it "instantiates an apache log entry object" do
      expect(subject.class).to eql(described_class)
    end

    it "has a remote_host attribute (%h is the remote host (ie the client IP))" do
      expect(subject.remote_host).not_to be(nil)
    end

    it "has an identity attribute (%l is the identity of the user determined by identd (not usually used since not reliable))" do
      expect(subject.identity).not_to be(nil)
    end

    it "has a username attribute (%u is the user name determined by HTTP authentication)" do
      expect(subject.username).not_to be(nil)
    end

    it "has a time_processed attribute (%t is the time the server finished processing the request)" do
      expect(subject.time_processed).not_to be(nil)
    end

    it "has a request attribute (%r is the request line from the client. (\"GET / HTTP/1.0\"))" do
      expect(subject.request).not_to be(nil)
    end

    it "has a status_code attribute (%>s is the status code sent from the server to the client (200, 404 etc.))" do
      expect(subject.status_code).not_to be(nil)
    end

    it "has a response_size attribute (%b is the size of the response to the client (in bytes))" do
      expect(subject.response_size).not_to be(nil)
    end

    it "has a referer attribute (Referer is the page that linked to this URL.)" do
      expect(subject.referer).not_to be(nil)
    end

    it "has a user_agent attribute (User-agent is the browser identification string.)" do
      expect(subject.user_agent).not_to be(nil)
    end
  end
end
