function varargout = ViewZHistory(varargin)
%I set varargin so that the first arg is interpreted as the 'data' struct
% VIEWZHISTORY MATLAB code for ViewZHistory.fig
%      VIEWZHISTORY, by itself, creates a new VIEWZHISTORY or raises the existing
%      singleton*.
%
%      H = VIEWZHISTORY returns the handle to a new VIEWZHISTORY or the handle to
%      the existing singleton*.
%
%      VIEWZHISTORY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWZHISTORY.M with the given input arguments.
%
%      VIEWZHISTORY('Property','Value',...) creates a new VIEWZHISTORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ViewZHistory_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ViewZHistory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ViewZHistory

% Last Modified by GUIDE v2.5 13-Feb-2019 14:59:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ViewZHistory_OpeningFcn, ...
                   'gui_OutputFcn',  @ViewZHistory_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ViewZHistory is made visible.
function ViewZHistory_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ViewZHistory (see VARARGIN)

% Choose default command line output for ViewZHistory
handles.output          = hObject;
handles.trial_view      = 1;
handles.variables       = varargin{1};
handles.data            = varargin{2};
handles.n_nrns          = size(handles.data.z_history,1);
handles.n_trials        = size(handles.data.z_history,3);
handles.nrn_min_view    = 1;
handles.nrn_max_view    = handles.n_nrns;
handles.display_request = {'Train','Test'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ViewZHistory wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ViewZHistory_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
trial = handles.trial_view;
switch eventdata.Key
    case 'leftarrow'
        if trial >1
            trial = trial-1;
        end
    case 'rightarrow'
        if trial < handles.n_trials
            trial = trial+1;
        end
end
handles.trial_view = trial;
guidata(hObject,handles)

UpdatePlot(handles)



% --- Executes on key press with focus on MinViewRange and none of its controls.
function MinViewRange_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MinViewRange (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function MinViewRange_Callback(hObject, eventdata, handles)
% hObject    handle to MinViewRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinViewRange as text
%        str2double(get(hObject,'String')) returns contents of MinViewRange as a double
nrn_min_view = str2double(get(hObject,'String'));

check_positive = nrn_min_view>0;
check_integer  = floor(nrn_min_view)==nrn_min_view;
check_max_compatible = nrn_min_view<=handles.nrn_max_view;

if check_positive && check_integer && check_max_compatible
    handles.nrn_min_view = nrn_min_view;
end

guidata(hObject,handles)

UpdatePlot(handles)



% --- Executes during object creation, after setting all properties.
function MinViewRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinViewRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1')



function MaxViewRange_Callback(hObject, eventdata, handles)
% hObject    handle to MaxViewRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxViewRange as text
%        str2double(get(hObject,'String')) returns contents of MaxViewRange as a double

nrn_max_view = str2double(get(hObject,'String'));
if isnan(nrn_max_view) %if nrn_max_view is not a number
    nrn_max_view = handles.n_nrns;
end
check_not_too_big = nrn_max_view<=handles.n_nrns;
check_integer  = floor(nrn_max_view)==nrn_max_view;
check_max_compatible = nrn_max_view>=handles.nrn_min_view;

if check_not_too_big && check_integer && check_max_compatible
    handles.nrn_max_view = nrn_max_view;
end

guidata(hObject,handles)

UpdatePlot(handles)

% --- Executes during object creation, after setting all properties.
function MaxViewRange_CreateFcn(hObject, eventdata, handles,varargin)
% hObject    handle to MaxViewRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','all nrns?')


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
contents = cellstr(get(hObject,'String'));
handles.display_request = contents(get(hObject,'Value'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

hObject.Max = 4;
hObject.Min = 1;
hObject.String = {...
    'Train',...
    'Test' ,...
    'K0History',...
    'MeanZ',...
    'CosComp',...
    };
set(hObject,'Value',[1,2])




function UpdatePlot(handles)

FigureZHistory(handles)
