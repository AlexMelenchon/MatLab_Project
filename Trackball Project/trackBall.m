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

%We create the global variables that will be used through all the code------

%This saves the rotation of the user input while it drags; the quaternion
%calculated is always seen like it's from what we determined front of the
%cube, because, in our script, we rotate 2 times: one with this quaternion &
%the other one with the previous rotation
global prevQuat;
prevQuat = [1;0;0;0];

%This stores the rotation between drags. What we do, is that we update this
%rotation only when the user stops draggin &, it is equal to the current
%drag rotation (prevQuat) * itself; what this does is that, when we rotate
%in the next click, the rotation inputed by the user will calculate itself
%like it is seen from the front (check prevQuat) & it will we rotated by
%this, causing the rotation to start & match the user's viewport
global prevRot;
prevRot = [1;0;0;0];

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

% We update the previous rotation: what this does is match the "next click
% rotation" with our viewport, because, when we rotate, the rotation given
% by the calculated quaternion is always seen from the font; the previous
% rotation makes that rotation has the impact that is expected by the user
% (Check the comments in the declaration of the global variables for more
% info)
updatePrevRot(0);

guidata(hObject,handles);
end

function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

%Variables used in the calculations----------------------
%Radius--
radius = sqrt(3);

%Normal--
NormalFromOrigin = [0;0;1];

