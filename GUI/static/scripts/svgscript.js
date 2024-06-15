///////////////////////////////
//     Global Variables!     //
///////////////////////////////

//Configure grid
var minorGridSize = 10;                 //Size of minor grid squares
var majorGridSize = 5*minorGridSize;    //Size of major grid squares
var gridStyle = 1;                      //0 for off, 1 for grid, 2 for dots

//For dragging
let dragSelectedElement = null;         //Item selected to drag
let dragOffset = { x: 0, y: 0 };        //Offset between mouse position and item position

//For adding elements
let placeRoundedX = 0;                  //Snapped position of mouse (X)
let placeRoundedY = 0;                  //Snapped posiiton of mouse (Y)

//For drag & drop
var activeLayer = null;

//Layers
let layerList = new Map();
let layerArray = null

//Opacity
let shownOpacity = 0.7
let hiddenOpacity = 0.2

let placeHorizontal = false;


///////////////////////////////
//     Helper Functions!     //
///////////////////////////////

//Draw grid:
function drawGrid(gridGroup, width, height, style, majorSize, minorSize) {
    //Grid style: 
        //0 corresponds to no grid
        //1 corresponds to normal grid
        //2 corresponds to dot grid
    
    //First reset grid:
    gridGroup.clear()

    //Now draw the grid itself:
    if(style != 0){
        // Draw vertical lines
        //Minor
        for (var x = 0; x < width; x += minorSize) {
            let tmpLine = gridGroup.line(x, 0, x, height).stroke({ width: 0.5, color:'#000'})
            if(style==2){
                tmpLine.stroke({dasharray:`${minorSize*0.1},${minorSize*0.9}`, dashoffset:`${minorSize*0.05}`})
            }
        }

        //Major
        for (var x = 0; x < width; x += majorSize) {
            let tmpLine = gridGroup.line(x, 0, x, height).stroke({ width: 1, color:'#000' })
            if(style==2){
                tmpLine.stroke({dasharray:`${majorSize*0.05},${majorSize*0.95}`, dashoffset:`${majorSize*0.025}`})
            }
        }

        // Draw horizontal lines
        //Minor
        for (var y = 0; y < height; y += minorSize) {
            let tmpLine = gridGroup.line(0, y, width, y).stroke({ width: 0.5, color:'#000'})
            if(style==2){
                tmpLine.stroke({dasharray:`${minorSize*0.1},${minorSize*0.9}`, dashoffset:`${minorSize*0.05}`})
            }
        }

        //Major
        for (var y = 0; y < height; y += majorSize) {
            let tmpLine = gridGroup.line(0, y, width, y).stroke({ width: 1, color:'#000' })
            if(style==2){
                tmpLine.stroke({dasharray:`${majorSize*0.05},${majorSize*0.95}`, dashoffset:`${majorSize*0.025}`})
            }
        }
    }
    
    
    return gridGroup;
  }


// Check if a point is on any existing line
function isPointOnLine(Layer, x, y, selectedLine = false) {
    const lines = Layer.find('.line');
    return lines.some(line => {
      
      //Check if overlapping with any lines in general
        const bbox = line.bbox();
        let onOther = (x >= bbox.x && x <= bbox.x2 && y >= bbox.y && y <= bbox.y2)
      
      //Check if overlapping with self (but only if a self is given!)
        let selfBbox = null;
        let onItself = false
        if(selectedLine){
            selfBbox = selectedLine.bbox();
            onItself = (x >= selfBbox.x && x <= selfBbox.x2 && y >= selfBbox.y && y <= selfBbox.y2)
        }
      
      return (
        onOther && (!onItself)
      );
    });
  }


function isLineOnLine(startX, startY, layer, GridSize, selectedLine) {
    const x1 = selectedLine.attr('x1');
    const y1 = selectedLine.attr('y1');
    const x2 = selectedLine.attr('x2');
    const y2 = selectedLine.attr('y2');

    //console.log("selected line is: "+x1 + ","+y1+" to "+x2+","+y2)

    let dX = x2-x1;
    let dY = y2-y1

    const lineLength = Math.sqrt(dX * dX + dY * dY)
    const numPoints = Math.floor(lineLength/GridSize)

    let overlap = false

    for (let i = 0; i<= numPoints; i++) {
        const ratio = i / numPoints;
        let x = startX + ratio * dX
        let y = startY + ratio * dY
        overlap = overlap || isPointOnLine(layer, x, y, selectedLine)
    }

    return overlap


}


