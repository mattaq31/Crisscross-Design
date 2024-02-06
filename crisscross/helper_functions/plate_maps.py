from itertools import product
from string import ascii_uppercase
import os
from os.path import join


plate96 = [x + str(y) for x, y in product(ascii_uppercase[:8], range(1, 12 + 1))]
plate384 = [x + str(y) for x, y in product(ascii_uppercase[:16], range(1, 24 + 1))]

base_directory = os.path.abspath(join(__file__, os.path.pardir, os.path.pardir, os.path.pardir))
plate_folder = join(base_directory, 'core_plates')

crisscross_handle_plates = ["P3247_SW", "P3248_SW", "P3249_SW", "P3250_SW", "P3251_CW",
                            "P3252_SW"]  # first 3 are 'handle' plates, last 3 are 'anti-handle' plates

seed_core = 'sw_src001_seedcore'  # this contains all the seed sequences, including the socket sequences
slat_core = 'sw_src002_slatcore'  # this contains all the slat sequences, including the control sequences (no handle)

seed_plug_plate_center = 'P2854_CW_seed_plug_center'  # this contains the H2 plug sequences to bind to the seed at the center of the x-slats
seed_plug_plate_corner = 'P3339_JL_seed_plug_corner' # this contains another variation of H2 plug sequences - they go to the corner of a set of x-slats
