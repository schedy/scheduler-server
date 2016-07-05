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
                                                                m '.col-md-12', style: { 'padding-left': '250px', position: 'absolute' },
                                                                        m.component(Executions)
                                                                m '', style: {  width: '250px', position: 'absolute'},
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
                m '#executions.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-striped.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th.id-column', 'ID'
                                                m 'th.creator-column', 'Creator'
                                                m 'th.status-column','Status'
                                                m 'th.created-at-column','Created At'
                                                m 'th.tasks-column', 'Tasks'
                                                m 'th.tags-column.text-center', 'Tags'
                                                m 'th.actions-column.text-center', 'Actions'
                                m 'tbody',
                                        if executions.initialized
                                                for execution in executions.elements.executions
                                                        m 'tr', key: execution.id,

                                                                m 'td.id_column',
                                                                        m 'a[href="?show=execution&execution_id='+execution.id+'"]', execution.id
                                                                m 'td.creator-column', execution.creator
                                                                m 'td.status-column', execution.status
                                                                m 'td.created-at-column', new Date(execution.created_at).toString().substr(0,25);
                                                                m 'td.tasks-column',
                                                                        for task in execution.tasks
                                                                                m 'div.task_marker.task_status_'+task.status, title: 'Task#'+task.id+' '+task.status, ''
                                                                m 'td.tags-column',
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
                                                                m 'td.actions-column.text-center',
                                                                        m '.dropdown',
                                                                                m 'button.btn.btn-default.btn-sm.dropdown-toggle',{'data-toggle':'dropdown'},
                                                                                        m '.icon',{'title':'Actions'},'★'
                                                                                m 'ul.dropdown-menu.pull-right',
                                                                                        m 'li',
                                                                                                m 'a.dropdown-toggle.execution-action.duplicate-execution',{'href':'?','data-action':'duplicate','data-execution-id': execution.id},'Duplicate'
                                                                                        m 'li',
                                                                                                m 'a.dropdown-toggle.execution-action.force-status-execution',{'href':'?','data-action':'force_status','data-execution-id': execution.id,'data-options':'cancelled'},'Force Cancel'
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
                        m '.filter-header', 'filters'
                        m 'ul#filters.list-unstyled',
                                if execution_filters.initialized
                                        grouped_tags = _.groupBy execution_filters.elements.tags, (obj) -> obj.substring(0,obj.indexOf(':'))
                                        for key,value of grouped_tags
                                                m 'li',
                                                        m 'hr',style: {margin: '3px'}
                                                        m 'span.filter-parent',key,
                                                                m 'a[href="?'+(_.contains(router.state.hidden_tags,key) and '-' or '')+'hidden_tags~='+key+'"]',{'data-parent-tag': key}, (_.contains(router.state.hidden_tags,key) and '▼' or '▲')
                                                        if ( undefined == router.state.hidden_tags) or (!_.contains(router.state.hidden_tags,key))
                                                                for tag in value
                                                                        m 'li.filter-child',
                                                                                m 'a[href="?'+(_.contains(router.state.executions_filter.tags,tag) and '-' or '')+'executions_filter~tags~='+tag+'"]',{'data-parent-tag':(tag).split(':')[0],'data-child-tag':(tag).split(':')[1]}, (_.contains(router.state.executions_filter.tags,tag) and '☑' or '☐') + ' ' + tag.substring(tag.indexOf(':')+1)

                        m.component(Spinner) if not execution_filters.valid
        }



