$ ->
  targetOfLink = ($link) ->
    $($link.attr('href') + "-tab")

  firstTab = ($tabs) ->
    $($tabs.find('.tab')[0])

  showTab = ($tab) ->
    $group = $tab.closest('.tabs')

    $group.find("> ul > li").toggleClass('active', false)
    href = ($tab.attr('id') || "").replace("-tab", "")
    $group.find("a[href='##{href}']").closest('li').toggleClass('active', true)

    $group.find('.tab').hide()
    $tab.show()

  $(document).on 'turbolinks:load', ->
    $('.tabs > ul > li a').attr("data-turbolinks", false)
    for tabs in $('.tabs')
      showTab(
        firstTab($(tabs)))
    showTab $(window.location.hash + "-tab")

  $(document).on 'click', '.tabs li a', (e) ->
    $tab = targetOfLink($(e.target).closest("a"))
    showTab($tab)
    return
