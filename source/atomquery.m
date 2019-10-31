function varargout = atomquery(varargin)
% ATOMQUERY M-file for atomquery.fig
%      ATOMQUERY, by itself, creates a new ATOMQUERY or raises the existing
%      singleton*.
%
%      H = ATOMQUERY returns the handle to a new ATOMQUERY or the handle to
%      the existing singleton*.
%
%      ATOMQUERY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATOMQUERY.M with the given input arguments.
%
%      ATOMQUERY('Property','Value',...) creates a new ATOMQUERY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before atomquery_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to atomquery_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help atomquery

% Last Modified by GUIDE v2.5 27-Jun-2013 16:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @atomquery_OpeningFcn, ...
                   'gui_OutputFcn',  @atomquery_OutputFcn, ...
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


% --- Executes just before atomquery is made visible.
function atomquery_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to atomquery (see VARARGIN)

% Choose default command line output for atomquery
%added by Luke.Qin, we do not find where to officially input 20181017
hObject.Name = 'Standard atmosphere query - Powered By Luke.Qin';
handles.output = hObject;
movegui('center')
pos=get(gcf,'Position');
pos(2)=pos(2)*1.5;
set(gcf,'Position',pos);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes atomquery wait for user response (see UIRESUME)
% uiwait(handles.fig_atomqury);


% --- Outputs from this function are returned to the command line.
function varargout = atomquery_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_altde_Callback(hObject, eventdata, handles)
% hObject    handle to edit_altde (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_altde as text
%        str2double(get(hObject,'String')) returns contents of edit_altde as a double
p=GetEditData(hObject,eventdata,handles);
% gain dynamic data
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_altde_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_altde (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mach_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mach as text
%        str2double(get(hObject,'String')) returns contents of edit_mach as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('Mach should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
% gain dynamic data
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_mach_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_qc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_qc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_qc as text
%        str2double(get(hObject,'String')) returns contents of edit_qc as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('VC should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
if get(handles.radio_altde,'Value')
    [p.altde,p.mach]=qc2atom(p.qc,p.altde,1);
else
    [p.altde,p.mach]=qc2atom(p.qc,p.mach,2);
end
% get dynamic data
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_qc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_qc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ps as text
%        str2double(get(hObject,'String')) returns contents of edit_ps as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('ps should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
% gain altitude
p.altde=ps2atom(p.ps);
% get VC
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)


% --- Executes during object creation, after setting all properties.
function edit_ps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rho_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rho as text
%        str2double(get(hObject,'String')) returns contents of edit_rho as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('density should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
% get alt
p.altde=rho2atom(p.rho);
% get dynamic data
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_snd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_snd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_snd as text
%        str2double(get(hObject,'String')) returns contents of edit_snd as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('Va should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
% get alt
p.altde=snd2atom(p.snd);
% get dynamic data
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_snd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_snd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vc as text
%        str2double(get(hObject,'String')) returns contents of edit_vc as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('vc should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
if get(handles.radio_altde,'Value')
    [p.altde,p.mach]=vc2atom(p.vc,p.altde,1);
else
    [p.altde,p.mach]=vc2atom(p.vc,p.mach,2);
end
% get dynamic value
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_vc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_va_Callback(hObject, eventdata, handles)
% hObject    handle to edit_va (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_va as text
%        str2double(get(hObject,'String')) returns contents of edit_va as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('va should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
if get(handles.radio_altde,'Value')
    [p.altde,p.mach]=va2atom(p.va,p.altde,1);
else
    [p.altde,p.mach]=va2atom(p.va,p.mach,2);
end
% get dynamic value
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_va_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_va (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function p=GetEditData(hObject,eventdata,handles)
hh=[hObject,handles.edit_altde,handles.edit_mach];
% hh=findobj(gcf,'-regexp','tag','edit_.+');
prop=get(hh,{'tag','string'});
for ii=1:size(prop,1)
        p.(prop{ii,1}(6:end))=eval(prop{ii,2}); 
end

function SetEditData(handles,p)
p.temp=atmoscoesa(p.altde,'None');
field=fieldnames(p);
for ii=1:length(field)
    set(handles.(['edit_',field{ii}]),'string',num2str(p.(field{ii})));
end



function edit_qc2ps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_qc2ps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_qc2ps as text
%        str2double(get(hObject,'String')) returns contents of edit_qc2ps as a double
try
    value=eval(get(gcbo,'String'));
    if value<0
        errordlg('qc2ps should not smaller than 0！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
% if get(handles.radio_mach,'Value')
%     errordlg({'A fixed Mach value should have only one qcops value!'
%         ''
%         '换句话说，只要马赫数确定，任意高度动静压之比都是相同的。'},'Input error','modal');
%     return;
% end
p=GetEditData(hObject,eventdata,handles);
if get(handles.radio_altde,'Value')
    [p.altde,p.mach]=qcps2atom(p.qc2ps,p.altde,1);
else
    [p.altde,p.mach]=qcps2atom(p.qc2ps,p.altde,1);
end
% get dynamic value
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_qc2ps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_qc2ps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_temp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_temp as text
%        str2double(get(hObject,'String')) returns contents of edit_temp as a double
try
    value=eval(get(gcbo,'String'));
    if value<=-273
        errordlg('temperature should not smaller than -273 degree Celsius！','Input error','modal');
        return
    end
catch exception
    errordlg(exception.message,'Input error','modal');
    return;
end
p=GetEditData(hObject,eventdata,handles);
% get alt
p.altde=fzero(@(altde)atmoscoesa(altde,'None')-p.temp,5000);
% get dynamic value
[p.vc,p.va,p.qc,p.ps,p.qc2ps,p.snd,p.rho]=atomdynamic(p.altde,p.mach);
SetEditData(handles,p)

% --- Executes during object creation, after setting all properties.
function edit_temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
