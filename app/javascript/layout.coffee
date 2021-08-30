if not window.extra_menu_items?
	window.extra_menu_items = []

window.Layout =
	view: (vnode) ->
		[
			m 'nav.navbar.navbar-expand-lg.navbar-dark.bg-dark',
				m '.container-fluid#main-container',
					m 'ul.nav.navbar-nav.me-auto.mb-2.mb-lg-0',
						m 'li.nav-item', [ m 'a.nav-link.executions-link[href="?show=executions"]', 'Executions' ]
						m 'li.nav-item', [ m 'a.nav-link.workers-link[href="?show=workers"]', 'Workers' ]
					m 'ul.nav.navbar-nav.navbar-right',
						[
							for extra_menu_item in window.extra_menu_items
								m 'li', [ extra_menu_item() ]
							m 'li',
								m 'a[href="https://github.com/schedy"]',
									m 'img.schedy-logo', {style: {'height':'32px'}, "src": "/schedy.svg"}
						]
			if router.state_valid
				$('a.nav-link').removeClass('active')
				$(router.state.show+'-link').addClass('active')
				m '.container-fluid.layout-container',
					m 'div',
						if router.state.show == 'executions'
							[
								m 'div.collapse.extra-filters-container#extrafilters',
									m '.input-group',
										m 'span.input-group-text','Before ID'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'id_before', value: router.state.executions_filter["id_before"],"placeholder":"ex. 20"}
										m 'span.input-group-text','After ID'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'id_after', value: router.state.executions_filter["id_after"],"placeholder":"ex. 25"}
										m 'span.input-group-text','Created At Before'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'created_before', value: router.state.executions_filter["created_before"],"placeholder":"ex. 2004-10-19 10:23:54+02"}
										m 'span.input-group-text','Created At After'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'created_after', value: router.state.executions_filter["created_after"],"placeholder":"ex. 2004-10-19 10:23:54+02"}
										m 'span.input-group-text','Status'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'status', value: router.state.executions_filter["status"],"placeholder":"ex. running"}
										m 'span.input-group-text','Limit'
										m 'input.form-control.filter-input',{"type":"text",'data-router-field':'limit', value: router.state.executions_filter["limit"],"placeholder":"ex. 50"}
								m '.executions-container',
									m '.executions-grid',
										m Executions
									m '.filters-grid',
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
						if router.state.show == 'resourcecontrol'
							[
								m '.col-md-12',
									m ResourceControl
							]
			else
				m '.container-fluid',
					m Spinner
		]