function willVertBeOnLine(startX, startY, layer, gridSize, length=32){
    let overlap = false
    for (let i = 0; i<= length; i++) {
        let x = startX 
        let y = startY + i*gridSize
        overlap = overlap || isPointOnLine(layer, x, y)
    }
    return overlap
}

function willHorzBeOnLine(startX, startY, layer, gridSize, length=32){
    let overlap = false
    for (let i = 0; i<= length; i++) {
        let x = startX + i*gridSize
        let y = startY 
        overlap = overlap || isPointOnLine(layer, x, y)
    }
    return overlap
}


///////////////////////////////
//       Drag and Drop       //
///////////////////////////////


//Start dragging
function startDrag(event) {
        
    dragSelectedElement = event.target.instance;

    if(activeLayer.children().includes(dragSelectedElement)){
        const point = dragSelectedElement.point(event.clientX, event.clientY);
    
        dragOffset.x = point.x - dragSelectedElement.x();
        dragOffset.y = point.y - dragSelectedElement.y();

        // Add event listeners for drag and end drag
        document.addEventListener('pointermove', drag)
        document.addEventListener('pointerup', endDrag);
    }

        
  }

//Actually drag the element
function drag(event) {
    if (dragSelectedElement) {
        let point = dragSelectedElement.point(event.clientX, event.clientY) 
        point.x = point.x - dragOffset.x
        point.y = point.y - dragOffset.y
        let roundedX = Math.round(point.x/(minorGridSize))*minorGridSize ;
        let roundedY = Math.round(point.y/(minorGridSize))*minorGridSize ;   

        //if(!isPointOnLine(activeLayer, roundedX, roundedY, dragSelectedElement)   && !isPointOnLine(activeLayer, roundedX, roundedY + 32 * minorGridSize, dragSelectedElement)){
        //    dragSelectedElement.move(roundedX, roundedY);
        //}

        if(!isLineOnLine(roundedX, roundedY, activeLayer,minorGridSize, dragSelectedElement)) {
            dragSelectedElement.move(roundedX, roundedY);
        }

        console.log("Im moving!")
    }
}


// Function to end dragging
function endDrag() {
    
    console.log("Dragging ended!")
    dragSelectedElement = null;
    dragOffset.x = 0
    dragOffset.y = 0

    // Remove event listeners for drag and end drag
    document.removeEventListener('pointermove', drag);
    document.removeEventListener('pointerup', endDrag);
  }



  
///////////////////////////////
//         Main Code!        //
///////////////////////////////

