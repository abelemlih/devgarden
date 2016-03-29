$ ->
  applyHeadingParallax = (scrollOffset, windowBottom) ->
    for heading in $('.summary-group h1')
      zeroPoint = Math.max(
        $(heading).offset().top - windowBottom,
        0)
      $(heading).css('top', "#{(scrollOffset - zeroPoint) / 2}px")

  applyPopupOnScroll = (scrollOffset, windowBottom) ->
    for popup in $('.popup-on-scroll')
      $popup = $(popup)
      em = parseFloat($("body").css("font-size"))
      offset =
        Math.max(
          0.6*em,          # Always show a little bit poking up
          Math.min(
            $popup.outerHeight(),
            scrollOffset * 0.67 - 1.2*em))
      $popup.css('margin-top', "#{-offset}px")

  applyScrollEffects = ->
    scrollOffset = $(document).scrollTop()
    windowBottom = $(window).height()

    applyHeadingParallax(scrollOffset, windowBottom)
    applyPopupOnScroll(scrollOffset, windowBottom)

  applyScrollEffects()
  $(window).scroll applyScrollEffects
