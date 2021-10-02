function PlotFig(hobject,eventdata,varargin)
% plot button key press function


global layout nvar_selected n_windows                % 供DispFigure.m使用
global idasdata File x_label index_selected i_windows    % 保存数据，供绘制下一图
global fileinfo

handles=GetHandles;
varlist = get(handles.varlist,'String');
index_selected = get(handles.varlist,'Value');
File = GetFiletoPlot(handles);
nvar=length(varlist);
nvar_selected=length(index_selected);
orderdata=get(handles.varorder,'Userdata');
if isempty(File)
    errordlg('Please select at least one data file')
    return
end
extendString=get(handles.extend,'String');
if ~isempty(orderdata)&&strcmp(extendString,'>')     % 如果排序框未收起，且排序框中有变量，则绘制排序框中变量
    nvar_selected =length(orderdata);
    index_selected=orderdata;
elseif nvar_selected==0         % 如果不选择变量，默认全部选中
    nvar_selected = nvar;
    index_selected = 1:nvar;
end


%% import data
% dotname=File{1}(length(File{1})-4+1:end);
[~, ~, dotname] = fileparts(File{1});%取出.mat后缀
for i=1:length(File)
    newfileinfo{i} = dir(File{i});
end
if ~isequal(fileinfo,newfileinfo)   % 判断文件是否更改，是则重新读取
    %     for i=1:length(File)
    %         idasdata{i}.Data=[]; % 释放被idasdata.Data占用的空间，防止内存溢出
    %     end
    idasdata=[];% 释放被idasdata占用的空间，直接砍掉所有内存，防止内存溢出
    try
        if (strcmpi(dotname,'.mat')||strcmpi(dotname,'.log'))%mat格式文件的读取按照load方式处理%log格式文件也走这条路
            idasdata=readdata_mat_log_bin(File,varlist);
        else
            idasdata=readdata(File,varlist);
        end
    catch
        fclose all;
        errordlg(lasterr,'头文件or数据文件错误');    % 头文件错误
        rethrow(lasterror);
    end
    fileinfo=newfileinfo;
end
for i=1:length(File)
    idasdata{i}.varlist=varlist; % 头文件改变时更新数据列表
end
%% ------------for set x axis-----------
userdata=get(handles.text_axis,'UserData');
if userdata~=0
    x_label=varlist(userdata);
    for i=1:length(File)
        idasdata{i}.xdata=idasdata{i}.Data(userdata,:);
    end
else
    if isfield(idasdata{1},'label')
        %读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
        cfgname='Configuration_LukeQin.cfg';
        cfgfpath=strcat(pwd,'\',cfgname);
        fid=fopen(cfgfpath);
        if fid==-1
            fprintf('Cannot find "%s" file in path:<"%s">!!\n\n\n',cfgfpath,cfgname);
            errordlg('Cannot find ".cfg" file in root path');
            return;
        end
        flag=1;
        while flag
            skip=fgetl(fid);
            tokens=textscan(skip,'%s','Delimiter','_');
            tokens=tokens{1};
            flag=~strcmp(tokens{1},'@@@');
        end
        for i=1:8
            fgetl(fid);
        end
        %时间单位选择
        fgetl(fid);
        temp=fscanf(fid,'%s',1);
        fclose(fid);
        if (~strcmpi(temp,'us') && ~strcmpi(temp,'ms') && ~strcmpi(temp,'sec') && ~strcmpi(temp,'min') && ~strcmpi(temp,'hou'))
            errordlg('The time unit is incorrect in cfg file');
            return;
        end
        x_label=strcat('Time(',temp,')');
    else
        x_label='Time';
    end
    for i=1:length(File)
        idasdata{i}.xdata=idasdata{i}.Time;
    end
end
% 设置x轴范围默认值
if isfield(idasdata{1},'label')
    xmin=zeros(length(File),1);
    xmax=zeros(length(File),1);
    for i=1:length(File)
        for j=1:length(idasdata{i}.xdata)
            if j==1
                xmin(i)=min(idasdata{i}.xdata{j});
                xmax(i)=max(idasdata{i}.xdata{j});
            else
                xmin(i)=min(min(idasdata{i}.xdata{j}),xmin(i));
                xmax(i)=max(max(idasdata{i}.xdata{j}),xmax(i));
            end
        end
    end
    xlim_property(1)=min(xmin);
    xlim_property(2)=max(xmax);
    if(xlim_property(1)==xlim_property(2)) % xlim 上下限不能相同
        xlim_property(1)=xlim_property(1)*0.9;
        xlim_property(2)=xlim_property(2)*1.1;
    end
else
    xmin=zeros(length(File),1);
    xmax=zeros(length(File),1);
    for i=1:length(File)
        % 若x轴非单调增，通过x(1)、x(end)取极值的方法不适用
        xmin(i)=min(idasdata{i}.xdata);
        xmax(i)=max(idasdata{i}.xdata);
    end
    xlim_property(1)=min(xmin);
    xlim_property(2)=max(xmax);
    if(xlim_property(1)==xlim_property(2)) % xlim 上下限不能相同
        xlim_property(1)=xlim_property(1)*0.9;
        xlim_property(2)=xlim_property(2)*1.1;
    end
end
%% -----------invisible the IDAS window-------------
h_IDAS = findobj('Name','IDAS');
set(h_IDAS,'Visible','off');
%% -----------------plot----------------
n_windows = fix(nvar_selected/(layout.m*layout.n));%B = fix(A) rounds the elements of A toward zero, resulting in an array of integers
if mod(nvar_selected,layout.m*layout.n)~=0
    n_windows=n_windows+1;
end
h_MainPlotFig = findobj('Tag','Main Plot Figure');
if isempty(h_MainPlotFig)
    PlotFigGUI;
end
h_MainPlotFig = findobj('Tag','Main Plot Figure');
set(h_MainPlotFig,'Userdata',xlim_property);
if isempty(varargin)  % 刷新时varargin{1}='refresh'
    i_windows=1;
end
if i_windows<n_windows && n_windows~=1
    index_plot=index_selected((layout.m*layout.n*(i_windows-1)+1):layout.m*layout.n*i_windows);
else
    index_plot=index_selected((layout.m*layout.n*(i_windows-1)+1):nvar_selected);
end
PlotAxes(File,index_plot,idasdata,layout,x_label);
EnableMenu(i_windows,n_windows);
savepara;
% 因双击打开文件时value值要变化，故通过userdata而不通过value保存已选中文件，使得能在原来已选中文件基础上新增文件
Userdata=get(handles.filelist,'Userdata');
Userdata.Value=get(handles.filelist,'value');
set(handles.filelist,'Userdata',Userdata);

