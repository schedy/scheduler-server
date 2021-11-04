window.ResourceControl =
        view: (vnode)->
            m '.resource-control-container',
                if resource? and resource.initialized
                        status = resource.object.description.task_id
                        if status == null
                                statStr = "Available"
                        else if status == 0
                                statStr = "Locked"
                        else
                                statStr = "Running"
                        [       m '.resource-control-header.resource-control-content',
                                        m 'p.h1', 'Resource Control for '+resource.object.description.identifier
                                m '.description-worker-grid.resource-control-content',
                                        m 'div','Description: ' #statStr
                                        m 'div',
                                                m 'code', (JSON.stringify(resource.object.description, undefined,8) or "Not Available")
                                m '.picture-grid.resource-control-content',
                                        m 'div',{style:{'text-align':'center'}},
                                                m 'img.resource-image', {style:{'max-width': '50%', 'max-height':'50%','margin':'2px'},"title": resource.object.description.identifier, "src": "/pictures/" + resource.object.description.identifier + ".jpg", "class":'figure-img img-fluid'}
                                                        #m 'figcaption', "class":'figure-caption text-right', "Picuture of Resource"
#                                m 'pre .mounts',resource.object.description.identifier m '.worker-state', 'Last Update: '+worker.last_status_update
#                                        m 'code', (JSON.stringify(resource.object.description.mounts, undefined, 8)  or "Not Available")
                        ]
                else
                        m Spinner