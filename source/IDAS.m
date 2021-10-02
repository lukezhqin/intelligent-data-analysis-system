%% ========================================
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
% use "mcc -e IDAS" cmd to generate the exe-file
function IDAS

global layout rootpath  % initialized when import IDASpara
rootpath=pwd;

if ~isempty(findobj('Name','IDAS'))
    delete(findobj('Name','IDAS'));
end
handles.IDAS=figure('Name','IDAS',...
    'Numbertitle','off',...
    'MenuBar','none',...
    'toolbar','none',...
    'Resize','off',...
    'Color',[0.31 0.4 0.58],...
    'Units','normalized',...
    'Position',[0.15 0.4 0.75 0.47],...
    'CloseRequestFcn',@exit_Callback);
% change icon
chgicon(handles.IDAS,'train.png');

% -----------------menu------------------
h_menu=uimenu(handles.IDAS,'Label','Help');
h1_submenu=uimenu(h_menu,...
    'Label','Manual',...
    'Callback','winopen(''Manual.doc'')');
h2_submenu=uimenu(h_menu,...
    'Label','IDAS Version',...
    'Callback','msgbox(''IDAS Version 1.6 , Mar. 26,2019'');');
%----------------uipanel-------------------
handles.uipanel  =  uipanel(handles.IDAS,...
    'BackgroundColor',[0.9 0.95 0.95],...
    'Units','normalized',...
    'Position',[0.05 0.13 0.45 0.77]);
% handles.text_headerfile=uicontrol(handles.uipanel,'Style','text',...
%                                 'String','header files',...
%                                 'FontSize',10,...
%                                 'HorizontalAlignment','left',...
%                                 'BackgroundColor',[0.9 0.95 0.95],...
%                                 'Units','normalized',...
%                                 'Position',[0.05 0.9 0.4 0.08]);
% handles.editbox_headerfile=uicontrol(handles.uipanel,'Style','listbox',...
%                                 'Tag','editbox_headerfile',...          % Tag:user-specified object identifier
%                                 'HorizontalAlignment','left',...
%                                 'BackgroundColor','white',...
%                                 'FontSize',10,...
%                                 'Units','normalized',...
%                                 'Position',[0.05 0.85 0.91 0.08],...
%                                 'Callback',@viewheaderfile_Callback);
handles.text_datafile=uicontrol(handles.uipanel,'Style','text',...
    'String','Data file£º',...
    'FontSize',10,...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.9 0.95 0.95],...
    'Units','normalized',...
    'Position',[0.05 0.88 0.4 0.08]);
handles.filelist=uicontrol(handles.uipanel,'Style','listbox',...
    'Tag','filelist',...
    'Units','normalized',...
    'BackgroundColor','white',...
    'FontSize',10,...
    'Position',[0.05 0.05 0.91 0.82],...
    'Min',0,...
    'Max',2,...         %  If Max - Min > 1, then list boxes allow multiple item selection
    'Callback',@filelist_ButtonDownFcn,...  % left click to add files
    'ButtonDownFcn',@delete_Callback,...    % right click to delete files
    'KeyPressFcn',@filelist_KeyPressFcn);   % ctr+del delete all£¬del delete the chosen file
handles.extend_comp=uicontrol(handles.uipanel,'Style','checkbox',...
    'Tag','extend_comp',...
    'String','Plot compare',...
    'FontSize',10,...
    'BackgroundColor',[0.9 0.95 0.95],...
    'Units','normalized',...
    'Position',[0.5 0.9 0.4 0.08],...
    'Callback',@extend_comp);
handles.filelist_comp=uicontrol(handles.uipanel,'Style','listbox',...% choose files in this window to do batch cmd
    'Tag','filelist_comp',...
    'Units','normalized',...
    'BackgroundColor','white',...
    'FontSize',10,...
    'Position',[0.51 0.05 0.45 0.82],...
    'Min',0,...
    'Max',2,...         %  If Max - Min > 1, then list boxes allow multiple item selection
    'Visible','off',...
    'Callback',@filelist_ButtonDownFcn,...  % left click to add files
    'ButtonDownFcn',@delete_Callback,...    % right click to delet files
    'KeyPressFcn',@filelist_KeyPressFcn);   % ctr+del delete all£¬del delete the chosen file
