window.Statistics =
        view: (vnode)->
                [
                        m '.row', style: { padding: '10px' },
                                m '#graph-by-date-container.col-lg-12',
                                        m '#graph-by-date.flex.flex-full-center'
                        m '.row', style: { padding: '10px' },
                                m '#graph-by-id-container.col-lg-12',
                                        m '#graph-by-id.flex.flex-full-center'
                ]

        graph_data: (execs, graph_by_date) ->
                data =[]
                if execs? and execs.initialized
                        for execution in execs.object.executions
                                id = execution.id
                                start_date = new Date(execution.created_at+"Z")
                                finish_date = if execution.finished_at? then new Date(execution.finished_at+"Z") else new Date()
                                duration = (finish_date - start_date) / 1000
                                if graph_by_date
                                        data.push([start_date, duration])
                                else
                                        data.push([id, duration])
                if graph_by_date
                        data.sort( (a, b) -> a[0].getTime() - b[0].getTime() )
                else
                        data.sort( (a, b) -> a[0] - b[0] )
                data


        onbeforeupdate: (vnode)->
                if executions_stats? and executions_stats.initialized
                        if not @graph_by_date or not @graph_by_id
                                @oncreate()
                        else
                                @graph_by_date.updateOptions( { 'file': @graph_data(executions_stats, true) } );
                                @graph_by_id.updateOptions( { 'file': @graph_data(executions_stats, false) } );
                false

        oncreate: (vnode)->
                if executions_stats? and executions_stats.initialized
                        @graph_by_date = new Dygraph(document.getElementById("graph-by-date"), @graph_data(executions_stats, true),
                                       title: 'Execution Duration by date'
                                       xlabel: 'Date'
                                       ylabel: 'Duration in hh:mm:ss'
                                       drawPoints: true
                                       pointSize: 4
                                       highlightCircleSize: 8
                                       height: 350
                                       strokeWidth: 0.0
                                       labelsDivWidth: 300
                                       rightGap: 20
                                       xRangePad: 20
                                       yRangePad: 20
                                       labels: [ 'x', 'Duration' ]
                                       axes:
                                               y:
                                                       axisLabelWidth: 75
                                                       valueFormatter: (secs) =>
                                                               sec2hhmmss secs
                                                       axisLabelFormatter: (secs) =>
                                                               sec2hhmmss secs
                        )
                        @graph_by_id = new Dygraph(document.getElementById("graph-by-id"), @graph_data(executions_stats, false),
                                       title: 'Execution Duration by ID'
                                       xlabel: 'Execution ID'
                                       ylabel: 'Duration in hh:mm:ss'
                                       drawPoints: true
                                       pointSize: 4
                                       highlightCircleSize: 8
                                       height: 350
                                       strokeWidth: 0.0
                                       labelsDivWidth: 300
                                       rightGap: 20
                                       xRangePad: 20
                                       yRangePad: 20
                                       labels: [ 'x', 'Duration' ]
                                       axes:
                                               y:
                                                       axisLabelWidth: 75
                                                       valueFormatter: (secs) =>
                                                               sec2hhmmss secs
                                                       axisLabelFormatter: (secs) =>
                                                               sec2hhmmss secs
                        )

