require File.join(File.dirname(__FILE__), '..', 'cloudstack_rest')

Puppet::Type.type(:cloudstack_network_vlan).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Cloudstack Networking - VLAN IP Settings"
  
  mk_resource_methods
  
  def flush    
    if @property_flush[:ensure] == :present
      createVlanIpRange
      return
    end
    
    if @property_flush[:ensure] == :absent
      deleteVlanIpRange
      return
    end 

    raise "VlanIpRange (cloudstack_network_vlan) does not offer any update functions!"
  end  

  def self.instances
    result = Array.new      
    
    list = get_objects(:listVlanIpRanges, "vlaniprange")
    if list != nil
      list.each do |object|    
        map = getVlanIpRange(object)
        if map != nil
          #Puppet.debug "VLAN (IP Range): "+map.inspect
          result.push(new(map))
        end
      end 
    end   
         
    result 
  end
      
  def self.getVlanIpRange(object)         
    if object["id"] != nil              
      zone = genericLookup(:listZones, 'zone', 'id', object["zoneid"], {}, 'name')
      #SYSTEM DEFAULT ???  -  network = genericLookup(:listNetworks, 'network', 'id', object["networkid"], {}, 'name') unless object["networkid"] == nil
      physicalnetwork = genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'id', object["physicalnetworkid"], {}, 'name') unless object["physicalnetworkid"] == nil
        
      vlan = object["vlan"].sub('vlan://', '')
        
      {
        :id                 => object["id"],
        :name               => physicalnetwork+'_'+vlan+'_'+object["startip"],   
        :vlan               => vlan,
        :zoneid             => object["zoneid"],          
        :zone               => zone, 
#        :podid              => object["podid"],
#        :pod                => object["podname"],
        :account            => object["account"],
        :domainid           => object["domainid"],
        :domain             => object["domain"],
        :startip            => object["startip"],
        :endip              => object["endip"],
        :netmask            => object["netmask"],
        :gateway            => object["gateway"],
#        :networkid          => object["networkid"],
#        :network            => network,          
        :physicalnetworkid  => object["physicalnetworkid"],
        :physicalnetwork    => physicalnetwork,
        :ensure           => :present
      }
    end
  end
  
  # TYPE SPECIFIC      
  private
  def createVlanIpRange
    Puppet.debug "Create VLAN (IP Range) "+resource[:name]
 
    params = {            
      :vlan               => resource[:vlan],       
      :startip            => resource[:startip],
      :endip              => resource[:endip],
      :netmask            => resource[:netmask],
      :gateway            => resource[:gateway],
    }
    
    # NOT OPTIONAL !!!
    if resource[:zone] != nil
      zoneid = self.class.genericLookup(:listZones, 'zone', 'name', resource[:zone], {}, 'id')
      params[:zoneid] = zoneid
    end
    
    if resource[:physicalnetwork] != nil
      physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:physicalnetwork], {}, 'id')
      params[:physicalnetworkid] = physicalnetworkid
    end
    
    if resource[:account] != nil
      domainid = self.class.genericLookup(:listDomains, 'domain', 'name', resource[:domain], {}, 'id')        
      params[:account] = resource[:account]
      params[:domainid] = domainid
    end
    
    # TODO POD ???
    
    # TODO NETWORK  ???
            
    Puppet.debug "createVlanIpRange PARAMS = "+params.inspect
    response = self.class.http_get('createVlanIpRange', params)
  end

  def deleteVlanIpRange
    Puppet.debug "Delete VLAN (IP Range) "+resource[:name]
      
    id = lookupId
     
    params = { 
      :id => id,
    }
    Puppet.debug "deleteVlanIpRange PARAMS = "+params.inspect
    response = self.class.http_get('deleteVlanIpRange', params)
  end
  
  def lookupId 
    physicalnetworkid = self.class.genericLookup(:listPhysicalNetworks, 'physicalnetwork', 'name', resource[:physicalnetwork], {}, 'id')
    params = { :vlan => 'vlan://'+resource[:vlan], :startip => resource[:startip], :physicalnetworkid => physicalnetworkid }
  
    list = self.class.get_objects(:listVlanIpRanges, "vlaniprange", params)
    if list != nil
      list.each do |object|    
        return object["id"]
      end
    end   
    
    raise "VlanIpRange could not be found: "+params.inspect
  end
end