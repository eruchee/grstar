scrollSpeed = 50
shift_flg = off
ccbJSON=[]
ccb = []
ccbpos = 0
oldIndex = -1
lastIndex = 100
index = -1
activeIndex=-1
listitems = []
mark = []
ccbflushcount = 0
DEBUG = false
#sync = 0

$(document).ready (e) ->
 $('#debughead').append "keydown <div id='keydown'></div><br />
index <div id='index'></div><br />
oldindex <div id='lastindex'></div>  <br />
selector <div id='selector'></div>  <br />
buffer <div id='buffer'></div><br />" if DEBUG is true
 loadJSON(0,100)
 #$("#items").unload (e) ->
  # ccbforced flush
 # ccbFlush()
 setInterval ( ()->
   # ccb flush check ( more than 50)
   ccbflushcount++
   if ccbflushcount is 5
    ccbFlush()
    ccbflushcount = 0
   else
    if ccbpos > 10
     ccbFlush()
 ), 30000
 $('a#next100').click ->
    loadJSON(lastIndex+1,lastIndex+100)
 $(window).keydown (keyDown)
 $(window).keyup (e) ->
  switch e.keyCode
   when 16
     shift_flg = off

keyDown = (e) ->
   #alert(e.which + " " + e.keyCode)
   $("#keydown").html "<p>" + e.keyCode + "</p>"  if DEBUG is true
   #e.preventDefault()
   switch e.keyCode
     when 68 then addDelicious() #d button
     when 74 then pushJ()
     when 75 then pushK()
     when 78 then pushN()
     when 79 then pushO()
     when 80 then pushP()
     when 82 then refresh()     #r push
     when 83 then triggerStar() #s button
     when 86 then openItem()    #v button
     when 16                     #shift
       shift_flg = on

loadJSON = (s,l) ->
 $("#keydown").html "test" if DEBUG is true
 $.getJSON "/assets/starred.json", (data) ->
  $.each data.items, (ix, item) ->
   if ix < s
      return true;
   listitems[ix] = item
   mark[ix] = 0
   #format date -> YYYY/MM/DD
   d = new Date(item.updated * 1000)
   blogTitle = item.origin.title
   if blogTitle.length >= 10
    blogTitle=blogTitle.substr(0,10) + "..."
   if ix < 5
     pt = 1
    else
     pt = ix - 4
   $('#items').append "<div class='item' style='width:100%; background-color:#ffffff;'><div class='item-mark'></div><div class='blog-title'>" + blogTitle + "</div>
<div class='title'><a href='#ac"+pt+"' name='ac"+ix+"' class='itemlink'>" + item.title + "</a></div><div class='date'>" + d.getFullYear() + "/" + (d.getMonth() + 1) + "/" + d.getDate() + "</div></div>"
   $('#items').append "<div class='item-body" + ix + "'></div>"
   $('div.item:eq('+ix+')').css "background-color","#ffffff"
   $('#lastindex').html "#item" + ix if DEBUG is true
   #return false
   $('a#next100').attr 'href',"#ac"+pt
   if ix >= l
    lastIndex = ix
    return false
  $('a.itemlink').click ->
      if shift_flg is on
        #check opposide to multiple select
      else
       oldIndex = index
       index = $('a.itemlink').index this
       $('#index').html index if DEBUG is true
       inActivated(oldIndex)
       selected(index)
       Activate(index)


pushJ = () ->
 if index != lastIndex
  oldIndex = index
  index = index + 1
  inActivated(oldIndex)
  selected(index)
  Activate(index)
 else
  nextLoad()

pushN = () ->
 if index != lastIndex
  oldIndex = index
  index = index + 1
  inActivated(oldIndex)
  selected(index)
 else
  nextLoad()

pushK = () ->
 if index > 0
  oldIndex = index
  index = index - 1
  inActivated(oldIndex)
  selected(index)
  Activate(index)

pushP = () ->
 if index > 0
  oldIndex = index
  index = index - 1
  inActivated(oldIndex)
  selected(index)

pushO = () ->
 if activeIndex is index
  inActivated(index)
  selected(index)
 else
  selected(index)
  Activate(index)

nextLoad= () ->
 if(index+1)>lastIndex
  loadJSON(lastIndex+1,lastIndex+100)

inActivated = (idx) ->
 $('#lastindex').html idx if DEBUG is true
 if idx >=0
  $('#selector').html "item" + idx if DEBUG is true
  $('div.item:eq('+idx+')').css("background-color","white")
  $('.item-body'+idx).html ""
  activeIndex=-1
 else
  return -1

Activate = (idx) ->
 $('#selector').html "item" + idx if DEBUG is true
 $('#index').html idx if DEBUG is true
 $('.item-body'+idx).html "<h2><a href='" + listitems[idx].alternate[0].href + "'>" + listitems[idx].title + "</a></h2>"
 if listitems[idx].content is undefined
   content = listitems[idx].summary.content
 else
   content = listitems[idx].content.content
 $('.item-body'+idx).append content
 activeIndex=index

selected = (idx) ->
 $('#index').html idx if DEBUG is true
 $('#selector').html "item" + idx if DEBUG is true
 if idx > 5
  offs = $('div.item:eq('+(idx-4)+')').offset()
 else
  offs = $('div.item:eq(0)').offset()
 $('html,body').animate {scrollTop:offs.top, scrollLeft:offs.Left}, scrollSpeed
 $('div.item:eq('+idx+')').css "background-color","#ffff99"

