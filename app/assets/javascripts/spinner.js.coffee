window.Spinner =
        view: (vnode)->
                m '.backdrop', style: { position: 'absolute', top: '0px', bottom: '0px', right: '0px', left: '0px', 'background-color': "rgba(0,0,0,0.2)" },
                        m '', style: { width: '45px', margin: 'auto', position: 'relative', top: '50%', transform: 'translateY(-50%)'  },
                                m '.spinner-loader'

