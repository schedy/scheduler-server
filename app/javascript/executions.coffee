

window.ExecutionStatusBar =
        view: (vnode)->
                total_tasks = 0
                task_width = 4
                return m "" if vnode.attrs.max_progressbar_width < 50
                for status, task_count of vnode.attrs.task_statuses
                        total_tasks += task_count
                statuses = _.sortBy(_.keys(vnode.attrs.task_statuses), (name) -> _.indexOf(["crashed","failed","timeout","finished","cancelled","started","transition","accepted","assigned","waiting","paused"],name))
                bar_sections = [[]]
                bar_lengths = [0]
                for status in statuses
                        pixels_to_distribute =  vnode.attrs.task_statuses[status] * task_width
                        while pixels_to_distribute > 0
                                space = vnode.attrs.max_progressbar_width - bar_lengths[bar_lengths.length-1]
                                if pixels_to_distribute <= space
                                        bar_sections[bar_sections.length-1].push([status, pixels_to_distribute])
                                        bar_lengths[bar_lengths.length-1] += pixels_to_distribute
                                        pixels_to_distribute = 0
                                else
                                        bar_sections[bar_sections.length-1].push([status, space])
                                        bar_lengths[bar_lengths.length-1] += space
                                        bar_sections.push([])
                                        bar_lengths.push(0)
                                        pixels_to_distribute -= space
                if total_tasks > 0
                        for i in [0...bar_lengths.length]
                                m '.progress', class: ( if i > 0 then 'no-top-border' else ''), style: "width: "+(bar_lengths[i]+2)+"px",
                                        for segment in bar_sections[i]
                                                m '.progress-bar.progress-bar-striped.task_status_'+segment[0], style: "width: "+segment[1]+"px", title: segment[0] + ': ' + vnode.attrs.task_statuses[segment[0]]


window.Executions =
        view: (vnode)->
                m '#executions.container-fluid', style: { position: 'relative' },
                        m 'table.table.executions-table-grid',
                                m 'thead.executions-table-header',
                                        m 'tr',
                                                m 'th.id-column', 'ID'
                                                m 'th.status-column', 'Status'
                                                m 'th.created-at-column',m.trust('Created&nbsp;at')
                                                m 'th.tasks-column', 'Tasks'
                                                m 'th.tags-column.text-center', 'Tags'
                                                m 'th.actions-column.text-center', 'Actions'
                                m 'tbody.executions-table-body',
                                        if executions? and executions.initialized
                                                for execution in executions.object.executions
                                                        m 'tr', key: execution.id,
                                                                m 'td.id_column',
                                                                        m 'a[href="?show=execution&execution_id='+execution.id+'"]', execution.id
                                                                m 'td.status-column', execution.status
                                                                m 'td.created-at-column', title: new Date(execution.created_at+"Z").toString().substr(0,25), short_date(execution.created_at+"Z")
                                                                m 'td.tasks-column',
                                                                        m ExecutionStatusBar, task_statuses: execution.task_statuses, max_progressbar_width: 500
                                                                m 'td.tags-column',
                                                                        if execution.tags?
                                                                                m '.tags',
                                                                                        for key,values of execution.tags
                                                                                                m '.tag',
                                                                                                        [
                                                                                                                m '.key.execution-tag-key-'+key,key
                                                                                                                for value in values
                                                                                                                        if value.match(/http/)
                                                                                                                                m 'a.value.execution-tag-value-link', href: value, value
                                                                                                                        else
                                                                                                                                m '.value.execution-tag-value-'+value,value

                                                                                                        ]
                                                                m 'td.actions-column.text-center',
                                                                        m '.dropdown',
                                                                                m 'button.btn.btn-outline-dark.btn-sm',{'data-bs-toggle':'dropdown'},
                                                                                        m 'svg.actions',{'xmlns':'http://www.w3.org/2000/svg', 'width':"16", 'height':"16", 'fill':"currentColor", 'class':"bi bi-list", 'viewBox':"0 0 16 16"},
                                                                                                 m 'path', {'fill-rule':"evenodd", 'd':"M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"}

                                                                                m 'ul.dropdown-menu.pull-right',
                                                                                        m 'li',
                                                                                                m 'a.dropdown-item.execution-action.retrigger-execution',{'href':'?','data-action':'retrigger','data-execution-id': execution.id},'Retrigger'
                                                                                        m 'li',
                                                                                                m 'a.dropdown-item.execution-action.force-status-execution',{'href':'?','data-action':'status','data-execution-id': execution.id,'data-options':'{ "from": "waiting", "to": "cancelled" }'},'Cancel'
                                                                                        m 'li',
                                                                                                m 'a.dropdown-item.execution-action.force-status-execution',{'href':'?','data-action':'status','data-execution-id': execution.id,'data-options':'{ "from": "waiting", "to": "paused" }'},'Pause'
                                                                                        m 'li',
                                                                                                m 'a.dropdown-item.execution-action.force-status-execution',{'href':'?','data-action':'status','data-execution-id': execution.id,'data-options':'{ "from": "paused", "to": "waiting" }'},'Resume'
                        m Spinner if (not executions?) or (not executions.valid)