triggerStar = ->
 findIndex = 0
 if index < 0
  return false
 if mark[index] is 10
  #if sync is 0
    #sync = 1
    ccbJSON[ccbpos]=listitems[index]
    ccb[ccbpos] = {"jsonID": listitems[index].id, "listID": index, "ccbpos":ccbpos, "json":listitems[index], "handleID": 110}
    $('div.item-mark:eq('+index+')').html "R"
    ccbpos++;
    mark[index] = 11
 else if mark[index] is 1 or mark[index] is 11
  if mark[index] is 1
   html = ""
   mk = 0
  else
   html = "D"
   mk = 10
  $('div.item-mark:eq('+index+')').html html
  mark[index] = mk
  #if sync is 0
   #sync = 1
  $.each ccb, (ix,ccbitem) ->
    if ccbitem['listID'] is index
      findIndex = ix
     #ccbitem['handleID'] = 0 #NOP
  ccbJSON.splice(findIndex,1)
  ccb.splice(findIndex,1)
  ccbpos--
 else if mark[index] is 0
   $('div.item-mark:eq('+index+')').html "M"
   mark[index] = 1
   ccbJSON[ccbpos]=listitems[index]
   ccb[ccbpos] = {"jsonID": listitems[index].id, "ccbpos":ccbpos,"listID": index, "handleID": 101}
   ccbpos++
  if DEBUG is true
   $('#buffer').html ccbpos + "<br />"
   $.each ccb, (ix,ccbitem) ->
    $('#buffer').append ix+": jsonid: "+ ccbitem['jsonID'] + " listID: " + ccbitem['listID'] + " handleID: " + ccbitem['handleID'] + " ccbpos: "+ ccbitem['ccbpos']+"<br />"
 #if ccbpos is 15
  #ccbFlush()

openItem = ->
 if index > 0
  #push V link
  #wnd = window
  nwn = window.open()
  nwn.opener = null
  nwn.location = listitems[index].alternate[0].href
  #nwn.blur()
  #wnd.focus()

refresh = ->
 #clear div.items
 #lastIndex = last
 $('#items').html ""
 listitems = []
 loadJSON(0, lastIndex)
 if DEBUG is true
   $('#buffer').html ccbpos + "<br />"
   $.each ccb, (ix,ccbitem) ->
     $('#buffer').append ix+": jsonid: "+ ccbitem['jsonID'] + " listID: " + ccbitem['listID'] + " handleID: " + ccbitem['handleID'] + "<br />"#finalize
 index = -1
 oldIndex = -1
 shift_flg = false

ccbFlush = ->
  #ask ccb flush to application
  if ccbpos is 0
   return false
  #sync = 1
  message("同期中です。")
  #$('#buffer').append ccb + "<br />" if DEBUG is true
  jsonarray = { "lastIndex":lastIndex, "ccb":ccb }
  jsonstr = JSON.stringify(jsonarray)
  $('#buffer').append jsonstr.substr(0,100) + "<br />" if DEBUG is true
  $.ajax {
   type: "POST",
   contentType: "application/json",
   url: '/proccb',
   data: jsonstr,
   complete: (e,xhr,setting)->
     #$('#buffer').append "ResText: "+e.responseText.substr(0,100)+"<br />"  if DEBUG is true
     $('#buffer').append "ResText: "+e.responseText+"<br />"  if DEBUG is true
     rv = JSON.parse (e.responseText)
     $.each rv, (ix, retel) ->
       if retel.result is "fail"
         if retel.handleID is 110
           ccbJSON[ccbpos]=retel.json
           ccb[ccbpos] = retel
           ccbpos++
           if DEBUG is true
             $('#buffer').html ccbpos + "<br />"
             $.each ccb, (ix,ccbitem) ->
             $('#buffer').append ix+": jsonid: "+ ccbitem['jsonID'] + " listID: " + ccbitem['listID'] + " handleID: " + ccbitem['handleID'] + "<br />"
       if retel.result is "ok"
         if mark[retel.listIndex] is 1
           markchar="D "
           mark[retel.listIndex] = 10
         else if mark[retel.listIndex] is 11
           markchar = ""
           mark[retel.listIndex] = 0
         $('div.item-mark:eq('+retel.listIndex+')').html markchar
           #delete ccb data which succeeded.
         j=0
         $.each ccbJSON, (ccbix, ccbelm) ->
             if ccbelm.id is retel.jsonID
               ccb.splice(j,1)
               ccbJSON.splice(j,1)
               ccbpos--
               return false
             else
               j++
     messageoff()
   dataType: "json"
  }

message = (msg) ->
 $(window).unbind "keydown",keyDown
 $('#message').html msg
 #h=($(document).scrollTop()+($(document).height()-$(window).height()))/2
 h=$(window).scrollTop()
 w=($(window).width()-$('#message').width())/2
 $('#message').css "top",h
 $('#message').css "left","50%"
 $('#message').css "background-color","gray"

messageoff = ->
 $('#message').html ""
 $('#message').css "top","-100px","left","-100px"
 $('#message').css "background-color","white"
 $(window).keydown (keyDown)
