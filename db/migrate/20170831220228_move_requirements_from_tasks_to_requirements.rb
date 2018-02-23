class MoveRequirementsFromTasksToRequirements < ActiveRecord::Migration[5.0]
        def change
                execute "insert into requirements (uuid, description,created_at,updated_at) select distinct md5((description->'requirements')::jsonb::text)::uuid, description -> 'requirements', now(), now() from tasks;"
		execute "update tasks set requirement_id = req.id from requirements req where md5((tasks.description->'requirements')::jsonb::text)::uuid = req.uuid;"
		execute "update tasks set description = description - 'requirements';"
		execute "alter table tasks alter column requirement_id set not null;"  # if this fails just comment it out
		execute "ALTER TABLE requirements ADD CONSTRAINT requirements_unique_uuid UNIQUE (uuid);"
        end
end
