import pandas as pd
import os
import numpy as np
import matplotlib.pyplot as plt

from crisscross.core_functions.megastructure_composition import convert_slats_into_echo_commands
from crisscross.core_functions.megastructures import Megastructure
from crisscross.core_functions.slat_design import generate_handle_set_and_optimize, calculate_slat_hamming
from crisscross.plate_mapping import get_plateclass

from crisscross.helper_functions.plate_constants import (slat_core, core_plate_folder, crisscross_h5_handle_plates,
                                                         crisscross_h2_handle_plates, assembly_handle_folder, 
                                                         cargo_plate_folder, seed_plug_plate_center, 
                                                         nelson_quimby_antihandles)

DesignFolder = "/Users/stellawang/Dropbox (HMS)/crisscross_team/Crisscross Designs/SW099_kineticsweep_design"
DesignFile = "SW099_kineticsweepfiniteribbon_design.xlsx"
ReadHandlesFromFile = True

# Useful names and variables
LayerList = ["Layer0_seed", "Layer1_X", "Layer2_Y", "Layer3_cargo"] # in order, seed at bottom and cargo on top
SeedLayer = "Layer0_seed"
CargoLayer = "Layer3_cargo"
OutputFilePrefix = "handle_array_layer"

# Global variables are in PascalCase
# Local variables are in camelCase
# Functions and some repo constants are in snake_case

# reads in and formats slat design into a 3D array
DesignDF = pd.read_excel(os.path.join(DesignFolder, DesignFile), sheet_name=None, header=None)

# Prepare an empty dataframe and fill with slat positions
SlatArray = np.zeros((DesignDF[LayerList[0]].shape[0], DesignDF[LayerList[0]].shape[1], len(DesignDF)-2))
for i, key in enumerate(LayerList[1:-1]):
    SlatArray[..., i] = DesignDF[key].values

# Prepare to load handle assignments from file, but if not available, regenerate a fresh handle set
if ReadHandlesFromFile:  # this is to re-load a pre-computed handle array and save time later
    HandleArray = np.zeros((SlatArray.shape[0], SlatArray.shape[1], SlatArray.shape[2]-1))
    for i in range(SlatArray.shape[-1]-1):
        try:
            HandleArray[..., i] = np.loadtxt(os.path.join(DesignFolder, OutputFilePrefix + "%s.csv" % (i+1)), delimiter=',').astype(np.float32)
        except FileNotFoundError:
            print("No handle array file was found. Switch 'HandlesFromFile' flag to False and try again.")

    UniqueSlatsPerLayer = [] # Count the number of slats in the design
    for i in range(SlatArray.shape[2]):
        slatIDs = np.unique(SlatArray[:, :, i])
        slatIDs = slatIDs[slatIDs != 0]
        UniqueSlatsPerLayer.append(slatIDs)

    _, _, res = calculate_slat_hamming(SlatArray, HandleArray, UniqueSlatsPerLayer, unique_sequences=32)
    print('Hamming distance from file-loaded design: %s' % np.min(res))

else:
    HandleArray = generate_handle_set_and_optimize(SlatArray, unique_sequences=32, min_hamming=29, max_rounds=10) ###
    for i in range(HandleArray.shape[-1]):
        np.savetxt(os.path.join(DesignFolder, OutputFilePrefix + "%s.csv" % (i+1)),
                   HandleArray[..., i].astype(np.int32), delimiter=',', fmt='%i')

# Generates plate dictionaries from provided files - don't change
CorePlate = get_plateclass('ControlPlate', slat_core, core_plate_folder)
CrisscrossAntihandleYPlates = get_plateclass('CrisscrossHandlePlates',
                                            crisscross_h5_handle_plates[3:] + crisscross_h2_handle_plates,
                                            assembly_handle_folder, plate_slat_sides=[5, 5, 5, 2, 2, 2])
CrisscrossHandleXPlates = get_plateclass('CrisscrossHandlePlates',
                                                crisscross_h5_handle_plates[0:3],
                                                assembly_handle_folder, plate_slat_sides=[5, 5, 5])
CenterSeedPlate = get_plateclass('CenterSeedPlugPlate', seed_plug_plate_center, core_plate_folder)
CargoPlate = get_plateclass('AntiNelsonQuimbyPlate', nelson_quimby_antihandles, cargo_plate_folder) ### Need to populate plate database with sw_src005!

# Combines handle and slat array into the megastructure
KineticMegastructure = Megastructure(SlatArray, None)
KineticMegastructure.assign_crisscross_handles(HandleArray, CrisscrossHandleXPlates, CrisscrossAntihandleYPlates)

# Prepare the seed layer and assign to array
SeedArray = DesignDF[SeedLayer].values
KineticMegastructure.assign_seed_handles(SeedArray, CenterSeedPlate, layer_id=1)

# Prepare the cargo layer, map cargo handle ids, and assign to array
CargoArray = DesignDF[CargoLayer].values
KineticMegastructure.assign_cargo_handles(CargoArray, CargoPlate, layer='top')

# Patch up missing controls
KineticMegastructure.patch_control_handles(CorePlate)

# Exports design to echo format csv file for production
convert_slats_into_echo_commands(KineticMegastructure.slats, 'kineticsweep', DesignFolder, 'all_echo_commands.csv')
...