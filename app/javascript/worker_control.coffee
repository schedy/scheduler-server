window.WorkerControl =
        view: (vnode)->
                m '.worker-control-container',
                if workers? and workers.initialized
                        worker = _.find(window.workers.object.workers, (worker)-> worker.id == parseInt(window.router.state.worker_id,10))
                        [
                                m '.worker-control-header.worker-control-content',
                                        m 'p.h1', 'Worker Control for ' +worker.name
                                m '.description-grid.worker-control-content',
                                        m 'div.h5.resource-info-header', 'Resource List'
                                        m '.resourcebox-grid',
                                                if worker.resources?
                                                        for resource in worker.resources
                                                                res_delay = (((new Date().getTime() - (resource.estimated_release_time or 0))));
                                                                resource_state = "Occupied"
                                                                if resource.task_id == 0 then hsl_degree = 0; sat_degree=0; light_degree=5; resource_state="Locked";
                                                                else if resource.task_id == null then hsl_degree = 100; sat_degree=5; light_degree=50; resource_state="Available";
                                                                else if resource.estimated_release_time == null or resource.estimated_release_time == 0 then  hsl_degree = 200; sat_degree=40; light_degree=50;
                                                                else if res_delay < -60000 then hsl_degree = 120; sat_degree=80; light_degree=40;
                                                                else if res_delay > 300000 then hsl_degree = 0; sat_degree=80; light_degree=40;
                                                                else hsl_degree = (91.4813 - 0.000291936*res_delay); sat_degree=80; light_degree=40;
                                                                resource_bg_color = 'hsl('+hsl_degree.toString()+', '+sat_degree+'%, '+light_degree+'%)'
                                                                task_id = if resource.task_id == 0 then '🔒' else resource.task_id
                                                                task_link = if (resource.task_id == 0) then '?' else "?show=execution&execution_id="+resource.execution_id+"&task_id="+resource.task_id
                                                                resource_icon = if resource.icon then resource.icon else '/schedy.svg'
                                                                resource_state_title =  if (resource.task_id == "0") then 'Locked' else if (resource_state == 'Occupied') then "Estimated Release: "+resource.estimated_release_time else 'Available'
                                                                resource_options = if resource.options then resource.options  else resource.type
                                                                m '.container-sm.resource-box', 'max-width': '200px',
                                                                        m '.row.resource-header',
                                                                                m 'a.resource-id', {"title": resource.identifier}, resource.id
                                                                                m 'a.resource-name[href=?show=resourcecontrol&resource_id='+resource.id+']', {"title":"Resource Control"}, resource.type
                                                                        m '.row.resource-body',
                                                                                m 'a.resource-state ', {"title": resource_state_title, style:{'background-color': resource_bg_color}}, resource_state #XXX:change back to resource.state
                                                                                m 'a.resource-task_id', {"title":"Execution View", "href": task_link}, resource.task_id
                                        m 'pre', (JSON.stringify(worker.resources,8) or "Not Available")
                                m 'div.worker-control-content'
                                m '.picture-grid.worker-control-content',
                                        m 'div.h5.worker-info-header', 'Worker Picture'
                                        m 'div.worker-info',
                                                m 'img.resource-image.img-thumbnail', {style:{'max-width': '75%', 'max-height':'75%','margin':'2px'},"title": worker.name, "src": "/pictures/" + worker.name + ".jpg", "class":'figure-img img-fluid', 'max-height': '100%', 'text-align': 'center'}
                        ]
                else
                        m Spinner