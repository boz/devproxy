require 'spec_helper'
describe Devproxy::Options do
  describe "defaults" do
    it "should have default values" do
      options = default_options
      expect(options.host        ).to eq("ssh.devproxy.io")
      expect(options.remote_port ).to eq(2222)
      expect(options.port        ).to eq(3000)
      expect(options.listen      ).to eq("0.0.0.0")
      expect(options.verbose     ).to eq(false)
    end
    it "should not have username or proxy" do
      options = default_options
      expect(options.username).to be_nil
      expect(options.proxy   ).to be_nil
    end
  end

  describe "valid?" do
    it "should not require a proxy" do
      expect(default_options(:user => "foo")).to be_valid
    end
    it "should require a username" do
      expect(default_options(:proxy => "bar")).to_not be_valid
    end
    it "should only need a username and proxy" do
      expect(default_options(:proxy => "foo", :user => "bar")).to be_valid
    end
  end

  describe "username" do
    it "should include name" do
      expect(default_options(:user => "bar").username).to include("bar")
    end
    it "should be nil if no name is given" do
      expect(default_options.username).to be_nil
    end
  end

  describe "app_host" do
    it "should return the tld when a subdomain is not given" do
      expect(default_options(:host=> "foo.com").app_host).to eq("foo.com")
    end
    it "should return the tld when a subdomain is given" do
      expect(default_options(:host=> "bar.foo.com").app_host).to eq("foo.com")
    end
  end

  def default_options(options = {})
    default = Devproxy::Options.default
    options.each do |key,value|
      default.__send__("#{key}=",value)
    end
    default
  end
end
