Layout = {
        view: (controller, args) ->
                if router.state_valid
                        [
                                m 'nav.navbar.navbar-inverse.navbar-static-top',
                                        m '.container-fluid',
                                                m 'ul.nav.navbar-nav',
                                                        m 'li', [ m 'a.executions-link[href="?show=executions"]', style: { "color": "#DDDDDD" }, 'Executions' ]
                                                        m 'li', [ m 'a[href="?show=workers"]', style: { "color": "#DDDDDD" }, 'Workers' ]
                                                m 'ul.nav.navbar-nav.navbar-right',
                                                        m 'li',
                                                                m 'a[href="https://github.com/schedy"]',
                                                                        m 'small',
                                                                                'Scheduler on Github'

                                m '.container-fluid',
                                        m '.row',
                                                if router.state.show == 'executions'
                                                        [
                                                                m '.col-md-12', style: { 'padding-left': '100px' },
                                                                        m.component(Executions)
                                                                m '', style: { position: 'fixed', width: '100px' },
                                                                        m.component(Filters)
                                                        ]
                                                if router.state.show == 'execution'
                                                        m '.col-md-12',
                                                                m.component(Execution)
                                                if router.state.show == 'workers'
                                                        m '.col-md-12',
                                                                m.component(Workers)
                        ]
                else
                        m 'span', 'Loading...'
}


Executions = {
        view: (controller, args) ->
                m '.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-striped.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th.id-column', 'ID'
                                                m 'th.creator-column', 'Creator'
                                                m 'th.status-column', 'Status'
                                                m 'th', 'Tasks'
                                                m 'th', 'Tags'
                                m 'tbody',
                                        if executions? and executions.object.executions?
                                                for execution in executions.object.executions
                                                        m 'tr', key: execution.id,

                                                                m 'td.id_column',
                                                                        m 'a[href="?show=execution&execution_id='+execution.id+'"]', execution.id
                                                                m 'td.creator-column', execution.creator
                                                                m 'td.status-column', execution.status
                                                                m 'td',
                                                                        for task in execution.tasks
                                                                                m 'div.task_marker.task_status_'+task.status, title: 'Task#'+task.id+' '+task.status, ''
                                                                m 'td',
                                                                        if execution.tags?
                                                                                m '.tags',
                                                                                        for key,values of execution.tags
                                                                                                m '.tag',
                                                                                                        [
                                                                                                                m '.key.execution-tag-key-'+key,key
                                                                                                                for value in values
                                                                                                                        if value.match(/http/)
                                                                                                                                m 'a.value.execution-tag-value-link[href="'+value+'"]',value
                                                                                                                        else
                                                                                                                                m '.value.execution-tag-value-'+value,value

                                                                                                        ]
                        m.component(Spinner) if not executions.valid
        }


Spinner = {
        view: ->
                m '.backdrop', style: { position: 'absolute', top: '0px', bottom: '0px', right: '0px', left: '0px', 'background-color': "rgba(0,0,0,0.2)" },
                        m '', style: { width: '45px', margin: 'auto', position: 'relative', top: '50%', transform: 'translateY(-50%)'  },
                                m '.spinner-loader'
        }


Filters = {
        view: ->
                m '.container-fluid', style: { position: 'relative', "min-height": "200px" },
                        m '.h5', 'Filter by:'
                        m 'ul.list-unstyled',
                                if execution_filters.valid
                                        for creator in execution_filters.object.creators
                                                m 'li',
                                                        m 'a[href="?'+((router.state.executions_filter.creator == creator) and '-' or '')+'executions_filter~creator='+creator+'"]', ((router.state.executions_filter.creator == creator) and '☑' or '☐') + ' ' + creator
                        m.component(Spinner) if not execution_filters.valid
        }



