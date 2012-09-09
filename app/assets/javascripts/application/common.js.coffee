$.fn.show = ->
  this.removeClass("hide")
$.fn.hide = ->
  this.addClass("hide")

$ ->
  $('.alert-message a').click (e) ->
    e.preventDefault()
    $(e.target).closest('.alert-message').hide()

  if navigator.userAgent.toLowerCase().indexOf("chrome") >= 0
    _interval = window.setInterval(->
      autofills = $("input:-webkit-autofill")
      if autofills.length > 0
        window.clearInterval _interval
        autofills.each ->
          clone = $(this).clone(true, true)
          $(this).after(clone).remove()
    , 20)
  $("#myModal").modal()

  setTimeout (->
    $("div.alert").fadeOut "slow", ->
      $("div.alert").remove()
  ), 3000
