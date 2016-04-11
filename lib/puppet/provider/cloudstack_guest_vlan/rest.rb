require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_guest_vlan).provide :rest, :parent => Puppet::Provider::CloudstackRest do
  desc "REST provider for Cloudstack Networking - Guest VLAN (Dedication)"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      dedicateGuestVlan
      return
    end
    
    if @property_flush[:ensure] == :absent
      releaseGuestVlan
      return
    end 

    raise "Guest VLAN does not have any update functions!"
  end  

  def self.instances
    result = Array.new      
    
    list = get_objects(:listDedicatedGuestVlanRanges, "dedicatedguestvlanrange")
    if list != nil
      list.each do |object|    
        map = getGuestVlan(object)
        if map != nil
          Puppet.debug "Guest VLAN: "+map.inspect
          result.push(new(map))
        end
      end 
    end   
         
    result 
  end
      
  def self.getGuestVlan(object)         
    if object["id"] != nil              
      physicalnetwork = genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'id', object["physicalnetworkid"], {}, 'name', false)
      {
        :id                 => object["id"],
        :name               => object["guestvlanrange"],   
        :account            => object["account"],
        :domainid           => object["domainid"],
        :domain             => object["domain"],    
        :physicalnetworkid  => object["physicalnetworkid"],
        :physicalnetwork    => physicalnetwork,
        :ensure             => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def dedicateGuestVlan
    Puppet.debug "Dedicate Guest VLAN Range "+resource[:name]
 
    domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:physicalnetwork], {}, 'id')
      
    params = {            
      :vlanrange          => resource[:name],       
      :account            => resource[:account],
      :domainid           => domainid,
      :physicalnetworkid  => physicalnetworkid,
    }
    
    Puppet.debug "dedicateGuestVlanRange PARAMS = "+params.inspect
    response = self.class.http_get('dedicateGuestVlanRange', params)
  end

  def releaseGuestVlan
    Puppet.debug "Release Guest VLAN Range "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "releaseDedicatedGuestVlanRange PARAMS = "+params.inspect
    response = self.class.http_get('releaseDedicatedGuestVlanRange', params)
    self.class.wait_for_async_call(response["jobid"])
  end
  
  def lookupId 
    params = { :vlanrange => resource[:name] }
    list = self.class.get_objects(:listDedicatedGuestVlanRanges, "dedicatedguestvlanrange", params)
    if list != nil
      list.each do |object|    
        return object["id"]
      end
    end   
    
    raise "DedicatedGuestVlanRange could not be found: "+params.inspect
  end
end