Execution = {
        view: (controller, args) ->
                m '.container-fluid', style: { position: 'relative' },
                        m '.execution-summary.alert.alert-info.col-xs-12',
                                m '.col-xs-12',
                                        m '.col-xs-4',
                                                m 'strong','Execution ID: '
                                                m 'span.execution-id',execution.object.id
                                        m '.col-xs-4',
                                                m 'strong','Execution Duration: '
                                                m 'span.execution-duration',execution.object.duration
                                        m '.col-xs-4',
                                                m 'strong','Execution Status: '
                                                m 'span.execution-duration',execution.object.status

                                m '.col-xs-12',
                                        if execution.object.tags?
                                                m '.tags.pull-left.col-xs-12',
                                                        m 'strong.pull-left','Tags: '
                                                        for key,values of execution.object.tags
                                                                m '.tag',
                                                                        [
                                                                                m '.key.execution-tag-key-'+key,key
                                                                                for value in values
                                                                                        if value.match(/http/)
                                                                                                m 'a.value.execution-tag-value-link[href="'+value+'"]',value
                                                                                        else
                                                                                                m '.value.execution-tag-value-'+value,value

                                                                        ]
                                m '.clear'

                        m 'table.table.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th.id-column', 'ID'
                                                m 'th.status-column', 'Status'
                                                m 'th.date-column', 'Created at'
                                                m 'th.date-column', 'Last status change at'
                                                m 'th', 'Executor'
                                                m 'th', 'Tags'
                                m 'tbody',
                                        if execution? and execution.valid
                                                for task in execution.object.tasks
                                                        [
                                                                m 'tr', key: task.id,
                                                                        m 'td.id-column',
                                                                                if router.state.task_unfolded == task.id.toString()
                                                                                        m 'a[href="?-task_unfolded='+task.id+'"]', task.id
                                                                                else
                                                                                        m 'a[href="?task_unfolded='+task.id+'"]', task.id
                                                                        m 'td.status-column', task.status
                                                                        m 'td.date-column', task.created_at
                                                                        m 'td.date-column', task.status_changed_at
                                                                        m 'td', task.description.executor
                                                                        m 'td',
                                                                                if task.tags?
                                                                                        m '.tags',
                                                                                                for key,values of task.tags
                                                                                                        m '.tag',
                                                                                                                [
                                                                                                                        m '.key.task-tag-key-'+key,key
                                                                                                                        for value in values
                                                                                                                                m '.value.task-tag-value-'+value,value
                                                                                                                ]


                                                                if router.state.task_unfolded == task.id.toString()
                                                                        m 'tr', key: task.id+'_description',
                                                                                m 'td.id-column', style: "border-top: none !important;", ''
                                                                                m 'td', colspan: 5, style: "border-top: none !important;" ,
                                                                                        m 'div', style: { position: 'relative', "min-height": "64px" },
                                                                                                m 'pre', JSON.stringify(window.task.object.description, undefined, 8)
                                                                                                m 'ul.list-unstyled',
                                                                                                        if window.task.object.artifacts?
                                                                                                                for artifact in window.task.object.artifacts
                                                                                                                        m 'li',
                                                                                                                                m 'a[href="/artifacts/'+artifact.id+'/'+artifact.name+'"]',artifact.name
                                                                                                m.component(Spinner) if (not window.task?) or (not window.task.valid)
                                                        ]
                        m '.tag-counts',


                        m.component(Spinner) if (not execution?) or (not execution.valid)
        }


Workers = {
        view: (controller, args) ->
                m '.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th.id-column', 'Name'
                                                m 'th.date-column', 'Last status update'
                                                m 'th.resources-column', 'Resources'
                                m 'tbody',
                                        if workers? and workers.valid
                                                for worker in workers.object.workers
                                                        m 'tr', key: worker.name,
                                                                m 'td.id-column', worker.name
                                                                m 'td.date-column', worker.last_status_update
                                                                m 'td.resources-column',
                                                                        if worker.resources?
                                                                                for resource in worker.resources
                                                                                        m '.resource'+((resource.task_id == null) and '.bg-success' or ((resource.task_id == 0) and '.bg-info' or '.bg-warning')), style: { float: 'left', "margin-right": '10px', 'padding-left': '5px', 'padding-right': '5px' }, resource.id.toString()+":"+resource.type+((resource.task_id == null) and ' ' or '('+resource.task_id+')')

        }



$(document).ready () =>

        @session_key = $('body').attr('data-session-key')

        @seapig_server = new SeapigServer('ws://'+window.location.host+'/seapig', name: 'web')

        @router = new SeapigRouter(@seapig_server, @session_key, "?show=executions&executions_filter~limit=50", false)

        @router.statefilter = (state)=>
                if state.show == 'executions'
                        delete state['execution_id']
                        delete state['task_unfolded']

        @executions = @execution = null

        @execution_filters = @seapig_server.slave('execution:filters')
        @execution_filters.onchange = ()=> m.redraw()

        @router.onstatechange = (state)=>

                if (not @executions) or (not _.isEqual(state.executions_filter, @executions.filter))
                        @executions.unlink() if @executions
                        @executions = @seapig_server.slave('executions-filtered-'+state.session_id+':'+state.id)
                        @executions.filter = JSON.parse(JSON.stringify(state.executions_filter))
                        @executions.onchange = ()=> m.redraw()


                if state.show == 'execution'
                        if (not @execution?) or (@execution.id != 'execution-'+state.execution_id)
                                @execution.unlink() if @execution?
                                @execution = @seapig_server.slave('execution-'+state.execution_id)
                                @execution.onchange = ()=> m.redraw()
                else
                        if @execution?
                                @execution.unlink()
                                @execution = null


                if state.task_unfolded?
                        if (not @task?) or (@task.id != 'task-'+state.task_unfolded)
                                @task.unlink() if @task?
                                @task = @seapig_server.slave('task-'+state.task_unfolded)
                                @task.onchange = ()=> m.redraw()
                else
                        if @task?
                                @task.unlink()
                                @task = null

                if state.show == 'workers'
                        if not @workers?
                                @workers = @seapig_server.slave('workers')
                                @workers.onchange = ()=> m.redraw()
                else
                        if @workers?
                                @workers.unlink()
                                @workers = null


                m.redraw()



        m.mount $('#layout')[0], Layout
        @router.location_changed()
