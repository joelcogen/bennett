class window.Projects
  reload_projects: (params) ->
    resource = new Resource()
    resource.reload("/projects.js", "#projects-summary", params)

  reload_builds : (params) ->
    resource = new Resource()
    url = "/projects/"+params["id"]+".js"
    resource.reload(url, "#builds-list", params)

$ ->
  $('select.right-role-select, select.invitation-role-select').change (e) ->
    $(e.target).closest('form').submit()

  $("#fetch-git-link").live "click", (e) ->
    e.preventDefault()
    form = $(e.target).closest("form")
    $("#fetch-git-link, #fetch-success, #fetch-error").hide()
    $("#fetch-loading").show()
    $.ajax
      url: form.attr("action")
      type: "post"
      data: form.serialize()
      success: (data) ->
        form.replaceWith(data)
        $("#fetch-git-link").hide()
        $("#fetch-loading").hide()
        $("#fetch-success").show()
      error: ->
        $("#fetch-git-link").show()
        $("#fetch-loading").hide()
        $("#fetch-error").show()
        $("#project_git_url").focus()

  $("#project_git_url").live "change", (e) ->
    $("#fetched-project-fields").remove()
    $("#fetch-git-link").show()
    $("#fetch-success, #fetch-error, #fetch-loading").hide()

  $("#project_test_all_branches").change ->
    $("ul.branches li.branch").toggle()

