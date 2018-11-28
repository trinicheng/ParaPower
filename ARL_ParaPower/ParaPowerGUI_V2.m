%Wish List
%   Got to figure out how to change cell edit callback to invoke update
%   status.

function varargout = ParaPowerGUI_V2(varargin)
% PARAPOWERGUI_V2 MATLAB code for ParaPowerGUI_V2.fig
%      PARAPOWERGUI_V2, by itself, creates a new PARAPOWERGUI_V2 or raises the existing
%      singleton*.
%
%      H = PARAPOWERGUI_V2 returns the handle to a new PARAPOWERGUI_V2 or the handle to
%      the existing singleton*.
%
%      PARAPOWERGUI_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAPOWERGUI_V2.M with the given input arguments.
%
%      PARAPOWERGUI_V2('Property','Value',...) creates a new PARAPOWERGUI_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParaPowerGUI_V2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParaPowerGUI_V2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ParaPowerGUI_V2

% Last Modified by GUIDE v2.5 28-Nov-2018 16:04:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParaPowerGUI_V2_OpeningFcn, ...
                   'gui_OutputFcn',  @ParaPowerGUI_V2_OutputFcn, ...
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


% --- Executes just before ParaPowerGUI_V2 is made visible.
function ParaPowerGUI_V2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParaPowerGUI_V2 (see VARARGIN)

% Choose default command line output for ParaPowerGUI_V2
handles.output = hObject;
handles.InitComplete=0;


clear Features ExternalConditions Params PottingMaterial Descr
Features.x=[]; Features.y=[]; Features.z=[]; Features.Matl=[]; Features.Q=[]; Features.Matl=''; 
Features.dz=0; Features.dy=0; Features.dz=0;

% Update handles structure
guidata(hObject, handles);

TimeStep_Callback(hObject, eventdata, handles)
TableHandle=handles.features;

UpdateMatList(TableHandle, MatListCol, 'Do Not Open Mat Dialog Box')
% UIWAIT makes ParaPowerGUI_V2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
AddStatusLine('ClearStatus')
disp('Visual stress checkbox is currently disabled because stress functionality is not implemented in this GUI yet.')
set(handles.VisualStress,'enable','off');
disp('stop button functionality is not implemented in this GUI yet.')
set(handles.pushbutton18,'enable','off')

axes(handles.PPLogo)
imshow('ARLlogoParaPower.png')
text(0,0,['Version ' ARLParaPowerVersion],'vertical','bott')
set(handles.GeometryVisualization,'visi','off');
ClearGUI_Callback(handles.ClearGUI, eventdata, handles)

%Setup callbacks to ensure that geometry update notification is displayed
%DispNotice=@(hobject,eventdata) ParaPowerGUI_V2('VisUpdateStatus',guidata(hobject),true);
%set(handles.features,'celleditcallback',DispNotice);
%set(handles.ExtCondTable,'celleditcallback',DispNotice);


%LogoAxes_CreateFcn(hObject, eventdata, handles)




% --- Outputs from this function are returned to the command line.
function varargout = ParaPowerGUI_V2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in visualize.
function visualize_Callback(hObject, eventdata, handles)
% hObject    handle to visualize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MI=getappdata(handles.figure1,'MI');

figure(2)

