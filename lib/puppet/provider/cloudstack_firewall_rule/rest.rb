require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_firewall_rule).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Firewall Rule"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      create_rule
      return
    end
    
    if @property_flush[:ensure] == :absent
      delete_rule
      return
    end 

    update_rule
  end  

  def self.instances
    list = get_objects(:listFirewallRules, "firewallrule", { :listall => true })
    if list == nil
      return Array.new
    end   
     
    result = Array.new  
    list.each do |object|
      map = getFirewallRule(object)
      if map != nil
        #Puppet.debug "Firewall Rules FOUND: "+map.inspect
        result.push(new(map))
      end
    end

    result 
  end
    
  def self.getFirewallRule(object)   
    if object["ipaddress"] != nil  
      if object["protocol"] == 'tcp' or object["protocol"] == 'udp' 
        name = "#{object["cidrlist"]}_#{object["ipaddress"]}_#{object["protocol"]}_#{object["startport"]}"
      else
        name = "#{object["cidrlist"]}_#{object["ipaddress"]}_#{object["protocol"]}"
      end
      
      {
        :name            => name,
        :source          => object["cidrlist"],
        :publicipaddress => object["ipaddress"],
        :protocol        => object["protocol"],        
        :startport       => object["startport"],
        :endport         => object["endport"],
        :ensure          => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def create_rule    
    Puppet.debug "Creating Firewall Rule "+resource[:name]

    publicip_id = self.class.genericLookup(:listPublicIpAddresses, 'publicipaddress', 'ipaddress', resource[:publicipaddress], { :listall => true }, 'id')   
      
    params = { 
      :ipaddressid => publicip_id,
      :cidrlist    => resource[:source],      
      :protocol    => resource[:protocol],
    }
    
    if resource["protocol"] == 'tcp' or resource["protocol"] == 'udp' 
      params['startport'] = resource[:startport]
      params['endport'] = resource[:endport] 
    else
      params['icmpcode'] = '-1'
      params['icmptype'] = '-1'
    end
    
    #Puppet.debug "createFirewallRule PARAMS = "+params.inspect
    response = self.class.http_get('createFirewallRule', params)
    self.class.wait_for_async_call(response["jobid"])   
  end

  def delete_rule
    Puppet.debug "Deleting Firewall Rule "+resource[:name]
    
    rule = self.class.getRule(resource[:source], resource[:publicipaddress], resource[:protocol], resource[:startport])    
    params = { 
      :id => rule['id'],
    }
    #Puppet.debug "deleteFirewallRule PARAMS = "+params.inspect
    response = self.class.http_get('deleteFirewallRule', params)      
    self.class.wait_for_async_call(response["jobid"])   
  end
  
  def update_rule
    Puppet.warning "Firewall Rule updates are not supported. Please delete the old rule with ensure => 'absent'"
    Puppet.warning "The Firewall Rule name needs to be in the format: source_publicip_proto[_startport] (startport only if tcp/udp)"
  end
  
  def self.getRule(source, publicipaddress, protocol, startport)
    params = { :cidrlist => source, :ipaddress => publicipaddress, :protocol => protocol, :startport => startport, :listall => true }
    if protocol == 'tcp' or protocol == 'udp' 
      params[:startport] = startport
    else
      params[:icmpcode] = '-1'
    end
    
    list = get_objects(:listFirewallRules, "firewallrule", params)    
    if list == nil
      raise "No firewall rule found - "+params.inspect
    end
    list.collect do |object|
      return object
    end
  end
end