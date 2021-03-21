if not window.extra_menu_items?
	window.extra_menu_items = []

window.Layout =
	view: (vnode) ->
		[
			m 'nav.navbar.navbar-inverse.navbar-static-top',
				m '.container-fluid#main-container',
					m 'ul.nav.navbar-nav',
						m 'li', [ m 'a.executions-link[href="?show=executions"]', style: { "color": "#DDDDDD" }, 'Executions' ]
						m 'li', [ m 'a[href="?show=workers"]', style: { "color": "#DDDDDD" }, 'Workers' ]
						m 'li', [ m 'a[href="?show=statistics"]', style: { "color": "#DDDDDD" }, 'Statistics' ]
					m 'ul.nav.navbar-nav.navbar-right',
						[
							for extra_menu_item in window.extra_menu_items
								m 'li', [ extra_menu_item() ]
							m 'li',
								m 'a[href="https://github.com/schedy"]',
									m 'small',
										'Scheduler on Github'
						]
			if router.state_valid
				m '.container-fluid',
					m '.row',
						if router.state.show == 'executions'
							[
								m '.col-md-12', style: { 'padding-left': '250px', position: 'absolute' },
									m Executions
								m '', style: {  width: '250px', position: 'absolute'},
									m Filters
							]
						if router.state.show == 'execution'
							[
								m '.col-md-12',
									m Execution
							]
						if router.state.show == 'workers'
							[
								m '.col-md-12',
									m Workers
							]
						if router.state.show == 'executioncontrol'
							[
								m '.col-md-12',
									m Executioncontrol
							]
						if router.state.show == 'statistics'
							[
								m '.col-md-12', style: { 'padding-left': '250px', position: 'absolute' },
									m '#statistics.container-fluid', style: { position: 'relative' },
										m Statistics
										m Spinner if (not executions_stats?) or (not executions_stats.valid)
								m '', style: {  width: '250px', position: 'absolute'},
									m Filters
							]
			else
				m '.container-fluid',
					m '.row',
						m '.col-md-12',
							m 'span', 'Loading state...'
		]
