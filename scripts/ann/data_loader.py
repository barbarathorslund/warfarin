import torch
import pandas as pd
import numpy as np
from torch.utils.data import Dataset

class PicsDataLoader(Dataset):
    """Pics dataset loader"""
    
    def __init__(self, csv_file):
        self.data = pd.read_csv(csv_file, sep=" ", header=None).values

        self.X = torch.tensor(self.data[1:, 2:108].astype(np.float64)).float()
        self.y = torch.tensor(self.data[1:, 109].astype(np.float64)).float()

    def __len__(self):
        return len(self.X)

    def __getitem__(self, idx):
        return self.X[idx], self.y[idx]