Execution = {
        view: (controller, args) ->
                m '#execution.container-fluid', style: { position: 'relative' },
                        if execution.initialized
                                [

                                        m '.execution-summary.alert.alert-info.col-xs-12',
                                                m '.col-xs-12',
                                                        m '.col-xs-4',
                                                                m 'strong','Execution ID: '
                                                                m 'span.execution-id',execution.elements.id
                                                        m '.col-xs-4',
                                                                m 'strong','Execution Duration: '
                                                                m 'span.execution-duration',execution.elements.duration
                                                        m '.col-xs-4',
                                                                m 'strong','Execution Status: '
                                                                m 'span.execution-duration',execution.elements.status
                                                m '.col-xs-12',
                                                        if execution.elements.tags?
                                                                m '.tags.pull-left.col-xs-12',
                                                                        m '.tag-group.cn.pull-left',
                                                                                m 'strong.inner','Tags:  '
                                                                                for key,values of execution.elements.tags  when key[0] != '_'
                                                                                        m '.tag.inner',
                                                                                                [
                                                                                                        m '.key.execution-tag-key-'+key,key
                                                                                                        for value in values
                                                                                                                if value.match(/http/ )
                                                                                                                        m 'a.value.execution-tag-value-link[href="'+value+'"]',value
                                                                                                                else
                                                                                                                        m '.value.execution-tag-value-'+value,value

                                                                                                ]
                                                m '.clear'
                                ]
                        m 'table-container.col-lg-12',
                                m 'table.table.table-condensed.table-hover.sortable-theme-bootstrap',{'data-sortable': ''},
                                        m 'thead',
                                                m 'tr',
                                                        m 'th.id-column', 'ID'
                                                        m 'th.status-column', 'Status'
                                                        m 'th.date-column', 'Created at'
                                                        m 'th.date-column', 'Last status change at'
                                                        m 'th', 'Requirements'
                                                        m 'th.hidden', 'Executor'
                                                        m 'th', 'Tags'
                                        m 'tbody',
                                                if execution.initialized
                                                        for task in execution.elements.tasks
                                                                [
                                                                        m 'tr', key: task.id,
                                                                                m 'td.id-column',
                                                                                        if router.state.task_unfolded == task.id.toString()
                                                                                                m 'a[href="?-task_unfolded='+task.id+'"]', task.id
                                                                                        else
                                                                                                m 'a[href="?task_unfolded='+task.id+'"]', task.id
                                                                                m 'td.status-column',{'data-task-status': task.status}, task.status
                                                                                m 'td.date-column', task.created_at
                                                                                m 'td.date-column', task.status_changed_at
                                                                                m 'td',
                                                                                        for requirement in task.description.requirements
                                                                                                m '.requirement.tag', {"data-toggle": "tooltip", "title": requirement.role},
                                                                                                        [
                                                                                                                if requirement.role.split('_').length > 0
                                                                                                                        m '.key',requirement.role.split('_')[0]
                                                                                                                if requirement.role.split('_').length > 1
                                                                                                                        m '.value', requirement.role.split('_')[1]
                                                                                                        ]
                                                                                m 'td.hidden', task.description.executor
                                                                                m 'td',
                                                                                        if task.tags?
                                                                                                m '.tags',
                                                                                                        for key,values of task.tags
                                                                                                                m '.tag',
                                                                                                                        [
                                                                                                                                m '.key.task-tag-key-'+key,key
                                                                                                                                for value in values
                                                                                                                                        value_title = value
                                                                                                                                        value_style = value
                                                                                                                                        if value.length > 20 then value = value.substring(0,20)+"..."; value_style = value.substring(0,5);
                                                                                                                                        m '.value.task-tag-value-'+value_style,{"title": value_title},value
                                                                                                                        ]


                                                                        if router.state.task_unfolded == task.id.toString()
                                                                                m 'tr', key: task.id+'_description',
                                                                                        m 'td.id-column', style: "border-top: none !important;", ''
                                                                                        m 'td', colspan: 5, style: "border-top: none !important;" ,
                                                                                                m 'div', style: { position: 'relative', "min-height": "64px" },
                                                                                                        if window.task.initialized
                                                                                                                [
                                                                                                                        m 'pre', JSON.stringify(window.task.elements.description, undefined, 8)
                                                                                                                        if window.task.elements.artifacts?
                                                                                                                                m 'h4','Task Artifacts'
                                                                                                                        m 'ul.artifacts-list.list-unstyled',
                                                                                                                                if window.task.elements.artifacts?
                                                                                                                                        for artifact in window.task.elements.artifacts
                                                                                                                                                m 'li',
                                                                                                                                                        m 'a[href="/artifacts/'+artifact.id+'/'+artifact.name+'"]',artifact.name
                                                                                                                ]
                                                                                                        m.component(Spinner) if (not window.task?) or (not window.task.valid)
                                                                ]
                        m '.',
                                m '.col-lg-6', [
                                        if execution.initialized and (execution.elements.task_tag_stats? and Object.keys(execution.elements.task_tag_stats).length > 0)
                                                [
                                                        m '.execution-tag-report', id: "tag-report",
                                                                m '.report',
                                                                        m 'h4','Tag Statistics'
                                                                        m 'table.table.table-condensed.table-hover.execution-tag-table.col-xs-12',
                                                                                m 'thead',
                                                                                        m 'tr',
                                                                                                m 'th.tag','Tag'
                                                                                                m 'th.count', 'Count'
                                                                                m 'tbody',
                                                                                        for key,value of execution.elements.task_tag_stats when key[0] != '_'
                                                                                                [
                                                                                                        for k,v of value when k[0] != '_'
                                                                                                                k_style = k
                                                                                                                k_title = k
                                                                                                                if k.length > 20 then k = k.substring(0,20)+"..."; k_style = k.substring(0,5);
                                                                                                                [
                                                                                                                        m 'tr',
                                                                                                                                m 'td.tag',

                                                                                                                                        m '.key.task-tag-key.task-tag-key-'+key,key
                                                                                                                                        m '.value.task-tag-value.task-tag-value-'+k_style,{"title": k_title},k
                                                                                                                                m 'td',v
                                                                                                                ]
                                                                                                ]

                                                ] ]
                                m '.col-lg-6',
                                        if execution.initialized and (execution.elements.artifacts.length > 0)
                                                [
                                                        m 'h4','Execution Artifacts'
                                                        for artifact in execution.elements.artifacts
                                                                m 'li.list-unstyled',
                                                                        m 'span.top-padding',
                                                                                m 'a[href="/artifacts/'+artifact.id+'/'+artifact.name+'"]',artifact.name
                                                ]


                                if execution.initialized and (execution.elements.timeline.length > 0)
                                        data = _.map(_.groupBy(execution.elements.timeline, (obj) -> obj.resource_id), (p, k) -> _.map( p, (obj2) -> obj2.from = new Date(obj2.from); obj2.to = new Date(obj2.to); obj2.label = obj2.task_id; obj2.type = TimelineChart.TYPE.INTERVAL); {label: k, data: p})
                                        TimelineChart.prototype.onVizChange (e) ->
                                                minDt = e.domain[0].getTime(); maxDt = e.domain[1].getTime(); router.stealth_change('?-domain=0&domain~='+(minDt)+'&domain~='+(maxDt));
                                        minheight = (data.length * 30)+15
                                        if router.state.domain then new_domain = {domain: [new Date(parseInt(router.state.domain[0])),new Date(parseInt(router.state.domain[1]))]} else new_domain = {}
                                        m '#timeline-container.col-lg-12',
                                                m 'h4','Execution Timeline'
                                                m '#timeline.flex.flex-full-center', { style:{'min-height': minheight+'px'},config: (e,i,context)-> $('svg').remove(); timeline = new TimelineChart(document.getElementById('timeline'), data,new_domain);};

                        m.component(Spinner) if not execution.valid
        }


