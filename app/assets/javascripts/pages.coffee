# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

arrLinks = $.parseJSON(gon.links)

$(document).ready ()->
  i = 0
  arrUrl = []
  while i < arrLinks.length
    arrUrl[i] = arrLinks[i]["id"]
    i++

  d3.select(".chart")
    .selectAll("div")
      .data(arrUrl)
    .enter().append("div")
      .style 'width', (d)-> d * 10 + 'px'
      .text((d)-> d )
