import torch.nn as nn

class PicsModel(nn.Module):
    """PICS model to predict warfarin dose"""
    
    def __init__(self, hidden_neurons):
        super(PicsModel, self).__init__()
        self.h1 = nn.Linear(106, hidden_neurons)
        self.output = nn.Linear(hidden_neurons, 1)
        self.relu = nn.ReLU()
        
    def forward(self, x):
        x = self.h1(x)
        x = self.relu(x)
        x = self.output(x)
        x = self.relu(x)

        return x