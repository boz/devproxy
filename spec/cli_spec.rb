require 'spec_helper'
describe Devproxy::CLI do
  describe "#parse" do
    it "should not have a default name" do
      options = parse("foo")
      expect(options.user).to  eq("foo")
      expect(options.proxy).to be_nil
    end
    it "should accept a different proxy name" do
      options = parse("foo","bar")
      expect(options.user).to  eq("foo")
      expect(options.proxy).to eq("bar")
    end
    it "should parse the port option" do
      expect(parse("foo","bar","-p"    ,"20").port).to eq(20)
      expect(parse("foo","bar","--port","20").port).to eq(20)
      expect(parse("foo","bar"              ).port).to eq(Devproxy::Options.default.port)
    end
    it "should parse the remote port option" do
      expect(parse("foo","bar","--remote-port","20").remote_port).to eq(20)
      expect(parse("foo","bar"                     ).remote_port).to eq(Devproxy::Options.default.remote_port)
    end
    it "should parse the test server option" do
      expect(parse("foo","bar","--test-server").test).to be_true
      expect(parse("foo","bar"                ).test).to be_false
    end
    it "should parse the verbose option" do
      expect(parse("foo","bar","-v"       ).verbose).to be_true
      expect(parse("foo","bar","--verbose").verbose).to be_true
      expect(parse("foo","bar"            ).verbose).to be_false
    end
  end

  def parse(*args)
    Devproxy::CLI::parse(args)
  end
end