cla;Visualize ('', MI, 'modelgeom','ShowQ')
VisUpdateStatus(false)
%Removed as this seems to have been replaced by below without the capital "A"
% % --- Executes on button press in AddFeature.
% function AddFeature_Callback(hObject, eventdata, handles)
% % hObject    handle to AddFeature (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% data = get(handles.features,'Data');
% data(end+1,:)=0;
% set(handles.features,'Data',data)




% --- Executes on button press in addfeature.
function addfeature_Callback(hObject, eventdata, handles)
% hObject    handle to addfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    x = get(handles.features,'Data');
    NumCols=length(get(handles.features,'columnWidth'));
    EmptyRow=EmptyFeatureRow;
    if isempty(x)
        x=EmptyRow;
    else
        x(end+1,:)=EmptyRow;
    end
    set(handles.features,'Data',x)
    VisUpdateStatus(handles,true);


% --- Executes during object creation, after setting all properties.
function Tinit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tinit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function E=EmptyFeatureRow
    E{1,14}=[];
    E{QValueCol}='0';
    E{QTypeCol}='Scalar';


% --- Executes during object creation, after setting all properties.
function Tprocess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function NumTimeSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumTimeSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    oldpathname=get(handles.loadbutton,'userdata');
    [fname,pathname] = uiputfile ([oldpathname '*.mat']);
    if fname ~= 0 
        set(handles.loadbutton,'userdata',pathname);
        AddStatusLine(['Savinging "' pathname fname '".']);
        TestCaseModel = getappdata(handles.figure1,'TestCaseModel');
        %save([pathname fname], '-struct' , 'TestCaseModel')
        %Remove saving as struct, just save TestCaseModel as a whole
        %variable itself
        save([pathname fname],'TestCaseModel')  
        CurTitle=get(handles.figure1,'name');
        Colon=strfind(CurTitle,':');
        if not(isempty(Colon))
            CurTitle(Colon:end)='';
        end
        CurTitle=[CurTitle ': ' fname];
        set(handles.figure1,'name',CurTitle);
    end



% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    oldpathname=get(hObject,'userdata');
    [filename,pathname] = uigetfile([oldpathname '*.mat']);
    if filename~=0
        AddStatusLine(['Loading "' pathname filename '".']);
        CurTitle=get(handles.figure1,'name');
        Colon=strfind(CurTitle,':');
        if not(isempty(Colon))
            CurTitle(Colon:end)='';
        end
        CurTitle=[CurTitle ': ' filename];
        set(handles.figure1,'name',CurTitle);
        set(hObject,'userdata',pathname);
%        TestCaseModel = uiimport([pathname filename]);
        %Changing from data saved as fields to saved as a structured variable
        
        load([pathname filename]);
        if not(exist('TestCaseModel','var'))
            warning(sprintf('"%s" saved in old format.  File will be loaded anyway with no user action necessary. File will be saved in new format by default.',[pathname filename]))
            TestCaseModel.ExternalConditions=ExternalConditions;
            TestCaseModel.Features=Features;
            TestCaseModel.Params=Params;
            TestCaseModel.PottingMaterial=PottingMaterial;
        end
        setappdata(handles.figure1,'TestCaseModel',TestCaseModel)
        ExternalConditions=TestCaseModel.ExternalConditions;
        Features=TestCaseModel.Features;
        Params=TestCaseModel.Params;
        PottingMaterial=TestCaseModel.PottingMaterial;

        %%% Set the External Conditions into the table 
        tabledata = get(handles.ExtCondTable,'data');

       tabledata(1,1) =  mat2cell(ExternalConditions.h_Left,1,1);
       tabledata(1,2) =  mat2cell(ExternalConditions.h_Right,1,1);
       tabledata(1,3) =  mat2cell(ExternalConditions.h_Front,1,1);
       tabledata(1,4) =  mat2cell(ExternalConditions.h_Back,1,1);
       tabledata(1,5) =  mat2cell(ExternalConditions.h_Top,1,1);
       tabledata(1,6) =  mat2cell(ExternalConditions.h_Bottom,1,1);

       tabledata(2,1) =  mat2cell(ExternalConditions.Ta_Left,1,1);
       tabledata(2,2) =  mat2cell(ExternalConditions.Ta_Right,1,1);
       tabledata(2,3) =  mat2cell(ExternalConditions.Ta_Front,1,1);
       tabledata(2,4) =  mat2cell(ExternalConditions.Ta_Back,1,1);
       tabledata(2,5) =  mat2cell(ExternalConditions.Ta_Top,1,1);
       tabledata(2,6) =  mat2cell(ExternalConditions.Ta_Bottom,1,1);

       set(handles.ExtCondTable,'Data',tabledata)


       %%%%Set the features into the table
       %tabledata = get(handles.features,'data');  %No need to load data
       %that won't be used.
       tabledata = {};
       [m n] = size(Features); 

       for count = 1: n 
            %FEATURESTABLE
           tabledata(count,1) = false;
           tabledata(count,2) = mat2cell(Features(count).x(1),1,1);
           tabledata(count,3) = mat2cell(Features(count).y(1),1,1);
           tabledata(count,4) = mat2cell(Features(count).z(1),1,1);
           tabledata(count,5) = mat2cell(Features(count).x(2),1,1);
           tabledata(count,6) = mat2cell(Features(count).y(2),1,1);
           tabledata(count,7) = mat2cell(Features(count).z(2),1,1);
           tabledata(count,8) = cellstr(Features(count).Matl);
           tabledata(count,9) = mat2cell(Features(count).Q,1,1);
           tabledata(count,12) = mat2cell(Features(count).dx,1,1);
           tabledata(count,13) = mat2cell(Features(count).dz,1,1);
       end 

       set(handles.features,'Data',tabledata)

       %%%Set Parameters
       set(handles.Tinit,'String', Params.Tinit)
       set(handles.TimeStep,'String',Params.DeltaT)
       set(handles.NumTimeSteps,'String',Params.Tsteps)
       set(handles.Tprocess,'String',ExternalConditions.Tproc)
    end
    Initialize_Callback(hObject, eventdata, handles, true)
    
    

% --- Executes on button press in RunAnalysis.
function RunAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to RunAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        if handles.InitComplete == 0 
            Initialize_Callback(hObject, eventdata, handles)
        else
            Initialize_Callback(handles.Initialize, eventdata, handles, false)
        end
        numplots = 1;
        AddStatusLine('Analysis running...');
        MI = getappdata(handles.figure1,'MI');
        if isempty(MI)
            AddStatusLine('Model not yet fully defined.')
            return
        end
        %MI=FormModel(TestCaseModel);
        %figure(numplots)
        %Visualize ('Model Input', MI, 'modelgeom','ShowQ')

        pause(.001)
        fprintf('Analysis executing...')
        
        TimeStepOutput = get(handles.slider1,'Value');

        GlobalTime=[0:MI.Tsteps-1]*MI.DeltaT;  %Since there is global time vector, construct one here.
        [Tprnt, Stress, MeltFrac]=ParaPowerThermal(MI.NL,MI.NR,MI.NC, ...
                                               MI.h,MI.Ta, ...
                                               MI.X,MI.Y,MI.Z, ...
                                               MI.Tproc, ...
                                               MI.Model,MI.Q, ...
                                               MI.DeltaT,MI.Tsteps,MI.Tinit,MI.matprops);
                                       
       fprintf('Complete.\n')
       

       
       StateN=round(length(GlobalTime)*TimeStepOutput,0);
       
       %%%%Plot time dependent plots for temp, stress and melt fraction 
        Dout(:,1)=GlobalTime;
        Dout(:,2)=zeros(size(GlobalTime));
        Dout(:,3)=zeros(size(GlobalTime));
        Dout(:,4)=zeros(size(GlobalTime));
        
    
       
       for I=1:length(GlobalTime)
            Dout(I,2)=max(max(max(Tprnt(:,:,:,I))));
            %Dout(I,3)=max(max(max(Stress(:,:,:,I))));
            Dout(I,4)=max(max(max(MeltFrac(:,:,:,I))));
       end
       
       numplots = 1; 
       figure(numplots)
       plot (Dout(:,1), Dout(:,2))
       figure(handles.figure1)
       
       setappdata(handles.figure1, 'Tprint', Tprnt);
       setappdata( handles.figure1, 'Stress', Stress);
       setappdata (handles.figure1, 'MeltFrac', MeltFrac);

       AddStatusLine('Done.', true);

% --- Executes on button press in VisualStress.
function VisualStress_Callback(hObject, eventdata, handles)
% hObject    handle to VisualStress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VisualStress

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

TimeStepOutput = get(handles.slider1,'Value'); %value between 0 and 1 from the slider

NumStep =str2num(get(handles.NumTimeSteps,'String')); %total number of time steps
StateN=round(NumStep*TimeStepOutput,0); %time step of interest 
TimeStepString = strcat('Time Step Output = ',int2str(StateN)); %create output string
set(handles.TextTimeStep,'String',TimeStepString)   %output string to GUI


TimeStep = str2num(get(handles.TimeStep,'String'));  %individual time step in seconds 
timeofinterest = TimeStep*NumStep*TimeStepOutput;
TimeString = strcat('Time of Interest = ',num2str(timeofinterest),' sec');
set(handles.InterestTime,'String',TimeString)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in AddMaterial.
function AddMaterial_Callback(hObject, eventdata, handles)
% hObject    handle to AddMaterial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TableHandle=handles.features;

UpdateMatList(TableHandle, MatListCol)


% --- Executes on button press in Initialize.
function Initialize_Callback(hObject, eventdata, handles, Visual)
% hObject    handle to Initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear the main variables that are passed out from it.
if not(exist('Visual'))
    Visual=true;
end
KillInit=0;
AddStatusLine('Initializing...')
clear Features ExternalConditions Params PottingMaterial Descr
Features.x=[]; Features.y=[]; Features.z=[]; Features.Matl=[]; Features.Q=[]; Features.Matl=''; 
Features.dz=0; Features.dy=0; Features.dz=0;

%0 = init has not been complete, 1 = init has been completed
handles.InitComplete = 1; 
guidata(hObject,handles)

x=2;


FeaturesMatrix = get(handles.features,'Data');
FeaturesMatrix = FeaturesMatrix(:,2:end);
ExtBoundMatrix = get(handles.ExtCondTable,'Data');
for K=1:length(ExtBoundMatrix(:))
    if isempty(ExtBoundMatrix{K})
        AddStatusLine('Error.',true);
        AddStatusLine('Env. parameters must be fully populated');
        return
    end
end

%Setting Structural BCs, using direction below if non-zero
    ExternalConditions.h_Left=ExtBoundMatrix{1,1};    %Heat transfer coefficient from each side to the external environment
    ExternalConditions.h_Right=ExtBoundMatrix{1,2};
    ExternalConditions.h_Front=ExtBoundMatrix{1,3};
    ExternalConditions.h_Back=ExtBoundMatrix{1,4};
    ExternalConditions.h_Top=ExtBoundMatrix{1,5};
    ExternalConditions.h_Bottom=ExtBoundMatrix{1,6};

    ExternalConditions.Ta_Left=ExtBoundMatrix{2,1};   %Ambiant temperature outside the defined the structure
    ExternalConditions.Ta_Right=ExtBoundMatrix{2,2};
    ExternalConditions.Ta_Front=ExtBoundMatrix{2,3};
    ExternalConditions.Ta_Back=ExtBoundMatrix{2,4};
    ExternalConditions.Ta_Top=ExtBoundMatrix{2,5};
    ExternalConditions.Ta_Bottom=ExtBoundMatrix{2,6};

    ExternalConditions.Tproc = str2num(get(handles.Tprocess,'String')); %Processing temperature, used for stress analysis

    %Parameters that govern global analysis
    Params.Tinit=str2num(get(handles.Tinit,'String')); %Initial temp of all nodes
    Params.DeltaT=str2num(get(handles.TimeStep,'String')); %Time Step Size
    if get(handles.Static,'value')==1
        Params.Tsteps=[]; %Number of time steps
        MaxTime = 0;
    elseif get(handles.transient,'value')==1
        Params.Tsteps=str2num(get(handles.NumTimeSteps,'String')); %Number of time steps
        MaxTime = Params.Tsteps * Params.DeltaT;
    end
    PottingMaterial  = 0;  %Material that surrounds features in each layer as defined by text strings in matlibfun. 
                       %If Material is 0, then the space is empty and not filled by any material.


%%%% SET ALL Feature Parameters
%Each feature is defined separately.  There is no limit to the number of
%features that can be defined.  For each layer of the model, unless a
%feature exists, the material is defined as "potting material."  There is
%no checking to ensure that features do not overlap.  The behavior for
%overlapping features is not defined.
 %Layer 1 is at bottom



[rows,cols]=size(FeaturesMatrix);
if rows==0
    AddStatusLine('No features to initialize.')
else
    CheckMatrix=FeaturesMatrix(:,[1:7 10:13]);
    for K=1:length(CheckMatrix(:))
        if isempty(CheckMatrix{K})
            AddStatusLine('Error.',true);
            AddStatusLine('Features table is not fully defined.')
            return
        end
    end
    QData=getappdata(gcf,TableDataName);
    if isempty(QData)
        QData{length(FeaturesMatrix(:,1))}=[];
    end
    for count = 1:rows

        %.x, .y & .z are the two element vectors that define the corners
        %of each features.  X=[X1 X2], Y=[Y1 Yz], Z=[Z1 Z2] is interpreted
        %that corner of the features are at points (X1, Y1, Z1) and (X2, Y2, Z2).
        %It is possible to define zero thickness features where Z1=Z2 (or X or Y)
        %to ensure a heat source at a certain layer or a certain discretization.
        %FEATURESTABLE
 
        Features(count).x  =  [FeaturesMatrix{count, 1} FeaturesMatrix{count, 4}];  % X Coordinates of edges of elements
        Features(count).y =   [FeaturesMatrix{count, 2} FeaturesMatrix{count, 5}];  % y Coordinates of edges of elements
        Features(count).z =   [FeaturesMatrix{count, 3} FeaturesMatrix{count, 6}]; % Height in z directions

        %These define the number of elements in each features.  While these can be 
        %values from 2 to infinity, only odd values ensure that there is an element
        %at the center of each features

        Features(count).dx =  FeaturesMatrix{count, 12}; %Number of divisions/feature in X
        Features(count).dy =  FeaturesMatrix{count, 12}; %Number of divisions/feature in Y
        Features(count).dz =  FeaturesMatrix{count, 13}; %Number of divisions/feature in Z (layers)


        
        Features(count).Matl = FeaturesMatrix{count, 7}; %Material text as defined in matlibfun
        QValue=FeaturesMatrix{count, QValueCol-1};
        Qtype=FeaturesMatrix{count, QTypeCol-1};
        Qtype=lower(Qtype(1:5));
        switch Qtype
            case 'scala'
                QValue=str2double(QValue);
                if QValue==0
                    Features(count).Q = 0;
                else
                    Features(count).Q = @(t)QValue;
                end
            case 'table'
                Table=QData{count};
                MakeUnique=eps(MaxTime)*2; %Use a value of 3 * epsilon to add to the time steps
                DeltaT=Table(2:end,1)-Table(1:end-1,1);
                if min(DeltaT) < eps(MaxTime)*3
                    AddStatusLine(['Smallest Delta T must be greater than 3*epsilon (machine precision for MaxTime) for feature ' num2str(count)]);
                    KillInit=1;
                else
                    DupTime=(Table(2:end,1)-Table(1:end-1)==0)*eps(MaxTime)*2;
                    DupTime=[0 DupTime];
                    Table(:,1)=Table(:,1)+DupTime;
                    if min(Table(2:end,1)-Table(1:end-1,1)) <= 0
                        AddStatusLine(['Time must be increasing.  It is not for feature ' num2str(count)]);
                        KillInit=1;
                    end
                    if max(Table(:,1)<MaxTime)
                        Table(end+1,:)=[MaxTime Table(end,2)];
                        AddStatusLine(['Feature ' num2str(count) ' time extended to maxtime with a flat line.'])
                    end
                    if min(Table(:,1))>0
                        Table=[0 0; Table(1,1)-2*eps(MaxTime) 0; Table];
                        AddStatusLine(['Feature ' num2str(count) ' time adjusted to begin at t=0, value of 0'])
                    end
                    Features(count).Q = @(t)interp1(Table(:,1), Table(:,2), t);
                end
            case 'funct'
                if isempty(QValue)
                    Features(count).Q=0;
                else
                    Features(count).Q = @(t)eval(QValue);
                end
            otherwise
                AddStatusLine(['Unknown Q type "' FeaturesMatrix{count, QTypeCol} '"' ] )
                KillInit=1;
        end
                    
        %Features(count).Q = FeaturesMatrix{count, 8}; %Total heat input at this features in watts.  The heat per element is Q/(# elements)
    end

    %Get Materials Database
    MatHandle=get(handles.features,'userdata');
    MatLib=getappdata(MatHandle,'Materials');

    %Assemble the above definitions into a single variablel that will be used
    %to run the analysis.  This is the only variable that is used from this M-file.

    TestCaseModel.ExternalConditions=ExternalConditions;
    TestCaseModel.Features=Features;
    TestCaseModel.Params=Params;
    TestCaseModel.PottingMaterial=PottingMaterial;
    TestCaseModel.MatLib=MatLib;

    if KillInit
        AddStatusLine('Unable to execute model due to errors.')
    else
        MI=FormModel(TestCaseModel);

    %    axes(handles.GeometryVisualization);
    %    Visualize ('Model Input', MI, 'modelgeom','ShowQ')

        setappdata(handles.figure1,'TestCaseModel',TestCaseModel);
        setappdata(handles.figure1,'MI',MI);

        MI=getappdata(handles.figure1,'MI');
        axes(handles.GeometryVisualization)
        %figure(2)

        if Visual
            AddStatusLine('drawing...',true)
            Visualize ('', MI, 'modelgeom','ShowQ')
            VisUpdateStatus(handles,false);
            AddStatusLine('Done',true)
            drawnow
        end
    end
end

function Feature2Del_Callback(hObject, eventdata, handles)
% hObject    handle to Feature2Del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Feature2Del as text
%        str2double(get(hObject,'String')) returns contents of Feature2Del as a double


% --- Executes during object creation, after setting all properties.


% function Feature2Del_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to Feature2Del (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in DeleteFeature.
function DeleteFeature_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.features, 'Data');


for I=length(data(:,1)):-1:1
    if data{I,1}
        data=[data(1:I-1,:); data(I+1:end,:)];
    end
end
if length(data(:,1))==0
    data=EmptyFeatureRow;
end
set(handles.features, 'Data', data);

% 
% D = get(handles.Feature2Del, 'String');
% D = str2num(D);
% if isempty(D)
%     fprintf('Error: No feature selected, please select feature')
% else 
%     if not(isempty(data))
%         QData=getappdata(gcf,TableDataName);
%         if length(QData)<length(data(:,1))
%             QData{length(data(:,1))}=[];
%         end
%         QData=[QData(1:D-1) QData(D+1:end)];
%         data(D,:)=[];
%         set(handles.features, 'Data', data); 
%         setappdata(gcf,TableDataName,QData);
%     end
% end
VisUpdateStatus(handles,true);





% --- Executes on button press in ClearGUI.
function ClearGUI_Callback(hObject, eventdata, handles)
% hObject    handle to ClearGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear figure in GUI
AddStatusLine('Clearing GUI...')
axes(handles.GeometryVisualization)
cla reset;

%Clear figures external to GUI 
%Figures = findobj( 'Type', 'Figure' , '-not' , 'Tag' , get(ParaPowerGUI_V2, 'Tag' ) );
Figures = findobj( 'Type', 'Figure' );
NFigures = length( Figures );
for nFigures = 1 : NFigures;
    if isempty(get(Figures(nFigures),'filename'))
        close( Figures( nFigures ) );
    end
end

Kids=get(handles.uipanel5,'children');
for i=1:length(Kids)
    if strcmpi(get(Kids(i),'userdata'),'REMOVE');
        delete(Kids(i))
    end
end

%Delete features matrix
% data = get(handles.features, 'Data');
% [M,N] = size(data);
% for count = 1:M
%     data(1,:)=[];
% end
% data(1,:)=mat2cell(0,1,1);
%set(handles.features, 'Data',data);

%Set Environmental Parameters to zero 
T = num2cell([0]);
set(handles.ExtCondTable, 'Data', [T T T T T T; T T T T T T]);

%Set Transient/Stress Conditions to 0 or 1
zero = num2str(0);
one = num2str(1);
set(handles.Tinit,'String',zero);
set(handles.TimeStep,'String',zero); 
set(handles.NumTimeSteps,'String',one);
set(handles.Tprocess,'String',zero);
set(handles.GeometryVisualization,'visi','off')

EmptyRow=EmptyFeatureRow;
set(handles.features, 'Data',EmptyRow); 
if isappdata(gcf,TableDataName);
    rmappdata(gcf,TableDataName)
end

RowNames=get(handles.ExtCondTable,'rowname');
set(handles.ExtCondTable,'rowname',RowNames(1:2,:))
NumCols=length(get(handles.ExtCondTable,'columnwidth'));
TableData{2,NumCols}=[];
set(handles.ExtCondTable,'Data',TableData);

VisUpdateStatus(handles,false)
CurTitle=get(handles.figure1,'name');
Colon=strfind(CurTitle,':');
if not(isempty(Colon))
    CurTitle(Colon:end)='';
end
set(handles.figure1,'name',CurTitle);

handles.InitComplete = 0;
set(handles.transient,'value',1)
AnalysisType_SelectionChangedFcn(handles.transient, eventdata, handles)


guidata(hObject, handles);
AddStatusLine('Done.', true)

% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MeshConverg.
function MeshConverg_Callback(hObject, eventdata, handles)
% hObject    handle to MeshConverg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Parametric analysis

% %Delete features matrix
% data = get(handles.features, 'Data');
% [M,N] = size(data);  %M is the number of features you have 
% for count = 1:M
%     dx =  data{N, 11}; %Number of divisions/feature in X
%     dy =  data{N, 11}; %Number of divisions/feature in Y
%     dz =  data(N, 12}; %Number of divisions/feature in Z (layers)
%     
%     
% end

    
    




% --- Executes during object creation, after setting all properties.
function TextTimeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in View.
function View_Callback(hObject, eventdata, handles)
% hObject    handle to View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MI = getappdata(handles.figure1,'MI');

       Tprnt = getappdata(handles.figure1, 'Tprint');
       Stress = getappdata( handles.figure1, 'Stress');
       MeltFrac = getappdata (handles.figure1, 'MeltFrac');

numplots = 3; 
TimeStepOutput = get(handles.slider1,'Value'); %value between 0 and 1 from the slider


NumStep =str2num(get(handles.NumTimeSteps,'String')); %total number of time steps
StateN=round(NumStep*TimeStepOutput,0); %time step of interest 

if TimeStepOutput==0
    StateN=1;
end
if get(handles.VisualTemp,'Value')==1
    if isempty(Tprnt)
        AddStatusLine('No temperature solution exists.')
    else
       numplots = numplots+1;
       figure(numplots)
       pause(.001)
       Visualize(sprintf('t=%1.2f ms, State: %i of %i',StateN*MI.DeltaT*1000, StateN,length(Tprnt(1,1,1,:))),MI ...
       ,'state', Tprnt(:,:,:,StateN), 'RemoveMaterial',[0] ...
       ,'scaletitle', 'Temperature' ...
       )                      
    end
end

if get(handles.VisualStress,'Value')==1
    if isempty(Stress)
        AddStatusLine('No stress solution exists.')
    else
       numplots =numplots+1;
       figure(numplots)
       pause(.001)
       Visualize(sprintf('t=%1.2f ms, State: %i of %i',StateN*MI.DeltaT*1000, StateN,length(Stress(1,1,1,:))),MI ...
       ,'state', Stress(:,:,:,StateN) ...
       ,'scaletitle', 'Stress' ...
       )                      
    end
end

if get(handles.VisualMelt,'Value')==1
    if isempty(MeltFrac)
        AddStatusLine('No melt-fraction solution exists.')
    else
       figure(numplots+1)
       pause(.001)
       Visualize(sprintf('t=%1.2f ms, State: %i of %i',StateN*MI.DeltaT*1000, StateN,length(MeltFrac(1,1,1,:))),MI ...
       ,'state', MeltFrac(:,:,:,StateN) ...
       ,'scaletitle', 'Melt Fraction' ...
       )                      
    end
end

% --- Executes during object creation, after setting all properties.
function VisualTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VisualTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function TimeStep_Callback(hObject, eventdata, handles)
% hObject    handle to TimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeStep as text
%        str2double(get(hObject,'String')) returns contents of TimeStep as a double


TimeStepOutput = str2num(get(handles.TimeStep,'String')); 
NumStepOutput = str2num(get(handles.NumTimeSteps,'String')); 
TotalTime = TimeStepOutput*NumStepOutput;

TimeStepString = strcat('Total Time = ',num2str(TotalTime), ' sec'); %create output string
set(handles.totaltime,'String',TimeStepString);   %output string to GUI

function NumTimeSteps_Callback(hObject, eventdata, handles)
% hObject    handle to NumTimeSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumTimeSteps as text
%        str2double(get(hObject,'String')) returns contents of NumTimeSteps as a double

TimeStep_Callback(hObject, eventdata, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
F=get(handles.features,'userdata');
if not(isempty(F))
    delete(F)
end
delete(hObject);


% --- Executes during object creation, after setting all properties.
function LogoAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LogoAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate LogoAxes


function AddStatusLine(textline,AddToLastLine)
    if not(exist('AddToLastLine','var'))
        AddToLastLine=false;
    end
    handles=guidata(gcf);
    Hstat=handles.text10;
    if strcmpi(class(textline),'boolean') && textline
        set(Hstat,'text',{})
    else
        OldUnit=get(Hstat,'unit');
        set(Hstat,'unit','char');
        Pos=get(Hstat,'posit');
        Lines=floor(Pos(1));
        set(Hstat,'style','edit');
        set(Hstat,'enable','inactive')
        set(Hstat,'pos',[Pos(1) Pos(2) Pos(3) floor(Pos(4))+.5]);
        MaxChar=floor(Pos(3));
        MaxWidth=Pos(3)+1;
        set(Hstat,'max',10);
        if strcmpi(textline,'ClearStatus')
            set(Hstat,'string','')
        else
            OldText=get(Hstat,'string');
            textline=textline(1:min([MaxChar length(textline)]));
            if isempty(OldText)
                NewText=textline;
            else
                if AddToLastLine
    %                NewText=str2mat(OldText(1:end-1,:), [strtrim(OldText(end,:)) textline]);
                    NewText=str2mat([strtrim(OldText(1,:)), textline],OldText(2:end,:) );
                else
                    OldLines=length(OldText(:,1));
                    %OldText=OldText(max([1 OldLines-Lines+1]):end,:);
    %                NewText=str2mat(OldText,textline);
                    NewText=str2mat(textline,OldText);
                end
            end
            E=MaxWidth;  %The following while ensure that lines don't wrap around.
            while E>Pos(3)
                set(Hstat,'string',NewText)
                E=get(Hstat,'extent');
                E=E(3);
                NewText=NewText(:,1:end-1);
            end
        set(Hstat,'unit',OldUnit);
        end
    end
    
function VisUpdateStatus(handles, NeedsUpdate)
    %handles=guidata(gcf);
    AxisHandle=handles.GeometryVisualization;
    if not(isfield(handles,'VisualUpdateText')) || not(isvalid(handles.VisualUpdateText))
        handles.VisualUpdateText=text(AxisHandle,0.5,0.85,'Geometry Visualization Needs to be Updated',...
            'unit','normal',...
            'horizon','center',...
            'vis','off',...
            'color','white',...
            'background','red',...
            'fontweight','bold');
        guidata(AxisHandle,handles);
    end
    
    if NeedsUpdate
        set(handles.VisualUpdateText,'vis','on');
    else
        set(handles.VisualUpdateText,'vis','off');
    end

% --- Executes during object creation, after setting all properties.
function GeometryVisualization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GeometryVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate GeometryVisualization

function T=TableShowDataText
    T='Show Data';

%The data for each table entry is stored in an appdata structure.  The
%structure has the same number of elements as the data table has rows.  It
%is up to the user to ensure that the rows of the data tables remain
%consistent with the parent table.

%TableOpenClose is called in the selection callback
%TableDataName is used with getappdata to extract the table data
%TableShowDataText is called in the selection callbback to show text that
%is used.

function H=TableEditHandles(Description)
    C=get(gcf,'children');
    Panel=C(strcmpi(get(C,'tag'),'TableEdit'));
    Cp=get(Panel,'children');
    switch lower(Description)
        case 'panel'
            H=Panel;
        case 'axes'
            H=Cp(strcmpi(get(Cp,'type'),'axes'));
        case 'label'
            H=Cp(strcmpi(get(Cp,'tag'),'FeatureLabel'));
        case 'table'
            H=Cp(strcmpi(get(Cp,'type'),'uitable'));
        case 'sourcetable'
            F=C(strcmpi(get(C,'tag','DefineFeatures')));
            Fc=get(F,'children');
            H=cp(strcmpi(get(Cp,'tag'),'Features'));
        otherwise
            warning([Description 'Unknown handle requested.'])
                
    end
            
                
                
function T=TableDataName
    T='Qtables';
    
function TableOpenClose(Action,SourceTableHandle, Index)
    Data=getappdata(gcf,TableDataName);
    if exist('SourceTableHandle','var')
        setappdata(gcf,'SourceTableHandle',SourceTableHandle);
    else
        SourceTableHandle=getappdata(gcf,'SourceTableHandle');
    end
    FrameHandle=TableEditHandles('panel');
    %HList=get(FrameHandle,'children');
    LabelH=TableEditHandles('label');
    TableH=TableEditHandles('table');
    if strcmpi(Action,'open')
        Childs=get(gcf,'children');
        ChildVisState=get(Childs,'visible');
        setappdata(gcf,'ChildVisState',{Childs ChildVisState})
        set(Childs,'vis','off');
        set(FrameHandle,'userdata',Index);
        if Index > length(Data)
            Data=[0 0];
        else
            if isempty(Data{Index});
                Data=[ 0 0 ];
            else
                Data=Data{Index};
            end
        end
        TableData(:,2:3)=num2cell(Data);
        for I=1:length(TableData(:,1));
            TableData{I,1}=false;
        end
        set(TableH,'data',TableData);  
        set(LabelH,'string',sprintf('Feature %i',Index))
        TableGraph
        set(FrameHandle,'visible','on');
    elseif strcmpi(Action,'close')
        Index=get(FrameHandle,'userdata');
        TableData=get(TableH,'data');
        TableData=TableData(:,2:3);
        TableData=cell2mat(TableData);
        Data{Index}=TableData;
        setappdata(gcf,TableDataName,Data)
        C_States=getappdata(gcf,'ChildVisState');
        ChildHandles=C_States{1};
        ChildStates=C_States{2};
        for I=1:length(ChildHandles)
            set(ChildHandles(I),'vis',ChildStates{I});
        end
    end
    
% --- Executes on button press in TableAddRow.
function TableAddRow_Callback(hObject, eventdata, handles)
% hObject    handle to TableAddRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%TableH=get(get(hObject,'parent'),'children');
TableH=TableEditHandles('table');
Table=get(TableH,'data');
AddEndRow=true;
for I=length(Table(:,1)):-1:1
    if Table{I,1}
        Table{I,1}=false;
        AddEndRow=false;
        Table=[Table(1:I-1,:); { false [0] [0] }; Table(I:end,:)];
    end
end
if AddEndRow
    Table=[Table; { false [0] [0] }];
end    
set(TableH,'data',Table)
TableGraph(hObject)

% --- Executes on button press in TableDelRow.
function TableDelRow_Callback(hObject, eventdata, handles)
% hObject    handle to TableDelRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%TableH=get(get(hObject,'parent'),'children');
TableH=TableEditHandles('table');
Table=get(TableH,'data');
for I=length(Table(:,1)):-1:1
    if Table{I,1}
        Table=[Table(1:I-1,:); Table(I+1:end,:)];
    end
end
set(TableH,'data',Table)  
TableGraph(hObject)

% --- Executes on button press in TableClose.
function TableClose_Callback(hObject, eventdata, handles)
% hObject    handle to TableClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TableOpenClose('close')
set(get(hObject,'parent'),'visible','off')

%function GraphTable (hObject)
%    TableH=TableEditHandles('table');
%    AxesH=TableEditHandles('axes');
    

% --- Executes on button press in TableGraph.
function TableGraph(hObject, eventdata, handles)
% hObject    handle to TableGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TableH=TableEditHandles('table');
AxesH=TableEditHandles('axes');
Table=get(TableH,'data');
NTable=cell2mat(Table(:,2:3));
plot(AxesH,NTable(:,1),NTable(:,2))


% --- Executes when entered data in editable cell(s) in TableTable.
function TableTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TableTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
TableGraph(hObject)
% 
% % --- Executes on button press in TableAddRow.
% function TableAddRow_Callback(hObject, eventdata, handles)
% % hObject    handle to TableAddRow (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in TableDelRow.
% function TableDelRow_Callback(hObject, eventdata, handles)
% % hObject    handle to TableDelRow (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in TableClose.
% function TableClose_Callback(hObject, eventdata, handles)
% % hObject    handle to TableClose (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes when entered data in editable cell(s) in TableTable.
% function TableTable_CellEditCallback(hObject, eventdata, handles)
% % hObject    handle to TableTable (see GCBO)
% % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
% %	Indices: row and column indices of the cell(s) edited
% %	PreviousData: previous data for the cell(s) edited
% %	EditData: string(s) entered by the user
% %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
% %	Error: error string when failed to convert EditData to appropriate value for Data
% % handles    structure with handles and user data (see GUIDATA)

function v=QValueCol
    v=10;
function v=QTypeCol
    v=9;
function v=MatListCol
    v=8;



% --- Executes when selected cell(s) is changed in features.
function features_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to features (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
  if not(isempty(eventdata.Indices))
    Row=eventdata.Indices(1);
    Col=eventdata.Indices(2);
    Table=get(hObject, 'Data');
    if Col==QValueCol && strcmpi(Table{Row,QValueCol},TableShowDataText)
        TempData=get(hObject,'data');
        set(hObject,'data',[])        % Clear selected cell hack by deleting 
        set(hObject,'data',TempData)  % data and then reinstating data.
        TableOpenClose('open',hObject,Row)
    end
  end


function features_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to features (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
%Check to see if column with Q Type is being modified
VisUpdateStatus(handles, true)
Row=eventdata.Indices(1);
Col=eventdata.Indices(2);
%CellTableData=get(hObject,'userdata');
if Col==QTypeCol
    %disp('changing Q Type')
    Table=get(hObject,'data');
    if strcmpi(eventdata.NewData,'Table')
        Table{Row,QValueCol}=TableShowDataText;
%        CellTableData{Row}=[0 0];
    else
        Table{Row,QValueCol}=[];
%        CellTableData{Row}=[];
    end
    set(hObject,'Data',Table);
 %   set(hObject,'userdata',CellTableData);
elseif Col==QValueCol
    if strcmpi(eventdata.PreviousData,TableShowDataText)
        Table{Row,QValueCol}=TableShowDataText;
        set(hObject,'Data',Table);
    end
end


% --- Executes when entered data in editable cell(s) in ExtCondTable.
function ExtCondTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ExtCondTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
    VisUpdateStatus(handles,true)


% --- Executes when selected object is changed in AnalysisType.
function AnalysisType_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in AnalysisType 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    Chooser=get(hObject,'string');
    if strncmpi(Chooser,'static',6)
        set([handles.text5 handles.text4 handles.TimeStep handles.NumTimeSteps handles.totaltime],'enable','off');
    elseif strncmpi(Chooser,'transient',8)
        set([handles.text5 handles.text4 handles.TimeStep handles.NumTimeSteps handles.totaltime],'enable','on');
    end
