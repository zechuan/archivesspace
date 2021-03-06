require 'spec_helper'

describe 'The ArchivesSpaceService app' do

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == "Hello, ArchivesSpace (#{ASConstants.VERSION})!"
  end
  

  it "gives you TMI is you ask in JSON" do
    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    ( json.keys - [ "databaseProductName", "databaseProductVersion", "ruby_version",
                    "host_os", "host_cpu", "build", "archivesSpaceVersion"] ).empty?.should be_true
  end

end
