$(document).ready () =>
        #console.timeStamp("document ready")

        $(document).on "click",".execution-action", ->
                action = $(this).data('action')
                execution_id = $(this).data('execution-id')
                options = $(this).data('options')

                endpoint = '/executions/'+execution_id+'/'+action
                $.post(endpoint, {options: options});
                $(this).closest(".dropdown-menu").prev().dropdown("toggle");

        $(document).on "click",".delete-worker", ->
                worker_id = $(this).data('worker-id')
                endpoint = '/workers/'+worker_id+'/status'
                $.post(endpoint, {status: null});

        $(document).on "keyup",".filter-search-input", ->
                search_word = $('.filter-search-input').val()
                endpoint = '?executions_filter.search='+search_word
                router.navigate(endpoint, defer: 1000)

        $(document).keypress (e) ->
                if (e.charCode == 112)
                        $(".task_status_finished").css("background-color", "pink")

        $(window).on("resize",()->m.redraw())

        @seapig_client = new SeapigClient('ws://'+window.location.host+'/seapig', name: 'web', debug: false)

        @router = new SeapigRouter(@seapig_client, debug: false)
        @router.onsessionopen = -> (router.onchange(router.state, router.state) if router.state_valid)
        @router.default_state = (window.default_route or { show: "executions", executions_filter: { limit: 50 } })
        @router.expose = [["execution_id", "execution"]]

        @router.filter = (state, previous_state)=>
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

        @router.onchange = (state, previous_state)=>
                if state.session_id?
                        if (not @executions) or (not _.isEqual(state.executions_filter, @executions.filter))
                                @executions = @subscribe(@executions, 'executions-filtered-'+state.session_id+':'+state.state_id)
                                @executions.filter = JSON.parse(JSON.stringify(state.executions_filter))
                        if (not @executions_stats) or (not _.isEqual(state.executions_filter, @executions_stats.filter))
                                @executions_stats = @subscribe(@executions_stats, 'executions-stats-filtered-'+state.session_id+':'+state.state_id)
                                @executions_stats.filter = JSON.parse(JSON.stringify(state.executions_filter))
                        if (state.show == "execution")
                                if ((not @execution_tasks?) or (not  _.isEqual(state["task_list_filter"], @execution_tasks.filter)))
                                        @execution_tasks = @subscribe(@execution_tasks, 'execution-tasks-filtered-'+state.session_id+':'+state.state_id)
                                        @execution_tasks.filter = JSON.parse(JSON.stringify(state.task_list_filter)) if @execution_tasks
                        else
                                @execution_tasks = @subscribe(@execution_tasks, null)

                @execution = @subscribe(@execution, if state.show == "execution" then 'execution:'+state.execution_id else null)
                @execution_task_details = @subscribe(@execution_task_details, if state.show_task_details? then 'execution-timeline:'+state.execution_id else null)
                @workers = @subscribe(@workers, if state.show == "workers" then 'workers' else null)
                @task = @subscribe(@task, if state.task_unfolded? then 'task-'+state.task_unfolded else null)

                if !_.isEqual(previous_state.hidden_tags,state.hidden_tags) or state.show != previous_state.show or state.execution_id != previous_state.execution_id or state.task_unfolded != previous_state.task_unfolded or (not _.isEqual(state.executions_filter, previous_state.executions_filter)) or !_.isEqual(previous_state.task_list_filter,state.task_list_filter) or (not _.isEqual(state.task_filter_unfolded, previous_state.task_filter_unfolded)) or (state.show_task_details != previous_state.show_task_details)
                        m.redraw()

                document.title = "Schedy - " + state["show"]
                document.title = "Schedy - execution "+state["execution_id"] if state["show"] == 'execution'


        @subscribe = (obj, new_object_id)->
                return obj if obj? and obj.id == new_object_id
                obj.unlink() if obj?
                if new_object_id
                        @seapig_client.slave(new_object_id).onstatuschange((obj)=>m.redraw())


        @execution_filters = @subscribe(undefined, 'execution-filters')
        @executions = @executions_stats = @execution = @workers = @task = undefined

        m.mount document.body, Layout
        @router.navigate(window.location.search, replace: true)
