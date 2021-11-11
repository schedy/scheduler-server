require './config/environment.rb'
require 'digest'

class ResourceSingle < Producer
	@patterns = ['resource:*']

	def self.produce(seapig_object_id)
		seapig_object_id =~ /resource:(.*)&worker:(.*)/
        resource_id = $1.to_i
        worker_id = $2.to_i
        version = SeapigDependency.versions('Resource:%010i'%[resource_id+worker_id])
        resource = Resource.where(worker_id: worker_id, remote_id: resource_id).first
        data = {
            id: resource_id,
            worker_id: worker_id,
            logs: ("Not Available"),
            description: (resource&.status&.description or 'None')
        }
		data = {} if not data
		[data, version]
	end
end
