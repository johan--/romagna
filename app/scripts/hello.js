(function() {
  var displayDiagram, getAttribute, lang, loadedContext, offsetX, offsetY;

  lang = 'coffeescript';

  loadedContext = null;

  offsetX = 250;

  offsetY = 300;

  getAttribute = function(id) {
    var attribute, context;
    context = loadedContext.conceptualSchema.context;
    console.log(context);
    attribute = _(context.attribute).find(function(d) {
      console.log(d);
      return d.keyAttributes.id === id;
    });
    console.log('getting attribute', id, attribute);
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
        return displayDiagram(1);
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
    var concepts, diagram, edges, r, svg;
    if (d == null) {
      d = d3.event.target.value;
    }
    svg = d3.select('svg#default-diagram');
    diagram = loadedContext.conceptualSchema.diagram[+d];
    concepts = svg.selectAll('circle').data(diagram.concept, function(d) {
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
    concepts.enter().append('circle').style('fill', function() {
      if (diagram.keyAttributes.title === "Status") {
        return 'steelblue';
      } else {
        return 'red';
      }
    }).attr('cy', function(d) {
      return +d.position.keyAttributes.y + offsetY;
    }).attr('cx', function(d) {
      return +d.position.keyAttributes.x + offsetX;
    }).attr('r', 30);
    edges = svg.selectAll('line').data(diagram.edge, function(d) {
      return "" + diagram.keyAttributes.title + "-" + d.keyAttributes.from + "-" + d.keyAttributes.to;
    });
    edges.enter().append('line').style('stroke', function(d) {
      if (diagram.keyAttributes.title) {
        return 'black';
      } else {
        return '#333';
      }
    }).style('stroke-width', 2).attr('x1', function(d) {
      var from, pos;
      from = parseInt(d.keyAttributes['from'], 10) - 1;
      console.log(from, diagram.concept);
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
    return edges.exit().remove();
  };

  console.log("'Allo from " + lang + "!");

}).call(this);
