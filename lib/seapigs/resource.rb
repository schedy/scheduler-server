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
            #logs: ['2021-05-20 12:36:34.820711+00','UPDATE','assign', 'tester','{"id": 41, "task_id": null, "parent_id": null, "created_at": "2020-08-27T20:05:13.625413", "updated_at": "2020-08-28T05:13:49.786227", "description": {"type": "Prosim", "mounts": {"1.7.1": {"name": "prosim-serial", "host_path": "/dev/serial/by-path/pci-0000:66:00.0-usb-0:1.7:1.0-port0", "guest_path": "/dev/serial/by-path/pci-0000:66:00.0-usb-0:1.7:1.0-port0", "updated_at": "2020"}}, "options": {"version": [null, "8"]}, "serialPort": "/dev/serial/by-path/pci-0000:66:00.0-usb-0:1.7:1.0-port0", "transition_dockerfile": "no"}, "children_ids": [35], "estimated_release_time": null}  '].join("\n"),
            icon: (resource["icon"] or 'http://localhost:8000/schedy.svg'),
            logs: (resource["logs"] or "Not Available"),
            description: resource.status.description
        }
		data = {} if not data
		[data, version]
	end
end
