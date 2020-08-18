require "net/http"
require "net/https"
require "uri"

class HttpClient

  def self.execute(url, headers = {})
    uri = URI.parse("#{url}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    if url.include?("https")
      puts "skip ssl check\n"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    count = 1
    while count < 6
      begin
        puts "[#{Time.now().iso8601(3)}] invoking #{uri}, headers: #{headers}\n"
        
        request = Net::HTTP::Get.new(uri.request_uri)
        headers.each do |key, value|
          request[key] = value
        end
        response = http.request(request)
        puts "[#{Time.now().iso8601(3)}] ResponseCode:#{response.code}\n"

        unless response["X-DEMOTRON-TRACE"].nil?
          trace = response["X-DEMOTRON-TRACE"]
          puts "Got trace:#{trace}\n"
        end

        return response
      rescue Exception => e
        puts "[#{Time.now().iso8601(3)}] Exception while executing on #{url} detail:#{e}\n"
      end

      count = count+1
      puts "Retrying, count:#{count}, in 10s..."
      sleep 10
    end

    return nil
  end

end