% -----------------------------right UI-----------------------
handles.text_axis=uicontrol(handles.IDAS,'Style','text',...
    'Tag','text_axis',...
    'String','X-Axis : Time',...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.31 0.4 0.58],...
    'ForegroundColor','white',...
    'Units','normalized',...
    'Position',[0.55 0.92 0.2 0.03],...
    'UserData',0);
handles.text_TotalVarNo=uicontrol(handles.IDAS,'Style','text',...
    'Tag','text_TotalVarNo',...
    'String','Total :',...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.31 0.4 0.58],...
    'ForegroundColor','white',...
    'Units','normalized',...
    'Position',[0.75 0.92 0.1 0.03]);
handles.text_SelectedVarNo=uicontrol(handles.IDAS,'Style','text',...
    'Tag','text_SelectedVarNo',...
    'String','Selected :',...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.31 0.4 0.58],...
    'ForegroundColor','white',...
    'Units','normalized',...
    'Position',[0.85 0.92 0.1 0.03]);
handles.varlist=uicontrol(handles.IDAS,'Style','listbox',...
    'Tag','varlist',...
    'HorizontalAlignment','left',...
    'BackgroundColor','white',...
    'FontSize',10,...
    'Min',0,...
    'Max',2,...             %  If Max - Min > 1, then list boxes allow multiple item selection
    'Value',[],...
    'Units','normalized',...
    'Position',[0.55 0.13 0.4 0.77],...
    'ButtonDownFcn',@varlist_ButtonDownFcn,...
    'KeyPressFcn',@varlist_KeyPressFcn);
handles.varorder=uicontrol(handles.IDAS,'Style','listbox',...
    'Tag','varorder',...
    'HorizontalAlignment','left',...
    'BackgroundColor','white',...
    'FontSize',10,...
    'Min',0,...
    'Max',1,...             %  If Max - Min > 1, then list boxes allow multiple item selection
    'Userdata',[],...
    'Visible','off',...
    'Units','normalized',...
    'Position',[0.755 0.13 0.195 0.77],...
    'KeyPressFcn',@varorder_KeyPressFcn,...
    'ButtonDownFcn',@varorder_ButtonDownFcn);
handles.extend=uicontrol(handles.IDAS,'Style','pushbutton',...
    'Tag','extend',...
    'String','<',...
    'TooltipString','open the sort window',...
    'Units','normalized',...
    'Position',[0.96 0.45 0.02 0.06],...
    'Callback',@extend_Callback);
handles.Export=uicontrol(handles.IDAS,'Style','pushbutton',...
    'Tag','export',...
    'String','Export',...
    'Units','normalized',...
    'Position',[0.55 0.03 0.06 0.06],...
    'Callback',@export_Callback);
handles.Plot=uicontrol(handles.IDAS,'Style','pushbutton',...
    'Tag','plot',...
    'String','Plot',...
    'Units','normalized',...
    'Position',[0.79 0.03 0.06 0.06],...
    'Callback',@PlotFig);
handles.Exit=uicontrol(handles.IDAS,'Style','pushbutton',...
    'Tag','exit',...
    'String','Exit',...
    'Units','normalized',...
    'Position',[0.89 0.03 0.06 0.06],...
    'Callback',@exit_Callback);
% % ---------------------PerformanceStatistic------------------------
handles.newDocument=uicontrol(handles.IDAS,'Style','checkbox',...
    'Tag','newDocument',...
    'String','New file',...
    'FontSize',10,...
    'BackgroundColor',[0.31 0.4 0.58],...
    'Units','normalized',...
    'Position',[0.43 0.03 0.1 0.06]);
% handles.PerformanceStatistic=uicontrol(handles.IDAS,'Style','popupmenu',...
%     'Tag','PerformanceStatistic',...
%     'String',{'','Roll performance','Maximum','Minimum','Batch figure','Slide magnitude','Sensitivity of lat-lon coordination'},...
%     'FontSize',10,...
%     'TooltipString','performance',...
%     'Units','normalized',...
%     'Position',[0.65 0.03 0.1 0.06],...
%     'Callback',@popupmenu_Callback);



% ---------------------end-----------------------------


