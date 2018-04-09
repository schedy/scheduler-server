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
                                                                                                m '.resource'+((resource.task_id == null) and '.bg-success' or ((resource.task_id == 0) and '.bg-info' or '.bg-warning')), style: { float: 'left', "margin-right": '10px', 'padding-left': '5px', 'padding-right': '5px' }, resource.id.toString()+":"+resource.type+((resource.task_id == null) and ' ' or '('+resource.task_id+')')
                                                                        m 'td.action-icons-column',
                                                                                m '.action-icon.seapig-binding-element-delete.seapig-binding-autosave.delete-worker',{"data-worker-id": worker.id},'✖'
                                                        ]
                        m Spinner if (not workers?) or (not workers.valid)


