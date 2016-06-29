require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_public_ip).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Public IP"
  
  mk_resource_methods
  
  def flush        
    required = resource[:count]
    
    if @property_flush[:ensure] == :absent
      required = 0
    end
    
    require_public_ips(required) 
  end  

  def self.instances 
    result = Array.new
     
    list = get_objects(:listNetworks, "network", { :listall => true })    
    if list != nil      
      list.each do |object|      
        result.push new(getPublicIp(object["name"]))
      end
    end    
    
    return result
  end
        
  def self.getPublicIp(networkName)
    networkId = genericLookup(:listNetworks, 'network', 'name', networkName, { :listall => true }, 'id')
    
    count = 0
    params = { :associatednetworkid => networkId, :listall => true }
    list = get_objects(:listPublicIpAddresses, "publicipaddress", params)    
    if list != nil
      list.collect do |o|    
        count = count + 1
      end
    end
    
    state = :present
    if count == 0
      state = :absent
    end
    
    {
      :name      => networkName,
      # :networkid => networkId,
      :iplist    => list,
      :count     => count.to_s,
      :ensure    => state
    }
  end
  
  # TYPE SPECIFIC      
  private
  def require_public_ips(required)  
    currentObject = self.class.getPublicIp(@property_hash[:name])
    currentCount = currentObject[:count].to_i
      
    if required.is_a? String
      requiredCount = required.to_i
    else
      requiredCount = required
    end
           
    Puppet.debug "Network #{resource[:name]} requires #{requiredCount.to_s} public IPs and currently has #{currentCount.to_s}"
    networkId = self.class.genericLookup(:listNetworks, 'network', 'name', @property_hash[:name], { :listall => true }, 'id')
    
    if requiredCount > currentCount
      params = { :networkid => networkId }
      add = requiredCount - currentCount
      
      for i in 1..add
        response = self.class.http_get('associateIpAddress', params)
        self.class.wait_for_async_call(response["jobid"])
      end
    elsif requiredCount < currentCount
      remove = currentCount - requiredCount
      
      possibleRemovals = Array.new
      
      iplist = currentObject[:iplist]
      iplist.collect do |ip| 
        if !ip["issourcenat"]
          if !ip["isstaticnat"]
            possibleRemovals.push(ip)
          end
        end        
      end
         
      if possibleRemovals.count >= remove
        possibleRemovals.sort_by!{ |ip| 
          ip[:ipaddress] 
        }
        
        i = 0
        possibleRemovals.collect do |ip|          
          params = { :id => ip['id'] }            
          response = self.class.http_get('disassociateIpAddress', params)
          self.class.wait_for_async_call(response["jobid"])
          
          i = i + 1          
          if i >= remove
            break
          end
        end
      else
        allocated = currentCount - possibleRemovals.count        
        raise "There are #{allocated} allocated (staticnat/sourcenat) Public IPs. It is not possible to assign less IPs to network #{resource[:name]}"
      end
    else      
      raise "Public IP update called even though required IPs = current IPs. Please debug the code."
    end
  end  
end