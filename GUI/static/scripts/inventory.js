let drivers = []; // List of drivers
let plateNames = [];
let plateToDriverMap = {};

// Sample inventory data
let inventoryData = [
    {id: "default_GFP", name: "Green Fluorescent Protein", tag: "GFP", color: "#00FF00", plate: "", driver: ""},
    {id: "default_RFP", name: "Red Fluorescent Protein", tag: "RFP", color: "#FF0000", plate: "", driver: ""},
    {id: "default_AB1", name: "Antibody 1", tag: "Ab1", color: "#0000FF", plate: "", driver: ""},
    {id: "default_AB2", name: "Antibody 2", tag: "Ab2", color: "#FFFF00", plate: "", driver: ""},
    {id: "default_DH", name: "Dummy Handle", tag: "DH", color: "#FF00FF", plate: "", driver: ""}
];

updatePlateDrivers("C:\\Users\\cmbec\\OneDrive\\Cloud_Documents\\Shih_Lab_2024\\Crisscross-Design\\GUI\\used-cargo-plates")
updateInventoryItems("C:\\Users\\cmbec\\OneDrive\\Cloud_Documents\\Shih_Lab_2024\\Crisscross-Design\\GUI\\used-cargo-plates")
renderInventoryTable() 


// Function to get all inventory items
export function updateInventoryItems(filepath, driverDict) {
    var socket = io();
    socket.emit('get_inventory', filepath, driverDict)
    socket.on('inventory_sent', function(inventory) {
        console.log("Imported inventory!", inventory)
        inventoryData = inventory
    });
}


/**
 * TODO: fill in
 * @param id
 * @returns {{color: string, tag: string, name: string, id: number} | {color: string, tag: string, name: string, id: number} | {color: string, tag: string, name: string, id: number} | {color: string, tag: string, name: string, id: number} | {color: string, tag: string, name: string, id: number}}
 */
// Function to get a specific inventory item by ID
export function getInventoryItemById(id) {
    return inventoryData.find(item => item.id === id);
}

/**
 * TODO: fill in
 */
// Function to populate the cargo palette
export function populateCargoPalette() {
    const cargoOptions = document.getElementById('cargo-options');
    cargoOptions.innerHTML = ''; // Clear existing options

    // Calculate 1/5th of the parent's width
    const paletteWidth = cargoOptions.offsetWidth;
    const optionSize = paletteWidth / 5;


    inventoryData.forEach(item => {
        const option = document.createElement('div');
        option.className = 'cargo-option';

        option.style.width = `${optionSize}px`;
        option.style.height = `${optionSize}px`;
        option.style.backgroundColor = 'lightgrey';
        option.style.borderRadius = '5px'

        option.dataset.id = item.id;
        option.title = item.name;

        const draw = SVG().addTo(option).size(optionSize, optionSize);
        draw.attr('pointer-events', 'none')
        let radius = optionSize * 0.33
        draw.circle(radius * 2).attr({
            cx: optionSize / 2,
            cy: optionSize / 2,
            fill: item.color, // Example color for the circle
            stroke: 'black'
        });

        let text = draw.text(item.tag)
            .attr({x: optionSize / 2, y: optionSize / 2, 'dominant-baseline': 'middle', 'text-anchor': 'middle'})
            .attr({'stroke-width': radius / 20})
            .font({size: radius * 0.4, family: 'Arial', weight: 'bold', stroke: '#000000'})
            .fill('#FFFFFF'); // White text
        text.attr('pointer-events', 'none');


        // Function to adjust text size
        function adjustTextSize() {
            let fontSize = radius;
            text.font({size: fontSize});

            while (text.bbox().width > 1.8 * radius ) {
                fontSize *= 0.9;
                text.font({size: fontSize});
                
            }
        }

        
        console.log("Adjusting font size!")
        adjustTextSize();

        cargoOptions.appendChild(option);
    });


    const editCargo = document.createElement('div');
    editCargo.id = 'cargo-editor';

    editCargo.style.width = `${optionSize}px`;
    editCargo.style.height = `${optionSize}px`;
    editCargo.style.backgroundColor = 'lightgrey';
    editCargo.style.borderRadius = '5px'

    editCargo.title = 'Edit cargo options';
    editCargo.textContent = 'Edit'
    editCargo.style.fontSize = `${optionSize * 0.33}px`
    editCargo.style.display = 'flex'
    editCargo.style.justifyContent = "center"
    editCargo.style.alignItems = "center"
    cargoOptions.appendChild(editCargo)

}

/**
 * TODO: fill in
 * @param name
 * @param tag
 * @param color
 * @returns {{color, tag, name, id: (number|number)}}
 */
