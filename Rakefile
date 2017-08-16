desc 'Filter-out nixos.org packages to local binary cache'
task 'upload-mycache' do
  require 'net/http'
  http = Net::HTTP.new '127.0.0.1', 8081

  Dir.glob('*.narinfo').each do |nar|
    response = http.head File.join('/repository/nixos-remote-cache', nar)

    if response.code == '404'
      nar_dump = IO.read(nar).match(/URL: (.*)$/)[1]
      puts 'Uploading ', nar, nar_dump
    end
  end
end
