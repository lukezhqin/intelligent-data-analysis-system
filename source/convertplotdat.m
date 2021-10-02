%% ========================================
% Copyright @XXX 2017-2019 All Rights Reserved.#
% Author   : Anakin.Qin  2017.12.26 11:16:24   #
% Website  : https://anakinqin.github.io       #
% E-mail   : zonghang.qin@foxmail.com          #
% Intelligent Data Analysis System(IDAS)
% This file is used to convert the mat formating file to the dat file
% We don't use this method any more in this software.
function convertplotdat(FileName,PathName)
appdir=pwd;
%% 导入数据,并读取配置文件
if isempty(FileName) || isempty(PathName)
    [FileName,PathName] = uigetfile({'*.mat'},'Select the data files to plot','MultiSelect', 'on');
end
if ischar(FileName);
    filedir=[PathName,FileName];
else
    return;        %暂时未添加多文件选择，只能单个文件处理
end
s = whos('-file',filedir);
whosdata = whos('-file',filedir);
if strcmp(whosdata(1).name,'@')%去掉特殊标志符
    whosdata=whosdata(2:end);
end
getallname=cell(length(whosdata),1);
for i=1:length(whosdata)
    getallname{i}=whosdata(i).name;
end
loadfile=load (filedir,getallname{:});
%读取配置文件，该文件写明了需要转换的变量，忽略不存在的变量
cfgname='Configuration_LukeQin.cfg';
cfgfpath=strcat(appdir,'\',cfgname);
fid=fopen(cfgfpath);
if fid==-1
    %未找到正确的配置文件
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
%时间单位选择
fgetl(fid);
% tmunit=fscanf(fid,'%s',1);
fgetl(fid);
fgetl(fid);
fgetl(fid);
numscan=fscanf(fid,'%f',1);
minussss=0;
scanset=cell(1,numscan);
t=1;
for i=1:numscan
    temp=fscanf(fid,'%s',1);
    if isrgtlabel(temp,getallname)%寻找是否是正确的label标签
        scanset{t}=temp;
        t=t+1;
    else
        minussss=minussss+1;
    end
end
fclose(fid);
len_labset=numscan-minussss;
labset=cell(1,len_labset);
for i=1:len_labset
    labset{i}=scanset{i};
end
%% 获取所需要转换的变量名称
% labset={'ATT_label','BAR2_label','BARO_label','CTRL_label','CTUN_label','GPS_label','IMU_label','IMU2_label','IMU3_label','MAG_label','MAG2_label','MAG3_label','NKF1_label','NKF6_label',...
%     'NTUN_label','POS_label','RCIN_label','RCOU_label','TERR_label'};
% len_labset=length(labset);
sigt=zeros(len_labset,1);
len_sig=zeros(len_labset,1);
cntset_tname=cell(len_labset,1);
cntset_tdata=cell(len_labset,1);
nstr=cell(len_labset,1);
for i=1:len_labset
    %     temp=(eval(labset{i}));
    temp=getfield(loadfile,labset{i});%读取loadfile中的变量
    lentemp=length(temp);
    num=0;
    
    for j=1:lentemp
        %if(~isstrsame(temp{j},'LineNo') && ~isstrsame(temp{j},'TimeUS'))
        %放弃自写函数strcmp和strcmpi前者严格比较大小写，后者忽略大小写，为matlab的inline函数
        if(~strcmp(temp{j},'LineNo') && ~strcmp(temp{j},'TimeUS'))
            num= num+1;
            if isempty(nstr{i})
                nstr{i}=strcat(labset{i}(1:length(labset{i})-5),temp{j});%label
            else
                nstr{i}=strcat(nstr{i},',',labset{i}(1:length(labset{i})-5),temp{j});%label
            end
            %sz=size(getfield(loadfile,labset{i}(1:length(labset{i})-6)));
            %valset.(eval(nstr))=zeros(sz(1),1);
            %valset=struct(nstr,zeros(sz(1),1));
        else
            sigt(i)=sigt(i)+1;
        end
    end
    tokens=textscan(nstr{i},'%s','Delimiter',',');
    nstr{i}=tokens{1};
    len_sig(i)=num;
end
len_sum=0;
for i=1:length(len_sig)
    len_sum=len_sum+len_sig(i);
end
namestr=cell(len_sum+length(len_sig),1);
t=1;
for i=1:len_labset
    t=t+1;%留出时间标签
    for j=1:len_sig(i)
        if ~isempty(nstr{i}{j})
            namestr{t}=nstr{i}{j};
            t=t+1;
        end
    end
end
t=1;
for i=1:(length(namestr)-1)
    %按照不同速率组插入各自的时间变量名
    if isempty(namestr{i})
        tokens=textscan(namestr{i+1},'%s','Delimiter','_');
        cntset_tname{t}=tokens{1}{1};
        namestr{i}=strcat('t_',cntset_tname{t});%时间前缀
        t=t+1;
    end
end
dataset.name=namestr;

%% 获取变量对应的数值
valstr=cell(len_sum+length(len_sig),1);
t=1;
for i=1:len_labset
    t=t+1;%留出时间数据
    %vstr=evalin('base',labset{i}(1:length(labset{i})-6));
    vstr=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    for j=1:len_sig(i)
        valstr{t}=vstr(:,j+sigt(i));
        t=t+1;
    end
end

%% 获取时间戳，添加不同速率组时间数据
for i=1:len_labset
    %temp=evalin('base',labset{i}(1:length(labset{i})-6));
    temp=getfield(loadfile,labset{i}(1:length(labset{i})-6));
    cntset_tdata{i}=temp(:,1);%正常情况时间计数器都在第一列数据
end
t=1;
for i=1:(length(valstr)-1)
    %按照不同速率组插入各自的时间变量数据
    if isempty(valstr{i})
        valstr{i}=cntset_tdata{t};
        t=t+1;
    end
end
dataset.value=valstr;

%% 封装数据到dat文件便于画图处理
wr2dir=strcat(PathName,FileName(1:length(FileName)-4),'.dat');
wr2datfiles(wr2dir,dataset,len_sig);%防止创建的文件无法正确释放，采用函数形式


end


function wr2datfiles(dir,data,tmlabel)
namestr=data.name;
valstr=data.value;
len_namestr=length(namestr);
len_val=cell(len_namestr,1);
for i=1:len_namestr
    len_val{i}=num2str(length(valstr{i}));
end
label=cell(length(tmlabel),1);
for i=1:length(tmlabel)
    label{i}=num2str(tmlabel(i));
end
numstr=num2str(length(namestr));
len_label=length(label);
fid=fopen(dir,'w');
%输入带标志的头文件第一行，表明数据类型为时间轴标签分类,标志位flag：AnakinQinForAPMdata
fprintf(fid,repmat('%s_',1,len_label),label{:});
fprintf(fid,'%s','AnakinQin4APMdata+');
fprintf(fid,strcat(repmat('%s_',1,len_namestr),'\n'),len_val{:});
fprintf(fid,'%s\n',numstr);
fprintf(fid,strcat(repmat('%s ',1,len_namestr),'\n'),namestr{:});
for i=1:len_namestr
    fprintf(fid,strcat(repmat('%f ',1,length(valstr{i})),'\n'),valstr{i});
end

fclose(fid);



end


function y=isrgtlabel(x,nameset)
y=false;
for i=1:length(nameset)
    if strcmp(x,nameset{i})
        y=true;
        return;
    end
end


end


function opt=isstrsame(x,y,i)
% return ture if str x is totally the same as y
% param i==1 indicate the compare method with searching for the upper and
% lower case. while i==0 means to ignore it.
if (~ischar(x) || ~ischar(y))
    opt=0;
    return;
end
lenx=length(x);
leny=length(y);
if (lenx~=leny)
    opt=0;
    return;
end
cnt=0;
for i=1:lenx
    if (x(i)~=y(i))
        opt=0;
        return;
    end
    cnt=cnt+1;
end
if cnt==lenx
    opt=1;
    return;
end
end