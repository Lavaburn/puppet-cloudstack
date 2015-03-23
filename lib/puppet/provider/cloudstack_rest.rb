begin
  require 'rest-client' if Puppet.features.rest_client?
  require 'json' if Puppet.features.json?  
rescue LoadError => e
  Puppet.info "Cloudstack Puppet module requires 'rest-client' and 'json' ruby gems."
end

class Puppet::Provider::Rest < Puppet::Provider
  desc "Cloudstack API REST calls"
  
  confine :feature => :json
  confine :feature => :rest_client
  
  def initialize(value={})
    super(value)
    @property_flush = {} 
  end
    
  def self.get_rest_info
    # TODO - read the below variables from a config file
    
    ip = '172.20.130.3'
    port = '8080'
    api_key = 'uLnaxqvEBjpAXuvhx1QCbrJCcCzE91VpxaQRBv-PYp9B59U8qh2pZTHZpnAgHZaIVra2JSZa9AzSJ-D0si-0gA'
    api_secret = 'Pb7nxPwoMnsjffdKiLHWvFBN678IcnVnxQGS915-uqUr2TVRvh_GXKgOItFpMzZJ29Gu4VSVlMi47NyDf0EHtg'

    { :ip         => ip,
      :port       => port,
      :api_key    => api_key,
      :api_secret => api_secret
    }
  end

  def exists?    
    @property_hash[:ensure] == :present || 
      @property_hash[:ensure] == :running ||
      @property_hash[:ensure] == :stopped
  end
  
  def create
    @property_flush[:ensure] = :present
  end

  def destroy        
    @property_flush[:ensure] = :absent
  end
          
  def self.prefetch(resources)        
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end  
   
  def self.get_objects(command, resultName, params = Hash.new)    
    #Puppet.debug "CLOUDSTACK-API (generic) get_objects: #{command}"
    
    response = http_get(command, params)
      
    items = response[resultName]
    #Puppet.debug("Call #{command} to Cloudstack API returned #{resultName} = #{items.inspect}")

    items
  end
  
  def self.sign(baseUrl, params, api_secret) 
    data = params.map{ |k,v| "#{k.to_s}=#{CGI.escape(v.to_s).gsub(/\+|\ /, "%20")}" }.sort.join('&')
    signature = OpenSSL::HMAC.digest 'sha1', api_secret, data.downcase
    signature = Base64.encode64(signature).chomp
    signature = CGI.escape(signature)
    #Puppet.debug "CLOUDSTACK-API signing with #{signature}"
    
    baseUrl + data + "&signature=#{signature}"
  end
  
  
  def self.http_get(command, params = Hash.new) 
    #Puppet.debug "CLOUDSTACK-API (generic) http_get: #{command}"
        
    rest = get_rest_info
    baseUrl = "http://#{rest[:ip]}:#{rest[:port]}/client/api?"

    params['command'] = command
    params['apiKey'] = rest[:api_key]
    params['response'] = 'json'
    signedUrl = sign(baseUrl, params, rest[:api_secret])

    responseJson = get_json_from_url(signedUrl)
    #Puppet.debug "Call #{command} to Cloudstack API returned: #{responseJson}"
    
    response = responseJson["#{command}response".downcase]
    #Puppet.debug "#{command}response = #{response}"
    if response == nil
      if command == "resetSSHKeyForVirtualMachine"
        response = responseJson["resetSSHKeyforvirtualmachineresponse"]
      end      
      if command == "updateVMAffinityGroup"
        response = responseJson["updatevirtualmachineresponse"]
      end
      
      if response == nil
        Puppet.debug "Call #{command} to Cloudstack API returned an expected result: #{responseJson}"
      end
    end
      
    response
  end
  
  def self.get_json_from_url(url)    
    #Puppet.debug "CLOUDSTACK-API (generic) get_json_from_url: #{url}"
    
    rest = get_rest_info
    
    begin
      response = RestClient.get url
    rescue => e
      #Puppet.debug "Cloudstack API response: "+e.inspect
      raise "Unable to contact Cloudstack API on http://#{rest[:ip]}:#{rest[:port]}/client/api: #{e.response}"
    end
  
    begin
      responseJson = JSON.parse(response)
    rescue
      raise "Could not parse the JSON response from Cloudstack API: #{response}"
    end
    
    responseJson
  end
  
  def self.wait_for_async_call(jobID)
    result = false
    while !result
      sleep 5.0
      params = { "jobid" => jobID }
      jobResult = http_get('queryAsyncJobResult', params)
      #Puppet.debug "Waiting for async call: "+jobResult.inspect
        
      if jobResult == nil
        result = true
      else
        result = (jobResult["jobstatus"] != 0) #PENDING => false
      end
      
      if !result
        Puppet.debug "Waiting 5s for asynchronous job result."
      end
    end
    
    if jobResult == nil
      raise "Could not retrieve Async Job Status"
    else
      if jobResult["jobstatus"] == 1
        return #SUCCESS
      else
        if jobResult["jobstatus"] == 2 && jobResult["jobresulttype"] == "text"
          raise "[ERROR #{jobResult["jobresultcode"]}] "+jobResult["jobresult"]
        else
          raise "Async Job Status Query did not return a valid result: "+jobResult.inspect
        end
      end
    end
  end
end