Workers = {
        view: (controller, args) ->
                m '#workers.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-condensed[data-seapig-binding-element=workers]',
                                m 'thead',
                                        m 'tr',
                                                m 'th.name-column', 'Name'
                                                m 'th.date-column', 'Last status update'
                                                m 'th.resources-column', 'Resources'
                                                m 'th.action-icons-column', ''
                                m 'tbody',
                                        if workers.initialized
                                                for worker in workers.elements.workers
                                                        m 'tr[data-seapig-binding-element='+worker.id+']', key: worker.name,
                                                                m 'td.name-column', {"title": worker.ip},  worker.name
                                                                m 'td.date-column', worker.last_status_update
                                                                m 'td.resources-column',
                                                                        if worker.resources?
                                                                                for resource in worker.resources
                                                                                        m '.resource'+((resource.task_id == null) and '.bg-success' or ((resource.task_id == 0) and '.bg-info' or '.bg-warning')), style: { float: 'left', "margin-right": '10px', 'padding-left': '5px', 'padding-right': '5px' }, resource.id.toString()+":"+resource.type+((resource.task_id == null) and ' ' or '('+resource.task_id+')')
                                                                m 'td.action-icons-column',
                                                                        m '.action-icon.seapig-binding-element-delete.seapig-binding-autosave','✖'
                        m.component(Spinner) if not workers.valid

        }



$(document).ready () =>
        $(document).on "click",".execution-action", ->
                action = $(this).data('action')
                execution_id = $(this).data('execution-id')
                options = $(this).data('options')
                endpoint = '/executions/'+action
                $.get(endpoint, {action: action, execution_id: execution_id, options: options});
                $(this).closest(".dropdown-menu").prev().dropdown("toggle");


        $(document).keypress (e) ->
                if (e.charCode == 112)
                        $(".task_status_finished").css("background-color", "pink")

        @session_key = $('body').attr('data-session-key')

        @seapig_server = new SeapigServer('ws://'+window.location.host+'/seapig', name: 'web')

        @execution_filters = new SeapigBinding(@seapig_server, debug: false, model: 'execution:filters', onchange: ()=> m.redraw())
        @executions = new SeapigBinding(@seapig_server, debug: false, onchange: ()=> m.redraw() )
        @execution = new SeapigBinding(@seapig_server, debug: false, onchange: ()=> m.redraw();Sortable.init();)
        @workers = new SeapigBinding(@seapig_server, view: "#workers", debug: false, onchange: ()=> m.redraw())
        @task = new SeapigBinding(@seapig_server, debug: false, onchange: ()=> m.redraw())


        @router = new SeapigRouter(@seapig_server, @session_key, "/", (window.default_route or "?show=executions&executions_filter~limit=50"), false)

        @router.statefilter = (state, previous_state)=>
                if state.show == 'executions'
                        delete state['execution_id']
                        delete state['task_unfolded']
                        #TODO: Clean state if you have different execution_id in previous state.
                if state.show != 'execution'
                        delete state['domain']

        @router.onstatechange = (state, previous_state)=>

                if (not @executions.object_id) or (not _.isEqual(state.executions_filter, @executions.filter))
                        @executions.model('executions-filtered-'+state.session_id+':'+state.id)
                        @executions.filter = JSON.parse(JSON.stringify(state.executions_filter))

                @execution.model(if state.show == "execution" then 'execution-'+state.execution_id else null)
                @workers.model(if state.show == "workers" then 'workers' else null)
                @task.model(if state.task_unfolded? then 'task-'+state.task_unfolded else null)

                if !_.isEqual(previous_state.hidden_tags,state.hidden_tags) or state.show != previous_state.show or state.execution_id != previous_state.execution_id or state.task_unfolded != previous_state.task_unfolded or (not _.isEqual(state.executions_filter, previous_state.executions_filter))
                        m.redraw()

                Sortable.init()

        m.mount $('#layout')[0], Layout
        @router.location_changed()
