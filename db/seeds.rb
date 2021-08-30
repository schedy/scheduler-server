# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


require 'securerandom'
require 'faker'

User.create!(
    nickname: Faker::Name.last_name,
    created_at: Time.now,
    updated_at: Time.now
)


Requirement.create!(
    uuid: SecureRandom.uuid,
    description: [{"role"=>Faker::Computer.type, "type"=>Faker::Computer.os, "children"=>[]}],
    created_at: Time.now,
    updated_at: Time.now
)



def create_workers(num)
    num.times { |c|
        worker = Worker.create!(
            name: 'worker-'+Faker::Name.last_name.downcase!,
            created_at: Time.now,
            updated_at: Time.now
        )
        resources = (10..40).map { |c|
            task_id = case Random.rand(0...100)
            when 0..30 then 0
            when 30..60 then Task.all.sample.id
            else  nil
            end
            estimated_release_time = if task_id != nil then (Time.now.to_i*1000)+Random.rand(10000...100000) else 0 end
            data = {
                "id"=> c,
                "name"=> Faker::Name.first_name,
                "type"=> Faker::Computer.os,
                "identifier"=> Faker::Name.last_name,
                "location"=> Faker::Address.city,
                "task_id"=> task_id,
                "worker_id"=> worker.id,
                "estimated_release_time"=> estimated_release_time,
                "icon": Faker::Avatar.image(slug: Faker::Address.city)
            }
            resource=Resource.create!(name: Faker::Name.first_name, worker_id: worker.id)
            ResourceStatus.create!("task_id": task_id, "description": data, "resource_id": resource.id, current: true)
            data
        }
        WorkerStatus.create!(
            worker_id: worker.id,
            current: true,
            data: JSON.parse({"ip": "#{Faker::Internet.ip_v4_address}", "resources": resources, "timestamp": Time.now.to_f}.to_json),
            created_at: Time.now,
            updated_at: Time.now
        )
}
end

def create_executions(exec_count, task_count)

    properties = Hash.new { |h, k| h[k] = Property.find_or_create_by!(name: k) }
    values = Hash.new { |h, k| h[k] = Value.find_or_create_by!(property_id: k[0] , value: k[1]) }



    exec_count.times { |ec|
        execution = Execution.create!(
            user_id:1,
            data: {"payload"=>{"pr"=>{"username"=>"john_doe"}, "hooks"=>{"finished"=>["data_exporter.rb"]}, "package"=>Faker::Computer.os, "payload"=>{}, "project"=>Faker::Computer.platform, "results"=>[{"arch"=>"i586", "package"=>Faker::Computer.os, "project"=>Faker::Computer.platform}], "eventtype"=>"manual", "parent_project"=>Faker::Computer.platform, "triggered_by_package"=>Faker::Computer.os}, "multiplier"=>"1"}
        )

        ExecutionStatus.create!(
            execution_id: execution.id,
            status:"waiting",
            current: true,
            created_at: Time.now,
            updated_at: Time.now
        )
        tags = {"name" => [Faker::Name.last_name], "title": [Faker::Job.title], "field":[Faker::Job.field]}
        (tags or {}).each_pair { |property_name, tag_names|
            [tag_names].flatten.uniq.each { |value_name|
                property = properties[property_name]
                value = values[[property.id, value_name]]
                execution_value = ExecutionValue.create!(execution_id: execution.id, value_id: value.id, property_id: property.id)
            }
        }

    Random.rand(task_count[0]..task_count[1]).times { |tc|
        task = Task.create!(
            execution_id: execution.id,
            requirement_id: 1,
            retry: nil,
            description: {"tags": {"name": Faker::Name.last_name,"event_type": "manual"},"test_name": "Example","executor": "none", "dockerfile": "none"},
            created_at: Time.now,
            updated_at: Time.now
        )

        TaskStatus.create!(
            task_id: task.id,
            status:"waiting",
            current: true,
            created_at: Time.now,
            updated_at: Time.now
        )

    }
    }


end


create_executions(20,[5,500])
create_workers(7)
