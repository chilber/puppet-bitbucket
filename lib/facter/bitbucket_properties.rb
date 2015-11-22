require 'json'
require 'open-uri'
Facter.add(:bitbucket_properties) do
  confine :bitbucket_setup => true
  setcode do
    path = '/var/tmp/.bitbucket'
    if File.exist? path
      begin
        url = 'http://localhost:7990/rest/api/1.0/application-properties'
        info = open(url, &:read)
        JSON.load(info)
      rescue
        false
      end
    end
  end
end
