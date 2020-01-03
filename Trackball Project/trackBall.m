function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 02-Jan-2020 17:18:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
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
end

% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)


set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.axes1});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.axes1});
axes(handles.axes1);

global prevVec;
prevVec = [0;0;1];

global prevQuat;
prevQuat = [1;0;0;0];

handles.Cube=DrawCube(eye(3));

set(handles.axes1,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.axes1,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
end
guidata(hObject,handles)
end

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.figure1,'WindowButtonMotionFcn','');
guidata(hObject,handles);
end

function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);
radius = sqrt(3);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    %%% DO things
    global prevVec;
    global prevQuat;
    
    vec3=SpaceCoordsToVec3(xmouse,ymouse,radius);
    newQ=QuatFrom2Vec(vec3, prevVec);
    newQ = newQ/ sqrt(newQ' * newQ);

    %Calculate = ?q;
    prevQuatConj = prevQuat;
    prevQuatConj(2:4) = -prevQuatConj(2:4);
    dq = quaternionMultiplication(newQ, prevQuatConj);
    
    % Calculate new quaternion
    dq = dq/ sqrt(dq' * dq);
    qK = quaternionMultiplication(dq, prevQuat);
    
    %Set the new quaternion
    set(handles.quat_0, 'String',qK(1));
    set(handles.quat_1, 'String', qK(2));
    set(handles.quat_2, 'String', qK(3));
    set(handles.quat_3, 'String', qK(4)); 
   
    %Send the new rotation to the other param. + cube
    R=quaternion2rotM(qK);
    handles.Cube = RedrawCube(R,handles.Cube);
    ReCalculateParametrization(R, 2, handles);
    prevQuat =  qK;
    prevVec = (vec3 + prevVec);
     
end
guidata(hObject,handles);
end

function h = DrawCube(R)

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end

end

function h = RedrawCube(R,hin)

h = hin;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end
end





% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

R= eye(3);
global prevVec;
global prevQuat;
prevVec = [1;1;1];
prevQuat = [1;0;0;0];

handles.Cube = RedrawCube(R, handles.Cube);

ReCalculateParametrization(R, 1, handles);

end



function eaa_aixsX_Callback(hObject, eventdata, handles)
% hObject    handle to eaa_aixsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eaa_aixsX as text
%        str2double(get(hObject,'String')) returns contents of eaa_aixsX as a double
end


% --- Executes during object creation, after setting all properties.
function eaa_aixsX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eaa_aixsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function rotVec_y_Callback(hObject, eventdata, handles)
% hObject    handle to rotVec_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotVec_y as text
%        str2double(get(hObject,'String')) returns contents of rotVec_y as a double
end


% --- Executes during object creation, after setting all properties.
function rotVec_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotVec_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function rotVec_z_Callback(hObject, eventdata, handles)
% hObject    handle to rotVec_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotVec_z as text
%        str2double(get(hObject,'String')) returns contents of rotVec_z as a double
end


% --- Executes during object creation, after setting all properties.
function rotVec_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotVec_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function rotVec_x_Callback(hObject, eventdata, handles)
% hObject    handle to rotVec_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotVec_x as text
%        str2double(get(hObject,'String')) returns contents of rotVec_x as a double
end

% --- Executes during object creation, after setting all properties.
function rotVec_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotVec_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in rotVec_button.
function rotVec_button_Callback(hObject, eventdata, handles)
% hObject    handle to rotVec_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

r = [
str2double(get(handles.rotVec_x, 'String'));
str2double(get(handles.rotVec_y, 'String'));
str2double(get(handles.rotVec_z, 'String'));
]

if(abs(r(1) - pi ) < 0.15)
r(1) = pi;
set(handles.rotVec_x, 'String',r(1));
end

if(abs(r(2) - pi ) < 0.15)
r(2) = pi;
set(handles.rotVec_y, 'String',r(2));
end

if(abs(r(3) - pi ) < 0.15)
r(3) = pi;
set(handles.rotVec_z, 'String',r(3));
end

if(abs(r(3) - pi ) < 0.15) r(2) = pi; end
if(abs(r(2) - pi ) < 0.15) r(3) = pi; end


R = RotVec2RotMat(r);

ReCalculateParametrization(R, 5, handles);

end



function eangles_Yaw_Callback(hObject, eventdata, handles)
% hObject    handle to eangles_Yaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eangles_Yaw as text
%        str2double(get(hObject,'String')) returns contents of eangles_Yaw as a double
end


% --- Executes during object creation, after setting all properties.
function eangles_Yaw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eangles_Yaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in eAngle_button.
function eAngle_button_Callback(hObject, eventdata, handles)
% hObject    handle to eAngle_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

yaw =  str2double(get(handles.eangles_Yaw, 'String'));
pitch = str2double(get(handles.eAngles_pitch, 'String'));
roll = str2double(get(handles.eAngles_roll, 'String'));

R = eAngles2rotM(yaw, pitch, roll);

ReCalculateParametrization(R, 4, handles);

end


function eAngles_pitch_Callback(hObject, eventdata, handles)
% hObject    handle to eAngles_pitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eAngles_pitch as text
%        str2double(get(hObject,'String')) returns contents of eAngles_pitch as a double
end


% --- Executes during object creation, after setting all properties.
function eAngles_pitch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eAngles_pitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function eAngles_roll_Callback(hObject, eventdata, handles)
% hObject    handle to eAngles_roll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eAngles_roll as text
%        str2double(get(hObject,'String')) returns contents of eAngles_roll as a double
end


% --- Executes during object creation, after setting all properties.
function eAngles_roll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eAngles_roll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function eaa_angle_Callback(hObject, eventdata, handles)
% hObject    handle to eaa_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eaa_angle as text
%        str2double(get(hObject,'String')) returns contents of eaa_angle as a double
end


% --- Executes during object creation, after setting all properties.
function eaa_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eaa_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function eaa_axisY_Callback(hObject, eventdata, handles)
% hObject    handle to eaa_axisY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eaa_axisY as text
%        str2double(get(hObject,'String')) returns contents of eaa_axisY as a double
end


% --- Executes during object creation, after setting all properties.
function eaa_axisY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eaa_axisY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function eaa_axisZ_Callback(hObject, eventdata, handles)
% hObject    handle to eaa_axisZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eaa_axisZ as text
%        str2double(get(hObject,'String')) returns contents of eaa_axisZ as a double
end


% --- Executes during object creation, after setting all properties.
function eaa_axisZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eaa_axisZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in Eaa_button.
function Eaa_button_Callback(hObject, eventdata, handles)
% hObject    handle to Eaa_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

angle =  str2double(get(handles.eaa_angle, 'String'));

u = [
str2double(get(handles.eaa_aixsX, 'String'));
str2double(get(handles.eaa_axisY, 'String'));
str2double(get(handles.eaa_axisZ, 'String'));
]

R = Eaa2rotMat(angle,u)

ReCalculateParametrization(R, 3, handles);

end



function quat_0_Callback(hObject, eventdata, handles)
% hObject    handle to quat_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quat_0 as text
%        str2double(get(hObject,'String')) returns contents of quat_0 as a double
end


% --- Executes during object creation, after setting all properties.
function quat_0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quat_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function quat_1_Callback(hObject, eventdata, handles)
% hObject    handle to quat_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quat_1 as text
%        str2double(get(hObject,'String')) returns contents of quat_1 as a double
end

% --- Executes during object creation, after setting all properties.
function quat_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quat_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function quat_2_Callback(hObject, eventdata, handles)
% hObject    handle to quat_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quat_2 as text
%        str2double(get(hObject,'String')) returns contents of quat_2 as a double
end


% --- Executes during object creation, after setting all properties.
function quat_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quat_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function quat_3_Callback(hObject, eventdata, handles)
% hObject    handle to quat_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quat_3 as text
%        str2double(get(hObject,'String')) returns contents of quat_3 as a double
end

% --- Executes during object creation, after setting all properties.
function quat_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quat_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in quat_button.
function quat_button_Callback(hObject, eventdata, handles)
% hObject    handle to quat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

q = [
str2double(get(handles.quat_0, 'String'));
str2double(get(handles.quat_1, 'String'));
str2double(get(handles.quat_2, 'String'));
str2double(get(handles.quat_3, 'String'));
]

R = quaternion2rotM(q);

ReCalculateParametrization(R, 2, handles);

end


function R12_Callback(hObject, eventdata, handles)
% hObject    handle to R12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R12 as text
%        str2double(get(hObject,'String')) returns contents of R12 as a double
end

% --- Executes during object creation, after setting all properties.
function R12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R13_Callback(hObject, eventdata, handles)
% hObject    handle to R13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R13 as text
%        str2double(get(hObject,'String')) returns contents of R13 as a double
end

% --- Executes during object creation, after setting all properties.
function R13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function R11_Callback(hObject, eventdata, handles)
% hObject    handle to R11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R11 as text
%        str2double(get(hObject,'String')) returns contents of R11 as a double
end

% --- Executes during object creation, after setting all properties.
function R11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R22_Callback(hObject, eventdata, handles)
% hObject    handle to R22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R22 as text
%        str2double(get(hObject,'String')) returns contents of R22 as a double
end

% --- Executes during object creation, after setting all properties.
function R22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R23_Callback(hObject, eventdata, handles)
% hObject    handle to R23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R23 as text
%        str2double(get(hObject,'String')) returns contents of R23 as a double
end

% --- Executes during object creation, after setting all properties.
function R23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R21_Callback(hObject, eventdata, handles)
% hObject    handle to R21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R21 as text
%        str2double(get(hObject,'String')) returns contents of R21 as a double
end

% --- Executes during object creation, after setting all properties.
function R21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R32_Callback(hObject, eventdata, handles)
% hObject    handle to R32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R32 as text
%        str2double(get(hObject,'String')) returns contents of R32 as a double
end

% --- Executes during object creation, after setting all properties.
function R32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R33_Callback(hObject, eventdata, handles)
% hObject    handle to R33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R33 as text
%        str2double(get(hObject,'String')) returns contents of R33 as a double
end

% --- Executes during object creation, after setting all properties.
function R33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function R31_Callback(hObject, eventdata, handles)
% hObject    handle to R31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R31 as text
%        str2double(get(hObject,'String')) returns contents of R31 as a double
end

% --- Executes during object creation, after setting all properties.
function R31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function [] = ReCalculateParametrization(R, alreadyComp, handles)
%alreadyComp is a flag that we set to not recalculate already computed
%parametrization:
    % Rotation Matrix = 1; when this occours, everyone will we reset.
    %Quaterion = 2;
    % Euler Axis & Angle = 3;
    % Euler Angles = 4;
    % Rotation Vector = 5;
     handles.Cube = RedrawCube(R,handles.Cube);
     
     %First of all, we set the new matrix into the UI
        set(handles.R11, 'String', R(1,1));
        set(handles.R12, 'String', R(1,2));
        set(handles.R13, 'String', R(1,3));

        set(handles.R21, 'String', R(2,1));
        set(handles.R22, 'String', R(2,2));
        set(handles.R23, 'String', R(2,3));

        set(handles.R31, 'String', R(3,1));
        set(handles.R32, 'String', R(3,2));
        set(handles.R33, 'String', R(3,3));
    
    if (alreadyComp == 1)
        %TODO: do not calculate, but put everything to identity
       newQuat = [1,0,0,0]; 
       a = 0;
       u = [0,0,0]
       yaw = 0;
       pitch = 0;
       roll = 0;
        r = [0,0,0]
        %Set handles---------------------
        
        % Quat
       set(handles.quat_0, 'String',newQuat(1));
       set(handles.quat_1, 'String', newQuat(2));
       set(handles.quat_2, 'String', newQuat(3));
       set(handles.quat_3, 'String', newQuat(4));
       
       % Euler principal axis & angle
       set(handles.eaa_angle, 'String',a);
       set(handles.eaa_aixsX, 'String', u(1));
       set(handles.eaa_axisY, 'String',u(2));
       set(handles.eaa_axisZ, 'String', u(3));
       
       % Euler angles
       set(handles.eangles_Yaw, 'String',yaw);
       set(handles.eAngles_pitch, 'String', pitch);
       set(handles.eAngles_roll, 'String',roll);       
              
       % Rotation Vector
       set(handles.rotVec_x, 'String',r(1));
       set(handles.rotVec_y, 'String', r(2));
       set(handles.rotVec_z, 'String',r(3));       
       

       return;        
    end
    
    
    if(alreadyComp ~= 2)
       newQuat = rotMat2Quaternion(R); 
       
       %Set handles
       set(handles.quat_0, 'String',newQuat(1));
       set(handles.quat_1, 'String', newQuat(2));
       set(handles.quat_2, 'String', newQuat(3));
       set(handles.quat_3, 'String', newQuat(4));

    end
    
     if(alreadyComp ~= 3)
       [a,u] = rotMat2Eaa(R); 
       
       %Set handles
       set(handles.eaa_angle, 'String',a);
       set(handles.eaa_aixsX, 'String', u(1));
       set(handles.eaa_axisY, 'String',u(2));
       set(handles.eaa_axisZ, 'String', u(3));
       
     end
    
     if(alreadyComp ~= 4)
       [yaw, pitch, roll] = rotM2eAngles(R);
       %Set handles
       set(handles.eangles_Yaw, 'String',yaw);
       set(handles.eAngles_pitch, 'String', pitch);
       set(handles.eAngles_roll, 'String',roll);       
     end
    
      if(alreadyComp ~= 5)
       [r] = RotMat2rotVec(R);
       %Set handles
       set(handles.rotVec_x, 'String',r(1));
       set(handles.rotVec_y, 'String', r(2));
       set(handles.rotVec_z, 'String',r(3));       
    end



end
