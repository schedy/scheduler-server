require './config/environment.rb'

class ResourceSingle < Producer
	@patterns = ['resource:*']

	def self.produce(seapig_object_id)
		seapig_object_id =~ /resource:(\d+)/
		id = $1.to_i
        version = SeapigDependency.versions('Resource:%010i'%[id])
        resource = Resource.where(id: id).first
        logs =
        data = {
            id: id,
            logs: (resource["logs"] or "Not Available"),
            description: resource.status.description
        }
		data = {} if not data
		[data, version]
	end
end
