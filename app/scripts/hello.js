(function() {
  var App, app, displayDiagram, getAttribute, loadedContext, offsetX, offsetY;

  App = (function() {
    function App() {
      console.log('initialized app');
    }

    return App;

  })();

  app = new App;

  loadedContext = null;

  offsetX = 250;

  offsetY = 300;

  getAttribute = function(id) {
    var attribute, context;
    context = loadedContext.conceptualSchema.context;
    attribute = _(context.attribute).find(function(d) {
      return d.keyAttributes.id === id;
    });
    return attribute;
  };

  $(document).ready(function() {
    $('#csx-file').change(function(e) {
      var reader;
      reader = new FileReader();
      reader.readAsText(e.target.files[0]);
      return reader.onload = (function(e) {
        return console.log(e.target.result);
      });
    });
    $('#sql-file').change(function(e) {
      return console.log('added sql file');
    });
    return d3.xml('fam.csx', 'application/xml', function(resp) {
      var diagrams, dispatch, schema;
      loadedContext = xml2json(resp);
      schema = loadedContext.conceptualSchema;
      console.log(loadedContext, xml2json(resp));
      diagrams = d3.selectAll('#diagrams').selectAll('option');
      diagrams.data(schema.diagram).enter().append('option').attr('value', function(d, i) {
        return i;
      }).text(function(d) {
        return d.keyAttributes.title;
      });
      dispatch = d3.dispatch('load', 'change');
      dispatch.on('load', function() {
        return displayDiagram(0);
      });
      dispatch.on('change', displayDiagram);
      dispatch.load(0);
      d3.selectAll('#diagrams').on('change', function() {
        return dispatch.change();
      });
      return loadedContext;
    }, function(err) {
      return console("ups, gvnr");
    });
  });

  displayDiagram = function(d) {
    var circles, concepts, diagram, diagramGroup, edges, r, svg;
    if (d == null) {
      d = d3.event.target.value;
    }
    diagram = loadedContext.conceptualSchema.diagram[+d];
    console.log("NEW DIAGRAM", diagram);
    svg = d3.select('svg#default-diagram');
    diagramGroup = svg.selectAll('g.diagram').data([diagram], function(d) {
      return d.keyAttributes.title;
    });
    diagramGroup.exit().remove();
    diagramGroup.enter().append('g').attr('class', 'diagram');
    edges = diagramGroup.selectAll('line').data(diagram.edge, function(d) {
      return "" + diagram.keyAttributes.title + "-" + d.keyAttributes.from + "-" + d.keyAttributes.to;
    });
    edges.exit().remove();
    edges.enter().append('line').style('stroke', function(d) {
      if (diagram.keyAttributes.title) {
        return 'black';
      } else {
        return '#333';
      }
    }).style('stroke-width', 2).attr('x1', function(d) {
      var from, pos;
      from = parseInt(d.keyAttributes['from'], 10) - 1;
      pos = parseInt(diagram.concept[from].position.keyAttributes.x) + offsetX;
      return pos;
    }).attr('x2', function(d) {
      var pos, to;
      to = parseInt(d.keyAttributes['to']) - 1;
      pos = parseInt(diagram.concept[to].position.keyAttributes.x) + offsetX;
      return pos;
    }).attr('y1', function(d) {
      var from, pos;
      from = parseInt(d.keyAttributes['from'], 10) - 1;
      pos = parseInt(diagram.concept[from].position.keyAttributes.y) + offsetY;
      return pos;
    }).attr('y2', function(d) {
      var pos, to;
      to = parseInt(d.keyAttributes['to'], 10) - 1;
      pos = parseInt(diagram.concept[to].position.keyAttributes.y, 10) + offsetY;
      return pos;
    });
    concepts = diagramGroup.selectAll('g.concept').data(diagram.concept, function(d) {
      console.log(diagram.keyAttributes.title + d.keyAttributes.id);
      return diagram.keyAttributes.title + d.keyAttributes.id;
    });
    r = d3.scale.linear().domain([
      0, d3.max(diagram.concept, function(d) {
        var _ref;
        return ((_ref = d.objectContingent.objectRef) != null ? _ref.length : void 0) || 0;
      })
    ]).range([15, 30]);
    concepts.exit().remove();
    concepts.enter().append('g').attr('transform', function(d) {
      return "translate(" + offsetX + ", " + offsetY + ")";
    }).attr('class', 'concept');
    circles = concepts.append('circle');
    circles.style('fill', function() {
      if (diagram.keyAttributes.title === "Status") {
        return 'steelblue';
      } else {
        return 'red';
      }
    }).attr('cy', function(d) {
      return +d.position.keyAttributes.y;
    }).attr('cx', function(d) {
      return +d.position.keyAttributes.x;
    }).attr('r', 30);
    return concepts.each(function(d) {
      var concept, label;
      concept = d3.select(this);
      if (d.attributeContingent.attributeRef) {
        label = concept.append('g').attr('class', 'concept-label').attr('transform', function(d) {
          var x, y, _ref, _ref1, _ref2, _ref3;
          x = parseInt(d.position.keyAttributes.x) + parseInt(((_ref = d.attributeContingent.labelStyle) != null ? (_ref1 = _ref.offset) != null ? _ref1.keyAttributes.x : void 0 : void 0) || 0) - 100 / 2;
          y = parseInt(d.position.keyAttributes.y) + parseInt(((_ref2 = d.attributeContingent.labelStyle) != null ? (_ref3 = _ref2.offset) != null ? _ref3.keyAttributes.y : void 0 : void 0) || 0) - 30 - 15;
          return "translate(" + x + ", " + y + ")";
        });
        label.append('rect').attr('width', 100).attr('height', 15).attr('fill', function(d) {
          var _ref, _ref1;
          return ((_ref = d.attributeContingent.labelStyle) != null ? (_ref1 = _ref.bgColor) != null ? _ref1["#text"] : void 0 : void 0) || "#fff";
        }).attr('stroke', "#000");
        return label.append('text').attr('fill', '#000').text(function(d) {
          var attribute;
          if (d.attributeContingent.attributeRef) {
            attribute = getAttribute(d.attributeContingent.attributeRef["#text"]);
            return attribute.keyAttributes.name;
          }
        }).attr('text-anchor', 'middle').attr('x', 50).attr('y', 12);
      }
    });
  };

}).call(this);
