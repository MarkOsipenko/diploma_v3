$(document).on 'page:load ready', ->
  arrExistingPage = $.parseJSON(gon.links)
  page = $.parseJSON(gon.page)
  word = $.parseJSON(gon.word)
  words = $.parseJSON(gon.words)
  page_links_page_association = $.parseJSON(gon.arrayPageLinksPageAssociation)

  fullPageArray = []
  i = 0
  while i < arrExistingPage.length
    arrWithLink = {}
    arrWithLink.link = arrExistingPage[i]
    arrWithLink.link.page = page
    words.forEach((entry)->
      if entry.page_id == arrExistingPage[i].id
        arrWithLink.link.word = entry
    )
    fullPageArray.push arrWithLink
    i++
  AssociationLinkWithLinks = {}
  ArrLinks = []
  j = 0
  keyz =  Object.keys(page_links_page_association).map( (item)->
    parseInt(item, 10)
  )
  for key of page_links_page_association
    page_links_page_association[key].forEach((entry)->
       keyz.forEach((k)->
         if k == entry
           ArrLinks.push entry
         )
       AssociationLinkWithLinks[key] = ArrLinks
      )
    j++
  k = 0
  while k < fullPageArray.length
    id_link = fullPageArray[k].link.id
    fullPageArray[k].link.linkToPages = AssociationLinkWithLinks[id_link]
    k++
  width = 900
  height = 600
  labelFill = '#444'
  adjLabelFill = '#A4A4A4'
  edgeStroke = '#aaa'
  nodeFill = '#337ab7'
  nodeRadius = 10
  selectedNodeRadius = 30
  linkDistance = Math.min(width, height) / 2
  console.log fullPageArray
  graph = d3.select('#graph')
  svg = graph.append('svg').attr('width', width).attr('height', height)

  notes = d3.select('#notes').style(
    'width': 400 + 'px'
    'height': height + 'px')
  positionEdge = (edge, nodes) ->
    edge.attr('x1', (d) ->
      if nodes then nodes[d.source].x else d.source.x
    ).attr('y1', (d) ->
      if nodes then nodes[d.source].y else d.source.y
    ).attr('x2', (d) ->
      if nodes then nodes[d.target].x else d.target.x
    ).attr 'y2', (d) ->
      if nodes then nodes[d.target].y else d.target.y
    return
  positionNode = (node) ->
    node.attr 'transform', (d) ->
      'translate(' + d.x + ',' + d.y + ')'
    return

  positionLabelText = (text, pseudonode, fillColor) ->
    # What's the width of the text element?
    textWidth = text.getBBox().width
    # How far is the pseudo-node from the real one?
    diffX = pseudonode.x - (pseudonode.node.x)
    diffY = pseudonode.y - (pseudonode.node.y)
    dist = Math.sqrt(diffX * diffX + diffY * diffY)
    # Shift in the x-direction a fraction of the text width
    shiftX = textWidth * (diffX - dist) / (dist * 2)
    shiftX = Math.max(-textWidth, Math.min(0, shiftX))
    shiftY = if pseudonode.node.selected then selectedNodeRadius else nodeRadius
    shiftY = 0.5 * shiftY * diffY / Math.abs(diffY)
    select = d3.select(text)
    if fillColor
      select = select.transition().style('fill', fillColor)
    select.attr 'transform', 'translate(' + shiftX + ',' + shiftY + ')'
    return

  data = fullPageArray.slice(0, 15)
  nodes = data.map((entry, idx, list) ->
    node = {}
    node.id = entry.link.id
    node.url = entry.link.url
    node.translation = entry.translation
    node.name = entry.link.word.definition
    node.description = entry.link.word.content
    node.links = entry.link.linkToPages
    node.color = "#FE2E2E"
    radius = 0.4 * Math.min(height, width)
    theta = idx * 2 * Math.PI / list.length
    node.x = width / 2 + radius * Math.sin(theta)
    node.y = height / 2 + radius * Math.cos(theta)
    node
  )
  links = []
  data.forEach (srcNode, srcIdx, srcList) ->
    srcNode.link.linkToPages.forEach (srcLink) ->
      tgtIdx = srcIdx + 1
      while tgtIdx < srcList.length
        tgtNode = srcList[tgtIdx]
        if tgtNode.link.linkToPages.some(((tgtLink) ->
            tgtLink == srcLink
          ))
          links.push
            source: srcIdx
            target: tgtIdx
            link: srcLink
        tgtIdx++
      return
    return
  edges = []
  links.forEach (link) ->
    existingEdge = false
    idx = 0
    while idx < edges.length
      if link.source == edges[idx].source and link.target == edges[idx].target
        existingEdge = edges[idx]
        # console.log link
        break
      idx++
    if existingEdge
      existingEdge.links.push link.link
    else
      edges.push
        source: link.source
        target: link.target
        links: [ link.link ]
    return
  edgeSelection = svg.selectAll('.edge')
    .data(edges)
    .enter()
    .append('line')
    .classed('edge', true)
    .style('stroke', edgeStroke)
    .call(positionEdge, nodes)
  nodeSelection = svg.selectAll('.node')
    .data(nodes)
    .enter()
    .append('g')
    .classed('node', true)
    .call(positionNode)

  nodeSelection.append('circle')
    .attr('r', nodeRadius)
    .attr('data-node-index', (d, i) ->
      i
    ).style 'fill', nodeFill
  nodeSelection.each (node) ->
    node.incidentEdgeSelection = edgeSelection.filter((edge) ->
      nodes[edge.source] == node or nodes[edge.target] == node
    )
    return
  nodeSelection.each (node) ->
    node.adjacentNodeSelection = nodeSelection.filter((otherNode) ->
      isAdjacent = false
      if otherNode != node
        node.incidentEdgeSelection.each (edge) ->
          otherNode.incidentEdgeSelection.each (otherEdge) ->
            if edge == otherEdge
              isAdjacent = true
            return
          return
      isAdjacent
    )
    return
  labels = []
  labelLinks = []
  nodes.forEach (node, idx) ->
    labels.push node: node
    labels.push node: node
    labelLinks.push
      source: idx * 2
      target: idx * 2 + 1
    return
  labelLinkSelection = svg.selectAll('line.labelLink').data(labelLinks)
  labelSelection = svg.selectAll('g.labelNode').data(labels).enter().append('g').classed('labelNode', true)
  labelSelection.append('text').text((d, i) ->
    if i % 2 == 0 then '' else d.node.name
  ).attr 'data-node-index', (d, i) ->
    if i % 2 == 0 then 'none' else Math.floor(i / 2)
  connectionSelection = graph.selectAll('ul.connection').data(edges).enter().append('ul').classed('connection hidden', true).attr('data-edge-index', (d, i) ->
    i
  )
  connectionSelection.each (connection) ->
    selection = d3.select(this)
    connection.links.forEach (link) ->
      selection.append('li').text link
      return
    return
  force = d3.layout.force().size([
    width
    height
  ]).nodes(nodes).links(edges).linkDistance(linkDistance).charge(-500)
  labelForce = d3.layout.force().size([
    width
    height
  ]).nodes(labels).links(labelLinks).gravity(0).linkDistance(0).linkStrength(0.8).charge(-100)
  nodeSelection.call force.drag
  nodeClicked = (node) ->
    if d3.event.defaultPrevented
      return
    selected = node.selected
    fillColor = "#000"
    nodeSelection.each((node) ->
      node.selected = false
      return
    ).selectAll('circle').transition().attr('r', nodeRadius).style 'fill', nodeFill
    edgeSelection.transition().style 'stroke', edgeStroke
    labelSelection.transition().style 'opacity', 0
    if !selected
      node.incidentEdgeSelection.transition().style 'stroke', node.color
      node.adjacentNodeSelection.selectAll('circle').transition().attr('r', nodeRadius).style 'fill', node.color
      labelSelection.filter((label) ->
        adjacent = false
        node.adjacentNodeSelection.each (d) ->
          if label.node == d
            adjacent = true
          return
        adjacent
      ).transition().style('opacity', 1).selectAll('text').style 'fill', adjLabelFill
      d3.selectAll('circle[data-node-index="' + node.index + '"]').transition().attr('r', selectedNodeRadius).style 'fill', node.color
      labelSelection.filter((label) ->
        label.node == node
      ).transition().style 'opacity', 1
      fillColor = node.text
      notes.selectAll('*').remove()
      notes.style 'opacity': 0
      notes.append('h4')
        .attr("class", "description")
        .text node.name
      notes.append('p')
        .attr("class", "description")
        .text node.description
      notes.append('p')
        .attr("class", "description")
        .text node.id

      notes.transition().style 'opacity': 1
    else
      notes.transition().style('opacity': 0).each 'end', ->
        notes.selectAll('*').remove()
        return
      labelSelection.transition()
        .style('opacity', 1)
        .selectAll('text')
        .style 'fill', labelFill
      fillColor = labelFill
    node.selected = !selected
    text = d3.select('text[data-node-index="' + node.index + '"]').node()
    label = null
    labelSelection.each (d) ->
      if d.node == node
        label = d
      return
    if text and label
      positionLabelText text, label, fillColor
    return
  edgeClicked = (edge, idx) ->
    selected = edge.selected
    connectionSelection.each((edge) ->
      edge.selected = false
      return
    ).transition().style('opacity', 0).each 'end', ->
      d3.select(this).classed 'hidden', true
      return
    if !selected
      d3.select('ul.connection[data-edge-index="' + idx + '"]').classed('hidden', false).style('opacity', 0).transition().style 'opacity', 1
    edge.selected = !selected
    return

  nodeSelection.on 'click', nodeClicked
  labelSelection.on 'click', (pseudonode) ->
    nodeClicked pseudonode.node
    return
  edgeSelection.on 'click', edgeClicked
  connectionSelection.on 'click', edgeClicked
  force.on 'tick', ->
    nodeSelection.each (node) ->
      node.x = Math.max(node.x, 2 * selectedNodeRadius)
      node.y = Math.max(node.y, 2 * selectedNodeRadius)
      node.x = Math.min(node.x, width - (2 * selectedNodeRadius))
      node.y = Math.min(node.y, height - (2 * selectedNodeRadius))
      return
    labelForce.start()
    labelSelection.each (label, idx) ->
      if idx % 2
        positionLabelText @childNodes[0], label
      else
        label.x = label.node.x
        label.y = label.node.y
      return
    connectionSelection.each (connection) ->
      x = (connection.source.x + connection.target.x) / 2 - 27
      y = (connection.source.y + connection.target.y) / 2
      d3.select(this).style
        'top': y + 'px'
        'left': x + 'px'
      return
    nodeSelection.call positionNode
    labelSelection.call positionNode
    edgeSelection.call positionEdge
    labelLinkSelection.call positionEdge
    return
  force.start()
  labelForce.start()