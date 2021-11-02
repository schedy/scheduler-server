window.Workers =
        view: (vnode)->
                m Spinner if (not workers?) or (not workers.valid)
                m '#workers.container-fluid', style: {position: 'relative'},
                        m 'table.workers-table.table[data-seapig-binding-element=workers]',
                                m 'thead.workers-table',
                                        m 'tr.workers-table',
                                                m 'th.workers-column',
                                                        m '.','Workers'
                                                m 'th.resources-column',
                                                        m '.','Resources'
                                m 'tbody.workers-table',
                                        if workers? and workers.initialized
                                                greens = _.reject(workers.object.workers, (o) ->
                                                        Date.now() - new Date(o.last_status_update).getTime() > 120000)
                                                reds = _.select(workers.object.workers, (o) ->
                                                        Date.now() - new Date(o.last_status_update).getTime() > 120000)
                                                workers_sorted = greens.concat(reds)
                                                for worker in workers_sorted
                                                        terminal_url = 'http://'+window.location.hostname+':2222/ssh/host/'+worker.ip
                                                        if (((new Date().getTime() - Date.parse(worker.last_status_update)) > 120000)) then worker_status = 'worker-dead' else worker_status = 'worker-alive'
                                                        [
                                                                m 'tr.workers-table',
                                                                        m 'td.worker-column.workers-table',
                                                                                m '.worker-grid-container.worker-box.'+worker_status,
                                                                                        m ".worker-name-grid",
                                                                                                m '.worker-name', {"title": worker.ip}, worker.name
                                                                                        m ".worker-last-update-grid",
                                                                                                m '.worker-state', 'Last Update: '+worker.last_status_update
                                                                                        m ".worker-action-grid",
                                                                                                m 'a.btn.terminal-access-button.btn-xs.btn-dark',{'target':'_blank','href': terminal_url,'type':'button','title':'Terminal Access'},'>_'
                                                                        m 'td.resource-column.workers-table',
                                                                                m '.row.resource-column-wrapper',
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
                                                                                                        task_link = if (resource.task_id == 0) then '?' else "/?show=execution&execution_id="+resource.execution_id+"&task_id="+resource.task_id #seapig router, click doesnt lead ?
                                                                                                        resource_options = if resource.options then JSON.stringify(resource.options) else resource.type
                                                                                                        resource_icon = if resource.icon then resource.icon else '/schedy.svg'
                                                                                                        m '.container-sm.resource-box',{'data-resource-state': resource_state, 'data-task-id': task_id, 'data-execution-id': resource.execution_id},
                                                                                                                m '.row.resource-header',
                                                                                                                        m 'a.resource-id', {"title": resource.identifier}, resource.id
                                                                                                                        m 'a.resource-name[href=?show=resourcecontrol&resource_id='+resource.id+']', {"title":"Resource Control"}, resource.type
                                                                                                                m '.row.resource-body',
                                                                                                                        m 'a.resource-state ', {"title":"Estimated Release: "+Date(resource.estimated_release_time), style:{'background-color': resource_bg_color}}, resource_state
                                                                                                                        m 'a.resource-task_id', {"title":"Execution View", "href": task_link}, task_id
                                                                                                                m '.resource-right',
                                                                                                                        m 'img.resource-icon', {"title": resource_options, "src": resource_icon}
                                                        ]


