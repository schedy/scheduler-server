window.ResourceControl =
        view: (vnode)->
                if resource? and resource.initialized
                        status = resource.object.description.task_id
                        identifier = if resource.object.description.identifier then resource.object.description.identifier else 'Unknown Resource'
                        m '.resource-control-container',
                                        [       m '.resource-control-header.resource-control-content',
                                                        m 'p.h1', 'Resource Control for '+identifier
                                                m '.description-worker-grid.resource-control-content',
                                                        m 'div',
                                                                m '.h5.resource-info-header','Description'
                                                                m 'pre', (JSON.stringify(resource.object.description, undefined,8) or "Not Available")
                                                m '.picture-grid.resource-control-content',
                                                        m 'div',{style:{'text-align':'center'}},
                                                                m '.h5.resource-info-header','Resource Picture'
                                                                m 'img.resource-image.img-thumbnail', {style:{'max-width': '75%', 'max-height':'75%','margin':'2px'},"title": identifier, "src": "/pictures/" + identifier + ".jpg", "class":'figure-img img-fluid'}
                                        ]
                else
                        m Spinner