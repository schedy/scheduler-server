window.Spinner =
	view: (vnode)->
		m '.container.spinner-container',
			m 'img.schedy-spinner', {"src": "/schedy.svg"}
			m 'h1', {style: {"text-align":"center"}}, 'Loading...'