// Function to add a new inventory item
export function addInventoryItem(name, tag, color, plate, driver) {
    const newId = inventoryData.length + 1;
    const newItem = {
        id: newId,
        name: name,
        tag: tag,
        color: color,
        plate: plate,
        driver: driver
    };
    inventoryData.push(newItem);
    populateCargoPalette();
    renderInventoryTable();
    return newItem;
}


/**
 * TODO: fill in
 * @param id
 */
// Function to remove an item
function removeItem(id) {
    inventoryData = inventoryData.filter(item => item.id !== id);
    populateCargoPalette();
    renderInventoryTable();
}

/**
 * TODO: fill in
 */
// Function to render the inventory table
export function renderInventoryTable() {
    const tableBody = document.getElementById('inventoryTableBody');
    tableBody.innerHTML = '';

    inventoryData.forEach(item => {
        const row = tableBody.insertRow();
        row.innerHTML = `
            <td>${item.id}</td>
            <td><input type="text" value="${item.name}" name="name" style="width: 100px;"></td>
            <td><input type="text" value="${item.tag}" name="tag" style="width: 100px;"></td>
            <td><input type="color" value="${item.color}" name="color"></td>
            <td>${item.plate}</td>
            <td>${item.driver}</td>
            <td>
                <button id="inventory-remove-item">Remove</button>
            </td>
        `;

        // Add event listeners to inputs
        const nameInput = row.querySelector('input[name="name"]');
        const tagInput = row.querySelector('input[name="tag"]');
        const colorInput = row.querySelector('input[name="color"]');
        const removeButton = row.querySelector('#inventory-remove-item');

        nameInput.addEventListener('input', (event) => {
            console.log(`Name changed to: ${event.target.value}`);
            item.name = event.target.value
            populateCargoPalette()
        });

        tagInput.addEventListener('input', (event) => {
            console.log(`Tag changed to: ${event.target.value}`);
            item.tag = event.target.value
            populateCargoPalette()

            const elementsWithSpecificCargoId = document.querySelectorAll(`[data-cargo-Id="${item.id}"]`);

            // Loop through the selected elements
            elementsWithSpecificCargoId.forEach(element => {
                const circle = element.querySelectorAll(`[data-cargo-component="circle"]`)[0]
                const text = element.querySelectorAll(`[data-cargo-component="text"]`)[0]
                console.log(text)
                text.firstChild.textContent = item.tag; //We need to do child bc there is a tspan in the <text> element...
            });
        });

        colorInput.addEventListener('input', (event) => {
            console.log(`Color changed to: ${event.target.value}`);
            item.color = event.target.value
            populateCargoPalette()

            const elementsWithSpecificCargoId = document.querySelectorAll(`[data-cargo-Id="${item.id}"]`);

            // Loop through the selected elements
            elementsWithSpecificCargoId.forEach(element => {
                const circle = element.querySelectorAll(`[data-cargo-component="circle"]`)[0]
                const text = element.querySelectorAll(`[data-cargo-component="text"]`)[0]
                circle.setAttribute('fill', item.color);
            });
        });

        removeButton.addEventListener('click', (event) => {
            const elementsWithSpecificCargoId = document.querySelectorAll(`[data-cargo-Id="${item.id}"]`);

            // Loop through the selected elements
            elementsWithSpecificCargoId.forEach(element => {
                element.remove()
            });

            removeItem(item.id)

            console.log(`Item to remove: ${item.id}`);
        });
    });
}







function updatePlateDrivers(filepath){
    var socket = io();
    socket.emit('get_drivers', filepath)
    socket.on('drivers_sent', function(plates){
        drivers = plates[0]
        plateNames = plates[1]

        return 1;
    })

}


export function renderMappingTable() {
    const tableBody = document.getElementById('plate-mapping-table');
    tableBody.innerHTML = '';

    updatePlateDrivers("C:\\Users\\cmbec\\OneDrive\\Cloud_Documents\\Shih_Lab_2024\\Crisscross-Design\\GUI\\used-cargo-plates")

    plateNames.forEach(plate =>{
        const row = tableBody.insertRow();
        row.innerHTML = `
            <td class="plate-name">${plate}</td>
            <td>
                <select name="driver-selector" style="width: 100px;">
                    <option value=""></option>
                    ${drivers.map(driver => `<option value="${driver}">${driver}</option>`).join('')}
                </select>
            </td>
        `;

        const driverSelector = row.querySelector('select[name="driver-selector"]');
        driverSelector.addEventListener('change', (event) =>{
            plateToDriverMap[plate] = event.target.value

            if(event.target.value == ""){
                delete plateToDriverMap[plate]
            }

            console.log("New Plate-Driver Map: ", plateToDriverMap)
            updateInventoryItems("C:\\Users\\cmbec\\OneDrive\\Cloud_Documents\\Shih_Lab_2024\\Crisscross-Design\\GUI\\used-cargo-plates", plateToDriverMap)

        })

    })

}
