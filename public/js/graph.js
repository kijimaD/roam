d3.json("js/graph.json").then(function(data) {
    // Canvas size
    height = 1000;
    width = 2000;
    scale = 1.0;
    // Radius function for nodes. Node radius are function of centrality
    radius = d => {
        if (!d.radius) {
            d.radius = 11 + 24 * Math.pow(d.centrality, 9/5);
        }
        return d.radius;
    };
    color = "#ffffff";

    // Number of colors is the number of clusters (given by communityLabel)
    num_colors = Math.max(...data.nodes.map(d => d.communityLabel)) + 1;
    angleArr = [...Array(num_colors).keys()].map(x => 2 * Math.PI * x / num_colors);
    // Cluster centers around an circle
    centersx = angleArr.map(x => Math.cos(Math.PI + x));
    centersy = angleArr.map(x => Math.sin(Math.PI + x));
    // Color palette
    nodeColors = [
        '#000080',
        '#00008b',
        '#0000cd',
        '#0000ee',
        '#0000ff',
        '#006400',
        '#00688b',
        '#00868b',
        '#008b00',
        '#008b45',
        '#008b8b',
        '#009acd',
        '#00b2ee',
        '#00bfff',
        '#00c5cd',
        '#00cd00',
        '#00cd66',
        '#00cdcd',
        '#00ced1',
        '#00e5ee',
        '#00ee00',
        '#00ee76',
        '#00eeee',
        '#00f5ff',
        '#00fa9a',
        '#00ff00',
        '#00ff7f',
        '#00ffff',
        '#030303',
        '#050505',
        '#080808',
        '#0a0a0a',
        '#0d0d0d',
        '#0f0f0f',
        '#104e8b',
        '#121212',
        '#141414',
        '#171717',
        '#1874cd',
        '#191970',
        '#1a1a1a',
        '#1c1c1c',
        '#1c86ee',
        '#1e90ff',
        '#1f1f1f',
        '#20b2aa',
        '#212121',
        '#228b22',
        '#242424',
        '#262626',
        '#27408b',
        '#292929',
        '#2b2b2b',
        '#2e2e2e',
        '#2e8b57',
        '#2f4f4f',
        '#303030',
        '#32cd32',
        '#333333',
        '#363636',
        '#36648b',
        '#383838',
        '#3a5fcd',
        '#3b3b3b',
        '#3cb371',
        '#3d3d3d',
        '#404040',
        '#40e0d0',
        '#4169e1',
        '#424242',
        '#436eee',
        '#43cd80',
        '#454545',
        '#458b00',
        '#458b74',
        '#4682b4',
        '#473c8b',
        '#474747',
        '#483d8b',
        '#4876ff',
        '#48d1cc',
        '#4a4a4a',
        '#4a708b',
        '#4d4d4d',
        '#4eee94',
        '#4f4f4f',
        '#4f94cd',
        '#525252',
        '#528b8b',
        '#53868b',
        '#545454',
        '#548b54',
        '#54ff9f',
        '#551a8b',
        '#556b2f',
        '#575757',
        '#595959',
        '#5c5c5c',
        '#5cacee',
        '#5d478b',
        '#5e5e5e',
        '#5f9ea0',
        '#607b8b',
        '#616161',
        '#636363',
        '#63b8ff',
        '#6495ed',
        '#666666',
        '#668b8b',
        '#66cd00',
        '#66cdaa',
        '#68228b',
        '#68838b',
        '#6959cd',
        '#696969',
        '#698b22',
        '#698b69',
        '#6a5acd',
        '#6b6b6b',
        '#6b8e23',
        '#6c7b8b',
        '#6ca6cd',
        '#6e6e6e',
        '#6e7b8b',
        '#6e8b3d',
        '#707070',
        '#708090',
        '#737373',
        '#757575',
        '#76ee00',
        '#76eec6',
        '#778899',
        '#787878',
        '#79cdcd',
        '#7a378b',
        '#7a67ee',
        '#7a7a7a',
        '#7a8b8b',
        '#7ac5cd',
        '#7b68ee',
        '#7ccd7c',
        '#7cfc00',
        '#7d26cd',
        '#7d7d7d',
        '#7ec0ee',
        '#7f7f7f',
        '#7fff00',
        '#7fffd4',
        '#828282',
        '#836fff',
        '#838b83',
        '#838b8b',
        '#8470ff',
        '#858585',
        '#878787',
        '#87ceeb',
        '#87cefa',
        '#87ceff',
        '#8968cd',
        '#8a2be2',
        '#8a8a8a',
        '#8b0000',
        '#8b008b',
        '#8b0a50',
        '#8b1a1a',
        '#8b1c62',
        '#8b2252',
        '#8b2323',
        '#8b2500',
        '#8b3626',
        '#8b3a3a',
        '#8b3a62',
        '#8b3e2f',
        '#8b4500',
        '#8b4513',
        '#8b4726',
        '#8b475d',
        '#8b4789',
        '#8b4c39',
        '#8b5742',
        '#8b5a00',
        '#8b5a2b',
        '#8b5f65',
        '#8b636c',
        '#8b6508',
        '#8b668b',
        '#8b6914',
        '#8b6969',
        '#8b7355',
        '#8b7500',
        '#8b7765',
        '#8b795e',
        '#8b7b8b',
        '#8b7d6b',
        '#8b7d7b',
        '#8b7e66',
        '#8b814c',
        '#8b8378',
        '#8b8386',
        '#8b864e',
        '#8b8682',
        '#8b8878',
        '#8b8970',
        '#8b8989',
        '#8b8b00',
        '#8b8b7a',
        '#8b8b83',
        '#8c8c8c',
        '#8db6cd',
        '#8deeee',
        '#8ee5ee',
        '#8f8f8f',
        '#8fbc8f',
        '#90ee90',
        '#912cee',
        '#919191',
        '#9370db',
        '#9400d3',
        '#949494',
        '#969696',
        '#96cdcd',
        '#97ffff',
        '#98f5ff',
        '#98fb98',
        '#9932cc',
        '#999999',
        '#9a32cd',
        '#9ac0cd',
        '#9acd32',
        '#9aff9a',
        '#9b30ff',
        '#9bcd9b',
        '#9c9c9c',
        '#9e9e9e',
        '#9f79ee',
        '#9fb6cd',
        '#a020f0',
        '#a0522d',
        '#a1a1a1',
        '#a2b5cd',
        '#a2cd5a',
        '#a3a3a3',
        '#a4d3ee',
        '#a52a2a',
        '#a6a6a6',
        '#a8a8a8',
        '#a9a9a9',
        '#ab82ff',
        '#ababab',
        '#adadad',
        '#add8e6',
        '#adff2f',
        '#aeeeee',
        '#afeeee',
        '#b03060',
        '#b0b0b0',
        '#b0c4de',
        '#b0e0e6',
        '#b0e2ff',
        '#b22222',
        '#b23aee',
        '#b2dfee',
        '#b3b3b3',
        '#b3ee3a',
        '#b452cd',
        '#b4cdcd',
        '#b4eeb4',
        '#b5b5b5',
        '#b8860b',
        '#b8b8b8',
        '#b9d3ee',
        '#ba55d3',
        '#bababa',
        '#bbffff',
        '#bc8f8f',
        '#bcd2ee',
        '#bcee68',
        '#bdb76b',
        '#bdbdbd',
        '#bebebe',
        '#bf3eff',
        '#bfbfbf',
        '#bfefff',
        '#c0ff3e',
        '#c1cdc1',
        '#c1cdcd',
        '#c1ffc1',
        '#c2c2c2',
        '#c4c4c4',
        '#c6e2ff',
        '#c71585',
        '#c7c7c7',
        '#c9c9c9',
        '#cae1ff',
        '#caff70',
        '#cccccc',
        '#cd0000',
        '#cd00cd',
        '#cd1076',
        '#cd2626',
        '#cd2990',
        '#cd3278',
        '#cd3333',
        '#cd3700',
        '#cd4f39',
        '#cd5555',
        '#cd5b45',
        '#cd5c5c',
        '#cd6090',
        '#cd6600',
        '#cd661d',
        '#cd6839',
        '#cd6889',
        '#cd69c9',
        '#cd7054',
        '#cd8162',
        '#cd8500',
        '#cd853f',
        '#cd8c95',
        '#cd919e',
        '#cd950c',
        '#cd96cd',
        '#cd9b1d',
        '#cd9b9b',
        '#cdaa7d',
        '#cdad00',
        '#cdaf95',
        '#cdb38b',
        '#cdb5cd',
        '#cdb79e',
        '#cdb7b5',
        '#cdba96',
        '#cdbe70',
        '#cdc0b0',
        '#cdc1c5',
        '#cdc5bf',
        '#cdc673',
        '#cdc8b1',
        '#cdc9a5',
        '#cdc9c9',
        '#cdcd00',
        '#cdcdb4',
        '#cdcdc1',
        '#cfcfcf',
        '#d02090',
        '#d15fee',
        '#d1d1d1',
        '#d1eeee',
        '#d2691e',
        '#d2b48c',
        '#d3d3d3',
        '#d4d4d4',
        '#d6d6d6',
        '#d8bfd8',
        '#d9d9d9',
        '#da70d6',
        '#daa520',
        '#db7093',
        '#dbdbdb',
        '#dcdcdc',
        '#dda0dd',
        '#deb887',
        '#dedede',
        '#e066ff',
        '#e0e0e0',
        '#e0eee0',
        '#e0eeee',
        '#e0ffff',
        '#e3e3e3',
        '#e5e5e5',
        '#e6e6fa',
        '#e8e8e8',
        '#e9967a',
        '#ebebeb',
        '#ededed',
        '#ee0000',
        '#ee00ee',
        '#ee1289',
        '#ee2c2c',
        '#ee30a7',
        '#ee3a8c',
        '#ee3b3b',
        '#ee4000',
        '#ee5c42',
        '#ee6363',
        '#ee6a50',
        '#ee6aa7',
        '#ee7600',
        '#ee7621',
        '#ee7942',
        '#ee799f',
        '#ee7ae9',
        '#ee8262',
        '#ee82ee',
        '#ee9572',
        '#ee9a00',
        '#ee9a49',
        '#eea2ad',
        '#eea9b8',
        '#eead0e',
        '#eeaeee',
        '#eeb422',
        '#eeb4b4',
        '#eec591',
        '#eec900',
        '#eecbad',
        '#eecfa1',
        '#eed2ee',
        '#eed5b7',
        '#eed5d2',
        '#eed8ae',
        '#eedc82',
        '#eedd82',
        '#eedfcc',
        '#eee0e5',
        '#eee5de',
        '#eee685',
        '#eee8aa',
        '#eee8cd',
        '#eee9bf',
        '#eee9e9',
        '#eeee00',
        '#eeeed1',
        '#eeeee0',
        '#f08080',
        '#f0e68c',
        '#f0f0f0',
        '#f0f8ff',
        '#f0fff0',
        '#f0ffff',
        '#f2f2f2',
        '#f4a460',
        '#f5deb3',
        '#f5f5dc',
        '#f5f5f5',
        '#f5fffa',
        '#f7f7f7',
        '#f8f8ff',
        '#fa8072',
        '#faebd7',
        '#faf0e6',
        '#fafad2',
        '#fafafa',
        '#fcfcfc',
        '#fdf5e6',
        '#ff0000',
        '#ff00ff',
        '#ff1493',
        '#ff3030',
        '#ff34b3',
        '#ff3e96',
        '#ff4040',
        '#ff4500',
        '#ff6347',
        '#ff69b4',
        '#ff6a6a',
        '#ff6eb4',
        '#ff7256',
        '#ff7f00',
        '#ff7f24',
        '#ff7f50',
        '#ff8247',
        '#ff82ab',
        '#ff83fa',
        '#ff8c00',
        '#ff8c69',
        '#ffa07a',
        '#ffa500',
        '#ffa54f',
        '#ffaeb9',
        '#ffb5c5',
        '#ffb6c1',
        '#ffb90f',
        '#ffbbff',
        '#ffc0cb',
        '#ffc125',
        '#ffc1c1',
        '#ffd39b',
        '#ffd700',
        '#ffdab9',
        '#ffdead',
        '#ffe1ff',
        '#ffe4b5',
        '#ffe4c4',
        '#ffe4e1',
        '#ffe7ba',
        '#ffebcd',
        '#ffec8b',
        '#ffefd5',
        '#ffefdb',
        '#fff0f5',
        '#fff5ee',
        '#fff68f',
        '#fff8dc',
        '#fffacd',
        '#fffaf0',
        '#fffafa',
        '#ffff00',
        '#ffffe0',
        '#fffff0',
    ];
    // Color function just maps cluster to color palette
    nodeColor = d => {
        return nodeColors[d.communityLabel];
    };
    // Make the nodes draggable
    drag = simulation => {
        function dragsubject(event) {
            return simulation.find(event.x, event.y);
        }

        function dragstarted(event) {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            event.subject.fx = event.subject.x;
            event.subject.fy = event.subject.y;        }

        function dragged(event) {
            event.subject.fx = event.x;
            event.subject.fy = event.y;
        }

        function dragended(event) {
            if (!event.active) simulation.alphaTarget(0);
            event.subject.fx = null;
            event.subject.fy = null;
        }

        return d3.drag()
            .subject(dragsubject)
            .on("start", dragstarted)
            .on("drag", dragged)
            .on("end", dragended);
    };
    // Make nodes interactive to hovering
    handleMouseOver = (d, i) => {
        nde = d3.select(d.currentTarget);
        nde.attr("fill", "#999")
            .attr("r", nde.attr("r") * 1.4);

        d3.selectAll("text")
            .filter('#' + CSS.escape(d.currentTarget.id))
            .style("font-size", "2em");

        d3.selectAll("line")
            .attr("stroke-width", 1);

        d3.selectAll("line")
            .filter((l, _) => {
                return l && l.source && l.source.index == i.index || l && l.target && l.target.index == i.index
            })
            .attr("stroke-width", 8);
    };
    handleMouseOut = (d, _) => {
        nde = d3.select(d.currentTarget);
        nde.attr("fill", nodeColor)
            .attr("r", nde.attr("r") / 1.4);

        d3.selectAll("text")
            .filter('#' + CSS.escape(d.currentTarget.id))
            .style("font-size", "1em");

        d3.selectAll("line")
            .attr("stroke-width", 1);
    };

    // Graph data
    const links = data.links.map(d => Object.create(d));
    const nodes = data.nodes.map(d => Object.create(d));

    // Force simulation for the graph
    simulation = d3.forceSimulation(nodes)
        .alpha(0.9)
        .velocityDecay(0.6)
        .force("link", d3.forceLink(links).id(d => d.id).strength(.1))
        .force("charge", d3.forceManyBody()
               .strength(-500))
        .force('collision',
               d3.forceCollide().radius(d => radius(d) * 1.2).strength(1.5))
        .force('x', d3.forceX().x(function(d) {
            return width / 2 +  (width / 4) * centersx[d.communityLabel];
        }).strength(0.25))
        .force('y', d3.forceY().y(function(d) {
            return height / 2 +  (height / 8) * centersy[d.communityLabel];
        }).strength(0.25));

    // Create all the graph elements
    const svg = d3.select("svg")
          .attr('max-width', '60%')
          .attr('class', 'node-graph')
          .attr("viewBox", [0, 0, width, height]);

    const link = svg.append("g")
          .attr("stroke", "#888")
          .attr("stroke-opacity", 0.6)
          .selectAll("line")
          .data(links)
          .join("line")
          .attr("stroke-dasharray", d => (d.predicted? "5,5": "0,0"))
          .attr("stroke-width", 1);

    const node = svg.append("g")
          .selectAll("circle")
          .data(nodes)
          .join("a")
          .attr("xlink:href", d => {
              return "./" + d.lnk;
          })
          .attr("id", d => "circle_" + d.lnk)
          .append("circle")
          .attr("id", d => d.id.toLowerCase())
          .attr("r", radius)
          .attr("fill", nodeColor)
          .on("mouseover", handleMouseOver)
          .on("mouseout", handleMouseOut)
          .call(drag(simulation));

    node.append("title")
        .text(d => d.label.replace(/"/g, ''));

    // Nodes have a label that is visible on hover
    // They have two layers a rectangle "background" and the text on top
    const label = svg.append("g")
          .selectAll("text")
          .data(nodes)
          .join("g");
    const label_background = label.append("text")
          .style("font-size", "45px")
          .text(function (d) { return "  "+ d.label.replace(/"/g, '') + "  "; })
          .attr("dy", -30)
          .attr("id", d => d.id.toLowerCase())
          .attr("class", "node_label")
          .style("display", "none")
          .style("pointer-events", "none")
          .style("alignment-baseline", "middle")
    // .attr("filter", "url(#solid)");
    const label_text = label.append("text")
          .style("fill", "#222")
          .style("font-size", "15px")
          .text(function (d) { return "  "+ d.label.replace(/"/g, '') + "  "; })
          .attr("dy", -12)
          .attr("id", d => d.id.toLowerCase())
          .attr("class", "node_label")

    // Run the simulation
    simulation.on("tick", () => {
        link.attr("x1", d => d.source.x)
            .attr("y1", d => d.source.y)
            .attr("x2", d => d.target.x)
            .attr("y2", d => d.target.y);

        node.attr("cx", d => d.x)
            .attr("cy", d => d.y);

        label_text.attr("x", d => d.x)
            .attr("y", d => d.y);

        label_background.attr("x", d => d.x)
            .attr("y", d => d.y);
    });
});
