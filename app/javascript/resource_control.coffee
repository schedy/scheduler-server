window.ResourceControl =
        view: (vnode)->
            m '.resource-control-container',
                if resource? and resource.initialized
                    [   m '.resource-control-header.resource-control-content',
                                m 'p.h1', 'Resource Control for '+resource.object.description.identifier
                        m '.actions-grid-container.resource-control-content',
                                m 'div',
                                        m 'a.btn.btn-outline-secondary.resource-action.lock-resource-action',{"type": "button","href":"?","data-action":"lock","data-resource-id":resource.object.id}, '🔒 Lock Resource'
                                m 'div',
                                        m 'a.btn.btn-outline-primary.resource-action.unlock-resource-action',{"type": "button","href":"?","data-action":"unlock","data-resource-id":resource.object.id}, '🔒 Unlock Resource'
                                m 'div',
                                        m 'a.btn.btn-outline-danger.resource-action.delete-resource-action',{"type": "button","href":"?","data-action":"delete","data-resource-id":resource.object.id}, '🗑️ Delete Resource'
                                m 'div',
                                        m 'a.btn.btn-outline-primary.resource-action.update-resource-action',{"type": "button","href":"?","data-action":"update","data-resource-id":resource.object.id}, '⬆️ Update Resource'
#                        m '.logs-grid.resource-control-content',
#                                m 'p.h2', 'Logs'
#                                m 'pre.logs',
#                                        m 'code', (resource.object.logs or "Not Available")
                        m '.description-grid.resource-control-content',
                                m 'p.h2', 'Description'
                                m 'pre.description',
                                        m 'code', (JSON.stringify(resource.object.description, undefined, 8) or "Not Available")
#                        m '.mounts-grid.resource-control-content',
#                                m 'p.h2', 'Mounts'
#                                m 'pre.mounts',
#                                        m 'code', (JSON.stringify(resource.object.description.mounts, undefined, 8)  or "Not Available")
                    ]
                else
                        m Spinner