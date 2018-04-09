
short_value = (value) ->
        ((value.length > 20) and value.substring(0,20)+"..." or value)


Timeline =

        y_axis_position_x: 80
        bar_height: 11
        bar_margin: 4

        view: (vnode) ->
                m '#timeline-container.col-lg-12',
                        m 'strong.inner', 'Execution Timeline:'
                        m '#timeline-graph', style: { position: 'relative', top: "5px" },
                                m 'canvas#timeline-canvas', style: { position: 'absolute' } #, 'background-color': 'red' }
                                m 'svg#timeline.flex.flex-full-center', style: { width: '100%', position: 'absolute', top: 0, left: 0  },
                                        m 'g#timeline-lower',
                                                m 'rect#lower-mask'
                                                m 'g#x-axis'
                                        m 'g#timeline-upper',
                                                m 'g#y-axis'
                                m '#timeline-tooltip', style: { position: 'absolute'  }, 'xxx'


        oncreate: (vnode)->
                @svg = d3.select("#timeline")
                @zoom = d3.zoom().on("zoom",()=> @onzoom())
                @svg.select("#timeline-lower").call(@zoom).on("dblclick.zoom", =>router.navigate('?-timeline_from=-&-timeline_span=-', defer: 1000); @reposition())
                @tasks = []
                @resources = []
                @onbeforeupdate(vnode,null)


        onbeforeupdate: (vnode, old_vnode)->
                @rectangles_data = for entry in execution_task_details.object.timeline when entry.to
                        { task_id: entry.task_id, resource_id: entry.resource_id, from: new Date(entry.from+"Z"), to: new Date(entry.to+"Z") }

                @resources = @resources.concat(_.uniq(line.resource_id for line in @rectangles_data when not _.contains(@resources,line.resource_id)))
                @resources = @resources.sort  (a, b)->
                        [worker_a, id_a] = a.split(":"); id_a = parseInt(id_a)
                        [worker_b, id_b] = b.split(":"); id_a = parseInt(id_a)
                        worker_a < worker_b and -1 or worker_a > worker_b and 1 or id_a < id_b and -1 or id_a > id_b and 1 or 0
                @tasks = @tasks.concat(_.uniq(line.task_id for line in @rectangles_data when not _.contains(@tasks,line.task_id)))
                @earliest_event = _.min(line.from for line in @rectangles_data)
                @latest_event = _.max(line.to for line in @rectangles_data)
                @redraw()
                @reposition()
                false


        onzoom: ()->
                return true if @disable_zoom
                span = (@x_scale.domain()[1].getTime()-@x_scale.domain()[0].getTime())/d3.event.transform.k
                if span > 4000 and span < 1000*3600*24
                        router.navigate('?timeline_from='+(@x_scale.invert(-d3.event.transform.x/d3.event.transform.k).getTime())+'&timeline_span='+(span), defer: 1000)
                @disable_zoom = true; @zoom.transform(@svg.select("#timeline-lower"),d3.zoomIdentity); @disable_zoom = false
                @reposition()


        redraw: ()->
                @graph_height = @resources.length * (@bar_height + @bar_margin)
                @graph_width = $('#main-container').width()-@y_axis_position_x-75 #250ms

                @color_scale = d3.scaleOrdinal(d3.schemeCategory20b).domain(@tasks)
                @y_scale = d3.scaleBand().domain(@resources).range([1,@graph_height])
                yAxis = d3.axisLeft(@y_scale).tickSizeOuter([10])

                $("#timeline-graph").css("height", @graph_height+30+"px")
                @svg.attr("height", @graph_height+25)
                @svg.select("#y-axis").attr("transform", "translate(" + (@y_axis_position_x - 2) + "," + 0 + ")").call(yAxis)
                @svg.select("#x-axis").attr("transform", "translate(" + 0 + "," + @graph_height + ")")
                @svg.select("#timeline-lower").attr("transform", "translate(" + (@y_axis_position_x - 2) + "," + 0 + ")")
                @svg.select("#lower-mask").attr("width",@graph_width).attr("height",@graph_height).attr("x", 0)
                d3.select("#timeline-canvas").style("left",(@y_axis_position_x-1)+"px").style("top","1px").attr('width',@graph_width).attr('height',@graph_height-1)

                d3.select('#lower-mask').on("mousemove",()=>
                        time = @x_scale.invert(d3.event.layerX-@y_axis_position_x)
                        resource_id = @resources[Math.floor((d3.event.layerY-5) / @y_scale.step())]
                        return if not resource_id?
                        x = if d3.event.layerX < $('#timeline').width()-$('#timeline-tooltip').width() then d3.event.layerX + 14 else d3.event.layerX - $('#timeline-tooltip').width() - 20
                        y = if d3.event.layerY < $('#timeline').height()-$('#timeline-tooltip').height() - 20 then d3.event.layerY + 8 else d3.event.layerY - $('#timeline-tooltip').height() - 20
                        block = _.find(@rectangles_data,(rectangle_data)-> rectangle_data.from <= time and rectangle_data.to >= time and rectangle_data.resource_id == resource_id)
                        if block?
                                text = "Task #"+block.task_id+"<br>Duration: "+sec2hhmmss((block.to-block.from)/1000)
                                d3.select('#timeline-tooltip').style("left",x+"px").style("top",y+"px").style("display","block").html(text)
                        else
                                d3.select('#timeline-tooltip').style("display","none"))
                d3.select('#lower-mask').on("mouseout",()=>d3.select('#timeline-tooltip').style("display","none"))


        reposition: ()->
                timeline_from = if router.state.timeline_from then parseInt(router.state.timeline_from) else @earliest_event.getTime() - (@latest_event.getTime() - @earliest_event.getTime())/80
                timeline_span = if router.state.timeline_span then parseInt(router.state.timeline_span) else (@latest_event.getTime() - @earliest_event.getTime()) + (@latest_event.getTime() - @earliest_event.getTime())/40
                @x_scale = d3.scaleTime()
                        .domain([new Date(timeline_from),new Date(timeline_from+timeline_span)])
                        .range([0,$('#main-container').width()-75-@y_axis_position_x])
                xAxis = d3.axisBottom(@x_scale)
                @svg.select("#x-axis").call(xAxis)

                canvas = $('#timeline-canvas')[0].getContext("2d")
                canvas.clearRect(0,0,@graph_width,@graph_height)
                canvas.lineWidth = 0.5
                canvas.strokeStyle = '#AAAAAA'
                for resource_id in @resources
                        canvas.beginPath()
                        canvas.moveTo(0,@y_scale(resource_id)+@bar_margin/2+@bar_height/2)
                        canvas.lineTo(@graph_width,@y_scale(resource_id)+@bar_margin/2+@bar_height/2)
                        canvas.stroke()
                for rectangle_data in @rectangles_data
                        canvas.fillStyle = @color_scale(rectangle_data.task_id)
                        canvas.fillRect(@x_scale(rectangle_data.from),@y_scale(rectangle_data.resource_id)+@bar_margin/2,@x_scale(rectangle_data.to)-@x_scale(rectangle_data.from),@bar_height)
                canvas.lineWidth = 0.7
                canvas.strokeStyle = 'black'
                for rectangle_data in @rectangles_data
                        canvas.strokeRect(@x_scale(rectangle_data.from),@y_scale(rectangle_data.resource_id)+@bar_margin/2,@x_scale(rectangle_data.to)-@x_scale(rectangle_data.from),@bar_height)