%We will only do the logic if the mouse if over the axis
if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    %Start calculating the next rotation-------
    global prevQuat;
    global prevRot;
    
    %We calculate the vector where the input is being done using Holroyd�s 
    %arcball
    vec3=SpaceCoordsToVec3(xmouse,ymouse,radius);
    
    %Then we create the new quaternion from the vector
    newQ=QuatFrom2Vec(vec3, NormalFromOrigin);
    newQ = newQ/ sqrt(newQ' * newQ);
        
    %Set the new quaternion
    set(handles.quat_0, 'String',newQ(1));
    set(handles.quat_1, 'String', newQ(2));
    set(handles.quat_2, 'String', newQ(3));
    set(handles.quat_3, 'String', newQ(4)); 
    
    %Calculate the new rotation from the new Quaternion & the previous
    %rotation
    R=quaternion2rotM(quaternionMultiplication(newQ, prevRot));
    
    
    %Send the new rotation to the other param. + cube
    ReCalculateParametrization(R, 2, handles);
    prevQuat =  newQ;

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

%We reset all the global variables back into their original values (a.k.a identity)
global prevQuat;
global prevRot;
prevQuat = [1;0;0;0];
prevRot = eye(3);

%We reset the cube & all the param. back to starting rotation.
R= eye(3);
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

%We get the re-written rotation vector
r = [
str2double(get(handles.rotVec_x, 'String'));
str2double(get(handles.rotVec_y, 'String'));
str2double(get(handles.rotVec_z, 'String'));
]

%We check if any of the inputs was intended to be pi, for more accurate
%calculations
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

%We craete a new rotation matrix from the rotation vector % we update the
%other param.
R = RotVec2RotMat(r);
ReCalculateParametrization(R, 5, handles);

% Update the global variables used in the rotation
updatePrevRot(1);

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

%Get the re-written euler angles
yaw =  str2double(get(handles.eangles_Yaw, 'String'));
pitch = str2double(get(handles.eAngles_pitch, 'String'));
roll = str2double(get(handles.eAngles_roll, 'String'));

%Check Boundaries (for visability porpuses)-----
if(yaw > 360) yaw = yaw - 360; end;
set(handles.eangles_Yaw, 'String',yaw);
       
if(pitch > 360) pitch = pitch - 360; end;
set(handles.eAngles_pitch, 'String', pitch);
       
if(roll > 360) roll = roll - 360; end;
set(handles.eAngles_roll, 'String',roll);       

%Create the new rotation matrix from the euler angles & update the other
%param.
R = eAngles2rotM(yaw, pitch, roll);
ReCalculateParametrization(R, 4, handles);

% Update the global variables used in the rotation
updatePrevRot(1);

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

%Get the re-written axis & angle
angle =  str2double(get(handles.eaa_angle, 'String'));

if(angle > 360) angle = angle - 360; end;
set(handles.eaa_angle, 'String',angle);       


u = [
str2double(get(handles.eaa_aixsX, 'String'));
str2double(get(handles.eaa_axisY, 'String'));
str2double(get(handles.eaa_axisZ, 'String'));
]

%Create the new rotation matrix from the axis & angle & update the other
%param.
R = Eaa2rotMat(angle,u)
ReCalculateParametrization(R, 3, handles);

% Update the global variables used in the rotation
updatePrevRot(1);

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

% Get the re-written quaternion
q = [
str2double(get(handles.quat_0, 'String'));
str2double(get(handles.quat_1, 'String'));
str2double(get(handles.quat_2, 'String'));
str2double(get(handles.quat_3, 'String'));
]

%Create the rotation matrix from the quaternions & update the the other
%param.
R = quaternion2rotM(q);
ReCalculateParametrization(R, 2, handles);

% Update the global variables used in the rotation
updatePrevQuat(q,1);
updatePrevRot(1);

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
    
    %Re-draw the cube according to the new rotation.
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
       newQuat = [1,0,0,0]; 
       a = 0;
       u = [0;0;0];
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
    
    %Update the quaternions, if it's not already updated    
    if(alreadyComp ~= 2)
       newQuat = rotMat2Quaternion(R);       
       updatePrevQuat(newQuat, 1);
       %Set handles
       set(handles.quat_0, 'String',newQuat(1));
       set(handles.quat_1, 'String', newQuat(2));
       set(handles.quat_2, 'String', newQuat(3));
       set(handles.quat_3, 'String', newQuat(4));

    end
    
    %Update the euler principal axis & angle, if it's not already updated
     if(alreadyComp ~= 3)
       [a,u] = rotMat2Eaa(R); 
       
       %Set handles
       set(handles.eaa_angle, 'String',a);
       set(handles.eaa_aixsX, 'String', u(1));
       set(handles.eaa_axisY, 'String',u(2));
       set(handles.eaa_axisZ, 'String', u(3));
       
     end
    
      %Update the euler angles, if it's not already updated
     if(alreadyComp ~= 4)
       [yaw, pitch, roll] = rotM2eAngles(R);
       
       %Set handles
       set(handles.eangles_Yaw, 'String',yaw);
       set(handles.eAngles_pitch, 'String', pitch);
       set(handles.eAngles_roll, 'String',roll);       
     end
    
     %Update the rotation axis, if it's not already updated
      if(alreadyComp ~= 5)
       [r] = RotMat2rotVec(R);
       %Set handles
       set(handles.rotVec_x, 'String',r(1));
       set(handles.rotVec_y, 'String', r(2));
       set(handles.rotVec_z, 'String',r(3));       
      end
end

%Updates the previous rotation so the inputs match w/ the actual cube
%rotation (called in MouseRelease & when updating any param.)
function [] = updatePrevRot(toReset)
%ToReset is a flag that tells if we have to reset the prevRot or not.
% Reset = 1
% NoReset = 0
% This is used so when the user pushes a new param. we get back to the
% origin, so we don't drag errors & so the rotation doesn't cause any
% critical condition w/ the previous stablished rotation &, therefore, the
% input from the user start not matching the viewport
global prevQuat;
global prevRot;

if(toReset == 1)
   prevRot = eye(3);
end;

prevRot = quaternionMultiplication(prevQuat, prevRot);
end

%Updates the prevoius Quaternion, that is the rotation that the user inputs
% while dragging.
function [] = updatePrevQuat(newQuat, toReset)
%ToReset is a flag that tells if we have to reset the prevQuat or not.
% Reset = 1
% NoReset = 0
% This is used so when the user pushes a new param. we get back to the
% origin, so we don't drag errors & so the rotation doesn't cause any
% critical condition w/ the previous stablished rotation &, therefore, the
% input from the user start not matching the viewport
global prevQuat;

if(toReset == 1)
   prevQuat = [1;0;0;0];
end;
   
prevQuat =  newQuat;
end
