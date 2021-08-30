window.Workers =
        view: (vnode)->
                m Spinner if (not workers?) or (not workers.valid)
                m '#workers.container-fluid', style: {position: 'relative'},
                        m 'table.workers-table.table[data-seapig-binding-element=workers]',
                                m 'thead.workers-table',
                                        m 'tr.workers-table',
                                                m 'th.workers-column', 'Workers'
                                                m 'th.resources-column', 'Resources'
                                m 'tbody.workers-table',
                                        if workers? and workers.initialized
                                                for worker in workers.object.workers
                                                        if (((new Date().getTime() - Date.parse(worker.last_status_update)) > 120000)) then worker_status = 'worker-dead' else worker_status = 'worker-alive'
                                                        [
                                                                m 'tr.workers-table',
                                                                        m 'td.worker-column.workers-table',
                                                                                m '.worker-grid-container.worker-box',
                                                                                        m ".worker-name-grid",
                                                                                                m '.worker-name', {"title": worker.ip}, worker.name
                                                                                        m ".worker-last-update-grid",
                                                                                                m '.worker-state', 'Last Update: '+worker.last_status_update
                                                                                        m ".worker-action-grid",
                                                                                                m 'a.btn.terminal-access-button.btn-xs.btn-dark',{'target':'_blank','href':worker.terminal_url,'type':'button','title':'Terminal Access'},'>_'
                                                                        m 'td.resource-column.workers-table',
                                                                                m '.row.resource-column-wrapper',
                                                                                        if worker.resources?
                                                                                                for resource in worker.resources
                                                                                                        res_delay = (((new Date().getTime() - (resource.estimated_release_time or 0))));
                                                                                                        hsl_degree = (91.4813 - 0.000291936*res_delay); sat_degree=80; light_degree=40;
                                                                                                        resource_bg_color = 'hsl('+hsl_degree.toString()+', '+sat_degree+'%, '+light_degree+'%)'
                                                                                                        resource_state = if (resource.task_id == null) then 'Available' else 'Occupied'
                                                                                                        task_link = if (resource.task_id == "0") then '?' else "/?show=execution&execution_id="+resource.execution_id+"&task_id="+resource.task_id
                                                                                                        resource_options = if resource.options then resource.description.options  else resource.type
                                                                                                        m '.container-sm.resource-box',
                                                                                                                m '.row.resource-header',
                                                                                                                        m 'a.resource-id', {"title": resource.identifier}, resource.id
                                                                                                                        m 'a.resource-name', {"title":"Resource Control", "href":"?show=resourcecontrol&resource_id="+resource.id}, resource.type
                                                                                                                m '.row.resource-body',
                                                                                                                        m 'a.resource-state ', {"title":"Estimated Release: "+resource.estimated_release_time, style:{'background-color': resource_bg_color}}, resource_state #XXX:change back to resource.state
                                                                                                                        m 'a.resource-task_id', {"title":"Execution View", "href": task_link}, resource.task_id
                                                                                                                m '.resource-right',
                                                                                                                        m 'img.resource-icon', {"title": resource_options, "src": resource.icon}

                                                        ]


