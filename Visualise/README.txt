Program description:
Returns a side by side comparison of the z firings during training and testing trials.

To use, type 'ViewResults' into the console.
Use left,right arrow keys to scroll through the patterns, 
type min and max neuron viewing range into the text box.

BEFORE USING:
Check that the structure containing the data is loaded into the workspace, and that it is named 'data'.
Inside the data struct, there needs to be the fields 'z_history' and 'z_test', which are to be a 
stack of matrices where the first index is neuron, second index is time, and third index is trial.

File descriptions:
ViewResults.m   : Wrapper to gui files. Checks which struct contains the data of interest.
ViewZHistory.fig: 'fig' file for gui (specifies visual interface elements)
ViewZHistory.m  : Contains all functions for gui
FigureZHistory.m: Generates two spy plots for a side by side comparison of training and testing trials.