% --------------------Check configuration files--------------------
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(pwd,'\',cfgname);
fid=fopen(cfgfpath);
if fid >= 0
    fclose(fid);
else
    %close all;
    fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
    errordlg('Cannot find ".cfg" file in root path');
    pause(2);%delay 2sec to close the main window
    close;
    return;
end

% --------------------Initialize gui--------------------
fid=fopen(fullfile(rootpath,'IDASpara.dat'),'r');
if fid~=-1
    % read layout
    temp= fscanf(fid,'%f',2);
    if isempty(temp)
        layout.m=4;layout.n=4;
        return
    end
    layout.m=temp(1);
    layout.n=temp(2);
    %     headerfile= fgetl(fid);
    %     if exist(headerfile,'file')
    %         [nvar,varlist]=readheader(headerfile);
    %     else
    %         return
    %     end
    nfile=fscanf(fid,'%f',1);
    skipline=fgetl(fid); 
    filelist=repmat({''},1,nfile);
    for i=1:nfile
        temptext= fgetl(fid);
        filelist{i}=temptext;
    end
    
    % read header
    if ~isempty(filelist)
        if exist(filelist{1},'file')
            if iscell(filelist)
                dotname=cell(length(filelist),1);
                for i=1:length(filelist)
                    %[pathstr, name, ext] = fileparts(File{iFile});
                    [~, ~, dotname{i}] = fileparts(filelist{i});
                    %dotname{i}=FileName{i}((length(FileName{i})-4+1):end)
                end
            elseif ischar(filelist)
                [~, ~, dotname] = fileparts(filelist);
            end
            if ~ischar(dotname)
                if (strcmpi(dotname{i},'.mat')||strcmpi(dotname{i},'.log'))
                    [nvar,varlist]=readheader_mat_log_bin(filelist{1});
                else
                    [nvar,varlist]=readheader(filelist{1});
                end
            else
                if (strcmpi(dotname,'.mat')||strcmpi(dotname,'.log'))
                    [nvar,varlist]=readheader_mat_log_bin(filelist{1});
                else
                    [nvar,varlist]=readheader(filelist{1});
                end
            end
        else
            return;
        end
    else
        return;
    end
    
    % filelist_comp
    nfile_comp=fscanf(fid,'%f',1);
    skipline=fgetl(fid);
    filelist_comp=repmat({''},1,nfile_comp);
    if nfile_comp~=0
        for i=1:nfile_comp
            temptext_comp= fgetl(fid);
            filelist_comp{i}=temptext_comp;
        end
        [pathstr_comp, name_comp, ext_comp]=fileparts(filelist_comp{end});
        Userdata_comp.Value=[];
        Userdata_comp.PathName=pathstr_comp;
        set(handles.filelist_comp,'String',filelist_comp,'Userdata',Userdata_comp,'Value',1:length(filelist_comp));
    else
        Userdata_comp.Value=[];
        Userdata_comp.PathName=[];
        set(handles.filelist_comp,'String',filelist_comp,'Userdata',Userdata_comp,'Value',1:length(filelist_comp));
    end
    % read sorted list
    orderdata=fscanf(fid,'%f');
    if max(orderdata)>length(varlist)
        orderdata=[];
    end
    if ~isempty(orderdata)
        orderstr=varlist(orderdata);
        set(handles.varlist,'Position',[0.55 0.13 0.205 0.77])
        set(handles.varorder,'String',orderstr,'Userdata',orderdata,'Visible','on')
        set(handles.text_SelectedVarNo,'String',['Selected :' int2str(length(orderdata))])
        set(handles.extend,'String','>','TooltipString','close sort window')
    end
    % checkbox
    extendcmp=fscanf(fid,'%s',1);
    if strcmp(extendcmp,'on')
        set(handles.extend_comp,'value',1);
        extend_comp;
    end
    % checkbox
    newDocument=fscanf(fid,'%s',1);
    if strcmp(newDocument,'on')
        set(handles.newDocument,'value',1);
    end
    % read the export path
    skipline=fgetl(fid);
    fullPathName_Export=fgetl(fid);
    %     set(handles.editbox_headerfile,'String',headerfile);
    set(handles.varlist,'String',varlist);
    set(handles.text_TotalVarNo,'String',['Total :',int2str(nvar)]);
    [pathstr, name, ext]=fileparts(filelist{end});
    Userdata.Value=[];
    Userdata.PathName=pathstr;
    set(handles.filelist,'String',filelist,'Userdata',Userdata,'Value',1:length(filelist));
    set(handles.varorder,'Userdata',orderdata);
    set(handles.Export,'Userdata',fullPathName_Export);
    fclose(fid);
end
%
if isempty(layout)||isnan(layout.m)
    layout.m=4;layout.n=4;
end







% --- Executes on left-click in filelist.
function filelist_ButtonDownFcn(hobject,eventdata,varargin)

% if the user double-clicks, the callback executes after each click. The software sets
% the figure SelectionType property to normal on the first click and to open on the second click.
% The callback can query the figure SelectionType property to determine if it was a single or double click.

handles=GetHandles;
File = get(hobject,'String');

SelectionType=get(handles.IDAS,'SelectionType');
if strcmp(SelectionType,'normal')
    return
end
dim=length(File);

% add for setting defaut directory
Userdata=get(hobject,'Userdata');
%support for the APM open source flight control system data analysis
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(pwd,'\',cfgname);
fid=fopen(cfgfpath);
if fid >= 0
    flag=1;
    while flag
        skip=fgetl(fid);
        tokens=textscan(skip,'%s','Delimiter','_');
        tokens=tokens{1};
        flag=~strcmp(tokens{1},'@@@');
    end
    for i=1:2
        fgetl(fid);
    end
    strline=fgetl(fid);
    fclose(fid);
else
    %close all;
    fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
    errordlg('Cannot find ".cfg" file in root path');
    pause(2);%delay 2sec to close the main window
    close;
    return;
end
tokens=textscan(strline,'%s','Delimiter',',');
tokens=tokens{1};
str_1234=cell(4,1);
if(strcmpi(tokens{1},'1'))
    str_1234{1}='*.dat;*.txt';
end
if(strcmpi(tokens{2},'1'))
    str_1234{2}='*.mat';
end
if(strcmpi(tokens{3},'1'))
    str_1234{3}='*.log';
end
if(strcmpi(tokens{4},'1'))
    str_1234{4}='*.BIN';
end
j=0;
for i=1:4
    if ~isempty(str_1234{i})
        j=j+1;
        if (j==1)
            str_ext=strcat(str_1234{i});
        else
            str_ext=strcat(str_ext,';',str_1234{i});
        end
    end
end
if isempty(Userdata)
    [FileName,PathName] = uigetfile({str_ext},'Select the data files','MultiSelect', 'on');
else
    [FileName,PathName] = uigetfile({str_ext},'Select the data files',Userdata.PathName,'MultiSelect', 'on');
end
% shortly cancel the left double click call-back, in case of double click
% twice
set(hobject,'Callback','');
pause(0.2)
% pause(0.3);
set(hobject,'Callback',@filelist_ButtonDownFcn);

%for APM data anlysis
if iscell(FileName)
    dotname=cell(length(FileName),1);
    for i=1:length(FileName)
        %[pathstr, name, ext] = fileparts(File{iFile});
        [~, ~, dotname{i}] = fileparts(FileName{i});
        %dotname{i}=FileName{i}((length(FileName{i})-4+1):end)
    end
elseif ischar(FileName)
    [~, ~, dotname] = fileparts(FileName);
end

if iscell(FileName)
    FileName=sort(FileName);  % Sorts the strings in ASCII dictionary order.
    for i=1:length(FileName)
        File{dim+i}=[PathName	FileName{i}];
    end
elseif ischar(FileName)
    File{dim+1}=[PathName	FileName];
else
    return;        %no file is selected
end

% double click the data file will change the value, so we save the chosen
% file via userdata, which enable add the incremental file in the foundation
% of the chosen files
if isempty(Userdata)
    Value=[];
else
    Value=Userdata.Value;
    if Value==0
        Value=[];
    end
end
newValue=[Value,dim+1:length(File)]; % select the last added file
Userdata.Value=newValue;
Userdata.PathName=PathName;
set(hobject,'String',File,'Value',newValue,'Userdata',Userdata);% select the last added file


% read the header file£¬do viewheaderfile_Callback
if ~ischar(dotname)
    if (strcmpi(dotname{i},'.mat')||strcmpi(dotname{i},'.log'))
        [nvar,varlist]=readheader_mat_log_bin(File{1});
    else
        [nvar,varlist]=readheader(File{1});
    end
else
    if (strcmpi(dotname,'.mat')||strcmpi(dotname,'.log'))
        [nvar,varlist]=readheader_mat_log_bin(File{1});
    else
        [nvar,varlist]=readheader(File{1});
    end
end

set(handles.varlist,'String',varlist);
% set(handles.varlist,'Value',[]);           % should we clear selection now£¿£¿£¿
text_disp=['Total :   ' num2str(nvar)];
set(handles.text_TotalVarNo,'String',text_disp);
set(handles.text_axis,'String','X-Axis : Time','UserData',0);
% update orderstr
orderdata = get(handles.varorder,'Userdata');
if ~isempty(orderdata)
    orderstr=varlist(orderdata);
    set(handles.varorder,'String',orderstr);
end




% ------------------- Executes on right-click in filelist.
function delete_Callback(hobject,eventdata,varargin)

handles=GetHandles;
filelist = get(hobject,'String');         % list_file: cell
index_selected = get(hobject,'Value');     % index_selected: vector
if length(filelist)<=0 || length(index_selected)<=0
    return
end

index=1:length(filelist);
index(index_selected)=[];
list_new=filelist(index);

if max(index_selected)>length(index) % multi-selection listbox control requires that Value be an integer within String range
    set(hobject,'Value',length(index));
end
set(hobject,'String',list_new);
% modify the saving list according to the chosen var
Userdata=get(hobject,'Userdata');
Userdata.Value=get(hobject,'value');
set(hobject,'Userdata',Userdata);


%---------Executes on key press in filelist------------------
function filelist_KeyPressFcn(hobject,eventdata,varargin)
% ctr+delete: delete all£¬ delete: delete the chosen file
if isempty(eventdata.Modifier) && strcmp(eventdata.Key,'delete')
    delete_Callback(hobject,eventdata,varargin);
elseif strcmp(eventdata.Key,'delete')
    set(hobject,'String','');
end


% --- Executes on button press in export.
function varargout = export_Callback(varargin)

global idasdata fileinfo

handles=GetHandles;
varlist = get(handles.varlist,'String');
File = get(handles.filelist,'String');
index_selected = get(handles.filelist,'value');
% we use the first data file to form the data label temporarily, Please
% note that we should improve this point to support different data souce.
index_selected=index_selected(1);
if isempty(File)
    errordlg('Please select at least one data file')
    return
end
if isempty(varlist)
    errordlg('Please select a header file');
    return
end
% choose the saving type: FilterIndex=1: *.dat£¬FilterIndex=1: *.mat
fullPathName_Export=get(handles.Export,'userdata');
% I do find a bug in uiputfile. when fullPathName_Export contain the extend
% names, for example 'FTINPUT.mat', if we choose *.dat as the saving type,
% we want the FileName to be FTINPUT.mat, in which the content of is in
% ASCII format, this is a txt file. So we should give up the extend file
% name we want to assign.
if isempty(fullPathName_Export)
    fullPathName_Export=userpath;
    fullPathName_Export=fullPathName_Export(1:end-1);
end
[pathstr, name, ext] = fileparts(fullPathName_Export);
fullPathName_Export=fullfile(pathstr,name);
[FileName,PathName,FilterIndex] = uiputfile({'*.dat';'*.mat'},'saving to file',fullPathName_Export);
if FileName==0
    return;
end
fullPathName_Export=fullfile(PathName,FileName);
set(handles.Export,'Userdata',fullPathName_Export);
savepara;

% read data file
for i=1:length(File)
    newfileinfo{i} = dir(File{i});
end
% we should reread from the data file if the consistency check should not pass 
if ~isequal(fileinfo,newfileinfo)  
    for i=1:length(File)
        idasdata{i}.Data=[]; %release the memory in case of buffer overruns
    end
    try
        idasdata=readdata(File,varlist);
    catch
        fclose all;
        errordlg(lasterr,'Header or data file is wrong');
        rethrow(lasterror);
    end
    fileinfo=newfileinfo;
end
% interception of the data fragment
h_MainPlotFig = findobj('Tag','Main Plot Figure');
if ~isempty(h_MainPlotFig)
    xlim_property=get(h_MainPlotFig,'Userdata');
else
    xlim_property=[];
end
if isempty(xlim_property)
    index1=1;
    index2=length(idasdata{1}.Time);
else
    index1=interp1(idasdata{1}.Time,1:length(idasdata{1}.Time),xlim_property(1),'nearest','extrap');
    index2=interp1(idasdata{1}.Time,1:length(idasdata{1}.Time),xlim_property(2),'nearest','extrap');
end
% saving data
if FilterIndex==2
    dataparts=idasdata;
    for i=1:length(File)
        dataparts{i}.Time=dataparts{i}.Time(index1:index2);
        dataparts{i}.Data=dataparts{i}.Data(:,index1:index2);
    end
    save(fullPathName_Export,'dataparts');
else
    % assure the saving params
    % button = questdlg('qstring','title','str1','str2',default)
    button=questdlg('Saving the default params£¿','Param chosen method','default params','params in the sorted list','default params');
    if strcmp('default params',button)
        fidGdasString=fopen('gdasString.dat');
        numGdas=fscanf(fidGdasString,'%f');
        skipTimeString=fscanf(fidGdasString,'%s',1);
        orderdata=repmat([],numGdas,1);
        for i=1:numGdas
            gdasString=fscanf(fidGdasString,'%s',1);
            switch varlist{1}
                case 'TBL_SELECTA'
                    indexLogic=strcmpi(varlist,[gdasString,'A']);
                case 'TBL_SELECTB'
                    indexLogic=strcmpi(varlist,[gdasString,'B']);
                case 'TBL_SELECTC'
                    indexLogic=strcmpi(varlist,[gdasString,'C']);
                case 'TBL_SELECTD'
                    indexLogic=strcmpi(varlist,[gdasString,'D']);
                otherwise
                    indexLogic=strcmpi(varlist,gdasString);
            end
            index=find(indexLogic,1,'first'); % find out the first location
            if isempty(index)
                errormsg=['Variable ''',gdasString,''' isn''t exist!'];
                errortitle='Error variable name!';
                errordlg(errormsg,errortitle);
                return;
            else
                orderdata(i)=index;
            end
        end
        fclose(fidGdasString);
    else
        flag=get(handles.extend,'String');
        if strcmp(flag,'<')   % the sorted list is closed
            orderdata=1:length(varlist);
        else
            orderdata=get(handles.varorder,'Userdata');
            if isempty(orderdata)
                orderdata=1:length(varlist);
            end
        end
    end
    savedata=[idasdata{index_selected}.Time(index1:index2);idasdata{index_selected}.Data(orderdata,index1:index2)];
    fid=fopen(fullPathName_Export,'wt');
    [m,n]=size(savedata);
    fprintf(fid,'ADAS DATA\n');
    fprintf(fid,'%i\n',m-1); % give out the number of output vars
    fprintf(fid,'%-16s','TIME');
    fprintf(fid,'%-16s',varlist{orderdata});% give out the name of output vars
    fprintf(fid,'\n');
    format=[repmat('%-16.7g',1,m),'\n'];
    fprintf(fid,format,savedata);
    fclose(fid);
end





% --- Executes on button press in exit.
function exit_Callback(varargin)

h_IDAS = findobj('Name','IDAS');
h_MainPlotFig = findobj('Tag','Main Plot Figure');
if isempty(h_MainPlotFig)
    delete(h_IDAS);
    clear;
else
    set(h_IDAS,'Visible','off');
end
fclose all;





% --- Executes on right-click on varlist.
function varlist_ButtonDownFcn(varargin)
% right click menu to set x-axis
handles=GetHandles;
varlist=get(handles.varlist,'String');
index_selected = get(handles.varlist,'Value');
Num_selected=length(index_selected);
rightclickmenu=uicontextmenu;
if Num_selected==1
    uimenu(rightclickmenu,'label','Select Variable','callback',@SelectVar)
    uimenu(rightclickmenu,'label','Select All Variable','callback',@SelectAll)
    uimenu(rightclickmenu,'label','Set as X-axis','callback',{@SetAxis,1},'enable','on')
    if get(handles.text_axis,'UserData')==0
        uimenu(rightclickmenu,'label','Reset Time as X-axis','callback',{@SetAxis,2},'enable','off')
    else
        uimenu(rightclickmenu,'label','Reset Time as X-axis','callback',{@SetAxis,2},'enable','on')
    end
elseif Num_selected>1
    uimenu(rightclickmenu,'label','Select Variable','callback',@SelectVar)
    uimenu(rightclickmenu,'label','Select All Variable','callback',@SelectAll)
    uimenu(rightclickmenu,'label','Set as X-axis','callback',{@SetAxis,1},'enable','off')
    if get(handles.text_axis,'UserData')==0
        uimenu(rightclickmenu,'label','Reset Time as X-axis','callback',{@SetAxis,2},'enable','off')
    else
        uimenu(rightclickmenu,'label','Reset Time as X-axis','callback',{@SetAxis,2},'enable','on')
    end
else
    return
end
uimenu(rightclickmenu,'label','Cancel selection','callback','handles=GetHandles;set(handles.varlist,''Value'',[])','enable','on')  % cancel the chosen status

set(handles.varlist,'uicontextmenu',rightclickmenu)%,'Value',[]





%---------subfunction of varlist_ButtonDownFcn------------------
%---------------=====--------------
function SetAxis(h,eventdata,flag,varargin)
handles=GetHandles;
list_var = get(handles.varlist,'String');
index_selected = get(handles.varlist,'Value');
orderdata=get(handles.varorder,'Userdata');
switch flag
    case 1
        set(handles.text_axis,'String',['X-Axis : ',list_var{index_selected}])
        set(handles.text_axis,'UserData',index_selected)
    case 2
        set(handles.text_axis,'String','X-Axis : Time')
        set(handles.text_axis,'UserData',0)
end
set(handles.varlist,'Value',[]) % cancel the chosen var
set(handles.text_SelectedVarNo,'String',['Selected :' int2str(length(orderdata))])
set(handles.varlist,'uicontextmenu',[]) % cancel the right click menu
%---------------=====--------------
function SelectVar(varargin)
handles=GetHandles;
varlist=get(handles.varlist,'String');
index_selected = get(handles.varlist,'Value');
orderdata=get(handles.varorder,'Userdata');
orderstr=get(handles.varorder,'String');
for i=1:length(index_selected)
    if length(find(orderdata==index_selected(i)))==0
        orderstr{length(orderstr)+1}=varlist{index_selected(i)};
        orderdata(length(orderstr))=index_selected(i);
    end
end
% open the sort window
set(handles.varlist,'Position',[0.55 0.13 0.205 0.77])
set(handles.text_SelectedVarNo,'String',['Selected :' int2str(length(orderdata))]);
set(handles.varorder,'String',orderstr,'Userdata',orderdata,'Visible','on');
set(handles.extend,'String','>','TooltipString','close the sort window')
%---------------=====--------------
function SelectAll(varargin)
handles=GetHandles;
varlist=get(handles.varlist,'String');
% set(handles.varorder,'String',varlist)
% set(handles.text_SelectedVarNo,'String',['Selected :' num2str(length(orderdata))])
index_selected = 1:length(varlist);
orderdata=get(handles.varorder,'Userdata');
orderstr=get(handles.varorder,'String');
for i=1:length(index_selected)
    if length(find(orderdata==index_selected(i)))==0
        orderstr{length(orderstr)+1}=varlist{index_selected(i)};
        orderdata(length(orderstr))=index_selected(i);
    end
end
% open the sort window
set(handles.varlist,'Position',[0.55 0.13 0.205 0.77])
set(handles.text_SelectedVarNo,'String',['Selected :' int2str(length(orderdata))])
set(handles.varorder,'String',orderstr,'Userdata',orderdata,'Visible','on')
set(handles.extend,'String','>','TooltipString','close the sort window')


%---------varlist_KeyPressFcn------------------
function varlist_KeyPressFcn(hobj,eventdata)
if strcmp(eventdata.Key,'rightarrow')
    SelectVar;
end


%---------varorder_KeyPressFcn------------------
function varorder_KeyPressFcn(hobj,eventdata)
handles=GetHandles;
orderstr=get(handles.varorder,'String');
orderindex = get(handles.varorder,'Value');
orderdata = get(handles.varorder,'Userdata');
if length(orderstr)<1
    return
else
    if strcmp(eventdata.Key,'delete')
        if orderindex==length(orderstr)
            orderstr(length(orderstr))=[];  % clear the last string
            orderdata(length(orderstr)+1)=[];% length(orderstr) has been reduced on the up step,so add 1
            if length(orderstr)>=1
                set(handles.varorder,'Value',length(orderstr))
            end
        else
            for i=orderindex:length(orderstr)-1
                orderstr{i}=orderstr{i+1};
                orderdata(i)=orderdata(i+1);
            end
            orderstr(length(orderstr))=[];  % clear the last string
            orderdata(length(orderstr)+1)=[];% length(orderstr) has been reduced on the up step,so add 1
        end
        set(handles.text_SelectedVarNo,'String',['Selected :',int2str(length(orderstr))]);
        if isempty(orderstr)
            set(handles.varlist,'Value',[]);  % cancel the selection in varlist if there's no variable left in varorder
        end
    elseif isempty(eventdata.Modifier)
        return
    elseif strcmp(eventdata.Modifier{1},'control')
        switch eventdata.Key
            case 'uparrow'
                if orderindex~=1
                    tempstr=orderstr{orderindex-1};
                    orderstr{orderindex-1}=orderstr{orderindex};
                    orderstr{orderindex}=tempstr;
                    tempdata=orderdata(orderindex-1);
                    orderdata(orderindex-1)=orderdata(orderindex);
                    orderdata(orderindex)=tempdata;
                end
            case 'downarrow'
                if orderindex~=length(orderstr)
                    tempstr=orderstr{orderindex+1};
                    orderstr{orderindex+1}=orderstr{orderindex};
                    orderstr{orderindex}=tempstr;
                    tempdata=orderdata(orderindex+1);
                    orderdata(orderindex+1)=orderdata(orderindex);
                    orderdata(orderindex)=tempdata;
                end
            otherwise
                return
        end
    end
    set(handles.varorder,'String',orderstr,'Userdata',orderdata)
end

% --- Executes on right-click on varorder.
function varorder_ButtonDownFcn(hobj,eventdata,varargin)
% right click to delet
handles=GetHandles;
orderstr=get(handles.varorder,'String');
orderindex = get(handles.varorder,'Value');
orderdata = get(handles.varorder,'Userdata');
if length(orderstr)<1
    return
else
    if orderindex==length(orderstr)
        orderstr(length(orderstr))=[];  % clear the last string
        orderdata(length(orderstr)+1)=[];% length(orderstr) has been reduced on the up step,so add 1
        if length(orderstr)>=1
            set(handles.varorder,'Value',length(orderstr))
        end
    else
        for i=orderindex:length(orderstr)-1
            orderstr{i}=orderstr{i+1};
            orderdata(i)=orderdata(i+1);
        end
        orderstr(length(orderstr))=[];  % clear the last string
        orderdata(length(orderstr)+1)=[];% length(orderstr) has been reduced on the up step,so add 1
    end
    set(handles.text_SelectedVarNo,'String',['Selected :',int2str(length(orderstr))]);
    if isempty(orderstr)
        set(handles.varlist,'Value',[]);  % cancel the selection in varlist if there's no variable left in varorder
    end
    set(handles.varorder,'String',orderstr,'Userdata',orderdata)
end




%-----------------------UI open callback---------------------
function extend_Callback(varargin)
handles=GetHandles;
flag=get(handles.extend,'String');
if strcmp(flag,'<')
    set(handles.varlist,'Position',[0.55 0.13 0.205 0.77])
    set(handles.varorder,'Visible','on')
    set(handles.extend,'String','>','TooltipString','close the sort window')
else
    set(handles.varlist,'Position',[0.55 0.13 0.4 0.77])
    set(handles.varlist,'Value',[]);
    set(handles.varorder,'Visible','off')
    set(handles.extend,'String','<','TooltipString','open the sort window')
end


% %-----------------------PerformanceStatistic callback---------------------
% not yet done
% function popupmenu_Callback(varargin)
% handles=GetHandles;
% selectindex=get(handles.PerformanceStatistic,'Value');
% switch selectindex
%     case 2
%         findRollPerformance
%     case 3
%         findMax
%     case 4
%         findMin
%     case 5
%         Plot_Compare
%     case 6
%         findBetaSwing
%     case 7
%         findlon_lonlat_xtlm
%     otherwise
%         
% end


%-----------------------plot compare callback---------------------
function extend_comp(varargin)
handles=GetHandles;
flag=get(handles.extend_comp,'value');
if flag
    set(handles.filelist,'Position',[0.05 0.05 0.45 0.82])
    set(handles.filelist_comp,'Visible','on')
else
    set(handles.filelist,'Position',[0.05 0.05 0.91 0.82])
    set(handles.filelist_comp,'Visible','off')
end


% %-----------------------transpose the mat formation to dat style---------------------
% function y=call_mat2dat(fname,Path)
% if ~ischar(fname)
%     y=cell(1,length(fname));
%     for i=1:length(fname)
%         y{i}=strcat(fname{i}(1:length(fname{i})-4),'.dat');
%         convertplotdat(fname{i},Path);
%     end
% else
%     convertplotdat(fname,Path);
%     y=strcat(fname(1:length(fname)-4),'.dat');
% end
