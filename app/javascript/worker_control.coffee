window.WorkerControl =
        view: (vnode)->
                m '.worker-control-container',
                if workers? and workers.initialized
                        worker = _.find(window.workers.object.workers, (worker)-> worker.id == parseInt(window.router.state.worker_id,10))
                        [
                                m '.worker-control-header.worker-control-content',
                                        m 'p.h1', 'Worker Control for ' +worker.name
                                        m 'div', 'Resources: '
                                m '.description-grid.worker-control-content',
                                        m 'resourcebox-grid',
                                                if worker.resources?
                                                        for resource in worker.resources
                                                                res_delay = (((new Date().getTime() - (resource.estimated_release_time or 0))));
                                                                hsl_degree = (91.4813 - 0.000291936*res_delay); sat_degree=80; light_degree=40;
                                                                resource_bg_color = 'hsl('+hsl_degree.toString()+', '+sat_degree+'%, '+light_degree+'%)'
                                                                resource_state = if (resource.task_id == null) then 'Available' else 'Occupied'
                                                                task_link = if (resource.task_id == "0") then '?' else "/?show=execution&execution_id="+resource.execution_id+"&task_id="+resource.task_id
                                                                resource_options = if resource.options then resource.description.options  else resource.type
                                                                m '.container-sm.resource-box', 'max-width': '200px',
                                                                        m '.row.resource-header',
                                                                                m 'a.resource-id', {"title": resource.identifier}, resource.id
                                                                                m 'a.resource-name[href=?show=resourcecontrol&resource_id='+resource.id+']', {"title":"Resource Control"}, resource.type
                                                                        m '.row.resource-body',
                                                                                m 'a.resource-state ', {"title":"Estimated Release: "+resource.estimated_release_time, style:{'background-color': resource_bg_color}}, resource_state #XXX:change back to resource.state
                                                                                m 'a.resource-task_id', {"title":"Execution View", "href": task_link}, resource.task_id
                                        m 'code', (JSON.stringify(worker.resources, ["type","id","location","identifier","options"],8) or "Not Available")
                                m 'div.worker-control-content'
                                m '.picture-gird.worker-control-content','text-align':'center',
                                        m 'div',
                                                m 'img.resource-image', {"title": worker.name, "src": "/pictures/" + worker.name + ".jpg", "class":'figure-img img-fluid', 'max-height': '100%', 'text-align': 'center'}
                        ]
                else
                        m Spinner