window.Execution =

        update_timer: ->
                if execution? and execution.initialized
                        if execution.object.status == 'finished'
                                $("#execution-duration").html(sec2hhmmss(Math.floor(((new Date(execution.object.finished_at+"Z")).getTime() - (new Date(execution.object.created_at+"Z")).getTime())/1000)))
                                clearInterval(@interval)
                        else
                                $("#execution-duration").html(sec2hhmmss(Math.floor(((new Date()).getTime() - (new Date(execution.object.created_at+"Z")).getTime())/1000)))


        oncreate: (vnode)->
                @interval = setInterval((()=>@update_timer()),1000)


        onupdate: (vnode)->
                @update_timer()


        onremove: (vnode)->
                clearInterval(@interval)


        view: (vnode)->
                m '', style: {"min-height": "400px"},
                        if execution? and execution.initialized
                                [

                                        m '.col-lg-12.top-padding',
                                                m '.col-lg-12',
                                                        m 'strong','ID: '
                                                        m 'span.execution-id',execution.object.id
                                        m '.col-lg-12', style: { 'padding-top': '5px'},
                                                m '.col-lg-12',
                                                        m 'strong','Status: '
                                                        m 'span.execution-duration',execution.object.status
                                        m '.col-lg-12', style: { 'padding-top': '5px'},
                                                m '.col-lg-12',
                                                        m 'strong','Run-time: '
                                                        m 'span', new Date(execution.object.created_at+"Z").toString().substr(0,25)
                                                        m 'span', ' — '
                                                        if execution.object.finished_at?
                                                                m 'span', new Date(execution.object.finished_at+"Z").toString().substr(0,25)
                                                        else
                                                                m 'span', "still running"
                                                        m 'span',' ('
                                                        m 'span#execution-duration'
                                                        m 'span',')'

                                        m '.col-lg-12', style: { 'padding-top': '5px'},
                                                if execution.object.tags?
                                                        m '.tags.pull-left.col-xs-12',
                                                                m '.tag-group.pull-left',
                                                                        m 'strong.inner',m.trust('Tags:&nbsp;&nbsp;')
                                                                        for key,values of execution.object.tags  when key[0] != '_'
                                                                                m '.tag.inner',
                                                                                        [
                                                                                                m '.key.execution-tag-key-'+key,key
                                                                                                for value in values
                                                                                                        if value.match(/http/ )
                                                                                                                m 'a.value.execution-tag-value-link', href: value,value
                                                                                                        else
                                                                                                                m '.value.execution-tag-value-'+value,value
                                                                                        ],
                                        m '.col-lg-12', style: { 'padding-top': '5px'},
                                                if execution.object.hooks?
                                                        m '.tags.pull-left.col-xs-12',
                                                                m '.tag-group.pull-left',
                                                                        m 'strong.inner',m.trust('Hooks:&nbsp;&nbsp;')
                                                                        for key,value of execution.object.hooks  when key[0] != '_'
                                                                                m '.tag.inner',
                                                                                        [
                                                                                                m 'span.key.execution-tag-key-'+value.status,'@'+value.status
                                                                                                m 'span.value.execution-tag-value-'+value.hook,value.hook
                                                                                        ]
                                        m '.clear'
                                        m '.col-lg-12#execution-section-width-reference', style: { 'padding-top': '5px'},
                                                m '.tags.pull-left.col-xs-12',
                                                        m '.tag-group.pull-left',
                                                                m 'strong.inner',"Task status ("
                                                                if router.state.show_task_details?
                                                                        m 'a', href: "?-show_task_details=1", "hide details"
                                                                else
                                                                        m 'a', href: "?show_task_details=1", "show details"
                                                                m 'strong.inner',"):"
                                        if execution_task_details? and execution_task_details.initialized
                                                [
                                                        m '.col-lg-12', style: { 'padding-top': '5px', 'margin-bottom': '20px'},
                                                                m '.col-lg-12',
                                                                        m '.tags.pull-left.col-xs-12',
                                                                                m '.tag-group.pull-left',
                                                                                        for task in execution_task_details.object.tasks
                                                                                                m 'div.task_marker.task_status_'+task.status, title: 'Task#'+task.id+' '+task.status, ''
                                                        m '.col-lg-12', style: { 'padding-top': '5px', 'margin-bottom': '15px'},
                                                                if execution_task_details? and execution_task_details.initialized and ((e for e in execution_task_details.object.timeline when e.to).length > 0)
                                                                        m Timeline
                                                ]
                                        else
                                                m '.col-lg-12',
                                                        m '.col-lg-12',
                                                                m '.col-lg-12#execution-status-bar-wrapper', style: { 'padding-top': '5px', 'margin-bottom': '30px', width: '100%', position: 'relative', overflow: "hidden"},
                                                                        m ExecutionStatusBar, task_statuses: execution.object.task_statuses, max_progressbar_width: $('#main-container').innerWidth()-120
                                                                        m Spinner if execution_task_details?
                                        m '.clear'
                                        m '.col-lg-12',
                                                m '.col-lg-12',
                                                        if execution? and execution.initialized and (execution.object.task_tag_stats? and Object.keys(execution.object.task_tag_stats).length > 0)
                                                                m '.execution-tag-report', id: "tag-report",
                                                                        m '.report',
                                                                                m 'strong','Tasks:'
                                                                                m '.col-lg-12',
                                                                                    m 'table.table.table-condensed.table-hover.execution-tag-table.col-xs-12',
                                                                                        m 'tbody',
                                                                                                stats = _.clone(execution.object.task_tag_stats)
                                                                                                for key,values of router.state.task_list_filter
                                                                                                        stats[base64decode(key)] = {} if not stats[base64decode(key)]?
                                                                                                        null
                                                                                                for key,values of stats when key[0] != '_'
                                                                                                        tagged = 0
                                                                                                        tagged += count for value,count of values when value[0] != '_'
                                                                                                        empties = _.values(execution.object.task_statuses).reduce(((a,b)->a+b),0) - tagged
                                                                                                        m 'tr',
                                                                                                                m 'td.tasks-filter-attribute',
                                                                                                                        m '.tag',
                                                                                                                                m '.key.task-tag-key.task-tag-key-'+base64encode(key),key
                                                                                                                m 'td',
                                                                                                                        if Object.keys(values).length > 4 and (not (base64encode(key) in (router.state.task_filter_unfolded or [])))
                                                                                                                                m '.task-filter-value-expand-link',
                                                                                                                                m 'a', href: '?task_filter_unfolded~='+base64encode(key),'show '+Object.keys(values).length+' filtering options'
                                                                                                                        else
                                                                                                                                toggle_all = []
                                                                                                                                [
                                                                                                                                        if empties > 0
                                                                                                                                                filtered_out = (router.state.task_list_filter[base64encode(key)] and router.state.task_list_filter[base64encode(key)][base64encode('-')] == 't')
                                                                                                                                                toggle_all.push("task_list_filter."+base64encode(key)+"."+base64encode('-')+"="+(if filtered_out then 'f' else 't'))
                                                                                                                                                m '.tag',
                                                                                                                                                        m '.key-checkbox',
                                                                                                                                                                m 'a.undecorated-links', href: "?task_list_filter."+base64encode(key)+"."+base64encode("-")+"="+(if filtered_out then 'f' else 't'), m.trust if filtered_out then '&nbsp;&nbsp;&nbsp;&nbsp;' else '✔'
                                                                                                                                                        m '.value.task-tag-value.task-tag-value-NOT_SET',
                                                                                                                                                                m 'a.undecorated-links', href: "?task_list_filter."+base64encode(key)+"."+base64encode("-")+"="+(if filtered_out then 'f' else 't'), 'Not Set ('+empties+')'
                                                                                                                                        for value,count of values when value[0] != '_'
                                                                                                                                                filtered_out = (router.state.task_list_filter[base64encode(key)] and router.state.task_list_filter[base64encode(key)][base64encode(value)] == 't')
                                                                                                                                                toggle_all.push("task_list_filter."+base64encode(key)+"."+base64encode(value)+"="+(if filtered_out then 'f' else 't'))
                                                                                                                                                m '.tag',
                                                                                                                                                        m '.key-checkbox',
                                                                                                                                                                m 'a.undecorated-links', href: "?task_list_filter."+base64encode(key)+"."+base64encode(value)+"="+(if filtered_out then 'f' else 't'), m.trust if filtered_out then '&nbsp;&nbsp;&nbsp;&nbsp;' else '✔'
                                                                                                                                                        m '.value.task-tag-value.task-tag-value-'+base64encode(value),
                                                                                                                                                                m 'a.undecorated-links', href: "?task_list_filter."+base64encode(key)+"."+base64encode(value)+"="+(if filtered_out then 'f' else 't'), title: value, short_value(value)+" ("+count+")"
                                                                                                                                        if Object.keys(values).length > 4
                                                                                                                                                m '', style: { display: "inline" },
                                                                                                                                                        m 'a', href: "?"+toggle_all.join("&"), style: { "margin-left": "20px", "vertical-align": "bottom" }, "toggle all"
                                                                                                                                ]
                                                m '.col-lg-12',
                                                        m '.col-lg-12', style: { "min-height": "200px", position: "relative" },
                                                                if execution_tasks? and execution_tasks.initialized
                                                                        m 'table.table.table-condensed.table-hover',
                                                                                m 'thead',
                                                                                        m 'tr',
                                                                                                m 'th.id-column', 'ID'
                                                                                                m 'th.status-column', 'Status'
                                                                                                m 'th', 'Worker'
                                                                                                m 'th', 'Resources'
                                                                                                m 'th.hidden', 'Executor'
                                                                                                m 'th', 'Tags'
                                                                                m 'tbody',
                                                                                        for task in execution_tasks.object.tasks
                                                                                                [
                                                                                                        m 'tr', key: task.id,
                                                                                                                m 'td.id-column.light-background', class: 'task_status_'+task.status,
                                                                                                                        if router.state.task_unfolded == task.id.toString()
                                                                                                                                m 'a[href="?-task_unfolded='+task.id+'"]', task.id
                                                                                                                        else
                                                                                                                                m 'a[href="?task_unfolded='+task.id+'"]', task.id
                                                                                                                m 'td.status-column.light-background.gradient', class: 'task_status_'+task.status, task.status
                                                                                                                m 'td.worker-column', task.worker
                                                                                                                m 'td.date-column',
                                                                                                                        for resource in task.resources
                                                                                                                                m '.resource', resource.remote_id
                                                                                                                m 'td',
                                                                                                                        if task.tags?
                                                                                                                                m '.tags',
                                                                                                                                        for key,values of task.tags
                                                                                                                                                m '.tag',
                                                                                                                                                        [
                                                                                                                                                                m '.key.task-tag-key-'+key,key
                                                                                                                                                                for value in values
                                                                                                                                                                        if value.match(/http/)
                                                                                                                                                                                m 'a.value.task-tag-value-'+base64encode(value),{"title": value, href: value}, short_value(value)
                                                                                                                                                                        else
                                                                                                                                                                                m '.value.task-tag-value-'+base64encode(value),{"title": value},short_value(value)


                                                                                                                                                        ]
                                                                                                        if router.state.task_unfolded == task.id.toString()
                                                                                                                m 'tr', key: task.id+'_description',
                                                                                                                        m 'td.id-column', style: "border-top: none !important;", ''
                                                                                                                        m 'td', colspan: 5, style: "border-top: none !important;" ,
                                                                                                                                m 'div', style: { position: 'relative', "min-height": "64px" },
                                                                                                                                        if window.task? and window.task.initialized
                                                                                                                                                [
                                                                                                                                                        if window.task.object.artifacts?
                                                                                                                                                                m 'h4','Task artifacts:'
                                                                                                                                                        m 'ul.artifacts-list.list-unstyled',
                                                                                                                                                                if window.task.object.artifacts?
                                                                                                                                                                        for artifact in window.task.object.artifacts
                                                                                                                                                                                m 'li',
                                                                                                                                                                                        if artifact.external_url?
                                                                                                                                                                                                m 'a[href="'+task.external_url+'"]',artifact.name
                                                                                                                                                                                        else
                                                                                                                                                                                                m 'a[href="/tasks/'+task.id+'/artifacts/'+artifact.name+'"]',artifact.name
                                                                                                                                                                                        m 'span', style: { color: 'darkgrey' }, ' ('+artifact.size+'B) '
                                                                                                                                                                                        if artifact.views.length > 0
                                                                                                                                                                                                [
                                                                                                                                                                                                        m 'span', ' ('
                                                                                                                                                                                                        for view, i in artifact.views
                                                                                                                                                                                                                [
                                                                                                                                                                                                                        m 'a', href: '/tasks/'+task.id+'/artifacts/'+artifact.name+'/'+view.path, view.label
                                                                                                                                                                                                                        m 'span', ' ' if i<(artifact.views.length-1)
                                                                                                                                                                                                                ]
                                                                                                                                                                                                        m 'span', ')'
                                                                                                                                                                                                ]
                                                                                                                                                        m 'h4','Task description:'
                                                                                                                                                        m 'pre', JSON.stringify(window.task.object.description, undefined, 8)
                                                                                                                                                        m 'h4','Task requirements:'
                                                                                                                                                        m 'pre', JSON.stringify(window.task.object.requirements, undefined, 8)
                                                                                                                                                ]
                                                                                                                                        m Spinner if (not window.task?) or (not window.task.valid)
                                                                                                ]
                                                                else
                                                                        m Spinner

                                        m '.col-lg-12#execution-section-width-reference', style: { 'padding-top': '15px'},
                                                m '.tags.pull-left.col-xs-6',
                                                        m '.tag-group.pull-left',
                                                                if execution? and execution.initialized and (execution.object.artifacts.length > 0)
                                                                        [
                                                                                m 'strong.inner',"Execution artifacts:"
                                                                                m '.col-lg-12',
                                                                                        for artifact in execution.object.artifacts
                                                                                                m 'li.list-unstyled',
                                                                                                        m 'span.top-padding',
                                                                                                                m 'a[href="/executions/'+execution.object.id+'/artifacts/'+artifact.name+'"]',artifact.name
                                                                        ]
                                        m '.clear', style: { height: "20px" }

                                ]
                        else
                                m Spinner if (not execution?) or (not execution.valid)
