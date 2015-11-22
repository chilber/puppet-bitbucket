path = '/var/tmp/.bitbucket.yaml'
y = YAML.load_file(path) if File.exist? path

# Fact to work around PUP-1125 requirement.
Facter.add(:bitbucket_setup) do
  setcode do
    if File.exist? path
      file = Facter::Util::FileRead.read(y['properties_file'])
      file =~ /removed by unattended setup on/ ? true : false
    else
      false
    end
  end
end

# Fact to work around PUP-1125 requirement.
Facter.add(:bitbucket_port) do
  confine :bitbucket_setup => true
  setcode do
    y['port'].empty? ? y['port'] : 'unknown'
  end
end
