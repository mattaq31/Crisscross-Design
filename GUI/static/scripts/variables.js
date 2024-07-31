var activeLayerId = null;
var activeLayerColor = null;

var activeHandleLayer = null;
var activeSlatLayer   = null;
var activeCargoLayer  = null;
var activeTopCargoLayer = null;
var activeBottomCargoLayer = null;

let placeHorizontal = false;

let selectedCargoId = null;

let slatCounter = 1;
let cargoCounter = 1;

let drawSlatCargoHandleMode = 0;    //0: slats, 1: cargo, 2: handles
var gridStyle = 2;                  //0: none,  1: grid   2: dots

//Dictionary for all global variables
let variables = {
    "activeLayerId" : activeLayerId,
    "activeLayerColor": activeLayerColor,
    "activeHandleLayer":activeHandleLayer,
    "activeSlatLayer": activeSlatLayer,
    "activeCargoLayer": activeCargoLayer,
    "activeTopCargoLayer": activeTopCargoLayer,
    "activeBottomCargoLayer": activeBottomCargoLayer,
    "placeHorizontal": placeHorizontal,
    "selectedCargoId": selectedCargoId,
    "slatCounter": slatCounter,
    "cargoCounter": cargoCounter,
    "drawSlatCargoHandleMode": drawSlatCargoHandleMode,
    "gridStyle": gridStyle
}

/**
 * Function to return the value of a global variable
 * @param {String} string String corresponding to variable name
 * @returns {*} Value of variable requested
 */
export function getVariable(string){
    return variables[string]
}

/**
 * Function to write to a global variable
 * @param {String} string String corresponding to the variable name
 * @param {*} value Value to write to the variable 
 * @returns {*} Value of the variable after assignment
 */
export function writeVariable(string, value){
    variables[string] = value
    return value
}
