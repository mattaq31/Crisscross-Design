document.addEventListener('DOMContentLoaded', () => {
    const layerList = document.getElementById('layer-list');
    const addLayerButton = document.getElementById('add-layer');

    addLayerButton.addEventListener('click', () => {
        addLayer();
    });

    function addLayer() {
        const layerItem = document.createElement('div');
        layerItem.className = 'layer-item';

        const layerCheckbox = document.createElement('input');
        layerCheckbox.type = 'checkbox';
        layerCheckbox.checked = true;
        layerCheckbox.addEventListener('change', toggleLayer);

        const layerName = document.createElement('span');
        layerName.textContent = `Layer ${layerList.children.length + 1}`;

        const layerRadio = document.createElement('input');
        layerRadio.type = 'radio';
        layerRadio.name = 'active-layer';
        layerRadio.addEventListener('change', setActiveLayer);

        const removeButton = document.createElement('button');
        removeButton.textContent = 'Remove';
        removeButton.addEventListener('click', () => {
            layerList.removeChild(layerItem);
        });

        layerItem.appendChild(layerCheckbox);
        layerItem.appendChild(layerRadio);
        layerItem.appendChild(layerName);
        layerItem.appendChild(removeButton);
        layerList.appendChild(layerItem);

        // Set the first added layer as active by default
        if (layerList.children.length === 1) {
            layerRadio.checked = true;
            setActiveLayer({ target: layerRadio });
        }
    }

    function toggleLayer(event) {
        const layerItem = event.target.parentElement;
        if (event.target.checked) {
            layerItem.classList.remove('disabled');
        } else {
            layerItem.classList.add('disabled');
        }
    }

    function setActiveLayer(event) {
        const allLayers = document.querySelectorAll('.layer-item');
        allLayers.forEach(layer => layer.classList.remove('active'));

        const activeLayer = event.target.parentElement;
        activeLayer.classList.add('active');
    }

    // Add initial layers
    addLayer();
    addLayer();

});
