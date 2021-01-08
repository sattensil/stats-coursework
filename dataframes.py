
import pandas as pd
import numpy as np


# import csv -- remove brackets first
convers_agg = pd.read_csv('convers_agg.csv')
print(convers_agg.head(10))

print(convers_agg.conversions_sum.sum())
print(convers_agg.conversions_sum.mean())
print(convers_agg.conversions_sum.unique())
print(convers_agg.conversions_sum.describe())
print(convers_agg.describe(include = object))
print(np.unique(convers_agg.channels_subset))
print(convers_agg.shape)


new_list = [x.replace('"', '') for x in my_list]

','.join([str(i) for i in convers_agg.channels_subset]).replace('Activities','').split(",")


convers_agg[convers_agg['channels_subset'].str.contains("SIGN", case=False)]


colors = {'first_set':  ['aa_xyz_bb','cc_xyz_dd','ee_xyz_ff','gg_xyz_hh'],
          'second_set': ['ii_xyz_jj','kk_xyz_ll','mm_xyz_nn','oo_xyz_pp']
         }

df = pd.DataFrame(colors, columns= ['first_set','second_set'])

df = df.replace('_xyz_','||', regex=True)
