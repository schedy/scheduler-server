format_02i = (inp) ->
        (inp < 10 and "0" or "") + inp

window.sec2hhmmss = (secs) ->
        hh = Math.floor(secs / 3600)
        mm = Math.floor((secs - (hh * 3600)) / 60)
        ss = secs - (hh * 3600) - (mm * 60)
        (hh > 0 and format_02i(hh) + "h " or "") + ((mm > 0 or hh >0) and format_02i(mm) + "m " or "") + format_02i(ss).substring(0,6) + "s"

window.short_date = (inp) ->
        date = new Date(inp)
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.getDay()] + ' ' + format_02i(date.getHours()) + ':' + format_02i(date.getMinutes())

window.base64encode = (text) -> btoa(encodeURIComponent(text)).replace(/=/g,"")
window.base64decode = (text) -> encodeURIComponent(atob(text))
