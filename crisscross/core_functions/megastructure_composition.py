import pandas as pd
import os
from crisscross.helper_functions.plate_constants import plate96


def convert_slats_into_echo_commands(slat_dict, destination_plate_name, output_folder, output_filename,
                                     transfer_volume=75, source_plate_type='384PP_AQ_BP', specific_plate_wells=None):

    # echo command prep
    complete_list = []
    for index, (_, slat) in enumerate(slat_dict.items()):
        if specific_plate_wells:
            well = specific_plate_wells[index]
        else:
            well = plate96[index]
        for h2_num, h2 in slat.get_sorted_handles('h2'):
            complete_list.append([slat.ID + '_h2_staple_%s' % h2_num, h2['plate'], h2['well'],
                                  well, transfer_volume, destination_plate_name, source_plate_type])

        for h5_num, h5 in slat.get_sorted_handles('h5'):
            complete_list.append([slat.ID + '_h5_staple_%s' % h5_num, h5['plate'], h5['well'],
                                  well, transfer_volume, destination_plate_name, source_plate_type])

    combined_df = pd.DataFrame(complete_list, columns=['Component', 'Source Plate Name', 'Source Well',
                                                       'Destination Well', 'Transfer Volume',
                                                       'Destination Plate Name', 'Source Plate Type'])
    combined_df.to_csv(os.path.join(output_folder, output_filename), index=False)

    return combined_df