SVG.on(document, 'DOMContentLoaded', function() {
    
    //Configure Grid
    
    var width = document.getElementById('svg-container').getBoundingClientRect().width
    var height = document.getElementById('svg-container').getBoundingClientRect().height
    var fullDrawing = SVG().addTo('#svg-container').size(width, height)
    
    //Layers
    var drawGridLayer = fullDrawing.group();
    //var draw = fullDrawing.group();
    //activeLayer = draw

    //Initialize Grid
    drawGrid(drawGridLayer, width, height, gridStyle, majorGridSize, minorGridSize)

    
    //Calibration Figures to Mark Locations
    //draw.rect(100,100).attr({fill: '#f00'}).move(0.25*width,0.25*height).draggable()
    //draw.rect(100,100).attr({fill: '#ff0'}).move(0.5*width,0.5*height).draggable().onClick = function() { console.log("clicked!"); };


    //Change grid configuration by radio buttons
        //Get radio buttons
        var radios = document.querySelectorAll('input[name="graphMode');

        //Add a change event listener to each radio button:
        radios.forEach(function(radio) {
            radio.addEventListener('change', function() {
                gridStyle = this.value;
                drawGrid(drawGridLayer, width, height, gridStyle, majorGridSize, minorGridSize)

            })
        })


    const svgcontainer = document.getElementById('svg-container')
    
    
    const panzoom = Panzoom(svgcontainer, {
        maxScale: 5,
        minScale: 0.25,
        contain: "outside",
      })
    
    //Turn of pan by default
    let disablePanStatus = true; 

    //Initial setup: Zoom & Pan
    setTimeout(() => {
        panzoom.pan(-width/4,-height/4);
        panzoom.setOptions({ disablePan: disablePanStatus });
        panzoom.zoom(2)
    });
    

    //Allow zoom with touchpad
    svgcontainer.parentElement.addEventListener('wheel', panzoom.zoomWithWheel)

    // Event listener to enable pan only when shift is down
    document.addEventListener('keydown', (event) => {
        if( event.key === 'Shift') {
            disablePanStatus = false;
            panzoom.setOptions({ disablePan: disablePanStatus })
        }
    });

    // Turn off pan when shift key is lifted
    document.addEventListener('keyup', (event) => {
        if( event.key === 'Shift') {
            disablePanStatus = true;
            panzoom.setOptions({ disablePan: disablePanStatus })
        }
    });

    // Place horiztonal slats instead of vertical when alt is down
    document.addEventListener('keydown', (event) => {
        if( event.key === 'Alt') {
            placeHorizontal = true;
        }
    });

    // Place vertical slats instead of horizontal when alt is up
    document.addEventListener('keyup', (event) => {
        if( event.key === 'Alt') {
            placeHorizontal = false;
        }
    });
    




    const targetElement = document.getElementById('svg-container');
    
    // Event listener to track mouse movement over the target element
    targetElement.addEventListener('mousemove', (event) => {
        // Calculate mouse position relative to the element
        let selectedElement = event.target.instance;
        let mousePoints = selectedElement.point(event.clientX, event.clientY);
        
        placeRoundedX = Math.round(mousePoints.x/(minorGridSize))*minorGridSize ;
        placeRoundedY = Math.round(mousePoints.y/(minorGridSize))*minorGridSize ;
    });




    //ID counter for slat IDs
    let slatCounter = 0;

    // Event listener to print slat when mouse is pressed
    targetElement.addEventListener('pointerdown', (event) => {
        if(disablePanStatus == true){
            console.log(`Rounded mouse position - X: ${placeRoundedX}, Y: ${placeRoundedY}`);

            if(!placeHorizontal){
                if(!willVertBeOnLine(placeRoundedX, placeRoundedY, activeLayer, minorGridSize, 32)) {
                    //if(!isPointOnLine(activeLayer, placeRoundedX, placeRoundedY)   && !isPointOnLine(activeLayer, placeRoundedX, placeRoundedY + 32 * minorGridSize)){
                        let tmpLine = activeLayer.line(placeRoundedX, placeRoundedY, placeRoundedX, placeRoundedY + 32 * minorGridSize)
                                                 .stroke({ width: 3, color:'#076900', opacity: shownOpacity });
                        tmpLine.attr('id','ID-L'+'-N' + slatCounter)
                        tmpLine.attr('class',"line")
                        tmpLine.attr({ 'pointer-events': 'stroke' })
                        slatCounter += 1;
        
                        //Adding draggability:
                        tmpLine.on('pointerdown', startDrag)
                    }
            }
            else if(placeHorizontal){
                if(!willHorzBeOnLine(placeRoundedX, placeRoundedY, activeLayer, minorGridSize, 32)) {
                    //if(!isPointOnLine(activeLayer, placeRoundedX, placeRoundedY)   && !isPointOnLine(activeLayer, placeRoundedX, placeRoundedY + 32 * minorGridSize)){
                        let tmpLine = activeLayer.line(placeRoundedX, placeRoundedY, placeRoundedX + 32 * minorGridSize, placeRoundedY )
                                                 .stroke({ width: 3, color:'#836108', opacity: shownOpacity });
                        tmpLine.attr('id','ID-L'+'-N' + slatCounter)
                        tmpLine.attr('class',"line")
                        tmpLine.attr({ 'pointer-events': 'stroke' })
                        slatCounter += 1;
        
                        //Adding draggability:
                        tmpLine.on('pointerdown', startDrag)
                    }
            }
            
            

        }        
    });


    //Layers Event Listeners
    document.addEventListener('layerAdded', (event) => {
        console.log(`Layer added: ${event.detail.layerId}`, event.detail.layerElement);
        //Layer added
        layerList.set(event.detail.layerId, fullDrawing.group());
    });

    document.addEventListener('layerRemoved', (event) => {
        console.log(`Layer removed: ${event.detail.layerId}`, event.detail.layerElement);
        //Layer removed
        layerList.get(event.detail.layerId).remove()
        layerList.delete(event.detail.layerId)
    });

    document.addEventListener('layerShown', (event) => {
        console.log(`Layer shown: ${event.detail.layerId}`, event.detail.layerElement);
        // Handle layer shown
        layerList.get(event.detail.layerId).attr('opacity',shownOpacity)
    });

    document.addEventListener('layerHidden', (event) => {
        console.log(`Layer hidden: ${event.detail.layerId}`, event.detail.layerElement);
        // Handle layer hidden
        layerList.get(event.detail.layerId).attr('opacity',hiddenOpacity)
        
    });

    document.addEventListener('layerMarkedActive', (event) => {
        console.log(`Layer marked active: ${event.detail.layerId}`, event.detail.layerElement);
        // Handle layer marked active
        activeLayer = layerList.get(event.detail.layerId)


    });
        






})
    

