# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

arrExistingPage = $.parseJSON(gon.links)

page = $.parseJSON(gon.page)
word = $.parseJSON(gon.word)
words = $.parseJSON(gon.words)
page_links_page_association = $.parseJSON(gon.arrayPageLinksPageAssociation)


$(document).ready ()->
  #create array with hash link { link, page_from, word }
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

  #find association between links
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

  # add array link edges
  k = 0
  while k < fullPageArray.length
    id_link = fullPageArray[k].link.id
    # if AssociationLinkWithLinks[id_link]
    fullPageArray[k].link.linkToPages = AssociationLinkWithLinks[id_link]
    k++

  console.log fullPageArray

  #size window with graph (svg)
  width = 900
  height = 600
  # Visual properties of the graph are next. We need to make
  # those that are going to be animated accessible to the
  # JavaScript.
  labelFill = '#444'
  adjLabelFill = '#aaa'
  edgeStroke = '#aaa'
  nodeFill = '#ccc'
  nodeRadius = 10
  selectedNodeRadius = 30
  linkDistance = Math.min(width, height) / 4
  # Find the main graph container.
  graph = d3.select('#graph')
  # Create the SVG container for the visualization and
  # define its dimensions.
  svg = graph.append('svg').attr('width', width).attr('height', height)
  # Select the container for the notes and dimension it.
  notes = d3.select('#notes').style(
    'width': 300 + 'px'
    'height': height + 'px')
  # Utility function to update the position properties
  # of an arbtrary edge that's part of a D3 selection.
  # The optional parameter is the array of nodes for
  # the edges. If present, the source and target properties
  # are assumed to be indices in this array rather than
  # direct references.

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

  # Utility function to update the position properties
  # of an arbitrary node that's part of a D3 selection.

  positionNode = (node) ->
    node.attr 'transform', (d) ->
      'translate(' + d.x + ',' + d.y + ')'
    return

  # Utility function to position text associated with
  # a label pseudo-node. The optional third parameter
  # requests transition to the specified fill color.

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

  data = fullPageArray

  # Find the graph nodes from the data set. Each
  # album is a separate node.
  nodes = data.map((entry, idx, list) ->
    # This iteration returns a new object for
    # each node.
    node = {}
    # We retain some of the album's properties.
    node.id = entry.link.id
    node.url = entry.link.url
    node.translation = entry.translation
    node.name = entry.link.word.definition
    node.description = entry.link.word.content
    # node.image = entry.cover
    # node.url = entry.itunes
    # node.color = entry.color
    # node.text = entry.text

    # We'll also copy the musicians, again using
    # a more neutral property. At the risk of
    # some confusion, we're going to use the term
    # "link" to refer to an individual connection
    # between nodes, and we'll use the more
    # mathematically correct term "edge" to refer
    # to a line drawn between nodes on the graph.
    # (This may be confusing because D3 refers to
    # the latter as "links."
    node.links = entry.link.linkToPages
    # As long as we're iterating through the nodes
    # array, take the opportunity to create an
    # initial position for the nodes. Somewhat
    # arbitrarily, we start the nodes off in a
    # circle in the center of the container.
    radius = 0.4 * Math.min(height, width)
    theta = idx * 2 * Math.PI / list.length
    node.x = width / 2 + radius * Math.sin(theta)
    node.y = height / 2 + radius * Math.cos(theta)
    # Return the newly created object so it can be
    # added to the nodes array.
    node
  )
  # Identify all the indivual links between nodes on
  # the graph. As noted above, we're using the term
  # "link" to refer to a single connection. As we'll
  # see below, we'll call lines drawn on the graph
  # (which may represent a combination of multiple
  # links) "edges" in a nod to the more mathematically
  # minded.
  links = []
  # Start by iterating through the albums.


  data.forEach (srcNode, srcIdx, srcList) ->
    # For each album, iterate through the musicians.

    # console.log srcNode
    # console.log srcNode.links.
    srcNode.link.linkToPages.forEach (srcLink) ->
      # For each musican in the "src" album, iterate
      # through the remaining albums in the list.
      tgtIdx = srcIdx + 1
      while tgtIdx < srcList.length
        # Use a variable to refer to the "tgt"
        # album for convenience.
        tgtNode = srcList[tgtIdx]
        # Is there any musician in the "tgt"
        # album that matches the musican we're
        # currently considering from the "src"
        # album?
        if tgtNode.link.linkToPages.some(((tgtLink) ->
            tgtLink == srcLink
          ))
          # When we do find a match, add a new
          # link to the links array.
          links.push
            source: srcIdx
            target: tgtIdx
            link: srcLink
        tgtIdx++
      return
    return



  # Now create the edges for our graph. We do that by
  # eliminating duplicates from the links array.




  edges = []
  # Iterate through the links array.
  links.forEach (link) ->
    # Assume for now that the current link is
    # unique.
    existingEdge = false
    # Look through the edges we've collected so
    # far to see if the current link is already
    # present.
    idx = 0
    while idx < edges.length
      # A duplicate link has the same source
      # and target values.
      if link.source == edges[idx].source and link.target == edges[idx].target
        # When we find an existing link, remember
        # it.
        existingEdge = edges[idx]
        # And stop looking.
        break
      idx++
    # If we found an existing edge, all we need
    # to do is add the current link to it.
    if existingEdge
      existingEdge.links.push link.link
    else
      # If there was no existing edge, we can
      # create one now.
      edges.push
        source: link.source
        target: link.target
        links: [ link.link ]
    return




  # Start the creation of the graph by adding the edges.
  # We add these first so they'll appear "underneath"
  # the nodes.
  edgeSelection = svg.selectAll('.edge')
    .data(edges)
    .enter()
    .append('line')
    .classed('edge', true)
    .style('stroke', edgeStroke)
    .call(positionEdge, nodes)

  # Next up are the nodes.
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
  # Now that we have our main selections (edges and
  # nodes), we can create some subsets of those
  # selections that will be helpful. Those subsets
  # will be tied to individual nodes, so we'll
  # start by iterating through them. We do that
  # in two separate passes.
  nodeSelection.each (node) ->
    # First let's identify all edges that are
    # incident to the node. We collect those as
    # a D3 selection so we can manipulate the
    # set easily with D3 utilities.
    node.incidentEdgeSelection = edgeSelection.filter((edge) ->
      nodes[edge.source] == node or nodes[edge.target] == node
    )
    return
  # Now make a second pass through the nodes.
  nodeSelection.each (node) ->
    # For this pass we want to find all adjacencies.
    # An adjacent node shares an edge with the
    # current node.
    node.adjacentNodeSelection = nodeSelection.filter((otherNode) ->
      # Presume that the nodes are not adjacent.
      isAdjacent = false
      # We can't be adjacent to ourselves.
      if otherNode != node
        # Look the incident edges of both nodes to
        # see if there are any in common.
        node.incidentEdgeSelection.each (edge) ->
          otherNode.incidentEdgeSelection.each (otherEdge) ->
            if edge == otherEdge
              isAdjacent = true
            return
          return
      isAdjacent
    )
    return
  # Next we create a array for the node labels.
  # We're going to use a "hidden" force layout to
  # position the labels so they don't overlap
  # each other. ("Hidden" because the links won't
  # be visible.)
  labels = []
  labelLinks = []
  nodes.forEach (node, idx) ->
    # For each node on the graph we create
    # two pseudo-nodes for its label. Once
    # pseudo-node will be anchored to the
    # center of the real node, while the
    # second will be linked to that node.
    # Add the pseudo-nodes to their array.
    labels.push node: node
    labels.push node: node
    # And create a link between them.
    labelLinks.push
      source: idx * 2
      target: idx * 2 + 1
    return
  # Construct the selections for the label layout.
  # There's no need to add any markup for the
  # pseudo-links between the label nodes, but
  # we do need a selection so we can run the
  # force layout.
  labelLinkSelection = svg.selectAll('line.labelLink').data(labelLinks)
  # The label pseud-nodes themselves are just
  # `<g>` containers.
  labelSelection = svg.selectAll('g.labelNode').data(labels).enter().append('g').classed('labelNode', true)
  # Now add the text itself. Of the paired
  # pseudo-nodes, only odd ones get the text
  # elements.
  labelSelection.append('text').text((d, i) ->
    if i % 2 == 0 then '' else d.node.name
  ).attr 'data-node-index', (d, i) ->
    if i % 2 == 0 then 'none' else Math.floor(i / 2)
  # The last bit of markup are the lists of
  # connections for each link.
  connectionSelection = graph.selectAll('ul.connection').data(edges).enter().append('ul').classed('connection hidden', true).attr('data-edge-index', (d, i) ->
    i
  )
  connectionSelection.each (connection) ->
    selection = d3.select(this)
    connection.links.forEach (link) ->
      selection.append('li').text link
      return
    return
  # Create the main force layout.
  force = d3.layout.force().size([
    width
    height
  ]).nodes(nodes).links(edges).linkDistance(linkDistance).charge(-500)
  # Create the force layout for the labels.
  labelForce = d3.layout.force().size([
    width
    height
  ]).nodes(labels).links(labelLinks).gravity(0).linkDistance(0).linkStrength(0.8).charge(-100)
  # Let users drag the nodes.
  nodeSelection.call force.drag
  # Function to handle clicks on node elements

  nodeClicked = (node) ->
    # Ignore events based on dragging.
    if d3.event.defaultPrevented
      return
    # Remember whether or not the clicked
    # node is currently selected.
    selected = node.selected
    # Keep track of the desired text color.
    fillColor = undefined
    # In all cases we start by resetting
    # all the nodes and edges to their
    # de-selected state. We may override
    # this transition for some nodes and
    # edges later.
    nodeSelection.each((node) ->
      node.selected = false
      return
    ).selectAll('circle').transition().attr('r', nodeRadius).style 'fill', nodeFill
    edgeSelection.transition().style 'stroke', edgeStroke
    labelSelection.transition().style 'opacity', 0
    # Now see if the node wasn't previously selected.
    if !selected
      # This node wasn't selected before, so
      # we want to select it now. That means
      # changing the styles of some of the
      # elements in the graph.
      # First we transition the incident edges.
      node.incidentEdgeSelection.transition().style 'stroke', node.color
      # Now we transition the adjacent nodes.
      node.adjacentNodeSelection.selectAll('circle').transition().attr('r', nodeRadius).style 'fill', node.color
      labelSelection.filter((label) ->
        adjacent = false
        node.adjacentNodeSelection.each (d) ->
          if label.node == d
            adjacent = true
          return
        adjacent
      ).transition().style('opacity', 1).selectAll('text').style 'fill', adjLabelFill
      # And finally, transition the node itself.
      d3.selectAll('circle[data-node-index="' + node.index + '"]').transition().attr('r', selectedNodeRadius).style 'fill', node.color
      # Make sure the node's label is visible
      labelSelection.filter((label) ->
        label.node == node
      ).transition().style 'opacity', 1
      # And note the desired color for bundling with
      # the transition of the label position.
      fillColor = node.text
      # Delete the current notes section to prepare
      # for new information.
      notes.selectAll('*').remove()
      # Fill in the notes section with informationm
      # from the node. Because we want to transition
      # this to match the transitions on the graph,
      # we first set it's opacity to 0.
      notes.style 'opacity': 0
      # Now add the notes content.
      # console.log node.text
      notes.append('h4')
        .attr("class", "description")
        .text node.name
      notes.append('p')
        .attr("class", "description")
        .text node.description
      notes.append('p')
        .attr("class", "description")
        .text node.id
      # if node.url
      #   notes.append('div').classed('artwork', true).append('a').attr('href', node.url)
      # list = notes.append('ul')
      # node.links.forEach (link) ->
      #   list.append('li').text link
      #   return
      # # With the content in place, transition
      # # the opacity to make it visible.
      notes.transition().style 'opacity': 1
    else
      # Since we're de-selecting the current
      # node, transition the notes section
      # and then remove it.
      notes.transition().style('opacity': 0).each 'end', ->
        notes.selectAll('*').remove()
        return
      # Transition all the labels to their
      # default styles.
      labelSelection.transition()
        .style('opacity', 1)
        .selectAll('text')
        .style 'fill', labelFill
      # The fill color for the current node's
      # label must also be bundled with its
      # position transition.
      fillColor = labelFill
    # Toggle the selection state for the node.
    node.selected = !selected
    # Update the position of the label text.
    text = d3.select('text[data-node-index="' + node.index + '"]').node()
    label = null
    labelSelection.each (d) ->
      if d.node == node
        label = d
      return
    if text and label
      positionLabelText text, label, fillColor
    return

  # Function to handle click on edges.

  edgeClicked = (edge, idx) ->
    # Remember the current selection state of the edge.
    selected = edge.selected
    # Transition all connections to hidden. If the
    # current edge needs to be displayed, it's transition
    # will be overridden shortly.
    connectionSelection.each((edge) ->
      edge.selected = false
      return
    ).transition().style('opacity', 0).each 'end', ->
      d3.select(this).classed 'hidden', true
      return
    # If the current edge wasn't selected before, we
    # want to transition it to the selected state now.
    if !selected
      d3.select('ul.connection[data-edge-index="' + idx + '"]').classed('hidden', false).style('opacity', 0).transition().style 'opacity', 1
    # Toggle the resulting selection state for the edge.
    edge.selected = !selected
    return

  # Handle clicks on the nodes.
  nodeSelection.on 'click', nodeClicked
  labelSelection.on 'click', (pseudonode) ->
    nodeClicked pseudonode.node
    return
  # Handle clicks on the edges.
  edgeSelection.on 'click', edgeClicked
  connectionSelection.on 'click', edgeClicked
  # Animate the force layout.
  force.on 'tick', ->
    # Constrain all the nodes to remain in the
    # graph container.
    nodeSelection.each (node) ->
      node.x = Math.max(node.x, 2 * selectedNodeRadius)
      node.y = Math.max(node.y, 2 * selectedNodeRadius)
      node.x = Math.min(node.x, width - (2 * selectedNodeRadius))
      node.y = Math.min(node.y, height - (2 * selectedNodeRadius))
      return
    # Kick the label layout to make sure it doesn't
    # finish while the main layout is still running.
    labelForce.start()
    # Calculate the positions of the label nodes.
    labelSelection.each (label, idx) ->
      # Label pseudo-nodes come in pairs. We
      # treat odd and even nodes differently.
      if idx % 2
        # Odd pseudo-nodes have the actual text.
        # That text needs a real position. The
        # pseudo-node itself we leave to the
        # force layout to position.
        positionLabelText @childNodes[0], label
      else
        # Even pseudo-nodes (which have no text)
        # are fixed to the center of the
        # corresponding real node. This will
        # override the position calculated by
        # the force layout.
        label.x = label.node.x
        label.y = label.node.y
      return
    # Calculate the position for the connection lists.
    connectionSelection.each (connection) ->
      x = (connection.source.x + connection.target.x) / 2 - 27
      y = (connection.source.y + connection.target.y) / 2
      d3.select(this).style
        'top': y + 'px'
        'left': x + 'px'
      return
    # Update the posistions of the nodes and edges.
    nodeSelection.call positionNode
    labelSelection.call positionNode
    edgeSelection.call positionEdge
    labelLinkSelection.call positionEdge
    return
  # Start the layout computations.
  force.start()
  labelForce.start()
