$(document).ready () =>
        console.log("@", @)
        console.timeStamp("document ready")

        $(document).on "click",".execution-action", ->
                action = $(this).data('action')
                execution_id = $(this).data('execution-id')
                options = $(this).data('options')

                endpoint = '/executions/'+execution_id+'/'+action
                $.post(endpoint, {options: options});
                $(this).closest(".dropdown-menu").prev().dropdown("toggle");

        $(document).on "keyup",".filter-input", ->
                search_word = $(this).val()
                router_field = $(this).data('router-field')
                endpoint = '?executions_filter.'+router_field+'='+search_word
                router.navigate(endpoint, defer: 1000)

        $(document).keypress (e) ->
                if (e.charCode == 112)
                        $(".task_status_finished").css("background-color", "pink")

        $(window).on("resize",()->m.redraw())

        window.seapig_client = new SeapigClient('ws://localhost/seapig', name: 'web', debug: false)

        window.router = new SeapigRouter(window.seapig_client, debug: false)
        window.router.onsessionopen = -> (router.onchange(router.state, router.state) if router.state_valid)
        window.router.default_state = (window.default_route or { show: "executions", executions_filter: { limit: 50 } })
        window.router.expose = [["execution_id", "execution","resource_id"]]

        window.router.filter = (state, previous_state)=>
                if state.show == 'executions'
                        delete state['execution_id']
                        delete state['task_unfolded']
                        delete state['task_filter_unfolded']
                        delete state['task_list_filter']
                        #TODO: Clean state if you have different execution_id in previous state.
                if state.show != 'execution'
                        delete state['execution_id']
                        delete state['timeline_from']
                        delete state['timeline_span']
                        delete state['show_task_details']
                if not state.task_list_filter
                        state.task_list_filter = {}
                        for property, values of (window.default_task_list_filter_out_tags or {})
                                state.task_list_filter[base64encode(property)] = {}
                                for value, filter of values
                                        state.task_list_filter[base64encode(property)][base64encode(value)] = filter

        window.router.onchange = (state, previous_state)=>
                if state.session_id?
                        if (not window.executions) or (not _.isEqual(state.executions_filter, window.executions.filter))
                                window.executions = window.subscribe(window.executions, 'executions-filtered-'+state.session_id+':'+state.state_id)
                                window.executions.filter = JSON.parse(JSON.stringify(state.executions_filter))
                        if (not window.executions_stats) or (not _.isEqual(state.executions_filter, window.executions_stats.filter))
                                window.executions_stats = window.subscribe(window.executions_stats, 'executions-stats-filtered-'+state.session_id+':'+state.state_id)
                                window.executions_stats.filter = JSON.parse(JSON.stringify(state.executions_filter))
                        if (state.show == "execution")
                                if ((not window.execution_tasks?) or (not  _.isEqual(state["task_list_filter"], window.execution_tasks.filter)))
                                        window.execution_tasks = window.subscribe(window.execution_tasks, 'execution-tasks-filtered-'+state.session_id+':'+state.state_id)
                                        window.execution_tasks.filter = JSON.parse(JSON.stringify(state.task_list_filter)) if window.execution_tasks
                        else
                                window.execution_tasks = window.subscribe(window.execution_tasks, null)

                window.execution = window.subscribe(window.execution, if state.show == "execution" then 'execution:'+state.execution_id else null)
                window.resource = window.subscribe(window.resource, if state.show == "resourcecontrol" then 'resource:'+state.resource_id else null)
                window.execution_task_details = window.subscribe(window.execution_task_details, if state.show_task_details? then 'execution-timeline:'+state.execution_id else null)
                window.workers = window.subscribe(window.workers, if state.show == "workers" then 'workers' else null)
                window.task = window.subscribe(window.task, if state.task_unfolded? then 'task-'+state.task_unfolded else null)

                if !_.isEqual(previous_state.hidden_tags,state.hidden_tags) or state.show != previous_state.show or state.execution_id != previous_state.execution_id or state.task_unfolded != previous_state.task_unfolded or (not _.isEqual(state.executions_filter, previous_state.executions_filter)) or !_.isEqual(previous_state.task_list_filter,state.task_list_filter) or (not _.isEqual(state.task_filter_unfolded, previous_state.task_filter_unfolded)) or (state.show_task_details != previous_state.show_task_details) or (state.tag_shorten != previous_state.tag_shorten)
                        m.redraw()

                document.title = "Schedy - " + state["show"]
                document.title = "Schedy - execution "+state["execution_id"] if state["show"] == 'execution'


        window.subscribe = (obj, new_object_id)->
                return obj if obj? and obj.id == new_object_id
                obj.unlink() if obj?
                if new_object_id
                        window.seapig_client.slave(new_object_id).onstatuschange((obj)=>m.redraw())


        window.execution_filters = window.subscribe(undefined, 'execution-filters')
        window.executions = window.executions_stats = window.execution = window.workers = window.task = undefined

        m.mount document.body, Layout
        window.router.navigate(window.location.search, replace: true)
