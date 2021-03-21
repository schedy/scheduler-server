window.Workers =
        view: (vnode)->
                m '#workers.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-condensed[data-seapig-binding-element=workers]',
                                m 'thead',
                                        m 'tr',
                                                m 'th.name-column', 'Name'
                                                m 'th.date-column', 'Last status update'
                                                m 'th.resources-column', 'Resources'
                                                m 'th.action-icons-column', ''
                                m 'tbody',
                                        if workers? and workers.initialized
                                                for worker in workers.object.workers
                                                        if (((new Date().getTime() - Date.parse(worker.last_status_update)) > 120000)) then worker_status = 'worker-dead' else worker_status = 'worker-alive'
                                                        [
                                                                m 'tr.'+worker_status+'[data-seapig-binding-element='+worker.id+']', key: worker.name,
                                                                        m 'td.name-column', {"title": worker.ip},  worker.name
                                                                        m 'td.date-column', worker.last_status_update
                                                                        m 'td.resources-column',
                                                                                if worker.resources?
                                                                                        for resource in worker.resources
                                                                                                res_delay = (((new Date().getTime() - (resource.estimated_release_time or 0))))
                                                                                                resource.info="Estimated: "+new Date(resource.estimated_release_time).toString();
                                                                                                if resource.task_id == 0 then hsl_degree = 0; sat_degree=0; light_degree=50; resource.info="Locked";
                                                                                                else if resource.estimated_release_time == null or resource.estimated_release_time == 0 then  hsl_degree = 200; sat_degree=65; light_degree=91; resource.info="Unknown";
                                                                                                else if resource.task_id == null then hsl_degree = 103; sat_degree=44; light_degree=89; resource.info="Available";
                                                                                                else if res_delay < -60000 then hsl_degree = 120; sat_degree=80; light_degree=40;
                                                                                                else if res_delay > 300000 then hsl_degree = 0; sat_degree=80; light_degree=40;
                                                                                                else hsl_degree = (91.4813 - 0.000291936*res_delay); sat_degree=80; light_degree=40;

                                                                                                resource_color = 'hsl('+hsl_degree.toString()+', '+sat_degree+'%, '+light_degree+'%)'
                                                                                                m '.resource', {"title": resource.info, style: { float: 'left', "margin-right": '10px', 'padding-left': '5px', 'padding-right': '5px', 'background-color': resource_color }}, resource.id.toString()+":"+resource.type+((resource.task_id == null) and ' ' or (((resource.task_id == 0) and '(🔒)' or '('+resource.task_id+')')))
                                                        ]
                        m Spinner if (not workers?) or (not workers.valid)
