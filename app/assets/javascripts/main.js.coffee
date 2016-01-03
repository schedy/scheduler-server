Layout = {
        view: (controller, args) ->
                [
                        m 'nav.navbar.navbar-inverse.navbar-static-top',
                                m '.container-fluid',
                                        m 'ul.nav.navbar-nav',
                                                m 'li', [ m 'a', 'Executions' ]
                                                m 'li', [ m 'a', 'Workers' ]
                                        m 'ul.nav.navbar-nav.navbar-right',
                                                m 'li', [ m 'a', 'Logged in as: yunta' ]
                        m '.container-fluid',
                                m '.row',
                                        if state.show == 'executions'
                                                [
                                                        m '', style: { position: 'fixed', width: '100px' },
                                                                m.component(Filters)
                                                        m '.col-md-12', style: { 'padding-left': '100px' },
                                                                m.component(Executions)
                                                ]
                                        if state.show == 'execution'
                                                m '.col-md-12',
                                                        m.component(Execution)
                ]
        }


Executions = {
        view: (controller, args) ->
                m '.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-striped.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th', 'ID'
                                                m 'th', 'Status'
                                                m 'th', 'Tasks'
                                m 'tbody',
                                        for execution in data.executions.data
                                                m 'tr', key: execution.id,
                                                        m 'td',
                                                                m 'a[href="?show=execution&execution='+execution.id+'"]', execution.id
                                                        m 'td', execution.status
                                                        m 'td', ''
                        m.component(Spinner) if not data.executions.valid
        }


Spinner = {
        view: ->
                m '.backdrop', style: { position: 'absolute', top: '0px', bottom: '0px', right: '0px', left: '0px', 'background-color': "rgba(0,0,0,0.2)" },
                        m '', style: { width: '45px', margin: 'auto', position: 'relative', top: '50%', transform: 'translateY(-50%)'  },
                                m '.spinner-loader'
        }


Filters = {
        view: ->
                m '.container-fluid', style: { position: 'relative' },
                        m 'ul.list-unstyled',
                                for filter in data.filters.data
                                        m 'li', filter.creator
                        m.component(Spinner) if not data.filters.valid
        }



Execution = {
        view: (controller, args) ->
                m '.container-fluid', style: { position: 'relative' },
                        m 'table.table.table-striped.table-condensed',
                                m 'thead',
                                        m 'tr',
                                                m 'th', 'ID'
                                                m 'th', 'Status'
                                                m 'th', 'Description'
                                                m 'th', 'Reviewed'
                                                m 'th', 'Fail reason'
                                m 'tbody',
                                        for task in data.execution.data.tasks
                                                m 'tr', key: task.id,
                                                        m 'td', task.id
                                                        m 'td', task.description
                                                        m 'td', ''
                        m.component(Spinner) if not data.execution.valid
        }


@data = {
        executions: {
                valid: true
                data: [ { id: 1, status: 'finished' } , { id: 2, status: 'finished' } , { id: 3, status: 'finished' }  ]
                }
        filters: {
                valid: true
                data: [ { creator: 'yunta' } , { creator: 'somebody-else' } ]
                }
        execution: {
                valid: true
                data: {
                        tasks: []
                        }
                }
        }

@state = {
        show: 'executions'
        execution_id: 2
        }


$(document).ready () ->
        m.mount $('#layout')[0], Layout
